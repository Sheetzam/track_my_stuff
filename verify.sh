#!/bin/bash
# verify.sh
# Master verification script — runs on Ubuntu.
# Executes local checks (Code Gen, Linting, Unit Tests, Android E2E),
# then pushes to Mac and runs iOS E2E remotely.
#
# Usage:
#   ./verify.sh          # Run everything (local + iOS)
#   ./verify.sh --local  # Run local checks only (skip iOS)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_ONLY=false
CURRENT_BRANCH=$(git -C "$SCRIPT_DIR" rev-parse --abbrev-ref HEAD)

if [[ "$1" == "--local" ]]; then
  LOCAL_ONLY=true
fi

echo "==========================================="
echo "🧹 1/5: Running Riverpod Code Gen..."
echo "==========================================="
dart run build_runner build -d

echo "==========================================="
echo "🔎 2/5: Running Linting (Non-fatal)..."
echo "==========================================="
flutter analyze || echo "⚠️  Linting found some issues, but continuing..."

echo "==========================================="
echo "🧪 3/5: Running Unit Tests..."
echo "==========================================="
flutter test

echo "==========================================="
echo "🤖 4/5: Running Android Maestro E2E Tests..."
echo "==========================================="
echo "Note: Make sure your Android Emulator is actively running!"
echo "      (Start with: ./start_android_emulator.sh)"

echo ""
echo "🔨 Building and installing Flutter app on Android Emulator..."
flutter build apk --debug
flutter install -d emulator --debug

echo ""
echo "🎭 Running Maestro flows..."
maestro test --env APP_ID=com.example.track_my_stuff .maestro/

echo "==========================================="
echo "🧹 Android Cleanup..."
echo "==========================================="
adb shell am force-stop com.example.track_my_stuff 2>/dev/null || true

if $LOCAL_ONLY; then
  echo "==========================================="
  echo "✅ Local verifications passed! (iOS skipped with --local)"
  echo "==========================================="
  exit 0
fi

echo "==========================================="
echo "🍎 5/5: Syncing to Mac & Running iOS E2E..."
echo "==========================================="

# Ensure all current changes are committed before pushing
if [[ -n $(git -C "$SCRIPT_DIR" status --porcelain) ]]; then
  echo "⚠️  You have uncommitted changes. Please commit before running iOS verification."
  echo "   (iOS verification requires a git push to the Mac)"
  exit 1
fi

echo "Pushing $CURRENT_BRANCH to macdev..."
git -C "$SCRIPT_DIR" push macdev "$CURRENT_BRANCH"

echo "Running iOS verification on Mac Mini via SSH..."
ssh macdev.local "bash ~/dev/track_my_stuff/verify_ios.sh"

echo "==========================================="
echo "✅ All verifications passed (Ubuntu + Mac)!"
echo "   You are ready to push to GitHub."
echo "==========================================="
