import SwiftUI

/// 菜单栏图标的 SwiftUI 封装
struct MenuIconView: View {
    let status: OverallStatus

    var body: some View {
        Image(nsImage: AppDelegate.shared.makeMenuBarIcon(status: status))
    }
}
