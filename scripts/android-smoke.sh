#!/usr/bin/env bash
set -euo pipefail

APK="generated/android/app/build/outputs/apk/debug/app-debug.apk"
PACKAGE="by.bali.cocktails"
ACTIVITY="$PACKAGE/.MainActivity"

if [ ! -f "$APK" ]; then
  echo "APK not found: $APK"
  exit 1
fi

echo "Installing BALI COCKTAIL APK on emulator..."
adb install -r "$APK"

adb logcat -c
adb shell am start -W -n "$ACTIVITY"
sleep 4

PID="$(adb shell pidof "$PACKAGE" | tr -d '\r')"
if [ -z "$PID" ]; then
  echo "BALI COCKTAIL process is not running after launch"
  exit 1
fi

adb shell uiautomator dump /sdcard/bali-window.xml >/dev/null
adb pull /sdcard/bali-window.xml /tmp/bali-window.xml >/dev/null

if ! grep -Eq 'BALI COCKTAIL|Коктейли' /tmp/bali-window.xml; then
  echo "Expected BALI COCKTAIL UI was not found"
  cat /tmp/bali-window.xml
  exit 1
fi

if adb logcat -d | grep -E 'FATAL EXCEPTION|Process: by\.bali\.cocktails'; then
  echo "Application crash detected"
  exit 1
fi

echo "BALI COCKTAIL installed and launched successfully on Android emulator."
