import SwiftUI

struct EndpointRowView: View {
    let endpoint: VPNEndpoint

    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var pingManager: PingManager

    @State private var isExpanded = true
    @State private var showingEdit = false

    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation(.easeInOut(duration: 0.15)) { isExpanded.toggle() } }) {
                HStack(spacing: 6) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 10)

                    Circle()
                        .fill(endpointColor)
                        .frame(width: 6, height: 6)

                    Text(endpoint.name)
                        .font(.system(size: 12, weight: .medium))
                    Spacer()
                    Text(endpointStatusSummary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button(action: { showingEdit = true }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 9))
                    }
                    .buttonStyle(.plain)
                    .help("编辑")
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)

            if isExpanded {
                if endpoint.tunnels.isEmpty {
                    Text("无隧道")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 28)
                        .padding(.bottom, 4)
                } else {
                    ForEach(endpoint.tunnels) { tunnel in
                        TunnelRowView(tunnel: tunnel,
                                      status: pingManager.tunnelStatuses[tunnel.id],
                                      greenMaxLatency: endpoint.greenMaxLatency,
                                      redMinLatency: endpoint.redMinLatency)
                    }
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddEndpointView(endpoint: endpoint)
        }
        .contextMenu {
            Button("编辑") { showingEdit = true }
            Button("删除", role: .destructive) { dataStore.deleteEndpoint(endpoint.id) }
        }
    }

    private var endpointStatusSummary: String {
        let tunnels = endpoint.tunnels
        guard !tunnels.isEmpty else { return "无隧道" }
        let statuses = tunnels.compactMap { pingManager.tunnelStatuses[$0.id] }
        let online = statuses.filter(\.isOnline).count
        return "\(online)/\(tunnels.count) 在线"
    }

    /// 端点颜色：有绿色隧道→绿→有橙色隧道→橙→否则红→无状态→灰
    private var endpointColor: Color {
        let tunnels = endpoint.tunnels
        let statuses = tunnels.compactMap { pingManager.tunnelStatuses[$0.id] }
        guard !statuses.isEmpty else { return .gray }

        let gm = endpoint.greenMaxLatency
        let rm = endpoint.redMinLatency
        let hasGreen  = statuses.contains { $0.level(greenMax: gm, redMin: rm) == .green }
        let hasOrange = statuses.contains { $0.level(greenMax: gm, redMin: rm) == .orange }
        if hasGreen  { return .green }
        if hasOrange { return .orange }
        return .red
    }
}
