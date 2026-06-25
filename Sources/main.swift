import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBar: StatusBarController!
    private var overlay: OverlayController!
    private var scheduler: Scheduler!
    private let settingsWC = SettingsWindowController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 단일 인스턴스 가드 (로그인 자동실행 + 수동실행 중복 방지)
        if let id = Bundle.main.bundleIdentifier {
            let myPID = ProcessInfo.processInfo.processIdentifier
            let others = NSRunningApplication.runningApplications(withBundleIdentifier: id)
                .filter { $0.processIdentifier != myPID }
            if !others.isEmpty { NSApp.terminate(nil); return }
        }

        overlay = OverlayController()
        statusBar = StatusBarController()
        scheduler = Scheduler(
            onFire: { [weak self] stretch in self?.overlay.show(stretch) },
            onStatus: { [weak self] status in self?.statusBar.updateStatus(status) })

        statusBar.onTriggerNow = { [weak self] in self?.scheduler.triggerNow() }
        statusBar.onOpenSettings = { [weak self] in self?.settingsWC.show(onboarding: false) }
        statusBar.onQuit = { NSApp.terminate(nil) }

        scheduler.start()

        if !Settings.shared.onboardingDone {
            settingsWC.show(onboarding: true)
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory) // Dock 아이콘 없는 메뉴바 상주 앱
app.run()
