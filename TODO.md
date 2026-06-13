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
- [x] **#11 Fix vision model assets & E2E test:** Downloaded matched Moondream2 GGUF pair from HuggingFace. Quantized text model from f16 (2.7GB) to Q4_K_M (877MB) via `llama-quantize`. Emulator AVD bumped to 8GB RAM / 1GB heap / 12GB data partition. `LocalVisionEngine` hardened with placeholder detection and graceful error handling in `generateTags()`. All 4 Maestro E2E flows pass on Android emulator and physical device (Pixel 10 Pro Fold, Android 16).
- [x] **#12 Maestro test isolation:** Added `clearState` to all Maestro flows so they can run together (`maestro test .maestro/`) without interfering. All 4 flows pass in a single batch run.
- [ ] **#13 Multi-capture item ingestion:** Currently the flow is: take one photo → review detected items → save → back to home. Instead, after saving reviewed items, return to the camera/capture screen so the user can take multiple photos in a row. Add a "Done" button to explicitly return to home when finished adding items to a container.
- [ ] **#14 Enhanced search functionality:** Improve search result ranking, add filters (by container, date, tags), implement search history.
- [ ] **#15 Bulk operations:** Add ability to move multiple items between containers, bulk tagging, batch delete.
- [ ] **#16 Data export/import:** JSON export for backup, CSV export for spreadsheet analysis, import from other inventory apps.
- [ ] **#17 Performance optimization:** Lazy loading for large inventories, image caching improvements, database query optimization.
- [ ] **#18 UI/UX improvements:** Dark mode, accessibility enhancements, better onboarding flow, tutorial screens.

