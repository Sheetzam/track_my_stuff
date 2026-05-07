#!/bin/bash
# start_android_emulator.sh
# Starts the Android emulator on Ubuntu in the background.

AVD_NAME="Medium_Phone_API_36.1"
EMULATOR="$HOME/Android/Sdk/emulator/emulator"

echo "🚀 Starting Android Emulator ($AVD_NAME)..."

# Check if the emulator is already running
if adb devices 2>/dev/null | grep -q "emulator"; then
  echo "✅ Android Emulator is already running."
  exit 0
fi

# Run the emulator in the background
nohup "$EMULATOR" -avd "$AVD_NAME" -no-snapshot-load > /dev/null 2>&1 &

echo "⏳ Waiting for emulator to boot..."
adb wait-for-device
# Wait until the boot animation completes
while [[ "$(adb shell getprop sys.boot_completed 2>/dev/null)" != "1" ]]; do
  sleep 1
done

echo "✅ Android Emulator is ready!"
