#!/bin/bash

echo "🛑 Stopping iOS Simulator..."
# Gracefully shutdown running devices
xcrun simctl shutdown all
# Politely ask the macOS Simulator app wrapper to quit itself, allowing it to save state
osascript -e 'quit app "Simulator"' 2>/dev/null

echo "🛑 Stopping Android Emulator..."
# Use adb to gracefully kill the running Android emulator
~/Library/Android/sdk/platform-tools/adb emu kill 2>/dev/null

echo "✅ Emulators shut down successfully!"
