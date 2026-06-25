import Foundation
import SwiftUI

/// 앱 전역 설정. UserDefaults에 저장되고 SwiftUI에서 관찰 가능.
final class Settings: ObservableObject {
    static let shared = Settings()

    private let d = UserDefaults.standard

    // 분(자정부터의 분) 단위로 저장한다.
    @Published var workStartMin: Int { didSet { d.set(workStartMin, forKey: "workStartMin") } }
    @Published var lunchStartMin: Int { didSet { d.set(lunchStartMin, forKey: "lunchStartMin") } }
    @Published var lunchEndMin: Int { didSet { d.set(lunchEndMin, forKey: "lunchEndMin") } }
    @Published var workEndMin: Int { didSet { d.set(workEndMin, forKey: "workEndMin") } }
    @Published var intervalMinutes: Int { didSet { d.set(intervalMinutes, forKey: "intervalMinutes") } }
    @Published var excludeWeekends: Bool { didSet { d.set(excludeWeekends, forKey: "excludeWeekends") } }
    @Published var paused: Bool { didSet { d.set(paused, forKey: "paused") } }
    @Published var onboardingDone: Bool { didSet { d.set(onboardingDone, forKey: "onboardingDone") } }

    /// 로그인 시 자동 실행. 실제 상태는 LaunchAgent plist 존재 여부로 판단.
    @Published var launchAtLogin: Bool {
        didSet { LaunchAtLogin.setEnabled(launchAtLogin) }
    }

    private init() {
        // 기본값: 09:00 출근 / 12:00~13:00 점심 / 18:00 퇴근 / 30분 간격
        let dd = UserDefaults.standard
        func get(_ key: String, _ def: Int) -> Int {
            dd.object(forKey: key) == nil ? def : dd.integer(forKey: key)
        }
        workStartMin = get("workStartMin", 9 * 60)
        lunchStartMin = get("lunchStartMin", 12 * 60)
        lunchEndMin = get("lunchEndMin", 13 * 60)
        workEndMin = get("workEndMin", 18 * 60)
        intervalMinutes = get("intervalMinutes", 30)
        excludeWeekends = dd.object(forKey: "excludeWeekends") == nil ? true : dd.bool(forKey: "excludeWeekends")
        paused = dd.bool(forKey: "paused")
        onboardingDone = dd.bool(forKey: "onboardingDone")
        launchAtLogin = LaunchAtLogin.isEnabled
    }

    // MARK: - 시간 변환 헬퍼

    static func minutes(from date: Date) -> Int {
        let c = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (c.hour ?? 0) * 60 + (c.minute ?? 0)
    }

    static func date(fromMinutes m: Int) -> Date {
        let cal = Calendar.current
        return cal.date(bySettingHour: m / 60, minute: m % 60, second: 0, of: Date()) ?? Date()
    }

    static func label(forMinutes m: Int) -> String {
        String(format: "%02d:%02d", m / 60, m % 60)
    }

    /// SwiftUI DatePicker(hourAndMinute)용 Date 바인딩.
    func timeBinding(_ keyPath: ReferenceWritableKeyPath<Settings, Int>) -> Binding<Date> {
        Binding(
            get: { Settings.date(fromMinutes: self[keyPath: keyPath]) },
            set: { self[keyPath: keyPath] = Settings.minutes(from: $0) }
        )
    }
}
