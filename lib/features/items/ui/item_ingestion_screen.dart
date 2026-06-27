import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:track_my_stuff/core/interfaces/object_detection_interface.dart';
import 'package:track_my_stuff/features/items/ui/review_items_screen.dart';
import 'package:track_my_stuff/features/items/providers/inventory_provider.dart';
import 'package:track_my_stuff/features/items/domain/storage_container.dart';

class ItemIngestionScreen extends ConsumerStatefulWidget {
  const ItemIngestionScreen({required this.container, super.key});

  final StorageContainer container;

  @override
  ConsumerState<ItemIngestionScreen> createState() => _ItemIngestionScreenState();
}

class _ItemIngestionScreenState extends ConsumerState<ItemIngestionScreen> {
  late File? _image;
  bool _isProcessing = false;

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isProcessing = true;
      });

      try {
        final detector = ref.read(objectDetectionEngineProvider);
        final objects = await detector.detectObjects(_image!);

        if (mounted) {
          // Navigate to review screen with detected objects
          await Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (context) => ReviewItemsScreen(
                container: widget.container,
                originalImage: _image!,
                detectedObjects: objects,
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  Future<void> _mockPhotoCapture() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Load pre-loaded reference image of electronics from assets
      final data = await DefaultAssetBundle.of(context).load('assets/test.jpg');
      final bytes = data.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final mockImageFile = File('${tempDir.path}/test.jpg');
      await mockImageFile.writeAsBytes(bytes);

      setState(() {
        _image = mockImageFile;
      });

      // Use the actual object detection engine to analyze the image
      final detector = ref.read(objectDetectionEngineProvider);
      final objects = await detector.detectObjects(mockImageFile);

      if (mounted) {
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (context) => ReviewItemsScreen(
              container: widget.container,
              originalImage: mockImageFile,
              detectedObjects: objects,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Items to ${widget.container.name}'),
      ),
      body: Center(
        child: _isProcessing
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Detecting items...', style: TextStyle(color: Colors.white)),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 100, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 24),
                  const Text(
                    'Capture all items going into this box',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 32),
                  Semantics(
                    identifier: 'capture_button',
                    child: ElevatedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Capture Box Contents'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                    ),
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 16),
                    Semantics(
                      identifier: 'mock_capture_button',
                      child: ElevatedButton.icon(
                        onPressed: _mockPhotoCapture,
                        icon: const Icon(Icons.bug_report),
                        label: const Text('Mock Camera Capture'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
