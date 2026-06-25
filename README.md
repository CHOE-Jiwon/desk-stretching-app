# 데스크 스트레칭 (DeskStretch)

장시간 착석하는 화이트칼라를 위한 macOS 메뉴바 스트레칭 알리미.
근무 시간대 안에서 일정 간격마다 화면 정중앙에 스트레칭 안내(SVG 애니메이션)를 띄운다.

## 특징
- 메뉴바 상주 + 움직이는 아이콘 (RunCat식)
- 출근 / 점심 / 퇴근 시간 설정, 그 시간대 안에서만 알림 (주말 제외 가능)
- 연구 기반 기본 간격 30분 (5~120분 조절)
- 화면 중앙 오버레이 + SVG 캐릭터 애니메이션, "완료" / "건너뛰기"
- 로그인 시 자동 실행 토글

## 빌드 (Xcode 불필요, Command Line Tools만 필요)
```bash
./build.sh
```
`build/DeskStretch.app` 이 생성된다.

## 실행 / 설치
```bash
# 바로 실행해 보기
open build/DeskStretch.app

# 정식 설치 (권장): Applications로 옮긴 뒤 실행
cp -R build/DeskStretch.app /Applications/
open /Applications/DeskStretch.app
```
> 자동 실행을 켜면 현재 실행 중인 앱의 경로를 LaunchAgent에 등록한다.
> 따라서 **먼저 `/Applications`로 옮기고 거기서 실행한 다음** "로그인 시 자동 실행"을 켜는 것을 권장한다.
> (그래야 경로가 안정적이다.)

## 사용
- 첫 실행 시 설정 창에서 출근/점심/퇴근 시간과 간격을 정한다.
- 메뉴바 아이콘 클릭 → `지금 스트레칭하기`(즉시 테스트), `일시정지/재개`, `설정…`, `종료`.

## 구조
- `Sources/` — Swift 소스 (AppKit + SwiftUI + WebKit)
- `build.sh` — `swiftc`로 컴파일 후 `.app` 번들 + Info.plist + ad-hoc 코드사인
- `docs/plan/` — 구현 계획

## 자동 실행 끄기
설정에서 토글을 끄거나:
```bash
rm ~/Library/LaunchAgents/com.jiwon.deskstretch.plist
```
