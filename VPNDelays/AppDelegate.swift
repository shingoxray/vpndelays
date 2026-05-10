import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate { NSApp.delegate as! AppDelegate }

    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var settingsWindowController: NSWindowController?

    private let dataStore = DataStore.shared
    private let pingManager = PingManager.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
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
        statusItem?.button?.action = #selector(togglePopover)
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
        case .someYellow: color = NSColor.systemYellow
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

    private func computeOverallStatus() -> OverallStatus {
        let statuses = pingManager.tunnelStatuses.values
        if statuses.isEmpty { return .unknown }
        if statuses.allSatisfy({ !$0.isOnline }) { return .someRed }
        if statuses.contains(where: { !$0.isOnline }) { return .someYellow }
        if statuses.allSatisfy({ $0.isOnline && ($0.latency ?? 0) < 50 && $0.packetLoss == 0 }) { return .allGreen }
        if statuses.allSatisfy({ $0.isOnline }) { return .someYellow }
        return .unknown
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

    @objc private func togglePopover() {
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
        // 异步执行，让当前 runloop 先完成 popover 事件处理
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
    case someYellow
    case someRed
    case unknown
}
