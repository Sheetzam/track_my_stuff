#!/bin/bash

echo "🚀 Starting iOS Simulator..."
open -a Simulator

echo "🚀 Starting Android Emulator (android_emulator)..."
# Run the Android emulator in the background so it doesn't block this terminal tab
nohup ~/Library/Android/sdk/emulator/emulator -avd android_emulator > /dev/null 2>&1 &

echo "✅ Emulators have been commanded to boot up. (Android may take a few seconds)"
