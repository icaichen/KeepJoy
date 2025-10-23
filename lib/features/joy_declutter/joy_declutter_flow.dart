import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';

// Data models
class JoyDeclutterItem {
  JoyDeclutterItem({
    required this.photoPath,
    required this.name,
    required this.category,
    this.sparksJoy,
    this.letGoRoute,
  });

  final String photoPath;
  final String name;
  final JoyDeclutterCategory category;
  bool? sparksJoy;
  LetGoRoute? letGoRoute;
}

enum JoyDeclutterCategory {
  clothes,
  books,
  papers,
  miscellaneous,
  sentimental,
  beauty;

  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case JoyDeclutterCategory.clothes:
        return l10n.categoryClothes;
      case JoyDeclutterCategory.books:
        return l10n.categoryBooks;
      case JoyDeclutterCategory.papers:
        return l10n.categoryPapers;
      case JoyDeclutterCategory.miscellaneous:
        return l10n.categoryMiscellaneous;
      case JoyDeclutterCategory.sentimental:
        return l10n.categorySentimental;
      case JoyDeclutterCategory.beauty:
        return l10n.categoryBeauty;
    }
  }
}

enum LetGoRoute {
  resell,
  donation,
  discard,
  recycle;

  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case LetGoRoute.resell:
        return l10n.routeResell;
      case LetGoRoute.donation:
        return l10n.routeDonation;
      case LetGoRoute.discard:
        return l10n.routeDiscard;
      case LetGoRoute.recycle:
        return l10n.routeRecycle;
    }
  }

  String description(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case LetGoRoute.resell:
        return l10n.routeResellDescription;
      case LetGoRoute.donation:
        return l10n.routeDonationDescription;
      case LetGoRoute.discard:
        return l10n.routeDiscardDescription;
      case LetGoRoute.recycle:
        return l10n.routeRecycleDescription;
    }
  }

  IconData get icon {
    switch (this) {
      case LetGoRoute.resell:
        return Icons.attach_money;
      case LetGoRoute.donation:
        return Icons.volunteer_activism;
      case LetGoRoute.discard:
        return Icons.delete_outline;
      case LetGoRoute.recycle:
        return Icons.recycling;
    }
  }
}

// Main Joy Declutter Flow Page
class JoyDeclutterFlowPage extends StatefulWidget {
  const JoyDeclutterFlowPage({super.key});

  @override
  State<JoyDeclutterFlowPage> createState() => _JoyDeclutterFlowPageState();
}

class _JoyDeclutterFlowPageState extends State<JoyDeclutterFlowPage> {
  final ImagePicker _picker = ImagePicker();
  final _nameController = TextEditingController();
  JoyDeclutterCategory _selectedCategory = JoyDeclutterCategory.miscellaneous;
  bool _isProcessing = false;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    // Auto-trigger camera on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureItem();
    });
  }

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
        title: Text(l10n.joyDeclutterCaptureTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCaptureCard(context),
          const SizedBox(height: 16),
          if (_photoPath != null) _buildPreviewForm(context),
          const SizedBox(height: 16),
          if (_photoPath == null)
            ElevatedButton.icon(
              onPressed: _captureItem,
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(l10n.captureItem),
            ),
          if (_photoPath != null)
            FilledButton(
              onPressed: _isProcessing ? null : _proceedToJoyQuestion,
              child: Text(l10n.nextStep),
            ),
        ],
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
            Text(
              l10n.step2ReviewDetails,
              style: Theme.of(context).textTheme.titleMedium,
            ),
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
            DropdownButtonFormField<JoyDeclutterCategory>(
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
              items: JoyDeclutterCategory.values
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
      if (picked == null) {
        // User canceled, go back
        if (mounted) Navigator.of(context).pop();
        return;
      }

      setState(() {
        _photoPath = picked.path;
        _nameController.clear();
        _selectedCategory = JoyDeclutterCategory.miscellaneous;
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

  Future<JoyDeclutterItem> _analyzeItem(String path) async {
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
      return JoyDeclutterItem(
        photoPath: path,
        name: inferredName,
        category: category,
      );
    } catch (_) {
      return JoyDeclutterItem(
        photoPath: path,
        name: 'Unnamed item',
        category: JoyDeclutterCategory.miscellaneous,
      );
    }
  }

  JoyDeclutterCategory _mapLabelToCategory(String? label) {
    if (label == null) return JoyDeclutterCategory.miscellaneous;
    final lower = label.toLowerCase();
    if (_matchesAny(lower, ['shirt', 'dress', 'shoe', 'coat', 'bag', 'pants'])) {
      return JoyDeclutterCategory.clothes;
    }
    if (_matchesAny(lower, ['book', 'magazine', 'novel', 'comic'])) {
      return JoyDeclutterCategory.books;
    }
    if (_matchesAny(lower, ['document', 'paper', 'file', 'letter'])) {
      return JoyDeclutterCategory.papers;
    }
    if (_matchesAny(lower, ['makeup', 'lipstick', 'cosmetic', 'beauty'])) {
      return JoyDeclutterCategory.beauty;
    }
    if (_matchesAny(lower, ['photo', 'picture', 'souvenir', 'memory'])) {
      return JoyDeclutterCategory.sentimental;
    }
    return JoyDeclutterCategory.miscellaneous;
  }

  bool _matchesAny(String text, List<String> keywords) {
    return keywords.any(text.contains);
  }

  void _proceedToJoyQuestion() {
    final path = _photoPath;
    if (path == null) return;

    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim().isEmpty
        ? l10n.unnamedItem
        : _nameController.text.trim();

    final item = JoyDeclutterItem(
      photoPath: path,
      name: name,
      category: _selectedCategory,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JoyQuestionPage(item: item),
      ),
    );
  }
}

// Joy Question Page
class JoyQuestionPage extends StatelessWidget {
  const JoyQuestionPage({super.key, required this.item});

  final JoyDeclutterItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.joyDeclutterTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Item photo
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                File(item.photoPath),
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            // Item name
            Text(
              item.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              item.category.localized(context),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Joy question
            Card(
              color: const Color(0xFFFFF4E6),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 48,
                      color: Color(0xFFFF9800),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.doesItSparkJoy,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.joyQuestionDescription,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Keep button
            FilledButton.icon(
              onPressed: () => _handleKeep(context),
              icon: const Icon(Icons.favorite),
              label: Text(l10n.keepItem),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            // Let go button
            OutlinedButton.icon(
              onPressed: () => _handleLetGo(context),
              icon: const Icon(Icons.heart_broken),
              label: Text(l10n.letGoItem),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _handleKeep(BuildContext context) {
    item.sparksJoy = true;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.celebration, size: 48, color: Color(0xFF4CAF50)),
        title: Text(l10n.joyDeclutterComplete),
        content: Text(l10n.itemKept),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleLetGo(BuildContext context) {
    item.sparksJoy = false;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LetGoRoutePage(item: item),
      ),
    );
  }
}

// Let Go Route Selection Page
class LetGoRoutePage extends StatelessWidget {
  const LetGoRoutePage({super.key, required this.item});

  final JoyDeclutterItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.joyDeclutterTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              l10n.itemLetGo,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.selectLetGoRoute,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: LetGoRoute.values
                    .map((route) => _buildRouteCard(context, route))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context, LetGoRoute route) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectRoute(context, route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getRouteColor(route).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  route.icon,
                  color: _getRouteColor(route),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.localized(context),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      route.description(context),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRouteColor(LetGoRoute route) {
    switch (route) {
      case LetGoRoute.resell:
        return const Color(0xFF4CAF50);
      case LetGoRoute.donation:
        return const Color(0xFF2196F3);
      case LetGoRoute.discard:
        return const Color(0xFF9E9E9E);
      case LetGoRoute.recycle:
        return const Color(0xFF8BC34A);
    }
  }

  void _selectRoute(BuildContext context, LetGoRoute route) {
    item.letGoRoute = route;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(route.icon, size: 48, color: _getRouteColor(route)),
        title: Text(l10n.joyDeclutterComplete),
        content: Text(
          '${l10n.itemLetGo}\n\n${route.localized(context)}: ${route.description(context)}',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
