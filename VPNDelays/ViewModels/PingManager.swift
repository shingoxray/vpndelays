import Foundation
import Combine

class PingManager: ObservableObject {
    static let shared = PingManager()

    @Published var tunnelStatuses: [UUID: TunnelStatus] = [:]
    @Published var isPinging = false
    @Published var secondsUntilNextPing: Int = 0

    private var timer: Timer?
    private var countdownTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private let pingQueue = DispatchQueue(label: "com.vpndelays.ping", qos: .utility)

    private let dataStore = DataStore.shared

    private init() {
        NotificationCenter.default.publisher(for: .pingSettingsChanged)
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.restart() }
            .store(in: &cancellables)
    }

    func start() {
        stop()
        let interval = max(dataStore.pingInterval, 2)
        secondsUntilNextPing = Int(interval)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.pingAll()
        }
        startCountdown(interval: interval)
        pingAll()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
    }

    func restart() { start() }

    func pingAll() {
        guard !isPinging else { return }
        isPinging = true
        secondsUntilNextPing = Int(max(dataStore.pingInterval, 2))

        let endpoints = dataStore.endpoints
        guard !endpoints.isEmpty else { isPinging = false; return }

        let group = DispatchGroup()
        for endpoint in endpoints {
            guard !endpoint.tunnels.isEmpty else { continue }
            group.enter()
            pingQueue.async { [weak self] in
                self?.pingEndpointSerially(endpoint)
                group.leave()
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.isPinging = false
        }
    }

    private func pingEndpointSerially(_ endpoint: VPNEndpoint) {
        let semaphore = DispatchSemaphore(value: 1)
        let count = dataStore.pingCount

        for tunnel in endpoint.tunnels {
            semaphore.wait()
            let status = runPing(host: tunnel.host, count: count, tunnelId: tunnel.id)
            DispatchQueue.main.async { [weak self] in
                self?.tunnelStatuses[tunnel.id] = status
            }
            semaphore.signal()
        }
    }

    private func runPing(host: String, count: Int, tunnelId: UUID) -> TunnelStatus {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/sbin/ping")
        task.arguments = ["-c", "\(count)", "-t", "2", "-i", "0.3", host]

        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = outputPipe

        do {
            try task.run()
            task.waitUntilExit()
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: .utf8) ?? ""
            return PingParser.parse(output: output, tunnelId: tunnelId)
        } catch {
            return TunnelStatus(tunnelId: tunnelId, isOnline: false, latency: nil, packetLoss: 100, lastChecked: Date())
        }
    }

    // MARK: - 倒计时

    private func startCountdown(interval: TimeInterval) {
        countdownTimer?.invalidate()
        secondsUntilNextPing = Int(interval)
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.secondsUntilNextPing > 0 {
                self.secondsUntilNextPing -= 1
            }
        }
    }
}
