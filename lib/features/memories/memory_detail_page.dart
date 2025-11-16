import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import 'package:keepjoy_app/models/memory.dart';

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
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
                    const Icon(Icons.share, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      l10n.memoryShare,
                      style: const TextStyle(
                        fontFamily: 'SF Pro Text',
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.memoryDeleteMemory,
                      style: const TextStyle(
                        fontFamily: 'SF Pro Text',
                        fontSize: 15,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPhotoSection(l10n),
                const SizedBox(height: 16),
                _buildDetailSheet(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection(AppLocalizations l10n) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _currentMemory.hasPhoto
                ? Hero(
                    tag: 'memory_photo_${_currentMemory.id}',
                    child: Image.file(
                      _currentMemory.photoFile!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    color: const Color(0xFF1F1F1F),
                    alignment: Alignment.center,
                    child: Text(
                      _currentMemory.type.icon,
                      style: const TextStyle(
                        fontSize: 64,
                        color: Colors.white70,
                      ),
                    ),
                  ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentMemory.itemName ?? l10n.memoryDetailTitle,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.memoryCreatedOn(_formatDate(_currentMemory.createdAt)),
                    style: const TextStyle(
                      fontFamily: 'SF Pro Text',
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSheet(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_currentMemory.description != null &&
              _currentMemory.description!.trim().isNotEmpty)
            Text(
              _currentMemory.description!,
              style: const TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 16,
                height: 1.6,
                color: Color(0xFF111827),
              ),
            )
          else
            Text(
              l10n.memoryNoDescription,
              style: const TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 15,
                color: Color(0xFF9CA3AF),
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.memoryDeleteMemory),
        content: Text(l10n.memoryDeleteConfirm),
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
            child: const Text('Delete'),
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
