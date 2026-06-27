# TrackMyStuff - Product Requirements Document

## 1. Overview & Core Problem
Humans possess many items that are not in daily use, making it difficult to remember where they are stored. **TrackMyStuff** solves this by leveraging AI to drastically reduce the friction of cataloging items and making retrieval as simple as a semantic search.

**Core Philosophy:** Maximum privacy, minimum reliance on external cloud services. Everything should run locally on the device whenever possible.

---

## 2. User Flows & Features (V1 - MVP)

### Flow 1: Cataloging a Container & Items
1. **Container Setup:** The user identifies a storage container (e.g., a moving box, a closet shelf) via a photo and a text description.
2. **Item Ingestion:** The user takes pictures of the items going into that container. 
3. **Multi-Item Processing:** If a single photo contains multiple items, the app will process the image to identify and extract each distinct item individually.
4. **Auto-Populated Ingestion & Review:** The on-device AI automatically generates and pre-populates a descriptive name and relevant keywords/tags for each detected item. The user is presented with a review screen pre-filled with these AI deductions. User intervention/editing is optional and expected to be rare, optimizing for a low-friction, single-tap save flow.
5. **Optional Context:** The user can speak or type additional context to supplement the AI tags and names.
6. **Looping:** Steps 2 through 5 will be repeated until the user decides to move on to another box or stop putting items in boxes.

### Flow 2: Finding an Item
1. **Search:** The user types or speaks a description of an item they are looking for.
2. **Retrieval:** The app matches the search against the local database of tags/descriptions.
3. **Result:** The user is shown the container's picture, its description, and the specific item record.

---

## 3. Data & AI Architecture Strategy
- **Container Hierarchy:** While the V1 UI will present a "flat" structure (items inside containers), the underlying database schema will be engineered to support nested containers (containers inside containers) via a self-referencing `parentId` field, paving the way for V2.
- **Semantic Vector Search:** We will use native platform embedding capabilities (such as CoreML/Apple Intelligence APIs on iOS and AICore on Android) to convert item descriptions into vector embeddings.
- **Local Database:** We will use **ObjectBox** as our local database due to its native support for blazing-fast, on-device vector similarity search.
- **Strict Modularity (Dependency Inversion):** To future-proof the application against the rapidly evolving AI landscape, all core technologies (AICore, Apple Intelligence, CoreML, ObjectBox) MUST be hidden behind abstract interfaces (e.g., `IEmbeddingEngine`, `ILocalDatabase`, `IObjectDetectionEngine`, `ITagGenerator`). This ensures that swapping out specific implementations or adding new platform-specific capabilities requires zero changes to the application's business logic or UI.
- **On-Device Vision & Tagging:** We utilize platform-native capabilities for intelligent object naming and tagging:
  - **Android:** We leverage **AICore** (utilizing Gemini Nano) for local semantic tag generation, descriptive naming, and keyphrase extraction.
  - **iOS/Apple Platforms:** We leverage **Apple Intelligence** and **CoreML** APIs for native on-device visual analysis, object detection, descriptive naming, and tag/metadata generation.
  - **Platform Modularity:** Given the architectural variations between Apple Silicon simulators and physical devices, the vision system must support mock/alternative engines during development to maintain CI/CD stability.

---

## 4. Future Features (V2)
- **Nested Containers UI:** Full support for navigating boxes inside closets.
- **Inventory Sharing:** Securely share inventory data with family members.
- **Privacy-Preserving Backups:** Encrypted cloud or local file exports.
- **Cross-Platform Fallback Engines:** Implement TFLite (`tflite_flutter` with MiniLM) and Google ML Kit as fallbacks for older devices or platforms that do not support native AICore, Apple Intelligence, or CoreML.
