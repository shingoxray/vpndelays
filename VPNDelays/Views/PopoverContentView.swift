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
            Text(pingManager.isPinging ? "检测中..." : "\(Int(dataStore.pingInterval))s")
                .font(.caption)
                .foregroundColor(.secondary)
            Button(action: openSettingsWin) {
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

    // MARK: - Overall Color

    private var overallColor: Color {
        let statuses = pingManager.tunnelStatuses.values
        if statuses.isEmpty { return .gray }
        if statuses.allSatisfy({ !$0.isOnline }) { return .red }
        if statuses.contains(where: { !$0.isOnline }) { return .orange }
        if statuses.allSatisfy({ $0.isOnline && ($0.latency ?? 999) < 50 && $0.packetLoss == 0 }) { return .green }
        return .yellow
    }
}

// MARK: - Actions

private func openSettingsWin() {
    AppDelegate.shared.openSettings()
}
