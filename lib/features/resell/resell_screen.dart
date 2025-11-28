import 'package:flutter/material.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/resell_item.dart';
import 'package:keepjoy_app/l10n/app_localizations.dart';
import 'package:keepjoy_app/widgets/smart_image_widget.dart';
import 'package:keepjoy_app/utils/responsive_utils.dart';

enum ResellSegment { toSell, listing, sold }

class ResellScreen extends StatefulWidget {
  const ResellScreen({
    super.key,
    required this.items,
    required this.resellItems,
    required this.onUpdateResellItem,
    required this.onDeleteItem,
  });

  final List<DeclutterItem> items;
  final List<ResellItem> resellItems;
  final Function(ResellItem) onUpdateResellItem;
  final Function(String itemId) onDeleteItem;

  @override
  State<ResellScreen> createState() => _ResellScreenState();
}

class _ResellScreenState extends State<ResellScreen> {
  int _selectedTab = 0; // 0 = To Sell, 1 = Listing, 2 = Sold
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');
    final topPadding = MediaQuery.of(context).padding.top;
    final responsive = context.responsive;

    // Calculate total money earned from sold items
    final soldItems = widget.resellItems.where(
      (item) => item.status == ResellStatus.sold,
    );
    final totalEarned = soldItems.fold(
      0.0,
      (sum, item) => sum + (item.soldPrice ?? 0.0),
    );

    // Get currency symbol
    final currencySymbol = isChinese ? '¥' : '\$';

    // Filter items by tab
    final List<ResellItem> displayItems;
    switch (_selectedTab) {
      case 0:
        displayItems = widget.resellItems
            .where((item) => item.status == ResellStatus.toSell)
            .toList();
        break;
      case 1:
        displayItems = widget.resellItems
            .where((item) => item.status == ResellStatus.listing)
            .toList();
        break;
      case 2:
        displayItems = widget.resellItems
            .where((item) => item.status == ResellStatus.sold)
            .toList();
        break;
      default:
        displayItems = [];
    }

    final pageName = isChinese ? '转售' : 'Resell';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: responsive.totalHeaderHeight),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Total Earned Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.attach_money_rounded,
                              size: 28,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isChinese ? '总收入' : 'Total Earned',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$currencySymbol${totalEarned.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF10B981),
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isChinese
                                      ? '${soldItems.length} 件已售出'
                                      : '${soldItems.length} items sold',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

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
                            child: _buildTab(
                              isChinese ? '待售' : 'To Sell',
                              0,
                              widget.resellItems
                                  .where(
                                    (item) =>
                                        item.status == ResellStatus.toSell,
                                  )
                                  .length,
                            ),
                          ),
                          Expanded(
                            child: _buildTab(
                              isChinese ? '在售' : 'Listing',
                              1,
                              widget.resellItems
                                  .where(
                                    (item) =>
                                        item.status == ResellStatus.listing,
                                  )
                                  .length,
                            ),
                          ),
                          Expanded(
                            child: _buildTab(
                              isChinese ? '已售' : 'Sold',
                              2,
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
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.sell_outlined,
                                  size: 36,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                isChinese ? '暂无物品' : 'No items',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B7280),
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

                        return _buildResellItemCard(
                          resellItem,
                          declutterItem,
                          isChinese,
                          currencySymbol,
                        );
                      }),
                  ]),
                ),
              ),
            ],
          ),

          // Collapsed header - only this rebuilds on scroll
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ListenableBuilder(
              listenable: _scrollController,
              builder: (context, child) {
                final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
                final scrollProgress = (scrollOffset / responsive.headerContentHeight).clamp(0.0, 1.0);
                final collapsedHeaderOpacity = scrollProgress >= 1.0 ? 1.0 : 0.0;
                return IgnorePointer(
                  ignoring: collapsedHeaderOpacity < 0.5,
                  child: Opacity(
                    opacity: collapsedHeaderOpacity,
                    child: child,
                  ),
                );
              },
              child: Container(
                height: responsive.collapsedHeaderHeight,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F6F7),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E5EA), width: 0.5),
                  ),
                ),
                padding: EdgeInsets.only(
                  top: topPadding,
                  left: responsive.horizontalPadding,
                  right: responsive.horizontalPadding,
                ),
                alignment: Alignment.center,
                child: Text(
                  pageName,
                  style: TextStyle(
                    fontSize: responsive.titleFontSize,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C1C1E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),

          // Original header - only this rebuilds on scroll
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ListenableBuilder(
              listenable: _scrollController,
              builder: (context, child) {
                final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
                final scrollProgress = (scrollOffset / responsive.headerContentHeight).clamp(0.0, 1.0);
                final headerOpacity = (1.0 - scrollProgress).clamp(0.0, 1.0);
                return Opacity(
                  opacity: headerOpacity,
                  child: child,
                );
              },
              child: Container(
                padding: EdgeInsets.only(
                  left: responsive.horizontalPadding,
                  right: responsive.horizontalPadding,
                  top: topPadding + 12,
                  bottom: 12,
                ),
                constraints: BoxConstraints(
                  minHeight: responsive.totalHeaderHeight,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pageName,
                    style: TextStyle(
                      fontSize: responsive.largeTitleFontSize,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C1C1E),
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index, int count) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
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
                color: isSelected
                    ? const Color(0xFF1C1C1E)
                    : const Color(0xFF6F7278),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF10B981)
                    : const Color(0xFF9CA3AF),
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
      onTap: isClickable
          ? () => _showResellStatusChangeSheet(
              resellItem,
              declutterItem,
              isChinese,
              currencySymbol,
            )
          : null,
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
            if (declutterItem.localPhotoPath != null || declutterItem.remotePhotoPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: SmartImageWidget(
                    localPath: declutterItem.localPhotoPath,
                    remotePath: declutterItem.remotePhotoPath,
                    fit: BoxFit.cover,
                  ),
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
                    declutterItem.displayName(context),
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
                  if (_selectedTab == 1 && resellItem.sellingPrice != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
                  else if (_selectedTab == 2 && resellItem.soldPrice != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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

  void _showResellStatusChangeSheet(
    ResellItem item,
    DeclutterItem declutterItem,
    bool isChinese,
    String currencySymbol,
  ) {
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
                          declutterItem.displayName(sheetContext),
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

  void _showListingDialog(
    ResellItem item,
    bool isChinese,
    String currencySymbol,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.markAsListing),
          content: TextField(
            controller: priceController,
            decoration: InputDecoration(
              labelText: l10n.sellingPrice,
              hintText: l10n.enterSellingPrice,
              prefixText: currencySymbol,
              border: const OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            autofocus: true,
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
                  sellingPrice: price,
                  updatedAt: DateTime.now(),
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
                  updatedAt: DateTime.now(),
                );
                widget.onUpdateResellItem(updatedItem);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.itemStatusUpdated)));
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }
}
