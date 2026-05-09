# TODO

- [x] **#1 Rename `presentation` → `ui`:** `lib/features/items/presentation` and `test/features/items/presentation` should be `ui` to match the AGENT_RULES feature-first architecture convention.
- [x] **#2 Lazy engine initialization:** `TfliteEmbeddingEngine` and `LocalVisionEngine` are instantiated eagerly in `main.dart`. Move initialization to first use (e.g., inside their Riverpod providers).
- [ ] **#3 Real vision model:** `assets/models/vision_model.gguf` is a 15-byte placeholder. ~~Replace with a real Moondream2 model~~ — decided to use Google ML Kit for object detection instead (on-device, no large model download). ML Kit is now enabled on Android and physical iOS; iOS Simulator uses mock. `LocalVisionEngine` / Moondream2 deferred until a proper model download flow is designed.
  - **iOS physical device setup in progress:**
    - [x] iPhone connected to Mac Mini, trusted
    - [x] Apple ID added to Xcode, personal team selected (`84H8T5TLQ2`)
    - [x] Bundle ID changed to `com.sheetzam.trackMyStuff`
    - [x] `DEVELOPMENT_TEAM` added to `project.pbxproj`
    - [x] Keychain unlock automated in `verify_ios.sh` via `~/.keychain_pass`
    - [ ] **NEXT: Open `ios/Runner.xcworkspace` in Xcode on Mac Mini → Runner target → Signing & Capabilities → hit ▶ Run once to generate provisioning profile. After that, SSH builds will work.**
- [x] **#4 ML engine unit tests:** No tests exist for `TfliteEmbeddingEngine`, `LocalVisionEngine`, or `MlKitObjectDetector`. Write them once the implementations are complete.
