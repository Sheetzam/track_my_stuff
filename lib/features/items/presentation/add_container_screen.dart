import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:track_my_stuff/features/items/domain/storage_container.dart';
import 'package:track_my_stuff/features/items/providers/inventory_provider.dart';
import 'package:uuid/uuid.dart';

class AddContainerScreen extends ConsumerStatefulWidget {
  const AddContainerScreen({super.key});

  @override
  ConsumerState<AddContainerScreen> createState() => _AddContainerScreenState();
}

class _AddContainerScreenState extends ConsumerState<AddContainerScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  File? _selectedImage;
  bool _isSaving = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    
    // Show a beautiful bottom sheet to choose source
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF6C63FF)),
                title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF6C63FF)),
                title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      try {
        final pickedFile = await picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
        
        if (pickedFile != null) {
          setState(() {
            _selectedImage = File(pickedFile.path);
          });
        }
      } on Exception catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _saveContainer() async {
    if (_nameController.text.isEmpty) return;

    setState(() => _isSaving = true);

    final container = StorageContainer(
      id: const Uuid().v4(),
      name: _nameController.text,
      description: _descController.text,
      imageUrl: _selectedImage?.path ?? '', // In a real app we'd copy this to app docs directory
      createdAt: DateTime.now(),
    );

    await ref.read(inventoryProvider.notifier).addContainer(container);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Container', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Massive glowing photo card
            Semantics(
              identifier: 'image_picker_button',
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 48, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(height: 12),
                            Text(
                              'Tap to take a photo',
                              style: TextStyle(color: Theme.of(context).colorScheme.primary),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Semantics(
              identifier: 'container_name_input',
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Container Name',
                  hintText: 'e.g., Garage Top Shelf',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              identifier: 'container_description_input',
              child: TextField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'What goes in here?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Semantics(
              identifier: 'save_container_button',
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveContainer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Container', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
