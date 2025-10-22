import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/localization.dart';

class QuickDeclutterItem {
  QuickDeclutterItem({
    required this.photoPath,
    required this.name,
    required this.category,
  });

  final String photoPath;
  final String name;
  final QuickDeclutterCategory category;
}

enum QuickDeclutterCategory {
  clothes('Clothes', '衣物'),
  books('Books', '书籍'),
  papers('Papers', '文件'),
  miscellaneous('Miscellaneous', '杂项'),
  sentimental('Sentimental', '情感纪念品'),
  beauty('Beauty', '美妆用品');

  const QuickDeclutterCategory(this.en, this.zh);
  final String en;
  final String zh;

  String localized(BuildContext context) => localizedText(context, en, zh);
}

class QuickDeclutterFlowPage extends StatefulWidget {
  const QuickDeclutterFlowPage({super.key});

  @override
  State<QuickDeclutterFlowPage> createState() => _QuickDeclutterFlowPageState();
}

class _QuickDeclutterFlowPageState extends State<QuickDeclutterFlowPage> {
  final ImagePicker _picker = ImagePicker();
  final _nameController = TextEditingController();
  QuickDeclutterCategory _selectedCategory =
      QuickDeclutterCategory.miscellaneous;
  bool _isProcessing = false;
  String? _photoPath;
  final List<QuickDeclutterItem> _items = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(localizedText(context, 'Quick Declutter', '快速整理')),
        actions: [
          TextButton(
            onPressed: _items.isEmpty ? null : _finish,
            child: Text(
              localizedText(context, 'Finish', '完成'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_items.isNotEmpty) _buildSummary(context),
          _buildCaptureCard(context),
          const SizedBox(height: 16),
          if (_photoPath != null) _buildPreviewForm(context),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _captureItem,
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(localizedText(context, 'Capture item', '拍摄物品')),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _photoPath != null && !_isProcessing
                ? _addCurrentItem
                : null,
            child: Text(localizedText(context, 'Add this item', '添加此物品')),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizedText(context, 'Items added', '已添加的物品'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _items
                  .map(
                    (item) => Chip(
                      avatar: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 18,
                      ),
                      label: Text(
                        '${item.name} · ${item.category.localized(context)}',
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizedText(
                context,
                'Step 1 · Capture your item',
                '步骤一 · 拍摄物品',
              ),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              localizedText(
                context,
                'Take a photo so we can identify and organize it for you.',
                '拍摄物品照片，我们会协助识别与归类。',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewForm(BuildContext context) {
    final displayQuote = localizedText(
      context,
      'Step 2 · Review details',
      '步骤二 · 查看详情',
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(displayQuote, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (_photoPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(_photoPath!),
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: localizedText(context, 'Item Name', '物品名称'),
              ),
            ),
            const SizedBox(height: 16),
            DropdownMenu<QuickDeclutterCategory>(
              initialSelection: _selectedCategory,
              onSelected: (value) => setState(() {
                if (value != null) {
                  _selectedCategory = value;
                }
              }),
              label: Text(localizedText(context, 'Category', '分类')),
              dropdownMenuEntries: QuickDeclutterCategory.values
                  .map(
                    (category) => DropdownMenuEntry(
                      value: category,
                      label: category.localized(context),
                    ),
                  )
                  .toList(),
            ),
            if (_isProcessing) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(localizedText(context, 'Identifying item…', '正在识别物品…')),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _captureItem() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() {
        _photoPath = picked.path;
        _nameController.clear();
        _selectedCategory = QuickDeclutterCategory.miscellaneous;
        _isProcessing = true;
      });

      final suggestion = await _analyzeItem(picked.path);
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _nameController.text = suggestion.name;
        _selectedCategory = suggestion.category;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizedText(context, 'Could not access camera.', '无法打开相机。'),
          ),
        ),
      );
    }
  }

  Future<QuickDeclutterItem> _analyzeItem(String path) async {
    try {
      final inputImage = InputImage.fromFilePath(path);
      final imageLabeler = ImageLabeler(
        options: ImageLabelerOptions(confidenceThreshold: 0.6),
      );
      final labels = await imageLabeler.processImage(inputImage);
      await imageLabeler.close();

      labels.sort((a, b) => b.confidence.compareTo(a.confidence));
      final top = labels.isNotEmpty ? labels.first : null;
      final inferredName = top?.label ?? 'Unnamed item';
      final category = _mapLabelToCategory(top?.label);
      return QuickDeclutterItem(
        photoPath: path,
        name: inferredName,
        category: category,
      );
    } catch (_) {
      return QuickDeclutterItem(
        photoPath: path,
        name: 'Unnamed item',
        category: QuickDeclutterCategory.miscellaneous,
      );
    }
  }

  QuickDeclutterCategory _mapLabelToCategory(String? label) {
    if (label == null) return QuickDeclutterCategory.miscellaneous;
    final lower = label.toLowerCase();
    if (_matchesAny(lower, [
      'shirt',
      'dress',
      'shoe',
      'coat',
      'bag',
      'pants',
    ])) {
      return QuickDeclutterCategory.clothes;
    }
    if (_matchesAny(lower, ['book', 'magazine', 'novel', 'comic'])) {
      return QuickDeclutterCategory.books;
    }
    if (_matchesAny(lower, ['document', 'paper', 'file', 'letter'])) {
      return QuickDeclutterCategory.papers;
    }
    if (_matchesAny(lower, ['makeup', 'lipstick', 'cosmetic', 'beauty'])) {
      return QuickDeclutterCategory.beauty;
    }
    if (_matchesAny(lower, ['photo', 'picture', 'souvenir', 'memory'])) {
      return QuickDeclutterCategory.sentimental;
    }
    return QuickDeclutterCategory.miscellaneous;
  }

  bool _matchesAny(String text, List<String> keywords) {
    return keywords.any(text.contains);
  }

  void _addCurrentItem() {
    final path = _photoPath;
    if (path == null) return;
    final name = _nameController.text.trim().isEmpty
        ? localizedText(context, 'Unnamed item', '未命名物品')
        : _nameController.text.trim();
    setState(() {
      _items.add(
        QuickDeclutterItem(
          photoPath: path,
          name: name,
          category: _selectedCategory,
        ),
      );
      _photoPath = null;
      _nameController.clear();
      _selectedCategory = QuickDeclutterCategory.miscellaneous;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localizedText(context, 'Item added.', '物品已添加。'))),
    );
  }

  void _finish() {
    Navigator.of(context).pop(_items);
  }
}
