import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_stuff/core/interfaces/embedding_engine_interface.dart';
import 'package:track_my_stuff/core/interfaces/local_database_interface.dart';
import 'package:track_my_stuff/core/interfaces/object_detection_interface.dart';
import 'package:track_my_stuff/core/interfaces/vision_llm_interface.dart';
import 'package:track_my_stuff/features/items/domain/item.dart';
import 'package:track_my_stuff/features/items/domain/storage_container.dart';
import 'package:track_my_stuff/features/items/providers/inventory_provider.dart';
import 'package:track_my_stuff/features/items/ui/review_items_screen.dart';

class FakeLocalDatabase implements ILocalDatabase {
  final List<Item> savedItems = [];

  @override
  Future<void> init() async {}

  @override
  Future<void> saveContainer(StorageContainer container) async {}

  @override
  Future<List<StorageContainer>> getAllContainers() async => [];

  @override
  Future<StorageContainer?> getContainer(String id) async => null;

  @override
  Future<void> deleteContainer(String id) async {}

  @override
  Future<void> saveItem(Item item, {List<double>? embedding}) async {
    savedItems.add(item);
  }

  @override
  Future<List<Item>> getItemsInContainer(String containerId) async => [];

  @override
  Future<Item?> getItem(String id) async => null;

  @override
  Future<void> deleteItem(String id) async {}

  @override
  Future<List<Item>> searchItemsByVector(List<double> vectorEmbedding, {int? limit}) async => [];
}

class FakeEmbeddingEngine implements IEmbeddingEngine {
  @override
  Future<void> init() async {}

  @override
  Future<List<double>> generateEmbedding(String text) async => List<double>.filled(384, 0.1);
}

class FakeVisionEngine implements IVisionLLMEngine {
  @override
  Future<void> init() async {}

  @override
  Future<String> analyzeImage(File imageFile, {String prompt = ""}) async => 'mock_tag';

  @override
  Future<List<String>> generateTags(File imageFile) async => ['mock_tag_1', 'mock_tag_2'];
}

void main() {
  late FakeLocalDatabase fakeDb;
  late FakeEmbeddingEngine fakeEmbedding;
  late FakeVisionEngine fakeVision;
  late StorageContainer container;
  late File dummyFile;

  setUp(() {
    fakeDb = FakeLocalDatabase();
    fakeEmbedding = FakeEmbeddingEngine();
    fakeVision = FakeVisionEngine();
    container = StorageContainer(
      id: 'container_1',
      name: 'Bin 1',
      description: 'First Bin',
      imageUrl: '',
      createdAt: DateTime.now(),
    );
    dummyFile = File('dummy.png');
  });

  Widget createReviewItemsScreen() {
    return ProviderScope(
      overrides: [
        localDatabaseProvider.overrideWithValue(fakeDb),
        embeddingEngineProvider.overrideWithValue(fakeEmbedding),
        visionLLMEngineProvider.overrideWithValue(fakeVision),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => ReviewItemsScreen(
                        container: container,
                        originalImage: dummyFile,
                        detectedObjects: [
                          DetectedObject(
                            boundingBox: Rect.zero,
                            imageFile: dummyFile,
                            label: 'Detected Item',
                            confidence: 0.9,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: const Text('Go to Review'),
              ),
            );
          },
        ),
      ),
    );
  }

  testWidgets('displays review screen and shows loop options dialog on save', (WidgetTester tester) async {
    await tester.pumpWidget(createReviewItemsScreen());

    // Navigate to Review screen
    await tester.tap(find.text('Go to Review'));
    await tester.pumpAndSettle();

    // Verify it shows item card
    expect(find.text('Review Items'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Click Save All
    final saveButton = find.text('Save All');
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify item saved to DB
    expect(fakeDb.savedItems.length, 1);
    expect(fakeDb.savedItems.first.name, 'Mock_tag_1');

    // Verify dialog pops up
    expect(find.text('Items Saved!'), findsOneWidget);
    expect(find.text('Add More Items to this Box'), findsOneWidget);
    expect(find.text('Move to Another Box'), findsOneWidget);
    expect(find.text('Done Cataloging'), findsOneWidget);

    // Tap "Add More Items to this Box"
    await tester.tap(find.text('Add More Items to this Box'));
    await tester.pumpAndSettle();

    // Verify dialog and ReviewItemsScreen are popped, returning back to the base Scaffold
    expect(find.text('Items Saved!'), findsNothing);
    expect(find.text('Review Items'), findsNothing);
    expect(find.text('Go to Review'), findsOneWidget);
  });
}
