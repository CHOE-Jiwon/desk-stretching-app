import AppKit
import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = Settings.shared
    let isOnboarding: Bool
    let onDone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 4) {
                Text(isOnboarding ? "데스크 스트레칭에 오신 걸 환영해요" : "설정")
                    .font(.system(size: 20, weight: .bold))
                if isOnboarding {
                    Text("근무 시간과 간격을 정하면, 그 안에서 주기적으로 스트레칭을 알려드릴게요.")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
            }

            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                timeRow("출근 시간", \.workStartMin)
                timeRow("점심 시작", \.lunchStartMin)
                timeRow("점심 종료", \.lunchEndMin)
                timeRow("퇴근 시간", \.workEndMin)
            }

            VStack(alignment: .leading, spacing: 6) {
                Stepper("스트레칭 간격: \(settings.intervalMinutes)분",
                        value: $settings.intervalMinutes, in: 5...120, step: 5)
                Text("연구 권고: 30분 이상 연속 착석 피하기. 기본값 30분.")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Toggle("주말(토·일) 제외", isOn: $settings.excludeWeekends)
            Toggle("로그인 시 자동 실행", isOn: $settings.launchAtLogin)

            Divider()

            HStack {
                Spacer()
                Button(action: done) {
                    Text(isOnboarding ? "시작하기" : "닫기")
                        .fontWeight(.semibold)
                        .frame(width: 120, height: 32)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(28)
        .frame(width: 420)
    }

    private func timeRow(_ label: String, _ keyPath: ReferenceWritableKeyPath<Settings, Int>) -> some View {
        GridRow {
            Text(label).gridColumnAlignment(.leading)
            DatePicker("", selection: settings.timeBinding(keyPath),
                       displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(.stepperField)
        }
    }

    private func done() {
        if isOnboarding { settings.onboardingDone = true }
        onDone()
    }
}

/// 설정 창 관리.
final class SettingsWindowController: NSObject, NSWindowDelegate {
    private var window: NSWindow?

    func show(onboarding: Bool) {
        if let w = window {
            NSApp.activate(ignoringOtherApps: true)
            w.makeKeyAndOrderFront(nil)
            return
        }
        let host = NSHostingController(rootView: SettingsView(
            isOnboarding: onboarding,
            onDone: { [weak self] in self?.close() }))
        let w = NSWindow(contentViewController: host)
        w.title = "데스크 스트레칭"
        w.styleMask = [.titled, .closable]
        w.isReleasedWhenClosed = false
        w.delegate = self
        w.center()
        window = w
        NSApp.activate(ignoringOtherApps: true)
        w.makeKeyAndOrderFront(nil)
    }

    private func close() { window?.close() }

    func windowWillClose(_ notification: Notification) { window = nil }
}
