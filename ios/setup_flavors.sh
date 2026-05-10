#!/bin/bash
# setup_flavors.sh
# One-shot script to configure iOS build flavors on the Mac Mini.
# Run this after a fresh clone or when flavor configs need regeneration.
#
# Usage: cd ios && bash setup_flavors.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

echo "1/4: Adding flavor build configurations to Xcode project..."
ruby ios/add_flavor_configs.rb

echo ""
echo "2/4: Running pod install..."
cd ios
export PATH="/opt/homebrew/bin:$PATH"
pod install

echo ""
echo "3/4: Fixing xcconfig references..."
cd ..
ruby ios/fix_flavor_xcconfigs.rb

echo ""
echo "4/4: Patching dev xcconfigs (removing ML Kit linker refs)..."
ruby ios/patch_dev_xcconfigs.rb

echo ""
echo "✅ iOS flavor setup complete!"
echo "   You can now run:"
echo "   flutter build ios --simulator --debug --flavor dev --dart-define=USE_MLKIT=false"
echo "   flutter build ios --release --flavor prod"
