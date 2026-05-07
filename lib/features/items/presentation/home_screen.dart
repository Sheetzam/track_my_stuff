import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_my_stuff/features/items/presentation/add_container_screen.dart';

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
      ),
      body: Center(
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
}
