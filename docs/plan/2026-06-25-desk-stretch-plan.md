# 데스크 스트레칭 (DeskStretch) — 구현 계획

작성일: 2026-06-25

## 목적
화이트칼라 노동자가 장시간 착석을 끊고 주기적으로 스트레칭하도록, macOS 메뉴바에 상주하며
근무 시간대 안에서 일정 간격마다 화면 정중앙에 "스트레칭하자" 오버레이를 띄우는 앱.

## 확정된 결정 (사용자)
- 기술: **네이티브 Swift** (메뉴바 앱). Xcode 불필요, CLT만으로 `swiftc` 직접 컴파일 + `.app` 번들링.
- 강제성: **중앙 오버레이** (크게 뜨되 "건너뛰기" 가능).
- 애니메이션: **직접 만든 SVG 캐릭터** (WKWebView로 인라인 SVG+CSS 렌더).
- 간격: **연구 기반 기본 30분 + 설정에서 조절**.

## 근거 (간격)
- 좌식행동 연구: 30분 이상 연속 착석을 끊고 움직이라는 권고가 일반적.
- 눈: 20-20-20 규칙(20분마다 20피트 밖을 20초). → 회전 목록에 "눈 휴식" 포함.
- 기본 30분, 5~120분 범위로 설정 가능.

## 아키텍처 (SPM 매니페스트가 이 CLT에서 깨져 있어 `swiftc` 직접 빌드)
- `main.swift` — NSApplication(.accessory) 진입점, 단일 인스턴스 가드.
- `Settings.swift` — UserDefaults 기반 ObservableObject(출근/점심/퇴근/간격/주말제외/일시정지/온보딩/자동실행).
- `Stretch.swift` — 스트레칭 8종 데이터 + 순환 제공자.
- `StretchAnimation.swift` — 종류별 SVG+CSS 애니메이션 HTML 생성.
- `Scheduler.swift` — 1초 하트비트로 근무시간대 판정 + 간격 도달 시 발동, 메뉴 카운트다운 상태 제공.
- `StatusBarController.swift` — NSStatusItem(프레임 애니메이션 아이콘, RunCat식) + 메뉴.
- `OverlayController.swift` — 화면 중앙 NSPanel(모든 스페이스/풀스크린 위), SwiftUI 호스팅.
- `OverlayView.swift` / `StretchWebView.swift` — 오버레이 UI + WKWebView 래퍼 + 가이드 카운트다운.
- `SettingsView.swift` — 온보딩 겸 설정 화면.
- `LaunchAtLogin.swift` — ~/Library/LaunchAgents plist로 로그인 시 자동 실행 토글.
- `build.sh` — `swiftc Sources/*.swift` → `.app` 번들 + Info.plist + ad-hoc 코드사인.

## 스케줄링 로직
근무 활성 = 평일(주말제외 시) ∧ 출근≤now<퇴근 ∧ ¬(점심시작≤now<점심끝).
하트비트(1s): 비활성/일시정지면 nextAt=nil. 활성+nil이면 nextAt=now+간격. now≥nextAt이면 오버레이 발동 후 nextAt=now+간격.
→ 점심·퇴근·일시정지 진입 시 타이머 리셋(재개 시 풀 간격 후 첫 알림).

## 스트레칭 8종
목 좌우 / 어깨 돌리기 / 척추 비틀기 / 손목 / 가슴 펴기 / 옆구리 늘이기 / 햄스트링(기립) / 눈 휴식(20-20-20).

## 검증
1. `./build.sh` 컴파일 성공 → verify: EXIT 0, `.app` 생성.
2. 실행 → 메뉴바 아이콘 등장·애니메이션, 메뉴 동작.
3. "지금 스트레칭하기" → 중앙 오버레이 + SVG 애니메이션 + 완료/건너뛰기.
4. 설정 저장/재기동 유지, 자동실행 토글 시 plist 생성/삭제.

## 비배포 범위 (지금 안 함)
- 공증/배포(타인 맥). 개인 맥 로컬 사용만. 필요 시 후속.
