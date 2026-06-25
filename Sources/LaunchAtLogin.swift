import Foundation

/// 로그인 시 자동 실행을 ~/Library/LaunchAgents의 LaunchAgent plist로 관리한다.
/// (코드 사인 없는 개인용 앱에서 SMAppService보다 안정적이라 plist 방식 사용.)
enum LaunchAtLogin {
    static let label = "com.jiwon.deskstretch"

    static var plistURL: URL {
        let dir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents", isDirectory: true)
        return dir.appendingPathComponent("\(label).plist")
    }

    static var isEnabled: Bool {
        FileManager.default.fileExists(atPath: plistURL.path)
    }

    /// 실행 파일 경로 (.app 번들 안의 바이너리).
    private static var executablePath: String {
        Bundle.main.executablePath ?? CommandLine.arguments[0]
    }

    static func setEnabled(_ on: Bool) {
        if on { enable() } else { disable() }
    }

    private static func enable() {
        let plist: [String: Any] = [
            "Label": label,
            "ProgramArguments": [executablePath],
            "RunAtLoad": true,
            "ProcessType": "Interactive",
        ]
        do {
            try FileManager.default.createDirectory(
                at: plistURL.deletingLastPathComponent(),
                withIntermediateDirectories: true)
            let data = try PropertyListSerialization.data(
                fromPropertyList: plist, format: .xml, options: 0)
            try data.write(to: plistURL)
            // 다음 로그인부터 자동 적용. 즉시 부트스트랩하면 중복 실행 위험이 있어 생략.
        } catch {
            NSLog("LaunchAtLogin enable 실패: \(error)")
        }
    }

    private static func disable() {
        try? FileManager.default.removeItem(at: plistURL)
        // 등록된 에이전트가 있으면 정리 (실패 무시).
        let p = Process()
        p.launchPath = "/bin/launchctl"
        p.arguments = ["bootout", "gui/\(getuid())/\(label)"]
        p.standardError = FileHandle.nullDevice
        p.standardOutput = FileHandle.nullDevice
        try? p.run()
    }
}
