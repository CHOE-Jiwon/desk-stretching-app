#!/bin/bash
# 데스크 스트레칭 빌드 스크립트 — Xcode 없이 CLT만으로 .app 생성.
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="DeskStretch"
BUNDLE_ID="com.jiwon.deskstretch"
APP="build/${APP_NAME}.app"
MACOS="$APP/Contents/MacOS"
RES="$APP/Contents/Resources"

echo "→ 정리"
rm -rf "$APP"
mkdir -p "$MACOS" "$RES"

echo "→ 컴파일 (swiftc)"
swiftc \
  -target arm64-apple-macosx13.0 \
  -o "$MACOS/${APP_NAME}" \
  Sources/*.swift

echo "→ 일러스트 복사"
cp Resources/illustrations/*.png "$RES/"

echo "→ Info.plist 생성"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>            <string>데스크 스트레칭</string>
  <key>CFBundleDisplayName</key>     <string>데스크 스트레칭</string>
  <key>CFBundleExecutable</key>      <string>${APP_NAME}</string>
  <key>CFBundleIdentifier</key>      <string>${BUNDLE_ID}</string>
  <key>CFBundlePackageType</key>     <string>APPL</string>
  <key>CFBundleShortVersionString</key> <string>1.0</string>
  <key>CFBundleVersion</key>         <string>1</string>
  <key>LSMinimumSystemVersion</key>  <string>13.0</string>
  <key>LSUIElement</key>             <true/>
  <key>NSHighResolutionCapable</key> <true/>
</dict>
</plist>
PLIST

echo "→ ad-hoc 코드사인"
codesign --force --sign - "$APP" >/dev/null 2>&1 || echo "  (코드사인 건너뜀)"

echo "→ zip 패키징 (릴리스 배포용)"
ZIP="build/${APP_NAME}.zip"
rm -f "$ZIP"
ditto -c -k --keepParent "$APP" "$ZIP"

echo "✅ 빌드 완료: $APP"
echo "   실행:  open \"$APP\""
echo "   설치:  cp -R \"$APP\" /Applications/"
echo "   배포:  $ZIP"
