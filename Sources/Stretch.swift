import Foundation

enum StretchKind: String, CaseIterable {
    case neckTurn, armOverhead, shoulderCross, chestOpen,
         neckTilt, shoulderShrug, neckRoll, armCross, squat
}

struct Stretch {
    let kind: StretchKind
    let name: String
    let instruction: String
    let durationSec: Int

    /// Resources/illustrations 안의 PNG 파일명(확장자 제외). kind 값과 동일.
    var image: String { kind.rawValue }

    /// 회전 순서대로의 전체 목록.
    static let all: [Stretch] = [
        Stretch(kind: .neckTurn,
                name: "목 돌려 뒤돌아보기",
                instruction: "고개를 천천히 한쪽으로 돌려 어깨 너머를 바라보며 15초, 반대쪽도 15초 유지하세요.",
                durationSec: 30),
        Stretch(kind: .armOverhead,
                name: "팔 위로 늘이기",
                instruction: "한 팔을 머리 위로 접어 반대 손으로 팔꿈치를 지그시 당겨 삼두를 늘이세요. 양쪽 15초씩.",
                durationSec: 30),
        Stretch(kind: .shoulderCross,
                name: "어깨 늘이기",
                instruction: "한 팔을 가슴 앞으로 가로질러 뻗고 반대 팔로 감아 당겨 어깨 뒤를 늘이세요. 양쪽 15초씩.",
                durationSec: 30),
        Stretch(kind: .chestOpen,
                name: "가슴 펴기",
                instruction: "등 뒤로 양손을 맞잡고 아래로 내리며 가슴을 활짝 열어 15초 유지하세요. 어깨는 뒤로.",
                durationSec: 30),
        Stretch(kind: .neckTilt,
                name: "목 옆으로 기울이기",
                instruction: "손을 머리 옆에 얹고 고개를 천천히 옆으로 기울여 목 옆을 늘이세요. 양쪽 15초씩.",
                durationSec: 30),
        Stretch(kind: .shoulderShrug,
                name: "어깨 으쓱",
                instruction: "양 어깨를 귀 쪽으로 끌어올렸다가 천천히 툭 내리기를 반복하세요.",
                durationSec: 30),
        Stretch(kind: .neckRoll,
                name: "목 돌리기",
                instruction: "고개를 앞으로 떨군 채 어깨를 따라 천천히 크게 원을 그리며 돌리세요. 양방향으로.",
                durationSec: 30),
        Stretch(kind: .armCross,
                name: "팔 가로질러 늘이기",
                instruction: "한 팔을 곧게 펴 가슴 앞으로 가로지르고 반대 팔로 몸 쪽으로 당기세요. 양쪽 15초씩.",
                durationSec: 30),
        Stretch(kind: .squat,
                name: "스쿼트 10개",
                instruction: "발을 어깨너비로 벌리고 허리를 곧게 편 채 천천히 앉았다 일어서기를 10회 반복하세요.",
                durationSec: 40),
    ]
}

/// 발동할 때마다 다음 스트레칭을 순환 제공.
final class StretchProvider {
    static let shared = StretchProvider()
    private var index = 0
    func next() -> Stretch {
        let s = Stretch.all[index % Stretch.all.count]
        index += 1
        return s
    }
}
