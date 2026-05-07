#!/bin/bash
# stop_android_emulator.sh
# Stops the Android emulator on Ubuntu.

echo "🛑 Stopping Android Emulator..."

if adb devices 2>/dev/null | grep -q "emulator"; then
  adb emu kill 2>/dev/null
  echo "✅ Android Emulator shut down."
else
  echo "ℹ️  No running Android Emulator found."
fi
