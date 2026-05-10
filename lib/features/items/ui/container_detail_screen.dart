import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_my_stuff/features/items/domain/item.dart';
import 'package:track_my_stuff/features/items/domain/storage_container.dart';
import 'package:track_my_stuff/features/items/providers/inventory_provider.dart';
import 'package:track_my_stuff/features/items/ui/item_detail_screen.dart';
import 'package:track_my_stuff/features/items/ui/item_ingestion_screen.dart';

/// Shows a container's details and all items stored inside it.
class ContainerDetailScreen extends ConsumerWidget {
  const ContainerDetailScreen({required this.container, super.key});

  final StorageContainer container;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          identifier: 'container_detail_title',
          child: Text(container.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      body: FutureBuilder<List<Item>>(
        future: ref.read(localDatabaseProvider).getItemsInContainer(container.id),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              // Container header
              SliverToBoxAdapter(child: _buildContainerHeader(context)),

              // Items section header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Row(
                    children: [
                      const Text(
                        'Items',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Semantics(
                        identifier: 'container_detail_item_count',
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${items.length}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Items list or empty state
              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (items.isEmpty)
                SliverFillRemaining(child: _buildEmptyItems(context))
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildItemTile(context, items[index]),
                      childCount: items.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Semantics(
        identifier: 'container_detail_add_items_fab',
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemIngestionScreen(container: container),
              ),
            );
          },
          icon: const Icon(Icons.add_a_photo),
          label: const Text('Add Items', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildContainerHeader(BuildContext context) {
    final file = File(container.imageUrl);
    final hasImage = container.imageUrl.isNotEmpty && file.existsSync();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Container photo
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
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
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
          ),
          if (container.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              container.description,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyItems(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo_outlined,
            size: 48,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No items yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the button below to capture items',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(BuildContext context, Item item) {
    final file = File(item.imageUrl);
    final hasImage = item.imageUrl.isNotEmpty && file.existsSync();

    return Card(
      color: const Color(0xFF1E1E2C),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 56,
            height: 56,
            child: hasImage
                ? Image.file(file, fit: BoxFit.cover)
                : Container(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.image, color: Theme.of(context).colorScheme.primary),
                  ),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: item.description.isNotEmpty
            ? Text(
                item.description,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.white24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ItemDetailScreen(item: item)),
          );
        },
      ),
    );
  }
}
