import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:track_my_stuff/core/interfaces/local_database_interface.dart';
import 'package:track_my_stuff/features/items/domain/item.dart';
import 'package:track_my_stuff/features/items/domain/storage_container.dart';
import 'package:track_my_stuff/features/items/providers/inventory_provider.dart';
import 'package:track_my_stuff/features/items/ui/item_detail_screen.dart';

import 'home_screen_test.mocks.dart';

void main() {
  late MockILocalDatabase mockDatabase;
  late Item testItem;
  late StorageContainer testContainer;

  setUp(() {
    mockDatabase = MockILocalDatabase();
    testItem = Item(
      id: 'item-1',
      containerId: 'container-1',
      name: 'Ski Boots',
      description: 'boots, winter, skiing',
      imageUrl: '',
      createdAt: DateTime(2024, 1, 1),
    );
    testContainer = StorageContainer(
      id: 'container-1',
      name: 'Garage Shelf',
      description: 'Winter gear and tools',
      imageUrl: '',
      createdAt: DateTime(2024, 1, 1),
    );
  });

  testWidgets('displays item name', (tester) async {
    when(mockDatabase.getContainer('container-1'))
        .thenAnswer((_) async => testContainer);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localDatabaseProvider.overrideWithValue(mockDatabase),
        ],
        child: MaterialApp(
          home: ItemDetailScreen(item: testItem),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ski Boots'), findsWidgets);
  });

  testWidgets('displays item tags as chips', (tester) async {
    when(mockDatabase.getContainer('container-1'))
        .thenAnswer((_) async => testContainer);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localDatabaseProvider.overrideWithValue(mockDatabase),
        ],
        child: MaterialApp(
          home: ItemDetailScreen(item: testItem),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('boots'), findsOneWidget);
    expect(find.text('winter'), findsOneWidget);
    expect(find.text('skiing'), findsOneWidget);
  });

  testWidgets('displays parent container info', (tester) async {
    when(mockDatabase.getContainer('container-1'))
        .thenAnswer((_) async => testContainer);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localDatabaseProvider.overrideWithValue(mockDatabase),
        ],
        child: MaterialApp(
          home: ItemDetailScreen(item: testItem),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Garage Shelf'), findsOneWidget);
    expect(find.text('Winter gear and tools'), findsOneWidget);
  });

  testWidgets('handles missing container gracefully', (tester) async {
    when(mockDatabase.getContainer('container-1'))
        .thenAnswer((_) async => null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localDatabaseProvider.overrideWithValue(mockDatabase),
        ],
        child: MaterialApp(
          home: ItemDetailScreen(item: testItem),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Item name should still show even without container
    expect(find.text('Ski Boots'), findsWidgets);
    // Container section should not appear
    expect(find.text('STORED IN'), findsNothing);
  });
}
