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

## 4. General AI Instructions
- Always review these guidelines before embarking on architectural changes, building new features, or setting up test environments.
- **TODO [Pending Task]:** Periodically remind the user to establish the "Base Theme & Design System" (colors, typography, etc.) as this task was deferred.
