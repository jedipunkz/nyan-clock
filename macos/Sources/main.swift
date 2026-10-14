import AppKit

private let alwaysOnTopKey = "alwaysOnTop"
private let showMenuBarIconKey = "showMenuBarIcon"
private let height: CGFloat = 24

/// Swallows clicks from subviews so the whole clock drags the window; right-click shows `menu`.
final class ClockView: NSView {
    override func hitTest(_ point: NSPoint) -> NSView? { frame.contains(point) ? self : nil }
    override func mouseDown(with event: NSEvent) { window?.performDrag(with: event) }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuItemValidation {
    private let defaults = UserDefaults.standard
    // Widest weekday, so sizeToFit leaves room for every day.
    private let label = NSTextField(labelWithString: "0000/00/00(Wed) 00:00")
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX") // English weekday whatever the system language
        f.dateFormat = "yyyy/MM/dd(EEE) HH:mm"
        return f
    }()
    private var window: NSWindow!
    private var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        defaults.register(defaults: [alwaysOnTopKey: true, showMenuBarIconKey: true])
        let nyan = Bundle.main.image(forResource: "nyan") ?? NSImage()

        let imageView = NSImageView(image: nyan)
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.frame = NSRect(x: 4, y: 3, width: 43, height: height - 6)

        label.font = .monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
        label.textColor = .white
        label.sizeToFit()
        label.frame.origin = NSPoint(x: imageView.frame.maxX + 4, y: (height - label.frame.height) / 2)

        let view = ClockView(frame: NSRect(x: 0, y: 0, width: label.frame.maxX + 8, height: height))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(red: 0, green: 0.2, blue: 0.4, alpha: 1).cgColor // nyan.png background
        view.layer?.cornerRadius = 6
        view.addSubview(imageView)
        view.addSubview(label)
        view.menu = makeMenu()

        window = NSWindow(contentRect: view.frame, styleMask: .borderless, backing: .buffered, defer: false)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.contentView = view
        window.center()
        window.setFrameAutosaveName("NyanClockWindow") // restores and saves the position
        // Saved position may be on a monitor that is no longer connected.
        if !NSScreen.screens.contains(where: { $0.frame.intersects(window.frame) }) { window.center() }
        window.orderFrontRegardless()

        let icon = nyan.copy() as! NSImage
        icon.size = NSSize(width: 18 * nyan.size.width / max(nyan.size.height, 1), height: 18)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = icon
        statusItem.menu = makeMenu()

        applySettings()
        tick()
        let timer = Timer(timeInterval: 1, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common) // keep ticking while a menu is open
    }

    @objc private func tick() {
        label.stringValue = formatter.string(from: Date())
    }

    private func makeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(withTitle: "Always on Top", action: #selector(toggleAlwaysOnTop), keyEquivalent: "").target = self
        menu.addItem(withTitle: "Show Menu Bar Icon", action: #selector(toggleMenuBarIcon), keyEquivalent: "").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Nyan Clock", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q").target = NSApp
        return menu
    }

    func validateMenuItem(_ item: NSMenuItem) -> Bool {
        switch item.action {
        case #selector(toggleAlwaysOnTop): item.state = defaults.bool(forKey: alwaysOnTopKey) ? .on : .off
        case #selector(toggleMenuBarIcon): item.state = defaults.bool(forKey: showMenuBarIconKey) ? .on : .off
        default: break
        }
        return true
    }

    @objc private func toggleAlwaysOnTop() { toggle(alwaysOnTopKey) }
    @objc private func toggleMenuBarIcon() { toggle(showMenuBarIconKey) }

    private func toggle(_ key: String) {
        defaults.set(!defaults.bool(forKey: key), forKey: key)
        applySettings()
    }

    private func applySettings() {
        window.level = defaults.bool(forKey: alwaysOnTopKey) ? .floating : .normal
        statusItem.isVisible = defaults.bool(forKey: showMenuBarIconKey)
    }
}

MainActor.assumeIsolated {
    let delegate = AppDelegate()
    NSApplication.shared.delegate = delegate
    NSApplication.shared.run()
}
