import Foundation
import Combine

extension Notification.Name {
    static let pingSettingsChanged = Notification.Name("pingSettingsChanged")
}

class DataStore: ObservableObject {
    static let shared = DataStore()

    @Published var endpoints: [VPNEndpoint] = [] {
        didSet { saveEndpoints() }
    }

    @Published var tunnelNamePresets: [String] = TunnelNamePresets.defaults {
        didSet { savePresets() }
    }

    @Published var pingInterval: TimeInterval = 5 {
        didSet {
            UserDefaults.standard.set(pingInterval, forKey: "pingInterval")
            NotificationCenter.default.post(name: .pingSettingsChanged, object: nil)
        }
    }

    @Published var pingCount: Int = 2 {
        didSet {
            UserDefaults.standard.set(pingCount, forKey: "pingCount")
            NotificationCenter.default.post(name: .pingSettingsChanged, object: nil)
        }
    }

    private let endpointsKey = "endpoints"
    private let presetsKey = "tunnelNamePresets"

    private init() { load() }

    // MARK: - 端点管理

    func addEndpoint(_ endpoint: VPNEndpoint) {
        endpoints.append(endpoint)
    }

    func updateEndpoint(_ endpoint: VPNEndpoint) {
        guard let index = endpoints.firstIndex(where: { $0.id == endpoint.id }) else { return }
        endpoints[index] = endpoint
    }

    func deleteEndpoint(_ id: UUID) {
        endpoints.removeAll { $0.id == id }
    }

    // MARK: - 持久化

    private func saveEndpoints() {
        if let data = try? JSONEncoder().encode(endpoints) {
            UserDefaults.standard.set(data, forKey: endpointsKey)
        }
    }

    private func savePresets() {
        UserDefaults.standard.set(tunnelNamePresets, forKey: presetsKey)
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: endpointsKey),
           let decoded = try? JSONDecoder().decode([VPNEndpoint].self, from: data) {
            endpoints = decoded
        }
        if let presets = UserDefaults.standard.stringArray(forKey: presetsKey) {
            tunnelNamePresets = presets
        } else {
            tunnelNamePresets = TunnelNamePresets.defaults
        }
        if UserDefaults.standard.object(forKey: "pingInterval") != nil {
            pingInterval = UserDefaults.standard.double(forKey: "pingInterval")
        }
        if UserDefaults.standard.object(forKey: "pingCount") != nil {
            pingCount = UserDefaults.standard.integer(forKey: "pingCount")
        }
    }
}
