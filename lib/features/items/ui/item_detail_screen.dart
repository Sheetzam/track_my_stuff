import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_my_stuff/features/items/domain/item.dart';
import 'package:track_my_stuff/features/items/domain/storage_container.dart';
import 'package:track_my_stuff/features/items/providers/inventory_provider.dart';

/// Detail screen showing a found item and the container it lives in.
/// Navigated to from search results.
class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({required this.item, super.key});

  final Item item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          identifier: 'item_detail_title',
          child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      body: FutureBuilder<StorageContainer?>(
        future: ref.read(localDatabaseProvider).getContainer(item.containerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final container = snapshot.data;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Item image
                _buildItemImage(context),
                const SizedBox(height: 24),

                // Item info card
                _buildInfoCard(
                  context,
                  icon: Icons.label_outline,
                  title: 'Item',
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: item.description.split(', ').map((tag) {
                          return Chip(
                            label: Text(tag, style: const TextStyle(fontSize: 12)),
                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                            side: BorderSide.none,
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Container info card
                if (container != null) _buildContainerCard(context, container),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemImage(BuildContext context) {
    final file = File(item.imageUrl);
    final hasImage = item.imageUrl.isNotEmpty && file.existsSync();

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
        image: hasImage
            ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
            : null,
      ),
      child: hasImage
          ? null
          : Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      color: const Color(0xFF1E1E2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildContainerCard(BuildContext context, StorageContainer container) {
    final file = File(container.imageUrl);
    final hasImage = container.imageUrl.isNotEmpty && file.existsSync();

    return Semantics(
      identifier: 'item_detail_container_card',
      child: _buildInfoCard(
        context,
        icon: Icons.inventory_2_outlined,
        title: 'STORED IN',
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Container thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 64,
                  height: 64,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  child: hasImage
                      ? Image.file(file, fit: BoxFit.cover)
                      : Icon(
                          Icons.inventory_2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Container details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      container.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (container.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        container.description,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
