# TODO

- [x] **#1 Rename `presentation` → `ui`:** `lib/features/items/presentation` and `test/features/items/presentation` should be `ui` to match the AGENT_RULES feature-first architecture convention.
- [x] **#2 Lazy engine initialization:** `TfliteEmbeddingEngine` and `LocalVisionEngine` are instantiated eagerly in `main.dart`. Move initialization to first use (e.g., inside their Riverpod providers).
- [x] **#3 Real vision model:** ~~Replace with a real Moondream2 model~~ — using Google ML Kit instead (on-device, no large model download). ML Kit enabled on Android and physical iOS; iOS Simulator uses mock. `LocalVisionEngine` / Moondream2 deferred.
  - [x] iPhone connected, trusted, provisioning profile generated
  - [x] Keychain unlock automated (`~/.keychain_pass`), Rosetta installed, git identity set on Mac Mini
  - [x] `verify_ios.sh` and `verify.sh` now use `--flavor` (see #5)
  - [x] **Full `./verify.sh` end-to-end (Android E2E + iOS E2E via Mac Mini) ✅**
- [x] **#4 ML engine unit tests:** No tests exist for `TfliteEmbeddingEngine`, `LocalVisionEngine`, or `MlKitObjectDetector`. Write them once the implementations are complete.
- [x] **#5 Flutter build flavors for ML Kit:** Replaces fragile `sed` pubspec toggling.
  - [x] `pubspec.yaml`: `google_mlkit_object_detection` permanently enabled (no more commenting)
  - [x] `android/app/build.gradle.kts`: added `dev` and `prod` flavors (dimension: `mlkit`)
  - [x] `ios/Podfile`: build configurations mapped to flavor names (`Debug-dev`, `Release-prod`, etc.)
  - [x] `ios/Runner.xcodeproj/xcshareddata/xcschemes/dev.xcscheme` + `prod.xcscheme` created
  - [x] `ios/add_flavor_configs.rb` + `fix_flavor_xcconfigs.rb` + `patch_dev_xcconfigs.rb`: Xcode project setup scripts
  - [x] `verify.sh`: uses `--flavor prod` for Android build (no more `sed`)
  - [x] `verify_ios.sh`: uses `--flavor dev` + `--dart-define=USE_MLKIT=false` for simulator, `--flavor prod` for device
  - [x] `MockObjectDetector` split out; provider selects via `USE_MLKIT` dart-define
  - [x] Android `flutter build apk --debug --flavor prod` ✅
  - [x] Android `flutter build apk --debug --flavor dev` ✅
  - [x] iOS `flutter build ios --simulator --debug --flavor dev` ✅
  - [x] Unit tests pass (15/15) ✅
  - [x] Maestro E2E: Android emulator ✅, iOS Simulator ✅
- [ ] **#6 Physical device Maestro E2E — iOS (BLOCKED):** `maestro-runner` installed, WDA builds and signs correctly, but **Xcode 26.4 has a regression** that prevents XCTest from running on physical devices with iOS < 26.3. Our iPhone 6s (iOS 15.8.7) is affected. Android physical device E2E works (Pixel 10 Pro Fold, 4/4 flows pass).
  - Options: (a) upgrade iPhone to one running iOS 26.x, (b) downgrade Xcode to 26.2, (c) wait for Apple fix
  - Tracking: https://developer.apple.com/forums/thread/820586
- [x] **#7 Wire up embedding generation on item save:** `Inventory.addItem()` now generates a 384-dim embedding from `name + description` via `TfliteEmbeddingEngine` before saving to ObjectBox's HNSW index.
- [x] **#8 Search result navigation:** `ItemDetailScreen` shows the matched item (image, name, tags) and its parent container (photo, name, description). Tapping a search result navigates there.
- [x] **#9 Container detail/browse screen:** `ContainerDetailScreen` shows container photo, description, item count badge, and a list of all items. Tapping an item goes to `ItemDetailScreen`. FAB to add more items.
- [x] **#10 Proper tokenizer for TFLite embeddings:** Implemented `WordPieceTokenizer` with full BERT-compatible algorithm + 30,522-token vocabulary from all-MiniLM-L6-v2.

## Repository Maintenance Completed
- [x] **Large model file cleanup:** Removed 868MB `vision_mmproj.gguf` from git history, added to `.gitignore`, created placeholder file. Repository now pushes successfully to GitHub.
- [x] **Core testing coverage & bug fix:** Wrote entity round-trip tests to fix vector-dropping bug in `ObxItem.toDomain()`. Added `InventoryProvider` unit tests for `addContainer`, `getItemsForContainer`, and `searchItems`. Added widget tests for `SearchScreen`.
- [x] **Accessibility & E2E Testing Improvements:** Added missing `Semantics` identifiers to `HomeScreen`, `ContainerDetailScreen`, `SearchScreen`, `ItemIngestionScreen`, and `ReviewItemsScreen`. Created E2E test flows for container details and full round-trip item ingestion using a programmatic mock camera capture button in debug mode.

## Next Priorities
- [ ] **#13 Multi-capture item ingestion (PRD Flow 1 Step 6):** Refactor the item ingestion flow to repeat steps 2 through 5 (capturing photos, object detection/extraction, tag review, and adding optional context) in a loop. Provide options for the user to:
  - Repeat the process for another item/photo in the same container.
  - Move on to another container/box.
  - Stop adding items and return to the home screen.
- [ ] **#19 Android Native AI (AICore) Integration:**
  - [ ] Research and integrate Google AI Edge / Google Play Services AICore API for Flutter.
  - [ ] Implement `AndroidAicoreEmbeddingEngine` implementing `IEmbeddingEngine` using on-device AICore.
  - [ ] Implement `AndroidAicoreTagGenerator` implementing `ITagGenerator` (utilizing Gemini Nano on-device).
  - [ ] Swap out TFLite and Moondream/ML Kit dependencies for the new AICore engine in V1 Android builds.
- [ ] **#20 iOS Native AI (Apple Intelligence & CoreML) Integration:**
  - [ ] Write Swift native platform channel implementation for Apple Intelligence APIs and CoreML.
  - [ ] Implement `AppleIntelligenceEmbeddingEngine` implementing `IEmbeddingEngine`.
  - [ ] Implement `AppleIntelligenceVisionEngine` implementing `ITagGenerator` (utilizing Apple Intelligence and CoreML for native object detection and tag generation).
  - [ ] Swap out ML Kit/TFLite dependencies for the new native iOS Apple Intelligence/CoreML engine in V1 iOS builds.
- [ ] **#21 Clean up & Remove unneeded V1 assets, models, and code:**
  - [ ] Delete now unneeded model files (e.g., MiniLM model/vocab assets, Moondream2 model placeholders/assets).
  - [ ] Remove TFLite/ML Kit-specific dart implementations (like `TfliteEmbeddingEngine`, `WordPieceTokenizer`, `LocalVisionEngine`).
  - [ ] Clean up `pubspec.yaml` (remove `google_mlkit_object_detection`, `tflite_flutter`, etc. from V1 active dependencies).
  - [ ] Clean up build configuration files (e.g., android build.gradle, ios Podfile/configurations, setup/patch scripts).
- [ ] **#22 Write unit tests and E2E tests for new native implementations:**
  - [ ] Write unit tests for `AndroidAicoreEmbeddingEngine` and `AndroidAicoreTagGenerator` (using platform channel mocks).
  - [ ] Write unit tests for `AppleIntelligenceEmbeddingEngine` and `AppleIntelligenceVisionEngine` (using platform channel mocks).
  - [ ] Update existing integration/widget/E2E tests to verify behavior with native engines and mock/dev modes.

## Future / V2 Priorities
- [ ] **#14 Enhanced search functionality:** Improve search result ranking, add filters (by container, date, tags), implement search history.
- [ ] **#15 Bulk operations:** Add ability to move multiple items between containers, bulk tagging, batch delete.
- [ ] **#16 Data export/import:** JSON export for backup, CSV export for spreadsheet analysis, import from other inventory apps.
- [ ] **#17 Performance optimization:** Lazy loading for large inventories, image caching improvements, database query optimization.
- [ ] **#18 UI/UX improvements:** Dark mode, accessibility enhancements, better onboarding flow, tutorial screens.
- [ ] **#23 Cross-Platform Fallback Engines (V2):** Re-introduce TFLite (`tflite_flutter` with MiniLM) and Google ML Kit as fallbacks for older devices or platforms lacking native AICore / Apple Intelligence support.

