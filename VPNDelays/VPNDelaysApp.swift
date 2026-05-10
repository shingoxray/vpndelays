import SwiftUI

@main
struct VPNDelaysApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
                .environmentObject(DataStore.shared)
        }
    }
}
