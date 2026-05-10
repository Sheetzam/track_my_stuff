# TODO

- [x] **#1 Rename `presentation` → `ui`:** `lib/features/items/presentation` and `test/features/items/presentation` should be `ui` to match the AGENT_RULES feature-first architecture convention.
- [x] **#2 Lazy engine initialization:** `TfliteEmbeddingEngine` and `LocalVisionEngine` are instantiated eagerly in `main.dart`. Move initialization to first use (e.g., inside their Riverpod providers).
- [ ] **#3 Real vision model:** ~~Replace with a real Moondream2 model~~ — using Google ML Kit instead (on-device, no large model download). ML Kit enabled on Android and physical iOS; iOS Simulator uses mock. `LocalVisionEngine` / Moondream2 deferred.
  - [x] iPhone connected, trusted, provisioning profile generated
  - [x] Keychain unlock automated (`~/.keychain_pass`), Rosetta installed, git identity set on Mac Mini
  - [x] `verify_ios.sh`: Phase 1 = Simulator E2E (ML Kit off), Phase 2 = Physical device build + Maestro E2E (ML Kit on)
  - [x] `verify.sh`: toggles ML Kit in pubspec around Android build
  - [ ] **NEXT: Run `./verify.sh` end-to-end to confirm full pipeline passes**
- [x] **#4 ML engine unit tests:** No tests exist for `TfliteEmbeddingEngine`, `LocalVisionEngine`, or `MlKitObjectDetector`. Write them once the implementations are complete.
- [ ] **#5 Flutter build flavors for ML Kit:** The current `verify_ios.sh` and `verify.sh` toggle `google_mlkit_object_detection` in `pubspec.yaml` via `sed` (comment/uncomment) around simulator vs device builds. This is fragile. The proper fix is to use **Flutter build flavors** (e.g., `dev` and `prod`) with separate Podfiles or conditional pod inclusion, so `flutter build ios --flavor dev` excludes ML Kit (simulator-safe) and `flutter build ios --flavor prod` includes it (device builds). This eliminates the pubspec toggling entirely.