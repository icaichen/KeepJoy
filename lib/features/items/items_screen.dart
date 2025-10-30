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
      backgroundColor: const Color(0xFFF5F6F7),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  _buildHeaderButton(
                    Icons.arrow_back_ios_new_rounded,
                    Navigator.of(context).canPop()
                        ? () => Navigator.of(context).pop()
                        : null,
                  ),
                  const SizedBox(width: 16),
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
            if (widget.items.isEmpty)
              Expanded(child: _buildEmptyState(context, isChinese))
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Filter tabs
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.hourglass_empty_rounded,
                                iconColor: const Color(0xFFF3A65A),
                                title: isChinese ? '待整理' : 'To Declutter',
                                count: toDecluterItems.length,
                                subtitle: isChinese ? '件剩余' : 'items remaining',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.check_circle_rounded,
                                iconColor: const Color(0xFF69C7A0),
                                title: isChinese ? '已整理' : 'Decluttered',
                                count: declutteredItems.length,
                                subtitle: isChinese ? '件完成' : 'items completed',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      if (categoryStats.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            isChinese ? '分类' : 'Categories',
                            style: const TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C1C1E),
                              letterSpacing: 0,
                              height: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.55,
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
                        const SizedBox(height: 28),
                      ],

                      if (recentItemsToShow.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isChinese ? '最近物品' : 'Recent Items',
                                style: const TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1C1C1E),
                                  letterSpacing: 0,
                                  height: 1.0,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Navigate to all items
                                },
                                child: Text(
                                  isChinese ? '查看全部' : 'View All',
                                  style: const TextStyle(
                                    fontFamily: 'SF Pro Text',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF94B26F),
                                    letterSpacing: 0,
                                    height: 1.0,
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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: recentItemsToShow.length,
                          itemBuilder: (context, index) {
                            return _buildRecentItemCard(
                              recentItemsToShow[index],
                              isChinese,
                            );
                          },
                        ),
                        const SizedBox(height: 28),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isChinese) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFE4E6EA)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F111827),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: Color(0xFFB0B4BB),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              isChinese ? '还没有物品' : 'No items yet',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1E),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isChinese
                  ? '使用“快速整理”或“心动检视”开始记录物品'
                  : 'Use Quick Declutter or Joy Declutter to start tracking.',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF6F7278),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
            color: isSelected ? const Color(0xFF97B777) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF97B777)
                  : const Color(0xFFE0E3E7),
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x1A7D9160),
                      blurRadius: 12,
                      offset: Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF7E828A),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10111827),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _getCategoryColor(item.category).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getCategoryIcon(item.category),
              size: 26,
              color: _getCategoryColor(item.category),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.category.label(context)} • $timeText',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7F8289),
                  ),
                ),
                if (item.notes != null && item.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.notes!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9A9DA3),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
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
