# TrackMyStuff 📦

A Flutter-based application for tracking items using on-device ML and vision.

## 🛠 Architecture & Development

This project uses a **Dual-Machine Development Workflow**:
- **Primary Workstation (Ubuntu):** Development, Unit Tests, Android Emulator.
- **Build Agent (Mac Mini):** iOS Builds, iOS Simulator, Maestro E2E for iOS.

### Local Setup
1.  **Dependencies:** Ensure Flutter 3.11.x+ and Maestro are installed.
2.  **Mac Sync:** Code is synced to the Mac Mini via a git remote named `macdev`.
    ```bash
    git push macdev main
    ```

### Verification Pipeline
To run the full verification suite (Unit tests + iOS E2E):
```bash
./verify.sh
```

## 🧠 ML Features & Limitations

The app uses `llama_cpp_dart` for local vision processing and Google ML Kit for object detection.

### iOS Simulator Caveat
Due to architecture limitations in the Google ML Kit binary (lack of `arm64-simulator` slice) and the requirements of iOS 26+ simulators on Apple Silicon:
- **ML Kit is mocked on the iOS Simulator.**
- Real object detection is currently only supported on **Android** and **Physical iOS Devices**.
- The `google_mlkit_object_detection` package is commented out in `pubspec.yaml` to allow simulator builds to succeed.

## 🧪 Testing Strategy
- **Unit Tests:** Mandatory TDD for all business logic.
- **E2E Tests:** Maestro-based flows in `.maestro/`.
- **UI Semantics:** Use `Semantics(identifier: '...')` for reliable Maestro interaction.

---
*Created by the Advanced Agentic Coding team at Google Deepmind.*
