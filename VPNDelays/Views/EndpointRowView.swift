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
                                      status: pingManager.tunnelStatuses[tunnel.id])
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
}
