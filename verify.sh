#!/bin/bash
# verify.sh
# Run this script to execute all local checks (Code Gen, Linting, Unit Tests, and E2E Tests)

# Exit immediately if a command exits with a non-zero status.
set -e

echo "==========================================="
echo "🧹 1/4: Running Riverpod Code Gen..."
echo "==========================================="
dart run build_runner build -d

echo "==========================================="
echo "🔎 2/4: Running Strict Linting..."
echo "==========================================="
flutter analyze

echo "==========================================="
echo "🧪 3/4: Running Unit Tests..."
echo "==========================================="
flutter test

echo "==========================================="
echo "🎭 4/4: Running Maestro E2E Tests..."
echo "==========================================="
echo "Note: Make sure your iOS Simulator or Android Emulator is actively running!"
# Run all maestro flows in the directory
# We pass APP_ID using the --env flag so maestro knows which app to launch
# Note: iOS uses camelCase (trackMyStuff), Android uses underscores (track_my_stuff)
maestro test --env APP_ID=com.example.trackMyStuff .maestro/

echo "==========================================="
echo "🧹 Cleaning up..."
echo "==========================================="
# Terminate the app so it's not left in a "unconnected" state
xcrun simctl terminate booted com.example.trackMyStuff 2>/dev/null || true
adb shell am force-stop com.example.track_my_stuff 2>/dev/null || true

echo "==========================================="
echo "✅ All verifications passed! You are ready to commit."
echo "==========================================="
