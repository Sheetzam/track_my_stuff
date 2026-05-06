import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:track_my_stuff/features/items/presentation/home_screen.dart';

void main() {
  testWidgets('HomeScreen displays title and add button', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Verify title exists
    expect(find.text('TrackMyStuff'), findsOneWidget);
    
    // Verify FAB or Add button exists
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
