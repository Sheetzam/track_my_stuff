# TODO

- [x] **#1 Rename `presentation` → `ui`:** `lib/features/items/presentation` and `test/features/items/presentation` should be `ui` to match the AGENT_RULES feature-first architecture convention.
- [x] **#2 Lazy engine initialization:** `TfliteEmbeddingEngine` and `LocalVisionEngine` are instantiated eagerly in `main.dart`. Move initialization to first use (e.g., inside their Riverpod providers).
- [ ] **#3 Real vision model:** `assets/models/vision_model.gguf` is a 15-byte placeholder. ~~Replace with a real Moondream2 model~~ — decided to use Google ML Kit for object detection instead (on-device, no large model download). ML Kit is now enabled on Android and physical iOS; iOS Simulator uses mock. `LocalVisionEngine` / Moondream2 deferred until a proper model download flow is designed. **NEXT: connect physical iOS device to Mac Mini and verify ML Kit works on device.**
- [x] **#4 ML engine unit tests:** No tests exist for `TfliteEmbeddingEngine`, `LocalVisionEngine`, or `MlKitObjectDetector`. Write them once the implementations are complete.
