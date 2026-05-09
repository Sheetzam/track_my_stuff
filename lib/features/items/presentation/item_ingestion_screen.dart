import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:track_my_stuff/features/items/presentation/review_items_screen.dart';
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
                  ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Capture Box Contents'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
