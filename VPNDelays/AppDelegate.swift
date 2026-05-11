import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    static weak var shared: AppDelegate?

    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var settingsWindowController: NSWindowController?

    private let dataStore = DataStore.shared
    private let pingManager = PingManager.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        NSApp.setActivationPolicy(.accessory) // 隐藏 Dock

        setupStatusItem()
        setupPopover()
        setupObservers()

        pingManager.start()
    }

    // MARK: - Status Item

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.image = makeMenuBarIcon(status: .unknown)
        statusItem?.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        statusItem?.button?.action = #selector(handleStatusItemClick)
        statusItem?.button?.target = self
    }

    private func updateMenuBarIcon() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.statusItem?.button?.image = self.makeMenuBarIcon(status: self.computeOverallStatus())
        }
    }

    func makeMenuBarIcon(status: OverallStatus) -> NSImage {
        let size = NSSize(width: 20, height: 16)
        let image = NSImage(size: size)
        image.lockFocus()
        defer { image.unlockFocus() }

        let color: NSColor
        switch status {
        case .allGreen:  color = NSColor.systemGreen
        case .someOrange: color = NSColor.systemOrange
        case .someRed:    color = NSColor.systemRed
        case .unknown:    color = NSColor.systemGray
        }

        let rect = NSRect(x: 3, y: 2, width: 14, height: 12)
        let path = NSBezierPath(roundedRect: rect, xRadius: 3, yRadius: 3)
        color.withAlphaComponent(0.85).setFill()
        path.fill()
        color.withAlphaComponent(0.6).setStroke()
        path.lineWidth = 1
        path.stroke()

        return image
    }

    /// 菜单栏图标颜色（与 Popover 顶部的圆点保持一致）
    private func computeOverallStatus() -> OverallStatus {
        let color = computeOverallColor(endpoints: dataStore.endpoints,
                                        statuses: pingManager.tunnelStatuses)
        switch color {
        case .green:  return .allGreen
        case .orange: return .someOrange
        case .red:    return .someRed
        default:      return .unknown
        }
    }

    // MARK: - Popover

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 380, height: 500)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: PopoverContentView()
                .environmentObject(dataStore)
                .environmentObject(pingManager)
        )
    }

    @objc private func handleStatusItemClick() {
        guard let event = NSApp.currentEvent else {
            togglePopoverInternal()
            return
        }
        if event.type == .rightMouseUp {
            let menu = NSMenu()
            menu.addItem(NSMenuItem(
                title: "退出 VPNDelays",
                action: #selector(NSApplication.terminate(_:)),
                keyEquivalent: "q"))
            NSMenu.popUpContextMenu(menu, with: event, for: statusItem!.button!)
            return
        }
        togglePopoverInternal()
    }

    @objc private func togglePopoverInternal() {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            guard let button = statusItem?.button else { return }
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    // MARK: - 设置窗口

    @objc func openSettings() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let existing = self.settingsWindowController {
                existing.window?.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
                return
            }

            let settingsView = SettingsView()
                .environmentObject(self.dataStore)
                .frame(width: 420, height: 320)

            let hostingController = NSHostingController(rootView: settingsView)
            let window = NSWindow(contentViewController: hostingController)
            window.title = "VPNDelays 设置"
            window.setContentSize(NSSize(width: 420, height: 320))
            window.styleMask = [.titled, .closable, .miniaturizable]
            window.center()

            let controller = NSWindowController(window: window)
            controller.window?.delegate = self
            self.settingsWindowController = controller

            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    // MARK: - 观察

    private func setupObservers() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateMenuBarIcon()
        }
    }
}

// MARK: - NSWindowDelegate

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        settingsWindowController = nil
    }
}

// MARK: - 状态枚举

enum OverallStatus {
    case allGreen
    case someOrange
    case someRed
    case unknown
}
