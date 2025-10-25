import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../models/memory.dart';

/// Memory detail page with photo viewer and editing capabilities
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
  bool _isEditingNote = false;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _currentMemory = widget.memory;
    _noteController = TextEditingController(text: _currentMemory.notes ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');

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
                case 'edit':
                  _toggleEditNote();
                  break;
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
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit),
                    const SizedBox(width: 8),
                    Text(_isEditingNote ? l10n.memorySaveNote : l10n.memoryEditNote),
                  ],
                ),
              ),
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
                  // Title
                  Text(
                    _currentMemory.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Type and date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentMemory.type.icon,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _currentMemory.type.displayName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.memoryCreatedOn(_formatDate(_currentMemory.createdAt)),
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
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
                    const SizedBox(height: 16),
                  ],
                  
                  // Item details (if from decluttering)
                  if (_currentMemory.itemName != null) ...[
                    _buildDetailRow(
                      icon: Icons.inventory_2_outlined,
                      label: l10n.memoryFromItem(_currentMemory.itemName!),
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  if (_currentMemory.category != null) ...[
                    _buildDetailRow(
                      icon: Icons.category_outlined,
                      label: l10n.memoryCategory(_currentMemory.category!),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Notes section
                  _buildNotesSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
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
                  Text(
                    'No photo available',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.note_outlined,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (!_isEditingNote && (_currentMemory.notes == null || _currentMemory.notes!.isEmpty))
              TextButton(
                onPressed: _toggleEditNote,
                child: Text(l10n.memoryAddNote),
              ),
          ],
        ),
        const SizedBox(height: 8),
        
        if (_isEditingNote) ...[
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              hintText: 'Add a note about this memory...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: _saveNote,
                child: Text(l10n.memorySaveNote),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: _cancelEditNote,
                child: const Text('Cancel'),
              ),
            ],
          ),
        ] else if (_currentMemory.notes != null && _currentMemory.notes!.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _currentMemory.notes!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'No notes added yet',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _toggleEditNote() {
    setState(() {
      _isEditingNote = !_isEditingNote;
    });
  }

  void _saveNote() {
    final updatedMemory = _currentMemory.copyWith(notes: _noteController.text);
    setState(() {
      _currentMemory = updatedMemory;
      _isEditingNote = false;
    });
    
    widget.onMemoryUpdated?.call(updatedMemory);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.memoryNoteSaved),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _cancelEditNote() {
    _noteController.text = _currentMemory.notes ?? '';
    setState(() {
      _isEditingNote = false;
    });
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
          memoryTitle: _currentMemory.title,
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
