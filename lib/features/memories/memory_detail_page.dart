import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import 'package:keepjoy_app/models/memory.dart';
import 'package:keepjoy_app/widgets/smart_image_widget.dart';
import 'package:keepjoy_app/widgets/modern_dialog.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1C1C1E),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF1C1C1E)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _showDeleteDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildPhotoSection(l10n), _buildDetailSection(l10n)],
        ),
      ),
    );
  }

  Widget _buildPhotoSection(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: _currentMemory.hasPhoto
          ? Hero(
              tag: 'memory_photo_${_currentMemory.id}',
              child: SmartImageWidget(
                localPath: _currentMemory.localPhotoPath,
                remotePath: _currentMemory.remotePhotoPath,
                fit: BoxFit.contain,
                errorWidget: Container(
                  height: 400,
                  color: const Color(0xFFF3F4F6),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    size: 64,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
            )
          : Container(
              height: 400,
              color: const Color(0xFFF3F4F6),
              alignment: Alignment.center,
              child: Text(
                _currentMemory.type.icon,
                style: const TextStyle(fontSize: 64, color: Color(0xFF9CA3AF)),
              ),
            ),
    );
  }

  Widget _buildDetailSection(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and date
          Text(
            _currentMemory.itemName ?? l10n.memoryDetailTitle,
            style: const TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.memoryCreatedOn(_formatDate(_currentMemory.createdAt)),
            style: const TextStyle(
              fontFamily: 'SF Pro Text',
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),

          // Description
          if (_currentMemory.description != null &&
              _currentMemory.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE5E7EB), height: 1),
            const SizedBox(height: 16),
            Text(
              _currentMemory.description!,
              style: const TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 16,
                height: 1.5,
                color: Color(0xFF374151),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showDeleteDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ModernDialog.showConfirmation(
      context: context,
      title: l10n.memoryDeleteMemory,
      content: l10n.memoryDeleteConfirm,
      cancelText: 'Cancel',
      confirmText: 'Delete',
    );

    if (confirmed == true) {
      if (!mounted) return;
      widget.onMemoryDeleted?.call(_currentMemory);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.memoryDeleted),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _shareMemory() {
    // Sharing removed per request
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
