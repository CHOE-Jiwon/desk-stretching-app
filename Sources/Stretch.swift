import Foundation

enum StretchKind: String, CaseIterable {
    case neck, shoulders, twist, wrist, chest, sideBend, forwardFold, eyes
}

struct Stretch {
    let kind: StretchKind
    let name: String
    let instruction: String
    let durationSec: Int

    /// 회전 순서대로의 전체 목록 (연구 기반 데스크 스트레칭).
    static let all: [Stretch] = [
        Stretch(kind: .neck,
                name: "목 옆으로 늘이기",
                instruction: "고개를 천천히 오른쪽 어깨 쪽으로 기울여 15초, 반대쪽도 15초. 어깨는 내린 채로.",
                durationSec: 30),
        Stretch(kind: .shoulders,
                name: "어깨 돌리기",
                instruction: "양 어깨를 으쓱 올렸다가 뒤로 크게 굴려 내리기를 천천히 반복하세요.",
                durationSec: 30),
        Stretch(kind: .twist,
                name: "앉아서 척추 비틀기",
                instruction: "의자에 앉은 채 상체를 한쪽으로 천천히 비틀어 15초씩. 시선은 어깨 너머로.",
                durationSec: 30),
        Stretch(kind: .wrist,
                name: "손목·손가락 풀기",
                instruction: "팔을 앞으로 뻗고 손등을 위로, 아래로 천천히 젖혀 손목을 늘여 주세요.",
                durationSec: 30),
        Stretch(kind: .chest,
                name: "가슴 펴기",
                instruction: "등 뒤로 양손을 깍지 끼고 가슴을 활짝 열어 15초 유지. 어깨는 뒤로.",
                durationSec: 30),
        Stretch(kind: .sideBend,
                name: "옆구리 늘이기",
                instruction: "한 팔을 머리 위로 뻗어 반대쪽으로 천천히 기울이기. 양쪽 15초씩.",
                durationSec: 30),
        Stretch(kind: .forwardFold,
                name: "일어서서 허리 굽히기",
                instruction: "일어서서 무릎을 살짝 굽힌 채 상체를 천천히 앞으로 떨어뜨려 햄스트링을 늘이세요.",
                durationSec: 30),
        Stretch(kind: .eyes,
                name: "눈 휴식 (20-20-20)",
                instruction: "화면에서 눈을 떼고 6m 이상 먼 곳을 20초간 편안히 바라보세요.",
                durationSec: 20),
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
