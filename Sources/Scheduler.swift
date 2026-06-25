import Foundation

/// 메뉴에 표시할 현재 상태.
enum SchedulerStatus {
    case active(secondsToNext: Int)
    case paused
    case outsideHours

    var menuText: String {
        switch self {
        case .active(let s):
            let m = s / 60, sec = s % 60
            if m > 0 { return "다음 스트레칭까지 \(m)분 \(sec)초" }
            return "다음 스트레칭까지 \(sec)초"
        case .paused:
            return "일시정지됨"
        case .outsideHours:
            return "근무 시간이 아닙니다"
        }
    }
}

/// 근무 시간대 안에서 간격마다 스트레칭을 발동시키는 스케줄러.
final class Scheduler {
    private let settings = Settings.shared
    private let onFire: (Stretch) -> Void
    private let onStatus: (SchedulerStatus) -> Void

    private var nextStretchAt: Date?
    private var timer: Timer?

    init(onFire: @escaping (Stretch) -> Void,
         onStatus: @escaping (SchedulerStatus) -> Void) {
        self.onFire = onFire
        self.onStatus = onStatus
    }

    func start() {
        timer?.invalidate()
        let t = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in self?.tick() }
        RunLoop.main.add(t, forMode: .common)
        timer = t
        tick()
    }

    /// "지금 스트레칭하기" — 즉시 발동하고 다음 주기를 재설정.
    func triggerNow() {
        onFire(StretchProvider.shared.next())
        if isActive(Date()) {
            nextStretchAt = Date().addingTimeInterval(intervalSeconds)
        }
    }

    // MARK: - 내부

    private var intervalSeconds: TimeInterval {
        TimeInterval(max(1, settings.intervalMinutes) * 60)
    }

    private func tick() {
        let now = Date()

        guard !settings.paused else {
            nextStretchAt = nil
            onStatus(.paused)
            return
        }
        guard isActive(now) else {
            nextStretchAt = nil
            onStatus(.outsideHours)
            return
        }

        if nextStretchAt == nil {
            nextStretchAt = now.addingTimeInterval(intervalSeconds)
        } else if now >= nextStretchAt! {
            onFire(StretchProvider.shared.next())
            nextStretchAt = now.addingTimeInterval(intervalSeconds)
        }

        let remaining = Int((nextStretchAt?.timeIntervalSince(now) ?? 0).rounded(.up))
        onStatus(.active(secondsToNext: max(0, remaining)))
    }

    /// 평일(주말제외 시) ∧ 출근≤now<퇴근 ∧ ¬점심.
    private func isActive(_ now: Date) -> Bool {
        let cal = Calendar.current
        if settings.excludeWeekends {
            let wd = cal.component(.weekday, from: now) // 1=일 … 7=토
            if wd == 1 || wd == 7 { return false }
        }
        let t = Settings.minutes(from: now)
        if t < settings.workStartMin || t >= settings.workEndMin { return false }
        if t >= settings.lunchStartMin && t < settings.lunchEndMin { return false }
        return true
    }
}
