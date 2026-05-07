#!/bin/bash
# verify_ios.sh
# iOS verification script — runs on the Mac Mini (invoked via SSH from Ubuntu).
# Boots the iOS Simulator, builds and installs the Flutter app,
# runs Maestro E2E tests, and cleans up.

set -e

# --- Configuration ---
# Non-interactive SSH doesn't source .zshrc, so we set paths explicitly.
export PATH="$HOME/dev/flutter/bin:$HOME/.maestro/bin:/opt/homebrew/bin:$PATH"

PROJECT_DIR="$HOME/dev/track_my_stuff"
APP_ID="com.example.trackMyStuff"
# Use iPhone 17 Pro as the default test device
SIMULATOR_NAME="iPhone 17 Pro"

cd "$PROJECT_DIR"

echo "==========================================="
echo "🍎 iOS Verification (Mac Mini)"
echo "==========================================="

# --- 1. Boot Simulator ---
echo ""
echo "📱 Booting iOS Simulator ($SIMULATOR_NAME)..."
xcrun simctl boot "$SIMULATOR_NAME" 2>/dev/null || true
# Wait for the simulator to be fully booted
xcrun simctl bootstatus "$SIMULATOR_NAME" -b

# --- 2. Resolve Dependencies ---
echo ""
echo "📦 Resolving dependencies..."
flutter pub get

# --- 3. Build & Install ---
echo ""
echo "🔨 Building and installing Flutter app on iOS Simulator..."
# Get the simulator device ID for flutter
DEVICE_ID=$(xcrun simctl list devices booted --json | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data['devices'].items():
    for d in devices:
        if d['state'] == 'Booted':
            print(d['udid'])
            sys.exit(0)
" 2>/dev/null)

if [[ -z "$DEVICE_ID" ]]; then
  echo "❌ No booted simulator found!"
  exit 1
fi

echo "   Using simulator: $SIMULATOR_NAME ($DEVICE_ID)"
flutter build ios --simulator --debug
flutter install -d "$DEVICE_ID"

# --- 4. Run Maestro E2E ---
echo ""
echo "🎭 Running Maestro E2E Tests on iOS..."
maestro test --env APP_ID="$APP_ID" .maestro/

# --- 5. Cleanup ---
echo ""
echo "🧹 Cleaning up..."
xcrun simctl terminate booted "$APP_ID" 2>/dev/null || true
xcrun simctl shutdown "$SIMULATOR_NAME" 2>/dev/null || true

echo ""
echo "✅ iOS verification passed!"
