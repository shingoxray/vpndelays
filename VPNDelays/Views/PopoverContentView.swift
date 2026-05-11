import SwiftUI

struct PopoverContentView: View {
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var pingManager: PingManager

    @State private var showingAddEndpoint = false

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            endpointList
            Divider()
            footer
        }
        .frame(width: 380)
        .background(Color(.windowBackgroundColor))
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingAddEndpoint) {
            AddEndpointView()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Circle()
                .fill(overallColor)
                .frame(width: 8, height: 8)
            Text("VPNDelays")
                .font(.system(size: 13, weight: .semibold))
            Spacer()
            // 倒计时
            if pingManager.isPinging {
                Text("检测中...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("\(pingManager.secondsUntilNextPing)s")
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.secondary)
            }
            Button(action: {
                AppDelegate.shared?.openSettings()
            }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            .help("设置")
            .padding(.leading, 4)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Endpoint List

    private var endpointList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if dataStore.endpoints.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "network.slash")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("暂无 VPN 端点")
                            .foregroundColor(.secondary)
                        Text("点击下方按钮添加")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 60)
                } else {
                    ForEach(dataStore.endpoints) { endpoint in
                        EndpointRowView(endpoint: endpoint)
                        if endpoint.id != dataStore.endpoints.last?.id {
                            Divider().padding(.leading, 12)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            Button(action: { showingAddEndpoint = true }) {
                Label("添加端点", systemImage: "plus.circle")
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            Spacer()
            Button(action: { pingManager.pingAll() }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 11))
            }
            .buttonStyle(.plain)
            .help("立即检测")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    // MARK: - Overall Color （与菜单栏图标一致）

    private var overallColor: Color {
        computeOverallColor(endpoints: dataStore.endpoints,
                            statuses: pingManager.tunnelStatuses)
    }
}

/// 全局统一的颜色计算
func computeOverallColor(endpoints: [VPNEndpoint],
                          statuses: [UUID: TunnelStatus]) -> Color {
    guard !statuses.isEmpty else { return .gray }

    var hasEndpointRed    = false
    var hasEndpointOrange = false

    for endpoint in endpoints {
        let tunnelStatuses = endpoint.tunnels.compactMap { statuses[$0.id] }
        guard !tunnelStatuses.isEmpty else { continue }

        let gm = endpoint.greenMaxLatency
        let rm = endpoint.redMinLatency
        let endpointGreen  = tunnelStatuses.contains { $0.level(greenMax: gm, redMin: rm) == .green }
        let endpointOrange = tunnelStatuses.contains { $0.level(greenMax: gm, redMin: rm) == .orange }

        if endpointGreen  { continue }
        if endpointOrange { hasEndpointOrange = true; continue }
        hasEndpointRed = true
    }

    if hasEndpointRed    { return .red }
    if hasEndpointOrange { return .orange }
    return .green
}
