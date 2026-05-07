# Agentic Development Guidelines

You are assisting in the development of the **TrackMyStuff** Flutter application. You must strictly adhere to the following rules at all times:

## 1. Test-Driven Development (TDD) is Mandatory
- **ALWAYS write tests first.** Before implementing any new feature, modifying existing business logic, or building UI, you must write a failing test case.
- Once the test is written, implement the minimum code required to make the test pass.
- Do not write new code without corresponding test coverage.

## 2. Hybrid Testing Strategy (Maestro + integration_test)
We utilize a strict hybrid approach to automated testing:

- **Maestro (Black-Box E2E):** Use Maestro exclusively for overarching user journeys, core happy paths, and tests requiring native OS interactions (permissions, external apps). 
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

## 5. General AI Instructions
- Always review these guidelines before embarking on architectural changes, building new features, or setting up test environments.
- Target platforms are **Android** and **iOS**. Linux/Web/Windows desktop targets are secondary.
- Apple Developer Program membership is not yet active. iOS testing is Simulator-only until further notice.
