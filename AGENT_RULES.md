# Agentic Development Guidelines

You are assisting in the development of the **TrackMyStuff** Flutter application. You must strictly adhere to the following rules at all times:

## 1. Test-Driven Development (TDD) is Mandatory
- **ALWAYS write tests first.** Before implementing any new feature, modifying existing business logic, or building UI, you must write a failing test case.
- Once the test is written, implement the minimum code required to make the test pass.
- Do not write new code without corresponding test coverage.
- As you iterate on code, update tests and test coverage to reflect changes. If a test fails, fix the test or fix the code.

## 2. Hybrid Testing Strategy (Maestro + integration_test)
We utilize a strict hybrid approach to automated testing:

- **Maestro (Black-Box E2E):** Use Maestro for overarching user journeys, core happy paths, and tests requiring native OS interactions (permissions, external apps). 
  - Maestro test flows should be written in YAML and placed in the `.maestro/` directory.
  - When creating interactive Flutter UI components, you MUST wrap them in a `Semantics` widget and assign a unique `identifier` (e.g., `Semantics(identifier: 'login_submit_button', child: ...)`). 
  - Use these semantic identifiers in your Maestro YAML files (`tapOn:\n    id: "login_submit_button"`).
- **`integration_test` (White-Box Validation):** Use Flutter's built-in `integration_test` package ONLY for complex, state-heavy component testing where you explicitly need to verify internal data models or application state during execution.

## 3. State Management & Architecture
- **Riverpod (Code Gen):** Use Riverpod 2.x with `riverpod_generator` and `riverpod_annotation` for all state management.
- Do NOT use legacy `StateNotifier` or `ChangeNotifier`. Always use `@riverpod` annotations and run `build_runner`.
- **Feature-First Architecture:** The codebase is organized into `lib/core` (app-wide configs, routing, theme), `lib/features` (business logic divided by feature), and `lib/shared` (reusable UI widgets).
  - Inside each feature folder (e.g., `lib/features/inventory/`), adhere to a strict separation of concerns using subfolders: `/data`, `/domain`, `/providers`, and `/ui`.

## 4. Dual-Machine Development Environment
We use two machines. The **Ubuntu workstation** is the primary development machine. The **Mac Mini** (8GB RAM, macOS 26.4.1) is used exclusively for tasks that require macOS (iOS builds, iOS Simulator, Xcode).

### Platform Responsibilities
| Task | Machine |
|---|---|
| Code editing, unit tests, `build_runner` | Ubuntu |
| Android emulator + Maestro E2E | Ubuntu |
| Linux desktop builds | Ubuntu |
| Web builds (Chrome) | Ubuntu |
| iOS Simulator + Maestro E2E | Mac Mini (via SSH) |
| iOS device builds & code signing | Mac Mini (via SSH) |
| Xcode project configuration | Mac Mini (via SSH) |

### Code Sync Workflow
Two git remotes are configured on the Ubuntu machine:
- **`origin`** → GitHub (`github.com/Sheetzam/track_my_stuff`). Push here **only** when code is passing tests.
- **`macdev`** → Mac Mini via SSH (`macdev.local:~/dev/track_my_stuff`). Push here for WIP iOS builds and testing.

Workflow:
1. Develop and commit on **Ubuntu**.
2. `git push macdev <branch>` to sync WIP code to the Mac for iOS builds/tests.
3. `git push origin <branch>` only when code passes all tests (unit + E2E).
4. Any Mac-side fixes should be committed and pushed from the Mac, then pulled on Ubuntu.

### Remote Mac Access
- SSH hostname: `macdev.local` (user: `sheetzam`).
- Access via SSH (e.g., `ssh macdev.local 'cd ~/dev/track_my_stuff && flutter build ios --simulator'`).
- The AI agent can execute commands on the Mac via SSH and observe output.

### Resource Constraints
- **Mac Mini (8GB RAM):** NEVER run commands that compile multiple heavy targets concurrently (e.g., `flutter run -d all`). This will cause OOM crashes. Always compile or run ONE target at a time.
- **Ubuntu:** No special constraints, but prefer sequential builds when possible.

## 5. iOS & ML Kit Limitations (IMPORTANT)
The project currently faces specific architectural limitations regarding Google ML Kit and iOS Simulators:

- **ML Kit Architecture Conflict:** Google ML Kit (specifically `MLImage`) does NOT provide an `arm64-simulator` slice. It only provides `x86_64` for simulators.
- **iOS 26+ Requirement:** On Apple Silicon Mac runners (M1/M2/M3), iOS 26+ simulators strictly require `arm64` binaries. They do not reliably support `x86_64` (Rosetta) for Flutter apps using native assets.
- **Native Assets (objective_c):** Modern Flutter dependencies (like `path_provider` via `objective_c`) use the **Native Assets** feature. Excluding `arm64` in the `Podfile` to fix ML Kit often breaks the Native Assets build hook, leading to `references objective_c, which was not found` errors.
- **Current Strategy (Build Flavors):**
  - `google_mlkit_object_detection` is permanently in `pubspec.yaml` but **commented out by `verify_ios.sh`** before iOS Simulator builds, then restored before device builds.
  - Two entry points: `main.dart` (imports real `MlKitObjectDetector`, used for prod/device builds) and `main_dev.dart` (no ML Kit import, used for simulator builds with `-t lib/main_dev.dart`).
  - The `objectDetectionEngineProvider` defaults to `MockObjectDetector`. `main.dart` overrides it with the real `MlKitObjectDetector`.
  - Android uses `--flavor prod` (ML Kit always works). iOS Simulator uses `--flavor dev` + `--dart-define=USE_MLKIT=false`.
  - **NEVER** exclude `arm64` in the `Podfile` globally, as it breaks the `objective_c` dependency required for app-wide file path resolution.
- **iOS Flavor Setup (one-time per clone on Mac Mini):**
  ```bash
  cd ios && bash setup_flavors.sh
  ```
  This runs `add_flavor_configs.rb`, `pod install`, and `fix_flavor_xcconfigs.rb`.

## 6. Physical iOS Device Testing (maestro-runner)
- The physical test device is an **iPhone 6s running iOS 15.8.7**. Maestro CLI requires iOS 16+, so we use **`maestro-runner`** (by DeviceLab) for physical device E2E.
- `maestro-runner` supports iOS 12+ and runs the same Maestro YAML flows with zero changes.
- It uses **WebDriverAgent (WDA)** for iOS automation, which requires code signing.
- **Free Apple Developer Account Limitation:** The WDA provisioning profile expires every **7 days**. When it expires, `maestro-runner` will fail with a signing/provisioning error. To fix:
  1. SSH into the Mac Mini (or Screen Share).
  2. Run: `maestro-runner wda update` (or just re-run the test — it rebuilds WDA automatically).
  3. If Xcode complains about provisioning, open Xcode GUI and re-trust the profile, or delete `~/.maestro-runner/cache/wda-builds/` and retry.
- **Required Xcode setup (one-time):** The Apple ID (`sheetzam@earthlink.net`) must be added to Xcode → Settings → Accounts. This was done manually via Screen Sharing.
- **Usage:**
  ```bash
  maestro-runner --platform ios \
    --device c436e44ff43f1f713f842da9f106d5ae8658efb0 \
    --team-id 84H8T5TLQ2 \
    -e APP_ID=com.example.trackMyStuff \
    test .maestro/
  ```

## 7. General AI Instructions
- Always review these guidelines before embarking on architectural changes, building new features, or setting up test environments.
- **TODO.md:** The file `TODO.md` at the repo root is the source of truth for outstanding work. Keep it up to date: check off items as they are completed, and add new items when new issues or tasks are identified.
- Target platforms are **Android** and **iOS**. Linux/Web/Windows desktop targets are secondary.
- Apple Developer Program membership is **free tier** (not paid). Provisioning profiles expire every 7 days. See Section 6 for details.
- **Verification:** Always run `./verify.sh` to trigger the cross-platform test suite (Local Unit Tests + Mac Mini iOS E2E).
