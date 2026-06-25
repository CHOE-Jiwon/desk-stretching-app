import AppKit

/// 메뉴바 상주 아이콘(프레임 애니메이션) + 메뉴.
final class StatusBarController: NSObject, NSMenuDelegate {
    private let item: NSStatusItem
    private let frames: [NSImage]
    private var frameIndex = 0
    private var animTimer: Timer?

    private let statusMenuItem = NSMenuItem(title: "준비 중…", action: nil, keyEquivalent: "")
    private let pauseMenuItem = NSMenuItem(title: "일시정지", action: nil, keyEquivalent: "")
    private let launchMenuItem = NSMenuItem(title: "로그인 시 자동 실행", action: nil, keyEquivalent: "")

    // AppDelegate가 연결.
    var onTriggerNow: (() -> Void)?
    var onOpenSettings: (() -> Void)?
    var onQuit: (() -> Void)?

    override init() {
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        frames = StatusBarController.makeFrames()
        super.init()

        item.button?.image = frames.first
        buildMenu()
        startAnimating()
    }

    // MARK: - 메뉴

    private func buildMenu() {
        let menu = NSMenu()
        menu.delegate = self

        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)
        menu.addItem(.separator())

        let now = NSMenuItem(title: "지금 스트레칭하기", action: #selector(triggerNow), keyEquivalent: "")
        now.target = self
        menu.addItem(now)

        pauseMenuItem.action = #selector(togglePause)
        pauseMenuItem.target = self
        menu.addItem(pauseMenuItem)

        menu.addItem(.separator())

        let settings = NSMenuItem(title: "설정…", action: #selector(openSettings), keyEquivalent: ",")
        settings.target = self
        menu.addItem(settings)

        launchMenuItem.action = #selector(toggleLaunch)
        launchMenuItem.target = self
        menu.addItem(launchMenuItem)

        menu.addItem(.separator())

        let quit = NSMenuItem(title: "종료", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        item.menu = menu
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        pauseMenuItem.title = Settings.shared.paused ? "재개" : "일시정지"
        launchMenuItem.state = Settings.shared.launchAtLogin ? .on : .off
    }

    func updateStatus(_ status: SchedulerStatus) {
        statusMenuItem.title = status.menuText
    }

    @objc private func triggerNow() { onTriggerNow?() }
    @objc private func openSettings() { onOpenSettings?() }
    @objc private func quit() { onQuit?() }
    @objc private func togglePause() {
        Settings.shared.paused.toggle()
        if Settings.shared.paused { stopAnimating() } else { startAnimating() }
    }
    @objc private func toggleLaunch() { Settings.shared.launchAtLogin.toggle() }

    // MARK: - 아이콘 애니메이션

    private func startAnimating() {
        animTimer?.invalidate()
        let t = Timer(timeInterval: 0.12, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.frameIndex = (self.frameIndex + 1) % self.frames.count
            self.item.button?.image = self.frames[self.frameIndex]
        }
        RunLoop.main.add(t, forMode: .common)
        animTimer = t
    }

    private func stopAnimating() {
        animTimer?.invalidate()
        animTimer = nil
        item.button?.image = frames.first // 팔 내린 정지 포즈
    }

    /// 팔을 들었다 내리는 스트레칭 동작 프레임들 (템플릿 이미지).
    private static func makeFrames() -> [NSImage] {
        let count = 10
        return (0..<count).map { i in
            let phase = (1 - cos(2 * .pi * Double(i) / Double(count))) / 2 // 0→1→0
            let armEndY = 6.5 + phase * 8.5
            let img = NSImage(size: NSSize(width: 18, height: 18))
            img.lockFocus()
            let p = NSBezierPath()
            p.lineWidth = 1.6
            p.lineCapStyle = .round
            p.lineJoinStyle = .round
            NSColor.black.setStroke()
            NSColor.black.setFill()
            // 머리
            let head = NSBezierPath(ovalIn: NSRect(x: 7.4, y: 13.0, width: 3.2, height: 3.2))
            head.fill()
            // 몸통
            p.move(to: NSPoint(x: 9, y: 12.6)); p.line(to: NSPoint(x: 9, y: 6.5))
            // 다리
            p.move(to: NSPoint(x: 9, y: 6.5)); p.line(to: NSPoint(x: 6.2, y: 2.2))
            p.move(to: NSPoint(x: 9, y: 6.5)); p.line(to: NSPoint(x: 11.8, y: 2.2))
            // 팔 (어깨 11.2에서 좌우 위로)
            p.move(to: NSPoint(x: 9, y: 11.2)); p.line(to: NSPoint(x: 5.2, y: armEndY))
            p.move(to: NSPoint(x: 9, y: 11.2)); p.line(to: NSPoint(x: 12.8, y: armEndY))
            p.stroke()
            img.unlockFocus()
            img.isTemplate = true
            return img
        }
    }
}
