#!/bin/bash
# verify_ios.sh
# iOS verification script — runs on the Mac Mini (invoked via SSH from Ubuntu).
#
# Two-phase verification:
#   Phase 1 — iOS Simulator: Maestro E2E (mock ML Kit path)
#   Phase 2 — Physical iPhone: build release, install, Maestro E2E (real ML Kit path)
#
# Requires:
#   ~/.keychain_pass  — Mac login password for codesign (chmod 600, not in git)

set -e

export PATH="$HOME/dev/flutter/bin:$HOME/.maestro/bin:/opt/homebrew/bin:$PATH"

PROJECT_DIR="$HOME/dev/track_my_stuff"
SIMULATOR_APP_ID="com.example.trackMyStuff"
DEVICE_APP_ID="com.sheetzam.trackMyStuff"
SIMULATOR_NAME="iPhone 17 Pro"
DEVICE_UDID="c436e44ff43f1f713f842da9f106d5ae8658efb0"

cd "$PROJECT_DIR"

echo "==========================================="
echo "🍎 iOS Verification (Mac Mini)"
echo "==========================================="

# --- Unlock keychain for code signing ---
if [[ -f "$HOME/.keychain_pass" ]]; then
  security unlock-keychain -p "$(cat "$HOME/.keychain_pass")" "$HOME/Library/Keychains/login.keychain-db"
  echo "🔑 Keychain unlocked."
else
  echo "⚠️  ~/.keychain_pass not found — code signing may fail."
fi

# ==========================================
# PHASE 1: iOS Simulator (Maestro E2E)
# ==========================================
echo ""
echo "==========================================="
echo "📱 Phase 1: iOS Simulator E2E"
echo "==========================================="

echo "Booting $SIMULATOR_NAME..."
xcrun simctl boot "$SIMULATOR_NAME" 2>/dev/null || true
open -a Simulator
xcrun simctl bootstatus "$SIMULATOR_NAME" -b

echo "Resolving dependencies..."
flutter pub get

SIMULATOR_DEVICE_ID=$(xcrun simctl list devices booted --json | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data['devices'].items():
    for d in devices:
        if d['state'] == 'Booted':
            print(d['udid'])
            sys.exit(0)
" 2>/dev/null)

if [[ -z "$SIMULATOR_DEVICE_ID" ]]; then
  echo "❌ No booted simulator found!"
  exit 1
fi

echo "Building for simulator ($SIMULATOR_NAME)..."
flutter build ios --simulator --debug
flutter install -d "$SIMULATOR_DEVICE_ID"

echo "🎭 Running Maestro E2E on Simulator..."
maestro test --env APP_ID="$SIMULATOR_APP_ID" .maestro/

echo "🧹 Shutting down simulator..."
xcrun simctl terminate booted "$SIMULATOR_APP_ID" 2>/dev/null || true
xcrun simctl shutdown "$SIMULATOR_NAME" 2>/dev/null || true

# ==========================================
# PHASE 2: Physical iPhone (build + install + Maestro E2E)
# ==========================================
echo ""
echo "==========================================="
echo "📱 Phase 2: Physical iPhone E2E"
echo "==========================================="

# Confirm device is connected
if ! flutter devices 2>/dev/null | grep -q "$DEVICE_UDID"; then
  echo "⚠️  Physical iPhone ($DEVICE_UDID) not connected — skipping Phase 2."
else
  echo "Building release for physical device..."
  flutter build ios --release

  echo "Installing on iPhone..."
  flutter install -d "$DEVICE_UDID" --release

  echo "🎭 Running Maestro E2E on iPhone..."
  maestro test --env APP_ID="$DEVICE_APP_ID" .maestro/

  echo "🧹 Stopping app on device..."
  # Maestro handles app lifecycle; nothing to clean up
fi

echo ""
echo "✅ iOS verification passed!"
