import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var newPreset = ""

    var body: some View {
        TabView {
            pingSettingsTab
                .tabItem { Label("Ping", systemImage: "network") }
            presetTab
                .tabItem { Label("隧道预设", systemImage: "list.bullet") }
        }
        .frame(width: 420, height: 320)
    }

    // MARK: - Ping 设置

    private var pingSettingsTab: some View {
        Form {
            Section {
                Picker("每次发包数", selection: $dataStore.pingCount) {
                    Text("1 个").tag(1)
                    Text("2 个").tag(2)
                    Text("3 个").tag(3)
                    Text("5 个").tag(5)
                }
                Picker("检测间隔", selection: $dataStore.pingInterval) {
                    Text("2 秒").tag(2.0)
                    Text("5 秒").tag(5.0)
                    Text("10 秒").tag(10.0)
                    Text("30 秒").tag(30.0)
                    Text("60 秒").tag(60.0)
                }
                HStack {
                    Spacer()
                    Text("发包越多结果越准确，但检测耗时更长")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } header: {
                Label("检测参数", systemImage: "gear")
            }
        }
        .padding()
    }

    // MARK: - 隧道名称预设

    private var presetTab: some View {
        VStack(spacing: 12) {
            if dataStore.tunnelNamePresets.isEmpty {
                Text("暂无预设，添加一些常用隧道名称方便快速输入")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 20)
            } else {
                List {
                    ForEach(dataStore.tunnelNamePresets, id: \.self) { preset in
                        HStack {
                            Image(systemName: "tag")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Text(preset)
                                .font(.system(size: 12))
                        }
                    }
                    .onDelete { indexSet in
                        dataStore.tunnelNamePresets.remove(atOffsets: indexSet)
                    }
                }
                .listStyle(.plain)
            }

            Divider()
            HStack {
                TextField("新预设名称", text: $newPreset)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12))
                Button("添加") {
                    let trimmed = newPreset.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty,
                          !dataStore.tunnelNamePresets.contains(trimmed) else { return }
                    dataStore.tunnelNamePresets.append(trimmed)
                    newPreset = ""
                }
                .buttonStyle(.borderedProminent)
                .disabled(newPreset.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding()
    }
}
