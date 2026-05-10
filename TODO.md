# TODO

- [x] **#1 Rename `presentation` → `ui`:** `lib/features/items/presentation` and `test/features/items/presentation` should be `ui` to match the AGENT_RULES feature-first architecture convention.
- [x] **#2 Lazy engine initialization:** `TfliteEmbeddingEngine` and `LocalVisionEngine` are instantiated eagerly in `main.dart`. Move initialization to first use (e.g., inside their Riverpod providers).
- [ ] **#3 Real vision model:** ~~Replace with a real Moondream2 model~~ — using Google ML Kit instead (on-device, no large model download). ML Kit enabled on Android and physical iOS; iOS Simulator uses mock. `LocalVisionEngine` / Moondream2 deferred.
  - [x] iPhone connected, trusted, provisioning profile generated
  - [x] Keychain unlock automated (`~/.keychain_pass`), Rosetta installed, git identity set on Mac Mini
  - [x] `verify_ios.sh` and `verify.sh` now use `--flavor` (see #5)
  - [ ] **NEXT: Run `./verify.sh --local` to confirm Android flavor build passes, then full `./verify.sh` for iOS**
- [x] **#4 ML engine unit tests:** No tests exist for `TfliteEmbeddingEngine`, `LocalVisionEngine`, or `MlKitObjectDetector`. Write them once the implementations are complete.
- [ ] **#5 Flutter build flavors for ML Kit:** Replaces fragile `sed` pubspec toggling.
  - [x] `pubspec.yaml`: `google_mlkit_object_detection` permanently enabled (no more commenting)
  - [x] `android/app/build.gradle.kts`: added `dev` and `prod` flavors (dimension: `mlkit`)
  - [x] `ios/Podfile`: build configurations mapped to flavor names (`Debug-dev`, `Release-prod`, etc.)
  - [x] `ios/Runner.xcodeproj/xcshareddata/xcschemes/dev.xcscheme` + `prod.xcscheme` created
  - [x] `verify.sh`: uses `--flavor prod` for Android build (no more `sed`)
  - [x] `verify_ios.sh`: uses `--flavor dev` for simulator, `--flavor prod` for physical device (no more `sed`)
  - [ ] **NEXT: Test that `flutter build apk --debug --flavor prod` works on Ubuntu, then test iOS flavors on Mac Mini**

