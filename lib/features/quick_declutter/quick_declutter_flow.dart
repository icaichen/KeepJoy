import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';
import '../../models/declutter_item.dart';
import '../../services/ai_identification_service.dart';

class QuickDeclutterFlowPage extends StatefulWidget {
  const QuickDeclutterFlowPage({super.key, required this.onItemCreated});

  final void Function(DeclutterItem item) onItemCreated;

  @override
  State<QuickDeclutterFlowPage> createState() => _QuickDeclutterFlowPageState();
}

class _QuickDeclutterFlowPageState extends State<QuickDeclutterFlowPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  int _itemsCaptured = 0;

  Future<void> _takePicture() async {
    setState(() => _isProcessing = true);

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => _QuickItemReviewPage(
              photoPath: photo.path,
              onItemCreated: widget.onItemCreated,
            ),
          ),
        );
        if (result == true && mounted) {
          setState(() => _itemsCaptured += 1);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.couldNotAccessCamera),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');
    return Scaffold(
      appBar: AppBar(title: Text(l10n.quickDeclutterTitle), centerTitle: false),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.inbox_outlined),
                title: Text(l10n.itemsCaptured),
                trailing: Text(
                  '$_itemsCaptured',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.camera_alt, size: 80),
                      const SizedBox(height: 16),
                      Text(
                        l10n.captureItemToStart,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _takePicture,
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.photo_camera),
                        label: Text(l10n.takePicture),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isChinese
                  ? '使用「快速整理」拍照記錄待處理物品。'
                  : 'Use Quick Declutter to capture items that still need decisions.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickItemReviewPage extends StatefulWidget {
  const _QuickItemReviewPage({
    required this.photoPath,
    required this.onItemCreated,
  });

  final String photoPath;
  final void Function(DeclutterItem item) onItemCreated;

  @override
  State<_QuickItemReviewPage> createState() => _QuickItemReviewPageState();
}

class _QuickItemReviewPageState extends State<_QuickItemReviewPage> {
  final TextEditingController _nameController = TextEditingController();
  DeclutterCategory _selectedCategory = DeclutterCategory.miscellaneous;
  final AIIdentificationService _aiService = AIIdentificationService();

  bool _isIdentifying = false;
  bool _isAISuggested = false;
  AIIdentificationResult? _aiResult;
  bool _hasInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      _identifyItem();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _identifyItem() async {
    setState(() => _isIdentifying = true);

    try {
      final locale = Localizations.localeOf(context).languageCode;
      print('🎯 Quick Declutter: Starting AI identification, locale: $locale');

      final result = await _aiService.identifyBasic(widget.photoPath, locale);

      print('🎯 Quick Declutter: AI result received: ${result != null ? "name=${result.itemName}, category=${result.suggestedCategory}" : "null"}');

      if (result != null && mounted) {
        setState(() {
          _aiResult = result;
          _nameController.text = result.itemName;
          _selectedCategory = result.suggestedCategory;
          _isAISuggested = true;
        });
        print('🎯 Quick Declutter: UI updated with AI result');
      }
    } catch (e) {
      print('❌ Quick Declutter: AI identification error: $e');
      // Silently fail - user can still enter manually
    } finally {
      if (mounted) {
        setState(() => _isIdentifying = false);
      }
    }
  }

  Future<void> _getDetailedInfo() async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    setState(() => _isIdentifying = true);

    try {
      final result = await _aiService.identifyDetailed(widget.photoPath, locale);
      if (result != null && mounted) {
        setState(() {
          _aiResult = result;
          _nameController.text = result.itemName;
          _selectedCategory = result.suggestedCategory;
          _isAISuggested = true;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.aiIdentificationFailed)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.aiIdentificationFailed)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isIdentifying = false);
      }
    }
  }

  void _retake() {
    Navigator.of(context).pop(false);
  }

  Future<void> _saveAndReturn({required bool finish}) async {
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');
    final name = _nameController.text.trim().isEmpty
        ? (isChinese ? '未命名物品' : 'Unnamed item')
        : _nameController.text.trim();

    final item = DeclutterItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      category: _selectedCategory,
      createdAt: DateTime.now(),
      status: DeclutterStatus.pending,
      photoPath: widget.photoPath,
    );

    widget.onItemCreated(item);

    if (!finish) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isChinese ? '已加入待整理清單' : 'Added to To Declutter list'),
        ),
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      if (mounted) {
        Navigator.of(context).pop(true);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.quickDeclutterTitle), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: widget.photoPath.isEmpty
                  ? Container(
                      height: size.height * 0.3,
                      alignment: Alignment.center,
                      color: Colors.grey[300],
                      child: const Icon(Icons.photo, size: 48),
                    )
                  : Image.file(
                      File(widget.photoPath),
                      height: size.height * 0.3,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.itemName,
                      hintText: l10n.itemName,
                      suffixIcon: _isIdentifying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : _isAISuggested
                              ? Tooltip(
                                  message: l10n.aiSuggested,
                                  child: const Icon(Icons.auto_awesome, size: 20),
                                )
                              : null,
                    ),
                    onChanged: (_) {
                      // User edited, no longer AI suggested
                      if (_isAISuggested) {
                        setState(() => _isAISuggested = false);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownMenu<DeclutterCategory>(
                    initialSelection: _selectedCategory,
                    label: Text(l10n.category),
                    dropdownMenuEntries: DeclutterCategory.values
                        .map(
                          (category) => DropdownMenuEntry(
                            value: category,
                            label: category.label(context),
                          ),
                        )
                        .toList(),
                    onSelected: (value) {
                      if (value != null) {
                        setState(() => _selectedCategory = value);
                      }
                    },
                  ),
                  if (_aiResult?.method == 'on-device') ...[
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _isIdentifying ? null : _getDetailedInfo,
                      icon: const Icon(Icons.search, size: 18),
                      label: Text(l10n.getDetailedInfo),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _retake,
                  child: Text(l10n.retakePhoto),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => _saveAndReturn(finish: false),
                  child: Text(l10n.nextItem),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _saveAndReturn(finish: true),
              child: Text(l10n.finishDeclutter),
            ),
          ),
        ],
      ),
    );
  }
}
