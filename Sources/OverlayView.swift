import SwiftUI

/// 번들 Resources의 일러스트 PNG를 표시. 비율이 제각각이라 scaledToFit로 안 깨지게.
struct StretchIllustration: View {
    let image: String

    var body: some View {
        Group {
            if let url = Bundle.main.url(forResource: image, withExtension: "png"),
               let nsImage = NSImage(contentsOf: url) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "figure.flexibility")
                    .font(.system(size: 64))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// 화면 중앙에 뜨는 스트레칭 안내 카드.
struct OverlayView: View {
    let stretch: Stretch
    let onComplete: () -> Void
    let onSkip: () -> Void

    @State private var remaining: Int
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(stretch: Stretch, onComplete: @escaping () -> Void, onSkip: @escaping () -> Void) {
        self.stretch = stretch
        self.onComplete = onComplete
        self.onSkip = onSkip
        _remaining = State(initialValue: stretch.durationSec)
    }

    private var done: Bool { remaining <= 0 }

    var body: some View {
        VStack(spacing: 18) {
            Text("잠깐, 스트레칭 한 번 할까요?")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)

            StretchIllustration(image: stretch.image)
                .frame(width: 300, height: 240)

            Text(stretch.name)
                .font(.system(size: 26, weight: .bold))

            Text(stretch.instruction)
                .font(.system(size: 15))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 360)

            countdownRing

            HStack(spacing: 12) {
                Button(action: onSkip) {
                    Text("건너뛰기").frame(width: 120, height: 40)
                }
                .buttonStyle(.bordered)
                .keyboardShortcut(.cancelAction)

                Button(action: onComplete) {
                    Text(done ? "완료! 잘하셨어요" : "완료")
                        .fontWeight(.semibold)
                        .frame(width: 160, height: 40)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
            .padding(.top, 2)
        }
        .padding(36)
        .frame(width: 440)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(.white.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 40, y: 16)
        .onReceive(timer) { _ in if remaining > 0 { remaining -= 1 } }
    }

    private var countdownRing: some View {
        ZStack {
            Circle().stroke(.secondary.opacity(0.2), lineWidth: 8)
            Circle()
                .trim(from: 0, to: max(0.0001, Double(remaining) / Double(stretch.durationSec)))
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: remaining)
            Text(done ? "👍" : "\(remaining)")
                .font(.system(size: done ? 26 : 30, weight: .bold, design: .rounded))
                .monospacedDigit()
        }
        .frame(width: 84, height: 84)
    }
}
