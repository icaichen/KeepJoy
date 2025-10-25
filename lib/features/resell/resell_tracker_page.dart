import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/declutter_item.dart';
import '../../models/resell_item.dart';

enum ResellSegment { toSell, listing, sold }

class ResellTrackerPage extends StatefulWidget {
  const ResellTrackerPage({
    super.key,
    required this.resellItems,
    required this.declutteredItems,
    required this.onUpdateResellItem,
    required this.onDeleteResellItem,
  });

  final List<ResellItem> resellItems;
  final List<DeclutterItem> declutteredItems;
  final Function(ResellItem) onUpdateResellItem;
  final Function(ResellItem) onDeleteResellItem;

  @override
  State<ResellTrackerPage> createState() => _ResellTrackerPageState();
}

class _ResellTrackerPageState extends State<ResellTrackerPage> {
  ResellSegment _segment = ResellSegment.toSell;

  DeclutterItem? _getDeclutterItem(String declutterItemId) {
    try {
      return widget.declutteredItems.firstWhere(
        (item) => item.id == declutterItemId,
      );
    } catch (e) {
      return null;
    }
  }

  String _getCurrencySymbol(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode.toLowerCase().startsWith('zh')) {
      return '¥';
    }
    return '\$';
  }

  String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode.toLowerCase().startsWith('zh')) {
      return DateFormat('yyyy年M月d日').format(date);
    }
    return DateFormat('MMM d, yyyy').format(date);
  }

  void _showStatusChangeSheet(BuildContext context, ResellItem item) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _StatusChangeSheet(
        item: item,
        declutterItem: _getDeclutterItem(item.declutterItemId),
        onUpdateResellItem: widget.onUpdateResellItem,
        currencySymbol: _getCurrencySymbol(context),
      ),
    );
  }

  void _showSoldDetails(BuildContext context, ResellItem item) {
    final l10n = AppLocalizations.of(context)!;
    final declutterItem = _getDeclutterItem(item.declutterItemId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(declutterItem?.name ?? l10n.unnamedItem),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.platform != null) ...[
              Text(
                '${l10n.platform}: ${item.platform!.label(context)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              '${l10n.soldPrice}: ${_getCurrencySymbol(context)}${item.soldPrice?.toStringAsFixed(2) ?? '0.00'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (item.soldDate != null)
              Text(
                '${l10n.soldDate}: ${_formatDate(context, item.soldDate!)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _deleteItem(ResellItem item) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteItem),
        content: Text(l10n.deleteItemConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              widget.onDeleteResellItem(item);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.itemDeleted)),
              );
            },
            child: Text(l10n.deleteItem),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final toSellItems = widget.resellItems
        .where((item) => item.status == ResellStatus.toSell)
        .toList();
    final listingItems = widget.resellItems
        .where((item) => item.status == ResellStatus.listing)
        .toList();
    final soldItems = widget.resellItems
        .where((item) => item.status == ResellStatus.sold)
        .toList();

    List<ResellItem> currentItems;
    String emptyMessage;

    switch (_segment) {
      case ResellSegment.toSell:
        currentItems = toSellItems;
        emptyMessage = l10n.noItemsToSell;
        break;
      case ResellSegment.listing:
        currentItems = listingItems;
        emptyMessage = l10n.noItemsListing;
        break;
      case ResellSegment.sold:
        currentItems = soldItems;
        emptyMessage = l10n.noItemsSold;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resellTracker),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<ResellSegment>(
              segments: [
                ButtonSegment(
                  value: ResellSegment.toSell,
                  label: Text(l10n.toSell),
                ),
                ButtonSegment(
                  value: ResellSegment.listing,
                  label: Text(l10n.listing),
                ),
                ButtonSegment(
                  value: ResellSegment.sold,
                  label: Text(l10n.sold),
                ),
              ],
              selected: <ResellSegment>{_segment},
              onSelectionChanged: (selection) {
                setState(() {
                  _segment = selection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: currentItems.isEmpty
                    ? Center(
                        key: ValueKey('empty-${_segment.name}'),
                        child: Text(
                          emptyMessage,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      )
                    : ListView.separated(
                        key: ValueKey('list-${_segment.name}-${currentItems.length}'),
                        itemCount: currentItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = currentItems[index];
                          final declutterItem = _getDeclutterItem(item.declutterItemId);

                          return Dismissible(
                            key: Key(item.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.delete,
                                color: Theme.of(context).colorScheme.onError,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              _deleteItem(item);
                              return false;
                            },
                            child: _ResellItemCard(
                              item: item,
                              declutterItem: declutterItem,
                              segment: _segment,
                              currencySymbol: _getCurrencySymbol(context),
                              formatDate: (date) => _formatDate(context, date),
                              onTap: () {
                                if (_segment == ResellSegment.sold) {
                                  _showSoldDetails(context, item);
                                } else {
                                  _showStatusChangeSheet(context, item);
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResellItemCard extends StatelessWidget {
  const _ResellItemCard({
    required this.item,
    required this.declutterItem,
    required this.segment,
    required this.currencySymbol,
    required this.formatDate,
    required this.onTap,
  });

  final ResellItem item;
  final DeclutterItem? declutterItem;
  final ResellSegment segment;
  final String currencySymbol;
  final String Function(DateTime) formatDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Photo
              if (declutterItem?.photoPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(declutterItem!.photoPath!),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.image,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(width: 12),
              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      declutterItem?.name ?? l10n.unnamedItem,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      declutterItem?.category.label(context) ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    // Status-specific info
                    if (segment == ResellSegment.toSell) ...[
                      Text(
                        l10n.addedOn(formatDate(item.createdAt)),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ] else if (segment == ResellSegment.listing) ...[
                      if (item.platform != null)
                        Text(
                          '${l10n.platform}: ${item.platform!.label(context)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      if (item.sellingPrice != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${l10n.sellingPrice}: $currencySymbol${item.sellingPrice!.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ] else if (segment == ResellSegment.sold) ...[
                      if (item.soldPrice != null)
                        Text(
                          '${l10n.soldPrice}: $currencySymbol${item.soldPrice!.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      if (item.soldDate != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          formatDate(item.soldDate!),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              Icon(
                segment == ResellSegment.sold ? Icons.info_outline : Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChangeSheet extends StatefulWidget {
  const _StatusChangeSheet({
    required this.item,
    required this.declutterItem,
    required this.onUpdateResellItem,
    required this.currencySymbol,
  });

  final ResellItem item;
  final DeclutterItem? declutterItem;
  final Function(ResellItem) onUpdateResellItem;
  final String currencySymbol;

  @override
  State<_StatusChangeSheet> createState() => _StatusChangeSheetState();
}

class _StatusChangeSheetState extends State<_StatusChangeSheet> {
  ResellStatus? _selectedStatus;
  ResellPlatform? _selectedPlatform;
  final TextEditingController _priceController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _handleStatusSelection(ResellStatus status) {
    setState(() {
      _selectedStatus = status;
      // Pre-fill sold price if changing from listing to sold
      if (status == ResellStatus.sold &&
          widget.item.status == ResellStatus.listing &&
          widget.item.sellingPrice != null) {
        _priceController.text = widget.item.sellingPrice!.toStringAsFixed(2);
      }
    });
  }

  Future<void> _saveChanges() async {
    final l10n = AppLocalizations.of(context)!;

    // Validation for sold status
    if (_selectedStatus == ResellStatus.sold) {
      if (_priceController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.soldPriceRequired)),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final price = _priceController.text.trim().isEmpty
          ? null
          : double.tryParse(_priceController.text.trim());

      final updatedItem = widget.item.copyWith(
        status: _selectedStatus,
        platform: _selectedStatus == ResellStatus.listing ? _selectedPlatform : widget.item.platform,
        sellingPrice: _selectedStatus == ResellStatus.listing ? price : widget.item.sellingPrice,
        soldPrice: _selectedStatus == ResellStatus.sold ? price : null,
        soldDate: _selectedStatus == ResellStatus.sold ? DateTime.now() : null,
      );

      widget.onUpdateResellItem(updatedItem);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.itemStatusUpdated)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isFromToSell = widget.item.status == ResellStatus.toSell;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.changeStatus,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          // Status selection buttons
          if (_selectedStatus == null) ...[
            if (isFromToSell) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _handleStatusSelection(ResellStatus.listing),
                  child: Text(l10n.markAsListing),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _handleStatusSelection(ResellStatus.sold),
                child: Text(l10n.markAsSold),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ),
          ] else ...[
            // Show input fields based on selected status
            if (_selectedStatus == ResellStatus.listing) ...[
              DropdownMenu<ResellPlatform>(
                initialSelection: _selectedPlatform,
                label: Text(l10n.platform),
                expandedInsets: EdgeInsets.zero,
                dropdownMenuEntries: ResellPlatform.forLocale(context)
                    .map(
                      (platform) => DropdownMenuEntry(
                        value: platform,
                        label: platform.label(context),
                      ),
                    )
                    .toList(),
                onSelected: (value) {
                  setState(() => _selectedPlatform = value);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: l10n.sellingPrice,
                  hintText: l10n.enterSellingPrice,
                  prefixText: widget.currencySymbol,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ] else if (_selectedStatus == ResellStatus.sold) ...[
              TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: l10n.soldPrice,
                  hintText: l10n.enterSoldPrice,
                  prefixText: widget.currencySymbol,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _selectedStatus = null;
                              _selectedPlatform = null;
                              _priceController.clear();
                            });
                          },
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.save),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
