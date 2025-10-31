import 'dart:io';

import 'package:flutter/material.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/memory.dart';
import 'package:keepjoy_app/features/memories/create_memory_page.dart';
import 'package:keepjoy_app/l10n/app_localizations.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({
    super.key,
    required this.items,
    required this.onItemCompleted,
    required this.onMemoryCreated,
    required this.onDeleteItem,
  });

  final List<DeclutterItem> items;
  final Function(DeclutterItem) onItemCompleted;
  final Function(Memory) onMemoryCreated;
  final Function(String itemId) onDeleteItem;

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  @override
  Widget build(BuildContext context) {
    final isChinese = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');

    // Calculate stats
    final toDecluterItems = widget.items
        .where((item) => item.status == DeclutterStatus.keep)
        .toList();
    final declutteredItems = widget.items
        .where((item) => item.status != DeclutterStatus.keep)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Text(
                    isChinese ? '我的物品' : 'My Items',
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                      letterSpacing: 0,
                      height: 1.0,
                    ),
                  ),
                  const Spacer(),
                  _buildHeaderButton(Icons.add_rounded, () {
                    // Navigate to add item
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // All Items Content
            Expanded(
              child: _buildAllItemsTab(toDecluterItems, declutteredItems, isChinese),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllItemsTab(
    List<DeclutterItem> toDecluterItems,
    List<DeclutterItem> declutteredItems,
    bool isChinese,
  ) {
    final categoryStats = _calculateCategoryStats(widget.items);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        const SizedBox(height: 8),

        // Stats Cards Row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.inventory_2_outlined,
                iconColor: const Color(0xFF5ECFB8),
                title: isChinese ? '全部' : 'Total',
                count: widget.items.length,
                subtitle: isChinese ? '件物品' : 'items',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.hourglass_empty_rounded,
                iconColor: const Color(0xFFFFB74D),
                title: isChinese ? '待整理' : 'To Do',
                count: toDecluterItems.length,
                subtitle: isChinese ? '件待处理' : 'pending',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Categories Section - Always show all categories
        Text(
          isChinese ? '分类' : 'Categories',
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1E),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: DeclutterCategory.values.length,
          itemBuilder: (context, index) {
            final category = DeclutterCategory.values[index];
            final stats = categoryStats[category] ?? {'total': 0, 'remaining': 0};
            return GestureDetector(
              onTap: () => _showCategoryItems(category, isChinese),
              child: _buildCategoryCard(
                category,
                stats['total']!,
                stats['remaining']!,
                isChinese,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E4E8)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D111827),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: const Color(0xFF1C1C1E)),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required int count,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10111827),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6F7278),
                ),
              ),
              const Spacer(),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1E),
              height: 1.05,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Color(0xFF7F8289)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    DeclutterCategory category,
    int total,
    int remaining,
    bool isChinese,
  ) {
    final isDone = remaining == 0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10111827),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getCategoryColor(category).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  size: 22,
                  color: _getCategoryColor(category),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDone
                      ? const Color(0xFFE5F5EE)
                      : const Color(0xFFFEF2E4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  isDone
                      ? (isChinese ? '全部完成' : 'All done!')
                      : '$remaining ${isChinese ? "剩余" : "left"}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDone
                        ? const Color(0xFF58B993)
                        : const Color(0xFFEB9D42),
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.label(context),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$total ${isChinese ? "已整理" : "decluttered"}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF7F8289)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<DeclutterCategory, Map<String, int>> _calculateCategoryStats(
    List<DeclutterItem> items,
  ) {
    final stats = <DeclutterCategory, Map<String, int>>{};

    for (final category in DeclutterCategory.values) {
      final categoryItems = items.where((item) => item.category == category);
      final totalCount = categoryItems.length;

      // Only add categories that have items
      if (totalCount > 0) {
        final remaining = categoryItems
            .where((item) => item.status == DeclutterStatus.keep)
            .length;

        stats[category] = {'total': totalCount, 'remaining': remaining};
      }
    }

    return stats;
  }

  Color _getCategoryColor(DeclutterCategory category) {
    switch (category) {
      case DeclutterCategory.clothes:
        return const Color(0xFF95E3C6);
      case DeclutterCategory.books:
        return const Color(0xFFFFB74D);
      case DeclutterCategory.papers:
        return const Color(0xFF89CFF0);
      case DeclutterCategory.miscellaneous:
        return const Color(0xFFFF9AA2);
      case DeclutterCategory.sentimental:
        return const Color(0xFFB794F6);
      case DeclutterCategory.beauty:
        return const Color(0xFFFFD93D);
    }
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
        return Icons.category_rounded;
      case DeclutterCategory.sentimental:
        return Icons.favorite_rounded;
      case DeclutterCategory.beauty:
        return Icons.face_retouching_natural_rounded;
    }
  }

  void _showCategoryItems(DeclutterCategory category, bool isChinese) {
    final categoryItems = widget.items
        .where((item) => item.category == category)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return _CategoryBottomSheet(
          category: category,
          items: categoryItems,
          isChinese: isChinese,
          onItemCompleted: widget.onItemCompleted,
          onMemoryCreated: widget.onMemoryCreated,
          onDeleteItem: widget.onDeleteItem,
        );
      },
    );
  }
}

// Joy Question Page for existing items
class _JoyQuestionPage extends StatefulWidget {
  final DeclutterItem item;
  final Function(DeclutterItem) onItemCompleted;
  final Function(Memory) onMemoryCreated;

  const _JoyQuestionPage({
    required this.item,
    required this.onItemCompleted,
    required this.onMemoryCreated,
  });

  @override
  State<_JoyQuestionPage> createState() => _JoyQuestionPageState();
}

class _JoyQuestionPageState extends State<_JoyQuestionPage> {
  Future<void> _showMemoryPrompt(DeclutterItem item) async {
    final l10n = AppLocalizations.of(context)!;

    final shouldCreateMemory = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.createMemoryQuestion),
        content: Text(l10n.createMemoryPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.skipMemory),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.createMemory),
          ),
        ],
      ),
    );

    if (shouldCreateMemory == true && mounted) {
      final memory = await Navigator.of(context).push<Memory>(
        MaterialPageRoute(
          builder: (_) => CreateMemoryPage(
            item: item,
            photoPath: widget.item.photoPath ?? '',
            itemName: item.name,
          ),
        ),
      );

      if (memory != null) {
        widget.onMemoryCreated(memory);
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleKeep() async {
    final l10n = AppLocalizations.of(context)!;

    widget.onItemCompleted(widget.item);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.itemSaved)),
    );
    Navigator.of(context).pop();
  }

  Future<void> _handleLetGo() async {
    final l10n = AppLocalizations.of(context)!;
    final status = await showModalBottomSheet<DeclutterStatus>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.timeToLetGo,
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.joyQuestionDescription,
                  style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLetGoOption(
                  sheetContext,
                  Icons.delete_outline,
                  l10n.routeDiscard,
                  () => Navigator.of(sheetContext).pop(DeclutterStatus.discard),
                ),
                _buildLetGoOption(
                  sheetContext,
                  Icons.volunteer_activism_outlined,
                  l10n.routeDonation,
                  () => Navigator.of(sheetContext).pop(DeclutterStatus.donate),
                ),
                _buildLetGoOption(
                  sheetContext,
                  Icons.recycling_outlined,
                  l10n.routeRecycle,
                  () => Navigator.of(sheetContext).pop(DeclutterStatus.recycle),
                ),
                _buildLetGoOption(
                  sheetContext,
                  Icons.attach_money_outlined,
                  l10n.routeResell,
                  () => Navigator.of(sheetContext).pop(DeclutterStatus.resell),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text(l10n.cancel),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (status == null || !mounted) return;

    final updatedItem = widget.item.copyWith(status: status);
    widget.onItemCompleted(updatedItem);

    await _showMemoryPrompt(updatedItem);
  }

  Widget _buildLetGoOption(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: Colors.white,
        title: Text(
          l10n.doesItSparkJoy,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6B5CE7), Color(0xFF5ECFB8)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      // Item Photo Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x11000000),
                              blurRadius: 20,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.item.photoPath != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: AspectRatio(
                                    aspectRatio: 4 / 3,
                                    child: Image.file(
                                      File(widget.item.photoPath!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              Text(
                                widget.item.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Chip(
                                backgroundColor: const Color(0xFFEFF4FF),
                                label: Text(
                                  widget.item.category.label(context),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Question Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x11000000),
                              blurRadius: 20,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isChinese ? '这件物品是否能带来怦然心动的感觉？' : 'Does this item spark joy?',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                isChinese
                                    ? '拿起它，感受一下它是否能让你心跳加速、感到快乐。'
                                    : 'Hold it in your hands and feel if it makes your heart beat faster with joy.',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF6B7280),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _handleLetGo,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isChinese ? '让它离开' : 'Let It Go',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleKeep,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6B5CE7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isChinese ? '保留它' : 'Keep It',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Category Bottom Sheet with tabs for 待整理 and 已整理
class _CategoryBottomSheet extends StatefulWidget {
  final DeclutterCategory category;
  final List<DeclutterItem> items;
  final bool isChinese;
  final Function(DeclutterItem) onItemCompleted;
  final Function(Memory) onMemoryCreated;
  final Function(String itemId) onDeleteItem;

  const _CategoryBottomSheet({
    required this.category,
    required this.items,
    required this.isChinese,
    required this.onItemCompleted,
    required this.onMemoryCreated,
    required this.onDeleteItem,
  });

  @override
  State<_CategoryBottomSheet> createState() => _CategoryBottomSheetState();
}

class _CategoryBottomSheetState extends State<_CategoryBottomSheet> {
  int _selectedTab = 0; // 0 = 待整理, 1 = 已整理

  @override
  Widget build(BuildContext context) {
    final toDecluterItems = widget.items.where((item) => item.status == DeclutterStatus.keep).toList();
    final declutteredItems = widget.items.where((item) => item.status != DeclutterStatus.keep).toList();

    final displayItems = _selectedTab == 0 ? toDecluterItems : declutteredItems;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(widget.category).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getCategoryIcon(widget.category),
                          size: 24,
                          color: _getCategoryColor(widget.category),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.category.label(context),
                              style: const TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1C1C1E),
                              ),
                            ),
                            Text(
                              '${widget.items.length} ${widget.isChinese ? "件物品" : "items"}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF7F8289),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tabs
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _selectedTab == 0
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x1A000000),
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    widget.isChinese ? '待整理' : 'To Do',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedTab == 0 ? const Color(0xFF1C1C1E) : const Color(0xFF6F7278),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${toDecluterItems.length}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _selectedTab == 0 ? const Color(0xFFFFB74D) : const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _selectedTab == 1
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x1A000000),
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    widget.isChinese ? '已整理' : 'Done',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedTab == 1 ? const Color(0xFF1C1C1E) : const Color(0xFF6F7278),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${declutteredItems.length}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _selectedTab == 1 ? const Color(0xFF5ECFB8) : const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: displayItems.isEmpty
                  ? Center(
                      child: Text(
                        widget.isChinese ? '暂无物品' : 'No items',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6F7278),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      itemCount: displayItems.length,
                      itemBuilder: (context, index) {
                        final item = displayItems[index];

                        // Wrap decluttered items with Dismissible for swipe-to-delete
                        if (_selectedTab == 1) {
                          return Dismissible(
                            key: Key(item.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: Text(widget.isChinese ? '删除物品' : 'Delete Item'),
                                  content: Text(widget.isChinese ? '确定要删除这个物品吗？' : 'Are you sure you want to delete this item?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(dialogContext).pop(false),
                                      child: Text(widget.isChinese ? '取消' : 'Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.of(dialogContext).pop(true),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(0xFFEF4444),
                                      ),
                                      child: Text(widget.isChinese ? '删除' : 'Delete'),
                                    ),
                                  ],
                                ),
                              ) ?? false;
                            },
                            onDismissed: (direction) {
                              widget.onDeleteItem(item.id);
                            },
                            child: _buildItemCard(item),
                          );
                        }

                        // To-do items - clickable to start joy assessment
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => _JoyQuestionPage(
                                  item: item,
                                  onItemCompleted: widget.onItemCompleted,
                                  onMemoryCreated: widget.onMemoryCreated,
                                ),
                              ),
                            );
                          },
                          child: _buildItemCard(item),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildItemCard(DeclutterItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EA)),
      ),
      child: Row(
        children: [
          if (item.photoPath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(item.photoPath!),
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getCategoryColor(widget.category).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _getCategoryIcon(widget.category),
                size: 24,
                color: _getCategoryColor(widget.category),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFD1D5DB),
            size: 20,
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(DeclutterCategory category) {
    switch (category) {
      case DeclutterCategory.clothes:
        return const Color(0xFF95E3C6);
      case DeclutterCategory.books:
        return const Color(0xFFFFB74D);
      case DeclutterCategory.papers:
        return const Color(0xFF89CFF0);
      case DeclutterCategory.miscellaneous:
        return const Color(0xFFFF9AA2);
      case DeclutterCategory.sentimental:
        return const Color(0xFFB794F6);
      case DeclutterCategory.beauty:
        return const Color(0xFFFFD93D);
    }
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
        return Icons.category_rounded;
      case DeclutterCategory.sentimental:
        return Icons.favorite_rounded;
      case DeclutterCategory.beauty:
        return Icons.face_retouching_natural_rounded;
    }
  }
}
