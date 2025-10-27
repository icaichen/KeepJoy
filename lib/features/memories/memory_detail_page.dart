import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../models/memory.dart';

/// Memory detail page with photo viewer
class MemoryDetailPage extends StatefulWidget {
  const MemoryDetailPage({
    super.key,
    required this.memory,
    this.onMemoryUpdated,
    this.onMemoryDeleted,
  });

  final Memory memory;
  final void Function(Memory memory)? onMemoryUpdated;
  final void Function(Memory memory)? onMemoryDeleted;

  @override
  State<MemoryDetailPage> createState() => _MemoryDetailPageState();
}

class _MemoryDetailPageState extends State<MemoryDetailPage> {
  late Memory _currentMemory;

  @override
  void initState() {
    super.initState();
    _currentMemory = widget.memory;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.memoryDetailTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _showDeleteDialog();
                  break;
                case 'share':
                  _shareMemory();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    const Icon(Icons.share),
                    const SizedBox(width: 8),
                    Text(l10n.memoryShare),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      l10n.memoryDeleteMemory,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo section
            _buildPhotoSection(),

            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (item name)
                  if (_currentMemory.itemName != null)
                    Text(
                      _currentMemory.itemName!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Date only
                  Text(
                    l10n.memoryCreatedOn(_formatDate(_currentMemory.createdAt)),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description
                  if (_currentMemory.description != null) ...[
                    Text(
                      _currentMemory.description!,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: _currentMemory.hasPhoto
          ? GestureDetector(
              onTap: () => _openPhotoViewer(),
              child: Hero(
                tag: 'memory_photo_${_currentMemory.id}',
                child: Image.file(
                  _currentMemory.photoFile!,
                  fit: BoxFit.cover,
                ),
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentMemory.type.icon,
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No photo available',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showDeleteDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.memoryDeleteMemory,
        ),
        content: Text(
          l10n.memoryDeleteConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onMemoryDeleted?.call(_currentMemory);
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.memoryDeleted),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'Delete',
            ),
          ),
        ],
      ),
    );
  }

  void _shareMemory() {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing functionality coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _openPhotoViewer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PhotoViewerPage(
          photoPath: _currentMemory.photoPath!,
          memoryTitle: _currentMemory.itemName ?? _currentMemory.title,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

/// Full-screen photo viewer
class PhotoViewerPage extends StatelessWidget {
  const PhotoViewerPage({
    super.key,
    required this.photoPath,
    required this.memoryTitle,
  });

  final String photoPath;
  final String memoryTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          memoryTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 3.0,
          child: Hero(
            tag: 'memory_photo_${photoPath.hashCode}',
            child: Image.file(
              File(photoPath),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
