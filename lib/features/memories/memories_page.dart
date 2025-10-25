import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../models/memory.dart';
import 'memory_detail_page.dart';

/// iOS-style memory page with grid layout similar to Photos app
class MemoriesPage extends StatefulWidget {
  const MemoriesPage({
    super.key,
    required this.memories,
    required this.onMemoryDeleted,
    required this.onMemoryUpdated,
  });

  final List<Memory> memories;
  final void Function(Memory memory) onMemoryDeleted;
  final void Function(Memory memory) onMemoryUpdated;

  @override
  State<MemoriesPage> createState() => _MemoriesPageState();
}

class _MemoriesPageState extends State<MemoriesPage> {
  MemoryType? _selectedFilter;
  bool _isGridView = true;
  String _sortBy = 'date';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');

    final filteredMemories = _getFilteredMemories();
    final groupedMemories = _groupMemoriesByDate(filteredMemories);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.memoriesTitle,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'filter':
                  _showFilterDialog();
                  break;
                case 'sort':
                  _showSortDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'filter',
                child: Row(
                  children: [
                    const Icon(Icons.filter_list),
                    const SizedBox(width: 8),
                    Text(l10n.memoryFilterByType),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sort',
                child: Row(
                  children: [
                    const Icon(Icons.sort),
                    const SizedBox(width: 8),
                    Text(l10n.memorySortByDate),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: filteredMemories.isEmpty
          ? _EmptyMemoriesState()
          : _isGridView
              ? _GridViewMemories(groupedMemories: groupedMemories)
              : _ListViewMemories(memories: filteredMemories),
    );
  }

  List<Memory> _getFilteredMemories() {
    List<Memory> memories = List.from(widget.memories);
    
    // Apply filter
    if (_selectedFilter != null) {
      memories = memories.where((m) => m.type == _selectedFilter).toList();
    }
    
    // Apply sorting
    switch (_sortBy) {
      case 'date':
        memories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'type':
        memories.sort((a, b) => a.type.displayName.compareTo(b.type.displayName));
        break;
    }
    
    return memories;
  }

  Map<String, List<Memory>> _groupMemoriesByDate(List<Memory> memories) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeek = today.subtract(Duration(days: now.weekday - 1));
    final thisMonth = DateTime(now.year, now.month, 1);

    final Map<String, List<Memory>> grouped = {};
    
    for (final memory in memories) {
      final memoryDate = DateTime(memory.createdAt.year, memory.createdAt.month, memory.createdAt.day);
      
      String groupKey;
      if (memoryDate == today) {
        groupKey = 'Today';
      } else if (memoryDate.isAfter(thisWeek.subtract(const Duration(days: 1)))) {
        groupKey = 'This Week';
      } else if (memoryDate.isAfter(thisMonth.subtract(const Duration(days: 1)))) {
        groupKey = 'This Month';
      } else {
        groupKey = 'Older';
      }
      
      grouped.putIfAbsent(groupKey, () => []).add(memory);
    }
    
    return grouped;
  }

  void _showFilterDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.memoryFilterByType),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<MemoryType?>(
              title: Text(l10n.memoryAll),
              value: null,
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value;
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<MemoryType>(
              title: Text(l10n.memoryTypeDecluttering),
              value: MemoryType.decluttering,
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value;
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<MemoryType>(
              title: Text(l10n.memoryTypeCleaning),
              value: MemoryType.cleaning,
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value;
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<MemoryType>(
              title: Text(l10n.memoryTypeCustom),
              value: MemoryType.custom,
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSortDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sort Memories'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(l10n.memorySortByDate),
              value: 'date',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.memorySortByType),
              value: 'type',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid view for memories (iOS Photos style)
class _GridViewMemories extends StatelessWidget {
  const _GridViewMemories({required this.groupedMemories});

  final Map<String, List<Memory>> groupedMemories;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return CustomScrollView(
      slivers: groupedMemories.entries.map((entry) {
        final groupTitle = _getGroupTitle(entry.key, l10n);
        final memories = entry.value;
        
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  groupTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final memory = memories[index];
                      return _MemoryGridItem(memory: memory);
                    },
                    childCount: memories.length,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getGroupTitle(String key, AppLocalizations l10n) {
    switch (key) {
      case 'Today':
        return 'Today';
      case 'This Week':
        return l10n.memoryThisWeek;
      case 'This Month':
        return l10n.memoryThisMonth;
      case 'Older':
        return l10n.memoryOlder;
      default:
        return key;
    }
  }
}

/// List view for memories
class _ListViewMemories extends StatelessWidget {
  const _ListViewMemories({required this.memories});

  final List<Memory> memories;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: memories.length,
      itemBuilder: (context, index) {
        final memory = memories[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _MemoryListItem(memory: memory),
        );
      },
    );
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (memory.hasPhoto)
                Image.file(
                  memory.photoFile!,
                  fit: BoxFit.cover,
                )
              else
                Container(
                  child: Center(
                    child: Text(
                      memory.type.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              // Gradient overlay for better text visibility
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
              // Memory type indicator
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    memory.type.icon,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              // Title overlay
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Text(
                  memory.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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

/// Individual memory list item
class _MemoryListItem extends StatelessWidget {
  const _MemoryListItem({required this.memory});

  final Memory memory;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openMemoryDetail(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: memory.hasPhoto
                      ? Image.file(
                          memory.photoFile!,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Text(
                            memory.type.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memory.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      memory.type.displayName,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(memory.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow
              const Icon(Icons.chevron_right),
            ],
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
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
