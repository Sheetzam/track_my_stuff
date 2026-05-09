import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:track_my_stuff/core/interfaces/local_database_interface.dart';
import 'package:track_my_stuff/features/items/ui/home_screen.dart';
import 'package:track_my_stuff/features/items/providers/inventory_provider.dart';

import 'home_screen_test.mocks.dart';

@GenerateMocks([ILocalDatabase])
void main() {
  late MockILocalDatabase mockDatabase;

  setUp(() {
    mockDatabase = MockILocalDatabase();
    when(mockDatabase.getAllContainers()).thenAnswer((_) async => []);
  });

  testWidgets('HomeScreen displays title and add button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localDatabaseProvider.overrideWithValue(mockDatabase),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Initial pump to show loading or empty state
    await tester.pump();

    // Verify title exists
    expect(find.text('TrackMyStuff'), findsOneWidget);
    
    // Verify FAB or Add button exists
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
