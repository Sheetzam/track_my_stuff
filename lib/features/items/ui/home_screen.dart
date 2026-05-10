import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_my_stuff/features/items/domain/storage_container.dart';
import 'package:track_my_stuff/features/items/ui/add_container_screen.dart';
import 'package:track_my_stuff/features/items/ui/container_detail_screen.dart';
import 'package:track_my_stuff/features/items/ui/search_screen.dart';
import 'package:track_my_stuff/features/items/providers/inventory_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          identifier: 'home_screen_title',
          child: const Text('TrackMyStuff', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: ref.watch(inventoryProvider).when(
        data: (_) => FutureBuilder<List<StorageContainer>>(
          future: ref.read(localDatabaseProvider).getAllContainers(),
          builder: (context, snapshot) {
            final containers = snapshot.data ?? [];
            if (containers.isEmpty) {
              return _buildEmptyState(context);
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: containers.length,
              itemBuilder: (context, index) {
                final container = containers[index];
                return Card(
                  color: const Color(0xFF1E1E2C),
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.inventory_2_outlined, color: Theme.of(context).colorScheme.primary),
                    ),
                    title: Text(container.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text(container.description, style: const TextStyle(color: Colors.white70)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.white24),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ContainerDetailScreen(container: container)),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: Semantics(
        identifier: 'add_container_fab',
        child: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.push<void>(
              context,
              MaterialPageRoute<void>(builder: (context) => const AddContainerScreen()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('New Container', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.inventory_2_outlined, 
              size: 80, 
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Semantics(
            identifier: 'empty_state_text',
            child: Text(
              'No containers yet.',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap the + button to catalog your first box.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
