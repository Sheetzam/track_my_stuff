import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:track_my_stuff/core/interfaces/local_database_interface.dart';
import 'package:track_my_stuff/features/items/domain/item.dart';
import 'package:track_my_stuff/features/items/domain/storage_container.dart';
import 'package:track_my_stuff/features/items/providers/inventory_provider.dart';
import 'package:track_my_stuff/features/items/ui/container_detail_screen.dart';

import 'home_screen_test.mocks.dart';

void main() {
  late MockILocalDatabase mockDatabase;
  late StorageContainer testContainer;

  setUp(() {
    mockDatabase = MockILocalDatabase();
    testContainer = StorageContainer(
      id: 'container-1',
      name: 'Garage Shelf',
      description: 'Winter gear and tools',
      imageUrl: '',
      createdAt: DateTime(2024, 1, 1),
    );
  });

  testWidgets('displays container name and description', (tester) async {
    when(mockDatabase.getItemsInContainer('container-1'))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localDatabaseProvider.overrideWithValue(mockDatabase),
        ],
        child: MaterialApp(
          home: ContainerDetailScreen(container: testContainer),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Garage Shelf'), findsOneWidget);
    expect(find.text('Winter gear and tools'), findsOneWidget);
  });

  testWidgets('displays item count badge', (tester) async {
    final items = [
      Item(
        id: 'item-1',
        containerId: 'container-1',
        name: 'Ski Boots',
        description: 'boots, winter, skiing',
        imageUrl: '',
        createdAt: DateTime(2024, 1, 1),
      ),
      Item(
        id: 'item-2',
        containerId: 'container-1',
        name: 'Snow Gloves',
        description: 'gloves, winter',
        imageUrl: '',
        createdAt: DateTime(2024, 1, 1),
      ),
    ];

    when(mockDatabase.getItemsInContainer('container-1'))
        .thenAnswer((_) async => items);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localDatabaseProvider.overrideWithValue(mockDatabase),
        ],
        child: MaterialApp(
          home: ContainerDetailScreen(container: testContainer),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
    expect(find.text('Ski Boots'), findsOneWidget);
    expect(find.text('Snow Gloves'), findsOneWidget);
  });

  testWidgets('shows empty state when no items', (tester) async {
    when(mockDatabase.getItemsInContainer('container-1'))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localDatabaseProvider.overrideWithValue(mockDatabase),
        ],
        child: MaterialApp(
          home: ContainerDetailScreen(container: testContainer),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No items yet'), findsOneWidget);
  });

  testWidgets('has Add Items FAB', (tester) async {
    when(mockDatabase.getItemsInContainer('container-1'))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localDatabaseProvider.overrideWithValue(mockDatabase),
        ],
        child: MaterialApp(
          home: ContainerDetailScreen(container: testContainer),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add Items'), findsOneWidget);
    expect(find.byIcon(Icons.add_a_photo), findsOneWidget);
  });
}
