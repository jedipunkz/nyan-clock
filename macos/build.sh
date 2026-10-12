#!/bin/bash
# Builds a universal build/NyanClock.app. Usage: VERSION=1.2.3 ./build.sh
set -euo pipefail
cd "$(dirname "$0")"

VERSION="${VERSION:-0.0.0}"
APP=build/NyanClock.app

rm -rf build
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
for arch in arm64 x86_64; do
  swiftc -O -target "$arch-apple-macos13" Sources/main.swift -o "build/NyanClock-$arch"
done
lipo -create build/NyanClock-arm64 build/NyanClock-x86_64 -output "$APP/Contents/MacOS/NyanClock"
cp Resources/nyan.png "$APP/Contents/Resources/"
cp Info.plist "$APP/Contents/"
plutil -replace CFBundleShortVersionString -string "$VERSION" "$APP/Contents/Info.plist"
plutil -replace CFBundleVersion -string "$VERSION" "$APP/Contents/Info.plist"
codesign --force --sign - "$APP" # ad-hoc; not notarized
echo "Built $APP ($VERSION)"
