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
4. **Human-in-the-Loop Review:** The on-device AI extracts keywords/tags for the items. The user is presented with a review screen to manually edit, add, or delete the AI's deductions to ensure accuracy before saving.
5. **Optional Context:** The user can speak or type additional context to supplement the AI tags.

### Flow 2: Finding an Item
1. **Search:** The user types or speaks a description of an item they are looking for.
2. **Retrieval:** The app matches the search against the local database of tags/descriptions.
3. **Result:** The user is shown the container's picture, its description, and the specific item record.

---

## 3. Data Architecture Strategy
- **Container Hierarchy:** While the V1 UI will present a "flat" structure (items inside containers), the underlying database schema will be engineered to support nested containers (containers inside containers) via a self-referencing `parentId` field, paving the way for V2.
- **Semantic Vector Search:** We will use **TFLite (`tflite_flutter`)** to run a lightweight, on-device embedding model (e.g., MiniLM) to convert item descriptions into vector embeddings. 
- **Local Database:** We will use **ObjectBox** as our local database due to its native support for blazing-fast, on-device vector similarity search.
- **Strict Modularity (Dependency Inversion):** To future-proof the application against the rapidly evolving AI landscape, all core technologies (TFLite, ObjectBox, ML Kit) MUST be hidden behind abstract interfaces (e.g., `IEmbeddingEngine`, `ILocalDatabase`). This ensures that swapping out TFLite or ObjectBox for a newer engine in the future requires zero changes to the application's business logic or UI.
- **On-Device Vision:** We will utilize lightweight, on-device machine learning (e.g., Google ML Kit) to draw bounding boxes and identify multiple objects in a single camera frame locally.

---

## 4. Future Features (V2)
- **Nested Containers UI:** Full support for navigating boxes inside closets.
- **Inventory Sharing:** Securely share inventory data with family members.
- **Privacy-Preserving Backups:** Encrypted cloud or local file exports.
