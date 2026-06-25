import Foundation

/// 스트레칭 종류별 SVG 캐릭터 애니메이션 HTML 생성.
/// WKWebView에 loadHTMLString으로 올린다. (전부 인라인, 네트워크 불필요.)
func stretchAnimationHTML(_ kind: StretchKind) -> String {
    let body = (kind == .eyes) ? eyeSVG() : figureSVG(animClass: kind.rawValue)
    return """
    <!DOCTYPE html>
    <html><head><meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
    \(baseCSS)
    </style></head>
    <body><div class="stage">\(body)</div></body></html>
    """
}

private let baseCSS = """
:root { --ink:#2b2d42; --accent:#4f7cff; --skin:#ffd9b3; }
* { margin:0; padding:0; box-sizing:border-box; }
html,body { width:100%; height:100%; background:transparent; overflow:hidden; }
.stage { width:100%; height:100%; display:flex; align-items:center; justify-content:center; }
svg { width:78%; height:78%; overflow:visible; }

/* 공통: 부드러운 호흡 */
#figure { animation: breathe 3.4s ease-in-out infinite; transform-box:view-box; transform-origin:110px 200px; }
@keyframes breathe { 0%,100%{ transform:translateY(0) } 50%{ transform:translateY(-3px) } }

.limb { stroke:var(--accent); stroke-width:13; stroke-linecap:round; fill:none; }
.spine { stroke:var(--ink); stroke-width:15; stroke-linecap:round; fill:none; }
.head  { fill:var(--skin); stroke:var(--ink); stroke-width:4; }
.hand  { fill:var(--accent); }
.shadow{ fill:rgba(43,45,66,0.12); }

#head, #upperBody, #armL, #armR, #handR, #handL { transform-box:view-box; }
#head      { transform-origin:110px 86px; }
#upperBody { transform-origin:110px 178px; }
#armL      { transform-origin:84px 100px; }
#armR      { transform-origin:136px 100px; }
#handL     { transform-origin:64px 150px; }
#handR     { transform-origin:156px 150px; }

/* 목: 좌우로 기울이기 */
.neck #head { animation: neckTilt 3s ease-in-out infinite; }
@keyframes neckTilt { 0%,100%{transform:rotate(-17deg)} 50%{transform:rotate(17deg)} }

/* 어깨: 으쓱 + 돌리기 */
.shoulders #armL { animation: rollL 2.4s ease-in-out infinite; }
.shoulders #armR { animation: rollR 2.4s ease-in-out infinite; }
.shoulders #head { animation: bob 2.4s ease-in-out infinite; }
@keyframes rollL { 0%,100%{transform:translateY(0) rotate(0)} 30%{transform:translateY(-10px) rotate(10deg)} 60%{transform:translateY(0) rotate(-6deg)} }
@keyframes rollR { 0%,100%{transform:translateY(0) rotate(0)} 30%{transform:translateY(-10px) rotate(-10deg)} 60%{transform:translateY(0) rotate(6deg)} }
@keyframes bob { 0%,100%{transform:translateY(0)} 30%{transform:translateY(-4px)} }

/* 척추 비틀기: 상체를 좌우로 (scaleX + skew로 회전감) */
.twist #upperBody { animation: twist 3.6s ease-in-out infinite; }
@keyframes twist {
  0%,100%{ transform:scaleX(1) skewX(0) rotate(0) }
  25%    { transform:scaleX(0.62) skewX(-6deg) rotate(5deg) }
  50%    { transform:scaleX(1) skewX(0) rotate(0) }
  75%    { transform:scaleX(0.62) skewX(6deg) rotate(-5deg) }
}

/* 손목: 팔을 앞으로 들고 손목 까딱 */
.wrist #armL { transform:rotate(72deg); animation: wristFlexL 1.8s ease-in-out infinite; }
.wrist #armR { transform:rotate(-72deg); animation: wristFlexR 1.8s ease-in-out infinite; }
@keyframes wristFlexL { 0%,100%{transform:rotate(64deg)} 50%{transform:rotate(80deg)} }
@keyframes wristFlexR { 0%,100%{transform:rotate(-64deg)} 50%{transform:rotate(-80deg)} }

/* 가슴 펴기: 팔을 뒤로 활짝 + 가슴 확장 */
.chest #armL { animation: chestL 3s ease-in-out infinite; }
.chest #armR { animation: chestR 3s ease-in-out infinite; }
.chest #torso { animation: chestOpen 3s ease-in-out infinite; transform-box:view-box; transform-origin:110px 120px; }
@keyframes chestL { 0%,100%{transform:rotate(0)} 50%{transform:rotate(-150deg)} }
@keyframes chestR { 0%,100%{transform:rotate(0)} 50%{transform:rotate(150deg)} }
@keyframes chestOpen { 0%,100%{transform:scaleX(1)} 50%{transform:scaleX(1.18)} }

/* 옆구리: 상체 기울이며 한 팔 머리 위로 */
.sideBend #upperBody { animation: lean 4s ease-in-out infinite; }
.sideBend #armR { animation: reachOver 4s ease-in-out infinite; }
@keyframes lean { 0%,100%{transform:rotate(-20deg)} 50%{transform:rotate(20deg)} }
@keyframes reachOver { 0%,100%{transform:rotate(-145deg)} 50%{transform:rotate(-160deg)} }

/* 허리 굽히기: 상체를 앞으로 숙였다 펴기 */
.forwardFold #upperBody { animation: fold 3.6s ease-in-out infinite; }
@keyframes fold { 0%,100%{transform:rotate(0)} 55%{transform:rotate(72deg)} }

/* 눈 휴식 */
.eyeWrap { animation: blink 4s ease-in-out infinite; transform-box:view-box; transform-origin:center; }
@keyframes blink { 0%,90%,100%{transform:scaleY(1)} 95%{transform:scaleY(0.08)} }
.pupil { animation: focusFar 4s ease-in-out infinite; transform-box:view-box; transform-origin:110px 90px; }
@keyframes focusFar { 0%,100%{transform:translateX(0) scale(1)} 50%{transform:translateX(0) scale(0.55)} }
"""

/// 공통 캐릭터(정면). 종류별 class로 어느 부위가 움직일지 결정.
private func figureSVG(animClass: String) -> String {
    """
    <svg class="\(animClass)" viewBox="0 0 220 280" xmlns="http://www.w3.org/2000/svg">
      <ellipse class="shadow" cx="110" cy="266" rx="58" ry="9"/>
      <g id="figure">
        <!-- 다리 -->
        <g id="legs">
          <line class="spine" x1="110" y1="176" x2="86"  y2="252"/>
          <line class="spine" x1="110" y1="176" x2="134" y2="252"/>
        </g>
        <g id="upperBody">
          <!-- 팔 -->
          <g id="armL"><line class="limb" x1="84" y1="100" x2="56" y2="156"/>
            <g id="handL"><circle class="hand" cx="56" cy="156" r="10"/></g></g>
          <g id="armR"><line class="limb" x1="136" y1="100" x2="164" y2="156"/>
            <g id="handR"><circle class="hand" cx="164" cy="156" r="10"/></g></g>
          <!-- 몸통 -->
          <g id="torso"><line class="spine" x1="110" y1="92" x2="110" y2="178"/></g>
          <!-- 머리 -->
          <g id="head">
            <circle class="head" cx="110" cy="58" r="26"/>
            <circle cx="101" cy="56" r="3.4" fill="#2b2d42"/>
            <circle cx="119" cy="56" r="3.4" fill="#2b2d42"/>
            <path d="M101 70 Q110 76 119 70" stroke="#2b2d42" stroke-width="3" fill="none" stroke-linecap="round"/>
          </g>
        </g>
      </g>
    </svg>
    """
}

/// 눈 휴식 전용 그래픽.
private func eyeSVG() -> String {
    """
    <svg class="eyes" viewBox="0 0 220 180" xmlns="http://www.w3.org/2000/svg">
      <g class="eyeWrap">
        <path d="M30 90 Q110 22 190 90 Q110 158 30 90 Z" fill="#ffffff" stroke="#2b2d42" stroke-width="6"/>
        <circle class="pupil" cx="110" cy="90" r="30" fill="var(--accent)"/>
        <circle cx="110" cy="90" r="14" fill="#2b2d42"/>
        <circle cx="120" cy="80" r="6" fill="#ffffff"/>
      </g>
      <path d="M196 52 l16 -10 M200 70 l18 -3 M196 128 l16 10" stroke="var(--accent)" stroke-width="5" stroke-linecap="round" fill="none"/>
    </svg>
    """
}
