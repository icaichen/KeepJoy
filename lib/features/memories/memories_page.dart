import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/memory.dart';
import 'create_memory_page.dart';
import 'memory_detail_page.dart';

/// iOS-style memory page with grid layout similar to Photos app
class MemoriesPage extends StatefulWidget {
  const MemoriesPage({
    super.key,
    required this.memories,
    required this.onMemoryDeleted,
    required this.onMemoryUpdated,
    required this.onMemoryCreated,
  });

  final List<Memory> memories;
  final void Function(Memory memory) onMemoryDeleted;
  final void Function(Memory memory) onMemoryUpdated;
  final void Function(Memory memory) onMemoryCreated;

  @override
  State<MemoriesPage> createState() => _MemoriesPageState();
}

class _MemoriesPageState extends State<MemoriesPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final memories = widget.memories;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.memoriesTitle,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: memories.isEmpty
          ? _EmptyMemoriesState()
          : GridView.builder(
              padding: const EdgeInsets.all(1),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
                childAspectRatio: 1,
              ),
              itemCount: memories.length,
              itemBuilder: (context, index) {
                final memory = memories[index];
                return _MemoryGridItem(memory: memory);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createMemory,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _createMemory() async {
    final memory = await Navigator.of(context).push<Memory>(
      MaterialPageRoute(
        builder: (_) => const CreateMemoryPage(),
      ),
    );

    if (memory != null) {
      widget.onMemoryCreated(memory);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.memoryCreated),
          ),
        );
      }
    }
  }
}

/// Individual memory grid item
class _MemoryGridItem extends StatelessWidget {
  const _MemoryGridItem({required this.memory});

  final Memory memory;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openMemoryDetail(context),
      child: memory.hasPhoto
          ? Image.file(
              memory.photoFile!,
              fit: BoxFit.cover,
            )
          : Container(
              color: Colors.grey[200],
              child: Center(
                child: Text(
                  memory.type.icon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
    );
  }

  void _openMemoryDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MemoryDetailPage(memory: memory),
      ),
    );
  }
}

/// Empty state when no memories exist
class _EmptyMemoriesState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.memoriesEmptyTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.memoriesEmptySubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate back to home to start decluttering
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text(l10n.memoriesEmptyAction),
            ),
          ],
        ),
      ),
    );
  }
}
