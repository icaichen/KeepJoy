import 'dart:io';

import 'package:flutter/material.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/resell_item.dart';
import 'package:keepjoy_app/models/memory.dart';
import 'package:keepjoy_app/features/memories/create_memory_page.dart';
import 'package:keepjoy_app/l10n/app_localizations.dart';

enum ItemsFilter { all, resell }
enum ResellSegment { toSell, listing, sold }

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({
    super.key,
    required this.items,
    required this.resellItems,
    required this.onItemCompleted,
    required this.onMemoryCreated,
    required this.onUpdateResellItem,
    required this.onDeleteItem,
  });

  final List<DeclutterItem> items;
  final List<ResellItem> resellItems;
  final Function(DeclutterItem) onItemCompleted;
  final Function(Memory) onMemoryCreated;
  final Function(ResellItem) onUpdateResellItem;
  final Function(String itemId) onDeleteItem;

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  ItemsFilter _selectedFilter = ItemsFilter.all;
  ResellSegment _resellSegment = ResellSegment.toSell;

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

            // Filter tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterTab(
                      isChinese ? '全部' : 'All Items',
                      ItemsFilter.all,
                      isChinese,
                    ),
                    const SizedBox(width: 12),
                    _buildFilterTab(
                      'Resell',
                      ItemsFilter.resell,
                      isChinese,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Content based on selected tab
            Expanded(
              child: _buildTabContent(
                toDecluterItems,
                declutteredItems,
                isChinese,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(
    List<DeclutterItem> toDecluterItems,
    List<DeclutterItem> declutteredItems,
    bool isChinese,
  ) {
    switch (_selectedFilter) {
      case ItemsFilter.all:
        return _buildAllItemsTab(toDecluterItems, declutteredItems, isChinese);
      case ItemsFilter.resell:
        return _buildResellTab(isChinese);
    }
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

  Widget _buildToDoTab(List<DeclutterItem> items, bool isChinese) {
    if (items.isEmpty) {
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
                  Icons.check_circle_outline_rounded,
                  size: 40,
                  color: Color(0xFFB0B4BB),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                isChinese ? '全部整理完了！' : 'All done!',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isChinese
                    ? '所有物品都已处理完毕'
                    : 'All items have been decluttered.',
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

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildSimpleItemCard(items[index], isChinese);
      },
    );
  }

  Widget _buildSimpleItemCard(DeclutterItem item, bool isChinese) {
    return GestureDetector(
      onTap: () {
        // Navigate to joy assessment page
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EA)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getCategoryColor(item.category).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _getCategoryIcon(item.category),
                size: 24,
                color: _getCategoryColor(item.category),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.category.label(context),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7F8289),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFD1D5DB),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResellTab(bool isChinese) {
    // Calculate total money earned from sold items
    final soldItems = widget.resellItems.where((item) => item.status == ResellStatus.sold);
    final totalEarned = soldItems.fold(0.0, (sum, item) => sum + (item.soldPrice ?? 0.0));

    // Get currency symbol
    final currencySymbol = isChinese ? '¥' : '\$';

    // Filter items by segment
    final List<ResellItem> displayItems;
    switch (_resellSegment) {
      case ResellSegment.toSell:
        displayItems = widget.resellItems.where((item) => item.status == ResellStatus.toSell).toList();
        break;
      case ResellSegment.listing:
        displayItems = widget.resellItems.where((item) => item.status == ResellStatus.listing).toList();
        break;
      case ResellSegment.sold:
        displayItems = widget.resellItems.where((item) => item.status == ResellStatus.sold).toList();
        break;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // Big Money Earned Card - 醒目
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3310B981),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.attach_money_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.trending_up, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          isChinese ? '总收入' : 'Total Earned',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                '$currencySymbol${totalEarned.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isChinese ? '${soldItems.length} 件已售出' : '${soldItems.length} items sold',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Segment Tabs
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildResellSegmentTab(
                  isChinese ? '待售' : 'To Sell',
                  ResellSegment.toSell,
                  widget.resellItems.where((item) => item.status == ResellStatus.toSell).length,
                ),
              ),
              Expanded(
                child: _buildResellSegmentTab(
                  isChinese ? '在售' : 'Listing',
                  ResellSegment.listing,
                  widget.resellItems.where((item) => item.status == ResellStatus.listing).length,
                ),
              ),
              Expanded(
                child: _buildResellSegmentTab(
                  isChinese ? '已售' : 'Sold',
                  ResellSegment.sold,
                  soldItems.length,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Item List
        if (displayItems.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE4E6EA)),
                    ),
                    child: const Icon(
                      Icons.sell_outlined,
                      size: 36,
                      color: Color(0xFFB0B4BB),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isChinese ? '暂无物品' : 'No items',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6F7278),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...displayItems.map((resellItem) {
            // Find the corresponding declutter item
            final declutterItem = widget.items.firstWhere(
              (item) => item.id == resellItem.declutterItemId,
              orElse: () => DeclutterItem(
                id: '',
                name: isChinese ? '未知物品' : 'Unknown Item',
                category: DeclutterCategory.miscellaneous,
                createdAt: DateTime.now(),
                status: DeclutterStatus.resell,
              ),
            );

            return _buildResellItemCard(resellItem, declutterItem, isChinese, currencySymbol);
          }),
      ],
    );
  }

  Widget _buildResellSegmentTab(String label, ResellSegment segment, int count) {
    final isSelected = _resellSegment == segment;
    return GestureDetector(
      onTap: () {
        setState(() {
          _resellSegment = segment;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
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
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF1C1C1E) : const Color(0xFF6F7278),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResellItemCard(
    ResellItem resellItem,
    DeclutterItem declutterItem,
    bool isChinese,
    String currencySymbol,
  ) {
    // Only allow clicking for non-sold items
    final bool isClickable = resellItem.status != ResellStatus.sold;

    return GestureDetector(
      onTap: isClickable ? () => _showResellStatusChangeSheet(resellItem, declutterItem, isChinese, currencySymbol) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EA)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Photo or placeholder
            if (declutterItem.photoPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(declutterItem.photoPath!),
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  color: Color(0xFF9CA3AF),
                  size: 28,
                ),
              ),
            const SizedBox(width: 14),

            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    declutterItem.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    declutterItem.category.label(context),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7F8289),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Price info based on status
                  if (_resellSegment == ResellSegment.listing && resellItem.sellingPrice != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$currencySymbol${resellItem.sellingPrice!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    )
                  else if (_resellSegment == ResellSegment.sold && resellItem.soldPrice != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$currencySymbol${resellItem.soldPrice!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF065F46),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            if (isClickable)
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFD1D5DB),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showResellStatusChangeSheet(ResellItem item, DeclutterItem declutterItem, bool isChinese, String currencySymbol) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          declutterItem.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.changeStatus,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7F8289),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (item.status == ResellStatus.toSell) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _showListingDialog(item, isChinese, currencySymbol);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(l10n.markAsListing),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _showSoldDialog(item, isChinese, currencySymbol);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(l10n.markAsSold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showListingDialog(ResellItem item, bool isChinese, String currencySymbol) {
    final l10n = AppLocalizations.of(context)!;
    final priceController = TextEditingController();
    ResellPlatform? selectedPlatform;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.markAsListing),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<ResellPlatform>(
                    value: selectedPlatform,
                    decoration: InputDecoration(
                      labelText: l10n.platform,
                      border: const OutlineInputBorder(),
                    ),
                    items: ResellPlatform.forLocale(context).map((platform) {
                      return DropdownMenuItem(
                        value: platform,
                        child: Text(platform.label(context)),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedPlatform = value),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: l10n.sellingPrice,
                      hintText: l10n.enterSellingPrice,
                      prefixText: currencySymbol,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    final price = double.tryParse(priceController.text.trim());
                    final updatedItem = item.copyWith(
                      status: ResellStatus.listing,
                      platform: selectedPlatform,
                      sellingPrice: price,
                    );
                    widget.onUpdateResellItem(updatedItem);
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.itemStatusUpdated)),
                    );
                  },
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSoldDialog(ResellItem item, bool isChinese, String currencySymbol) {
    final l10n = AppLocalizations.of(context)!;
    final priceController = TextEditingController(
      text: item.sellingPrice?.toStringAsFixed(2) ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.markAsSold),
          content: TextField(
            controller: priceController,
            decoration: InputDecoration(
              labelText: l10n.soldPrice,
              hintText: l10n.enterSoldPrice,
              prefixText: currencySymbol,
              border: const OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (priceController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.soldPriceRequired)),
                  );
                  return;
                }
                final price = double.tryParse(priceController.text.trim());
                final updatedItem = item.copyWith(
                  status: ResellStatus.sold,
                  soldPrice: price,
                  soldDate: DateTime.now(),
                );
                widget.onUpdateResellItem(updatedItem);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.itemStatusUpdated)),
                );
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConsumptionTab(bool isChinese) {
    // Get reviewed items
    final reviewedItems = widget.items.where((item) => item.purchaseReview != null).toList();

    // Calculate regret statistics
    final regretItems = reviewedItems.where(
      (item) => item.purchaseReview == PurchaseReview.wasteMoney ||
                item.purchaseReview == PurchaseReview.neutral
    ).toList();

    final worthItItems = reviewedItems.where(
      (item) => item.purchaseReview == PurchaseReview.worthIt ||
                item.purchaseReview == PurchaseReview.wouldBuyAgain
    ).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // Stats Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33EF4444),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isChinese ? '消费复盘' : 'Review',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isChinese ? '后悔购买' : 'Regret Purchases',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${regretItems.length}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.0,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${reviewedItems.length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isChinese ? '已复盘' : 'Reviewed',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (reviewedItems.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildReviewStat('💸', regretItems.where((i) => i.purchaseReview == PurchaseReview.wasteMoney).length.toString()),
                      _buildReviewStat('😐', regretItems.where((i) => i.purchaseReview == PurchaseReview.neutral).length.toString()),
                      _buildReviewStat('⭐', worthItItems.where((i) => i.purchaseReview == PurchaseReview.worthIt).length.toString()),
                      _buildReviewStat('🔄', worthItItems.where((i) => i.purchaseReview == PurchaseReview.wouldBuyAgain).length.toString()),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        if (reviewedItems.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE4E6EA)),
                    ),
                    child: const Icon(
                      Icons.rate_review_outlined,
                      size: 36,
                      color: Color(0xFFB0B4BB),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isChinese ? '还没有复盘记录' : 'No reviews yet',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isChinese
                      ? '对已整理的物品进行消费复盘\n帮助未来做出更明智的购买决策'
                      : 'Review your decluttered items\nto make smarter purchase decisions',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6F7278),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else ...[
          // Regret Section
          if (regretItems.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '💸',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isChinese ? '后悔购买' : 'Regret Purchases',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      Text(
                        isChinese ? '${regretItems.length} 件物品' : '${regretItems.length} items',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7F8289),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...regretItems.map((item) => _buildReviewItemCard(item, isChinese)),
            const SizedBox(height: 24),
          ],

          // Good Purchases Section
          if (worthItItems.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '⭐',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isChinese ? '值得购买' : 'Worth It',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      Text(
                        isChinese ? '${worthItItems.length} 件物品' : '${worthItItems.length} items',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7F8289),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...worthItItems.map((item) => _buildReviewItemCard(item, isChinese)),
          ],
        ],
      ],
    );
  }

  Widget _buildReviewStat(String emoji, String count) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItemCard(DeclutterItem item, bool isChinese) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Photo or placeholder
          if (item.photoPath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(item.photoPath!),
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.image_outlined,
                color: Color(0xFF9CA3AF),
                size: 28,
              ),
            ),
          const SizedBox(width: 14),

          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.purchaseReview!.emoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
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
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.category.label(context),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7F8289),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getReviewColor(item.purchaseReview!).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.purchaseReview!.label(context),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getReviewColor(item.purchaseReview!),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getReviewColor(PurchaseReview review) {
    switch (review) {
      case PurchaseReview.worthIt:
        return const Color(0xFF10B981);
      case PurchaseReview.wouldBuyAgain:
        return const Color(0xFF3B82F6);
      case PurchaseReview.neutral:
        return const Color(0xFF6B7280);
      case PurchaseReview.wasteMoney:
        return const Color(0xFFEF4444);
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
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                            child: _buildDeclutteredItemCard(item, context),
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
                          child: Container(
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
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeclutteredItemCard(DeclutterItem item, BuildContext context) {
    return GestureDetector(
      onTap: () => _showReviewDialog(item),
      child: Container(
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
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getCategoryColor(widget.category).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getCategoryIcon(widget.category),
                  size: 28,
                  color: _getCategoryColor(widget.category),
                ),
              ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      if (item.purchaseReview != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getReviewColor(item.purchaseReview!).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.purchaseReview!.emoji,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(item.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.status.label(context),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(item.status),
                          ),
                        ),
                      ),
                      if (item.purchaseReview == null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.isChinese ? '待复盘' : 'Review',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (item.purchaseReview != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.purchaseReview!.label(context),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getReviewColor(item.purchaseReview!),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFD1D5DB),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewDialog(DeclutterItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(widget.isChinese ? '消费复盘' : 'Purchase Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.isChinese ? '这次购买值得吗？' : 'Was this purchase worth it?',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              ...PurchaseReview.values.map((review) {
                return InkWell(
                  onTap: () {
                    final updatedItem = item.copyWith(
                      purchaseReview: review,
                      reviewedAt: DateTime.now(),
                    );
                    widget.onItemCompleted(updatedItem);
                    Navigator.of(dialogContext).pop();
                    setState(() {}); // Refresh to show updated review
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: item.purchaseReview == review
                          ? _getReviewColor(review).withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: item.purchaseReview == review
                            ? _getReviewColor(review)
                            : const Color(0xFFE5E7EA),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          review.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            review.label(context),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: item.purchaseReview == review
                                  ? _getReviewColor(review)
                                  : const Color(0xFF1C1C1E),
                            ),
                          ),
                        ),
                        if (item.purchaseReview == review)
                          Icon(
                            Icons.check_circle,
                            color: _getReviewColor(review),
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(widget.isChinese ? '关闭' : 'Close'),
            ),
          ],
        );
      },
    );
  }

  Color _getReviewColor(PurchaseReview review) {
    switch (review) {
      case PurchaseReview.worthIt:
        return const Color(0xFF10B981);
      case PurchaseReview.wouldBuyAgain:
        return const Color(0xFF3B82F6);
      case PurchaseReview.neutral:
        return const Color(0xFF6B7280);
      case PurchaseReview.wasteMoney:
        return const Color(0xFFEF4444);
    }
  }

  Color _getStatusColor(DeclutterStatus status) {
    switch (status) {
      case DeclutterStatus.keep:
        return const Color(0xFF10B981);
      case DeclutterStatus.discard:
        return const Color(0xFF6B7280);
      case DeclutterStatus.donate:
        return const Color(0xFF8B5CF6);
      case DeclutterStatus.recycle:
        return const Color(0xFF06B6D4);
      case DeclutterStatus.resell:
        return const Color(0xFFF59E0B);
      case DeclutterStatus.pending:
        return const Color(0xFF9CA3AF);
    }
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
