import SwiftUI

struct AddEndpointView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss

    private let editingEndpoint: VPNEndpoint?

    @State private var name: String
    @State private var tunnels: [Tunnel]

    init(endpoint: VPNEndpoint? = nil) {
        editingEndpoint = endpoint
        _name = State(initialValue: endpoint?.name ?? "")
        _tunnels = State(initialValue: endpoint?.tunnels ?? [])
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(editingEndpoint == nil ? "添加端点" : "编辑端点")
                .font(.headline)

            HStack {
                Text("名称")
                    .frame(width: 60, alignment: .leading)
                    .foregroundColor(.secondary)
                TextField("例如: AWS Tokyo", text: $name)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("隧道")
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(action: addTunnel) {
                        Label("添加", systemImage: "plus")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                }

                if tunnels.isEmpty {
                    Text("请至少添加一个隧道")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                }

                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(Array(tunnels.enumerated()), id: \.offset) { index, _ in
                            TunnelEditRow(
                                tunnel: $tunnels[index],
                                presets: dataStore.tunnelNamePresets,
                                onDelete: { tunnels.remove(at: index) }
                            )
                        }
                    }
                }
                .frame(maxHeight: 240)
            }

            Divider()
            HStack {
                Button("取消") { dismiss() }
                Spacer()
                Button("保存") { save(); dismiss() }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isValid)
            }
        }
        .padding()
        .frame(width: 420, height: 400)
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !tunnels.isEmpty &&
        tunnels.allSatisfy {
            !$0.name.trimmingCharacters(in: .whitespaces).isEmpty &&
            !$0.host.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    private func addTunnel() {
        tunnels.append(Tunnel(name: "", host: ""))
    }

    private func save() {
        let cleanName = name.trimmingCharacters(in: .whitespaces)
        let cleanTunnels = tunnels.map {
            Tunnel(id: $0.id,
                   name: $0.name.trimmingCharacters(in: .whitespaces),
                   host: $0.host.trimmingCharacters(in: .whitespaces))
        }
        if let existing = editingEndpoint {
            dataStore.updateEndpoint(VPNEndpoint(id: existing.id, name: cleanName, tunnels: cleanTunnels))
        } else {
            dataStore.addEndpoint(VPNEndpoint(name: cleanName, tunnels: cleanTunnels))
        }
        PingManager.shared.pingAll()
    }
}

// MARK: - 隧道编辑行

struct TunnelEditRow: View {
    @Binding var tunnel: Tunnel
    let presets: [String]
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            HStack(spacing: 2) {
                TextField("名称", text: $tunnel.name)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 130)
                    .font(.system(size: 11))

                Menu {
                    ForEach(presets, id: \.self) { preset in
                        Button(preset) { tunnel.name = preset }
                    }
                    if !presets.isEmpty { Divider() }
                    Button("管理预设...") { AppDelegate.shared.openSettings() }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9))
                }
                .menuStyle(.borderlessButton)
                .frame(width: 16)
            }

            TextField("域名 或 IP", text: $tunnel.host)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 11))

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
            }
            .buttonStyle(.plain)
            .help("删除此隧道")
        }
    }
}

