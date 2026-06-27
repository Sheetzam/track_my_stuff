import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_my_stuff/core/theme/app_theme.dart';
import 'package:track_my_stuff/features/items/data/objectbox/objectbox_repository.dart';
import 'package:track_my_stuff/features/items/ui/home_screen.dart';
import 'package:track_my_stuff/features/items/providers/inventory_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final objectBoxRepo = ObjectBoxRepository();
  await objectBoxRepo.init();

  runApp(
    ProviderScope(
      overrides: [
        localDatabaseProvider.overrideWithValue(objectBoxRepo),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackMyStuff',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
