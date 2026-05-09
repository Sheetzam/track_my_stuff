import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_my_stuff/core/interfaces/object_detection_interface.dart';
import 'package:track_my_stuff/features/items/domain/item.dart';
import 'package:track_my_stuff/features/items/domain/storage_container.dart';
import 'package:track_my_stuff/features/items/providers/inventory_provider.dart';
import 'package:uuid/uuid.dart';

class ReviewItemsScreen extends ConsumerStatefulWidget {
  const ReviewItemsScreen({
    required this.container,
    required this.originalImage,
    required this.detectedObjects,
    super.key,
  });

  final StorageContainer container;
  final File originalImage;
  final List<DetectedObject> detectedObjects;

  @override
  ConsumerState<ReviewItemsScreen> createState() => _ReviewItemsScreenState();
}

class _ReviewItemsScreenState extends ConsumerState<ReviewItemsScreen> {
  final Map<int, TextEditingController> _nameControllers = {};
  final Map<int, List<String>> _suggestedTags = {};
  bool _isAnalyzing = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _analyzeAllObjects();
  }

  Future<void> _analyzeAllObjects() async {
    final vision = ref.read(visionLLMEngineProvider);
    
    for (int i = 0; i < widget.detectedObjects.length; i++) {
      _nameControllers[i] = TextEditingController(text: widget.detectedObjects[i].label ?? 'Item ${i + 1}');
      
      // Run vision analysis in background
      unawaited(vision.generateTags(widget.detectedObjects[i].imageFile).then((tags) {
        if (mounted) {
          setState(() {
            _suggestedTags[i] = tags;
          });
        }
      }));
    }

    setState(() => _isAnalyzing = false);
  }

  Future<void> _saveAllItems() async {
    setState(() => _isSaving = true);

    try {
      final inventory = ref.read(inventoryProvider.notifier);
      
      for (var i = 0; i < widget.detectedObjects.length; i++) {
        final item = Item(
          id: const Uuid().v4(),
          containerId: widget.container.id,
          name: _nameControllers[i]!.text,
          description: _suggestedTags[i]?.join(', ') ?? '',
          imageUrl: widget.detectedObjects[i].imageFile.path,
          createdAt: DateTime.now(),
        );
        
        await inventory.addItem(item);
      }

      if (mounted) {
        // Go back to home screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Items'),
        actions: [
          if (!_isAnalyzing)
            TextButton(
              onPressed: _isSaving ? null : _saveAllItems,
              child: _isSaving 
                ? const CircularProgressIndicator() 
                : const Text('Save All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: widget.detectedObjects.isEmpty
          ? const Center(child: Text('No items detected.', style: TextStyle(color: Colors.white)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.detectedObjects.length,
              itemBuilder: (context, index) {
                final obj = widget.detectedObjects[index];
                return Card(
                  color: const Color(0xFF1E1E2C),
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(obj.imageFile, width: 100, height: 100, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _nameControllers[index],
                                decoration: const InputDecoration(
                                  labelText: 'Item Name',
                                  isDense: true,
                                ),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              const Text('Suggested Tags:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                children: (_suggestedTags[index] ?? ['Analyzing...']).map((tag) => Chip(
                                  label: Text(tag, style: const TextStyle(fontSize: 10)),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                )).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
