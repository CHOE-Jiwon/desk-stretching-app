import AppKit
import SwiftUI

/// 보더리스 패널이 키 윈도우가 되어 버튼/단축키를 받도록.
final class KeyablePanel: NSPanel {
    override var canBecomeKey: Bool { true }
}

/// 화면 정중앙에 스트레칭 오버레이를 띄운다.
final class OverlayController {
    private var panel: NSPanel?

    func show(_ stretch: Stretch) {
        guard panel == nil else { return } // 이미 떠 있으면 중복 표시 방지

        let host = NSHostingController(rootView: OverlayView(
            stretch: stretch,
            onComplete: { [weak self] in self?.close() },
            onSkip: { [weak self] in self?.close() }
        ))
        host.view.layoutSubtreeIfNeeded()
        let fitting = host.view.fittingSize
        let size = NSSize(width: fitting.width > 0 ? fitting.width : 520,
                          height: fitting.height > 0 ? fitting.height : 660)

        let p = KeyablePanel(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered, defer: false)
        p.contentViewController = host
        p.setContentSize(size)
        p.isOpaque = false
        p.backgroundColor = .clear
        p.hasShadow = false
        p.isFloatingPanel = true
        p.hidesOnDeactivate = false
        p.level = .screenSaver
        p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        p.center()

        NSApp.activate(ignoringOtherApps: true)
        p.makeKeyAndOrderFront(nil)
        panel = p
    }

    private func close() {
        panel?.orderOut(nil)
        panel = nil
    }
}
