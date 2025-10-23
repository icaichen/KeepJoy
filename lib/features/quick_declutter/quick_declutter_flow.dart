import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';

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
  clothes,
  books,
  papers,
  miscellaneous,
  sentimental,
  beauty;

  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case QuickDeclutterCategory.clothes:
        return l10n.categoryClothes;
      case QuickDeclutterCategory.books:
        return l10n.categoryBooks;
      case QuickDeclutterCategory.papers:
        return l10n.categoryPapers;
      case QuickDeclutterCategory.miscellaneous:
        return l10n.categoryMiscellaneous;
      case QuickDeclutterCategory.sentimental:
        return l10n.categorySentimental;
      case QuickDeclutterCategory.beauty:
        return l10n.categoryBeauty;
    }
  }
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quickDeclutterTitle),
        actions: [
          TextButton(
            onPressed: _items.isEmpty ? null : _finish,
            child: Text(
              l10n.finish,
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
            label: Text(l10n.captureItem),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _photoPath != null && !_isProcessing
                ? _addCurrentItem
                : null,
            child: Text(l10n.addThisItem),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.itemsAdded,
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
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.step1CaptureItem,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(l10n.step1Description),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewForm(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.step2ReviewDetails, style: Theme.of(context).textTheme.titleMedium),
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
                labelText: l10n.itemName,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<QuickDeclutterCategory>(
              initialValue: _selectedCategory,
              onChanged: (value) => setState(() {
                if (value != null) {
                  _selectedCategory = value;
                }
              }),
              decoration: InputDecoration(
                labelText: l10n.category,
                border: const OutlineInputBorder(),
              ),
              items: QuickDeclutterCategory.values
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category.localized(context)),
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
                  Text(l10n.identifyingItem),
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.couldNotAccessCamera),
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
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim().isEmpty
        ? l10n.unnamedItem
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
      SnackBar(content: Text(l10n.itemAdded)),
    );
  }

  void _finish() {
    Navigator.of(context).pop(_items);
  }
}
