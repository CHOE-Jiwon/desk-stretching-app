import Foundation

enum StretchKind: String, CaseIterable {
    case neckTurn, armOverhead, crossBodyShoulder, chestOpen,
         neckTilt, shoulderShrug, neckRoll, wristForearm, anklePumps,
         calfToeRaise, squat
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
                name: "삼두 스트레칭",
                instruction: "한 팔을 머리 위로 접어 반대 손으로 팔꿈치를 지그시 당겨 삼두를 늘이세요. 양쪽 15초씩.",
                durationSec: 30),
        Stretch(kind: .crossBodyShoulder,
                name: "크로스바디 어깨 스트레칭",
                instruction: "한쪽 팔을 펴 가슴 앞을 가로지르고, 반대 팔로 팔꿈치나 전완을 걸어 가슴 쪽으로 지그시 당기세요. 양쪽 15초씩.",
                durationSec: 30),
        Stretch(kind: .chestOpen,
                name: "가슴 펴기",
                instruction: "등 뒤로 양손을 맞잡고 아래로 내리며 가슴을 활짝 열어 15초 유지하세요. 어깨는 뒤로.",
                durationSec: 15),
        Stretch(kind: .neckTilt,
                name: "목 옆으로 기울이기",
                instruction: "손을 머리 옆에 얹고 고개를 천천히 옆으로 기울여 목 옆을 늘이세요. 양쪽 10초씩.",
                durationSec: 20),
        Stretch(kind: .shoulderShrug,
                name: "어깨 으쓱",
                instruction: "양 어깨를 귀 쪽으로 끌어올렸다가 천천히 툭 내리기를 반복하세요.",
                durationSec: 20),
        Stretch(kind: .neckRoll,
                name: "목 돌리기",
                instruction: "고개를 앞으로 떨군 채 어깨를 따라 천천히 크게 원을 그리며 돌리세요. 양방향으로.",
                durationSec: 30),
        Stretch(kind: .wristForearm,
                name: "손목·전완 스트레칭",
                instruction: "한쪽 팔을 앞으로 쭉 뻗고 반대 손으로 손가락을 몸 쪽으로 지그시 당기세요. 손바닥 방향을 바꾸면 손목 신전·굴곡을 번갈아 늘일 수 있습니다. 양쪽 15초씩.",
                durationSec: 30),
        Stretch(kind: .anklePumps,
                name: "종아리 스트레칭",
                instruction: "의자에 앉아 한쪽 다리를 앞으로 뻗고, 발끝을 몸 쪽으로 당겼다 앞으로 미는 동작을 반복하세요. 종아리를 펌핑해 다리 혈액순환을 돕습니다. 양쪽 번갈아.",
                durationSec: 30),
        Stretch(kind: .calfToeRaise,
                name: "발끝·뒤꿈치 들기",
                instruction: "의자에 앉아 발을 바닥에 두고, 뒤꿈치를 고정한 채 발끝을 위로 들었다가, 이어서 앞꿈치를 누르며 뒤꿈치를 높이 들어 올리세요. 정강이·종아리를 번갈아 자극합니다.",
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
