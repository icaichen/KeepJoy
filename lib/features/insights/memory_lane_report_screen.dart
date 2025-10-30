import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:keepjoy_app/models/declutter_item.dart';

class MemoryLaneReportScreen extends StatelessWidget {
  const MemoryLaneReportScreen({super.key, required this.declutteredItems});

  final List<DeclutterItem> declutteredItems;

  @override
  Widget build(BuildContext context) {
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    // Get items with photos
    final itemsWithPhotos =
        declutteredItems.where((item) => item.photoPath != null).toList()..sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        ); // Sort by newest first

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final scrollY = (constraints.maxHeight - kToolbarHeight).clamp(
                  0.0,
                  150.0,
                );
                final progress = 1 - (scrollY / 150.0);

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gradient background
                    Transform.translate(
                      offset: Offset(0, progress * -30),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFF3EBFF), Color(0xFFB794F6)],
                          ),
                        ),
                      ),
                    ),

                    // Large title
                    Positioned(
                      left: 24,
                      bottom: 40,
                      child: Opacity(
                        opacity: 1 - progress,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isChinese ? '记忆长廊' : 'Memory Lane',
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isChinese
                                  ? '${itemsWithPhotos.length} 张照片'
                                  : '${itemsWithPhotos.length} photos',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Top pinned header with blur
                    Align(
                      alignment: Alignment.topCenter,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 10 * progress,
                            sigmaY: 10 * progress,
                          ),
                          child: Container(
                            height:
                                kToolbarHeight +
                                MediaQuery.of(context).padding.top,
                            color: Colors.white.withValues(
                              alpha: progress * 0.9,
                            ),
                            alignment: Alignment.center,
                            child: SafeArea(
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.arrow_back_ios_rounded,
                                      color: Colors.black.withValues(
                                        alpha: progress,
                                      ),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  Expanded(
                                    child: Opacity(
                                      opacity: progress,
                                      child: Text(
                                        isChinese ? '记忆长廊' : 'Memory Lane',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Content
          if (itemsWithPhotos.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB794F6).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.photo_library_rounded,
                          size: 64,
                          color: Color(0xFFB794F6),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        isChinese ? '还没有照片记忆' : 'No photos yet',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isChinese
                            ? '开始记录你的整理瞬间吧'
                            : 'Start capturing your decluttering moments',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = itemsWithPhotos[index];
                  return _buildPhotoCard(context, item, isChinese);
                }, childCount: itemsWithPhotos.length),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(
    BuildContext context,
    DeclutterItem item,
    bool isChinese,
  ) {
    return GestureDetector(
      onTap: () {
        // Show full screen photo with details
        _showPhotoDetail(context, item, isChinese);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: item.photoPath != null
                    ? Image.file(
                        File(item.photoPath!),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFF5F5F5),
                            child: const Center(
                              child: Icon(
                                Icons.broken_image_rounded,
                                size: 48,
                                color: Color(0xFFBDBDBD),
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: const Color(0xFFF5F5F5),
                        child: const Center(
                          child: Icon(
                            Icons.image_rounded,
                            size: 48,
                            color: Color(0xFFBDBDBD),
                          ),
                        ),
                      ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(item.category),
                        size: 14,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.category.label(context),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.black54, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(item.createdAt, isChinese),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black45,
                      fontSize: 10,
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

  void _showPhotoDetail(
    BuildContext context,
    DeclutterItem item,
    bool isChinese,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Photo
              Flexible(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: item.photoPath != null
                      ? Image.file(
                          File(item.photoPath!),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 300,
                              color: const Color(0xFFF5F5F5),
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image_rounded,
                                  size: 64,
                                  color: Color(0xFFBDBDBD),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 300,
                          color: const Color(0xFFF5F5F5),
                          child: const Center(
                            child: Icon(
                              Icons.image_rounded,
                              size: 64,
                              color: Color(0xFFBDBDBD),
                            ),
                          ),
                        ),
                ),
              ),
              // Details
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          _getCategoryIcon(item.category),
                          size: 16,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.category.label(context),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(item.createdAt, isChinese),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                    if (item.notes != null && item.notes!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.notes!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.black87),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB794F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(isChinese ? '关闭' : 'Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(DeclutterCategory category) {
    switch (category) {
      case DeclutterCategory.clothes:
        return Icons.checkroom_rounded;
      case DeclutterCategory.books:
        return Icons.menu_book_rounded;
      case DeclutterCategory.papers:
        return Icons.description_rounded;
      case DeclutterCategory.miscellaneous:
        return Icons.widgets_rounded;
      case DeclutterCategory.sentimental:
        return Icons.favorite_rounded;
      case DeclutterCategory.beauty:
        return Icons.face_rounded;
    }
  }

  String _formatDate(DateTime date, bool isChinese) {
    if (isChinese) {
      return '${date.year}年${date.month}月${date.day}日';
    } else {
      const months = [
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
}
