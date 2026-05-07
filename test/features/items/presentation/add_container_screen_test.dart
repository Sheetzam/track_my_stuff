import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:track_my_stuff/features/items/presentation/add_container_screen.dart';

void main() {
  testWidgets('AddContainerScreen displays form fields and buttons', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AddContainerScreen(),
        ),
      ),
    );

    // Verify Title
    expect(find.text('New Container'), findsOneWidget);

    // Verify Form Fields
    expect(find.byType(TextField), findsNWidgets(2)); // Name and Description
    
    // Verify Save Button
    expect(find.text('Save Container'), findsOneWidget);
    
    // Verify Image Picker Card/Button
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
  });
}
