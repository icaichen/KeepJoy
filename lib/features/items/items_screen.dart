import 'package:flutter/material.dart';
import 'package:keepjoy_app/models/declutter_item.dart';

enum ItemsFilter { all, toDeclutter, decluttered }

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key, required this.items});

  final List<DeclutterItem> items;

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  ItemsFilter _selectedFilter = ItemsFilter.all;

  @override
  Widget build(BuildContext context) {
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    // Calculate stats
    final toDecluterItems = widget.items
        .where((item) => item.status == DeclutterStatus.keep)
        .toList();
    final declutteredItems = widget.items
        .where((item) => item.status != DeclutterStatus.keep)
        .toList();

    // Filter items based on selected filter
    final filteredItems = _selectedFilter == ItemsFilter.all
        ? widget.items
        : _selectedFilter == ItemsFilter.toDeclutter
        ? toDecluterItems
        : declutteredItems;

    // Calculate category stats (based on filtered items)
    final categoryStats = _calculateCategoryStats(filteredItems);

    // Get recent items (last 10) from filtered items
    final recentItems = filteredItems.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recentItemsToShow = recentItems.take(10).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isChinese ? '我的物品' : 'My Items',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF6B4E71)),
            onPressed: () {
              // Navigate to add item
            },
          ),
        ],
      ),
      body: widget.items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 80,
                      color: Colors.black26,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isChinese ? '还没有物品' : 'No items yet',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isChinese
                          ? '使用"快速整理"或"心动检视"开始记录物品'
                          : 'Use Quick Declutter or Joy Declutter to start',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black38,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Filter tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterTab(
                    isChinese ? '全部' : 'All Items',
                    ItemsFilter.all,
                    isChinese,
                  ),
                  const SizedBox(width: 12),
                  _buildFilterTab(
                    isChinese ? '待整理' : 'To Declutter',
                    ItemsFilter.toDeclutter,
                    isChinese,
                  ),
                  const SizedBox(width: 12),
                  _buildFilterTab(
                    isChinese ? '已整理' : 'Decluttered',
                    ItemsFilter.decluttered,
                    isChinese,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.hourglass_empty_rounded,
                      iconColor: const Color(0xFFFFB74D),
                      title: isChinese ? '待整理' : 'To Declutter',
                      count: toDecluterItems.length,
                      subtitle: isChinese ? '件剩余' : 'items remaining',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.check_circle_rounded,
                      iconColor: const Color(0xFF5ECFB8),
                      title: isChinese ? '已整理' : 'Decluttered',
                      count: declutteredItems.length,
                      subtitle: isChinese ? '件完成' : 'items completed',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Categories section
            if (categoryStats.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  isChinese ? '分类' : 'Categories',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: categoryStats.entries.map((entry) {
                    return _buildCategoryCard(
                      entry.key,
                      entry.value['total'] as int,
                      entry.value['remaining'] as int,
                      isChinese,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Recent items section
            if (recentItemsToShow.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isChinese ? '最近物品' : 'Recent Items',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to all items
                      },
                      child: Text(
                        isChinese ? '查看全部' : 'View All',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF95E3C6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: recentItemsToShow.length,
                itemBuilder: (context, index) {
                  return _buildRecentItemCard(
                    recentItemsToShow[index],
                    isChinese,
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, ItemsFilter filter, bool isChinese) {
    final isSelected = _selectedFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = filter;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF95E3C6)
                : const Color(0xFFE8E8ED),
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF8E8E93),
            ),
          ),
        ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const Spacer(),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.black45),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getCategoryColor(category).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  size: 20,
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
                      ? const Color(0xFF5ECFB8).withValues(alpha: 0.15)
                      : const Color(0xFFFFB74D).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isDone
                      ? (isChinese ? '全部完成' : 'All done!')
                      : '$remaining ${isChinese ? "剩余" : "left"}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDone
                        ? const Color(0xFF5ECFB8)
                        : const Color(0xFFFFB74D),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$total ${isChinese ? "已整理" : "decluttered"}',
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentItemCard(DeclutterItem item, bool isChinese) {
    final daysAgo = DateTime.now().difference(item.createdAt).inDays;
    final timeText = daysAgo == 0
        ? (isChinese ? '今天添加' : 'Added today')
        : daysAgo == 1
        ? (isChinese ? '昨天添加' : 'Added yesterday')
        : isChinese
        ? '$daysAgo 天前添加'
        : 'Added $daysAgo days ago';

    final statusText = item.status == DeclutterStatus.keep
        ? (isChinese ? '待整理' : 'To declutter')
        : (isChinese ? '已整理' : 'Decluttered');

    final statusColor = item.status == DeclutterStatus.keep
        ? const Color(0xFFFFB74D)
        : const Color(0xFF5ECFB8);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Item icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _getCategoryColor(item.category).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(item.category),
              size: 28,
              color: _getCategoryColor(item.category),
            ),
          ),
          const SizedBox(width: 16),
          // Item info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.category.label(context)} • $timeText',
                  style: const TextStyle(fontSize: 13, color: Colors.black45),
                ),
                if (item.notes != null && item.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.notes!,
                    style: const TextStyle(fontSize: 12, color: Colors.black38),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
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
}
