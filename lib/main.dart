import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_my_stuff/core/theme/app_theme.dart';
import 'package:track_my_stuff/features/items/data/ml/local_vision_engine.dart';
import 'package:track_my_stuff/features/items/data/ml/ml_kit_object_detector.dart';
import 'package:track_my_stuff/features/items/data/ml/tflite_embedding_engine.dart';
import 'package:track_my_stuff/features/items/data/objectbox/objectbox_repository.dart';
import 'package:track_my_stuff/features/items/presentation/home_screen.dart';
import 'package:track_my_stuff/features/items/providers/inventory_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the repositories/engines
  final objectBoxRepo = ObjectBoxRepository();
  await objectBoxRepo.init();

  final embeddingEngine = TfliteEmbeddingEngine();
  // We'll init the engines lazily in the providers or on first use to save startup time
  
  final objectDetector = MlKitObjectDetector();
  final visionLLM = LocalVisionEngine();

  runApp(
    ProviderScope(
      overrides: [
        localDatabaseProvider.overrideWithValue(objectBoxRepo),
        embeddingEngineProvider.overrideWithValue(embeddingEngine),
        objectDetectionEngineProvider.overrideWithValue(objectDetector),
        visionLLMEngineProvider.overrideWithValue(visionLLM),
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
