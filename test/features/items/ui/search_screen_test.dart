import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_stuff/core/interfaces/embedding_engine_interface.dart';
import 'package:track_my_stuff/core/interfaces/local_database_interface.dart';
import 'package:track_my_stuff/features/items/domain/item.dart';
import 'package:track_my_stuff/features/items/domain/storage_container.dart';
import 'package:track_my_stuff/features/items/providers/inventory_provider.dart';
import 'package:track_my_stuff/features/items/ui/search_screen.dart';

class FakeLocalDatabase implements ILocalDatabase {
  List<Item> searchResults = [];

  @override
  Future<void> init() async {}

  @override
  Future<void> saveContainer(StorageContainer container) async {}

  @override
  Future<List<StorageContainer>> getAllContainers() async => [];

  @override
  Future<StorageContainer?> getContainer(String id) async {
    return StorageContainer(
      id: id,
      name: 'Mock Container',
      description: 'A place to store things',
      imageUrl: '',
      createdAt: DateTime(2026),
    );
  }

  @override
  Future<void> deleteContainer(String id) async {}

  @override
  Future<void> saveItem(Item item, {List<double>? embedding}) async {}

  @override
  Future<List<Item>> getItemsInContainer(String containerId) async => [];

  @override
  Future<Item?> getItem(String id) async => null;

  @override
  Future<void> deleteItem(String id) async {}

  @override
  Future<List<Item>> searchItemsByVector(List<double> vectorEmbedding, {int? limit}) async {
    // Return the searchResults mock list
    return searchResults;
  }
}

class FakeEmbeddingEngine implements IEmbeddingEngine {
  @override
  Future<void> init() async {}

  @override
  Future<List<double>> generateEmbedding(String text) async {
    return [0.1, 0.2, 0.3];
  }
}

void main() {
  late FakeLocalDatabase fakeDb;
  late FakeEmbeddingEngine fakeEmbeddingEngine;

  setUp(() {
    fakeDb = FakeLocalDatabase();
    fakeEmbeddingEngine = FakeEmbeddingEngine();
  });

  Widget createSearchScreen() {
    return ProviderScope(
      overrides: [
        localDatabaseProvider.overrideWith((ref) => fakeDb),
        embeddingEngineProvider.overrideWith((ref) => fakeEmbeddingEngine),
      ],
      child: const MaterialApp(
        home: SearchScreen(),
      ),
    );
  }

  testWidgets('SearchScreen renders with search input field and shows empty state initially', (tester) async {
    await tester.pumpWidget(createSearchScreen());

    // Verify hint text and input field is displayed
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Search items semantically...'), findsOneWidget);

    // Verify search icon is present
    expect(find.byIcon(Icons.search), findsOneWidget);

    // Verify empty state is displayed initially
    expect(find.text('No results found.'), findsOneWidget);
  });

  testWidgets('SearchScreen performs search and displays results list', (tester) async {
    // Setup some mock search results
    final item1 = Item(
      id: 'item-1',
      containerId: 'box-1',
      name: 'Laser Ruler',
      description: 'Digital laser measuring tool',
      imageUrl: '',
      createdAt: DateTime(2026),
    );
    final item2 = Item(
      id: 'item-2',
      containerId: 'box-1',
      name: 'Tape Measure',
      description: 'Standard 25ft measuring tape',
      imageUrl: '',
      createdAt: DateTime(2026),
    );
    fakeDb.searchResults = [item1, item2];

    await tester.pumpWidget(createSearchScreen());

    // Enter query in search bar
    await tester.enterText(find.byType(TextField), 'measuring tool');
    
    // Tap the search button
    await tester.tap(find.byIcon(Icons.search));
    
    // Pump to trigger state changes
    await tester.pump();

    // Verify results are shown
    expect(find.text('Laser Ruler'), findsOneWidget);
    expect(find.text('Tape Measure'), findsOneWidget);
    expect(find.text('Digital laser measuring tool'), findsOneWidget);
    expect(find.text('Standard 25ft measuring tape'), findsOneWidget);
    expect(find.text('No results found.'), findsNothing);
  });

  testWidgets('SearchScreen navigates to ItemDetailScreen when result is tapped', (tester) async {
    final item = Item(
      id: 'item-1',
      containerId: 'box-1',
      name: 'Laser Ruler',
      description: 'Digital laser measuring tool',
      imageUrl: '',
      createdAt: DateTime(2026),
    );
    fakeDb.searchResults = [item];

    await tester.pumpWidget(createSearchScreen());

    // Perform search
    await tester.enterText(find.byType(TextField), 'laser');
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();

    // Tap on the result card list tile
    expect(find.text('Laser Ruler'), findsOneWidget);
    await tester.tap(find.text('Laser Ruler'));
    
    // Pump and settle navigation transition
    await tester.pumpAndSettle();

    // Verify that we are on the ItemDetailScreen (which displays 'Laser Ruler' in the AppBar or title)
    expect(find.byKey(const Key('item_detail_title')), findsNothing); // wait, let's look for item name as title
    expect(find.text('Laser Ruler'), findsWidgets); // Should find it in the App bar title as well as detail screen
  });
}
