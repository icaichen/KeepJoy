import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/memory.dart';
import '../../services/ai_identification_service.dart';
import '../memories/create_memory_page.dart';

const LinearGradient _joyMintPurpleGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF6B5CE7), Color(0xFF5ECFB8)],
);

Widget _buildJoyProgressIndicator(int activeIndex, {int totalSteps = 3}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(totalSteps, (index) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: index == activeIndex ? 28 : 20,
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: index == activeIndex
              ? Colors.black.withValues(alpha: 0.75)
              : Colors.white.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }),
  );
}

Widget _buildJoySurface({
  required Widget child,
  EdgeInsetsGeometry margin = EdgeInsets.zero,
  EdgeInsetsGeometry padding = const EdgeInsets.all(24),
}) {
  return Card(
    margin: margin,
    elevation: 0,
    color: Colors.white.withValues(alpha: 0.95),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    child: Padding(padding: padding, child: child),
  );
}

class JoyDeclutterFlowPage extends StatefulWidget {
  final Function(DeclutterItem) onItemCompleted;
  final Function(Memory) onMemoryCreated;

  const JoyDeclutterFlowPage({
    super.key,
    required this.onItemCompleted,
    required this.onMemoryCreated,
  });

  @override
  State<JoyDeclutterFlowPage> createState() => _JoyDeclutterFlowPageState();
}

class _JoyDeclutterFlowPageState extends State<JoyDeclutterFlowPage> {
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePicture() async {
    setState(() => _isProcessing = true);

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _PhotoReviewPage(
              photoPath: photo.path,
              onItemCompleted: widget.onItemCompleted,
              onMemoryCreated: widget.onMemoryCreated,
            ),
          ),
        );
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
    final theme = Theme.of(context);
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: Colors.white,
        title: Text(
          l10n.joyDeclutterTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: _joyMintPurpleGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _buildJoyProgressIndicator(0),
                const SizedBox(height: 24),
                Expanded(
                  child: _buildJoySurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.joyDeclutterCaptureTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.captureItemToStart,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF4B5563),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(
                                    0xFF6B5CE7,
                                  ).withValues(alpha: 0.85),
                                  const Color(
                                    0xFF5ECFB8,
                                  ).withValues(alpha: 0.85),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 20,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.camera_alt_rounded,
                                size: 72,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _isProcessing ? null : _takePicture,
                            icon: _isProcessing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.photo_camera_rounded),
                            label: Text(l10n.takePicture),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isChinese
                      ? '拍攝物品，我們會陪你完成怦然心動檢查。'
                      : 'Capture one item at a time—we will guide your joy check.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoReviewPage extends StatefulWidget {
  final String photoPath;
  final Function(DeclutterItem) onItemCompleted;
  final Function(Memory) onMemoryCreated;

  const _PhotoReviewPage({
    required this.photoPath,
    required this.onItemCompleted,
    required this.onMemoryCreated,
  });

  @override
  State<_PhotoReviewPage> createState() => _PhotoReviewPageState();
}

class _PhotoReviewPageState extends State<_PhotoReviewPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final AIIdentificationService _aiService = AIIdentificationService();

  DeclutterCategory _selectedCategory = DeclutterCategory.miscellaneous;
  bool _isIdentifying = false;
  bool _isAISuggested = false;
  String? _itemName;
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
      final result = await _aiService.identifyBasic(widget.photoPath, locale);

      if (result != null && mounted) {
        setState(() {
          _itemName = result.itemName;
          _nameController.text = result.itemName;
          _selectedCategory = result.suggestedCategory;
          _isAISuggested = true;
        });
      }
    } catch (_) {
      // Allow manual entry when AI fails.
    } finally {
      if (mounted) {
        setState(() => _isIdentifying = false);
      }
    }
  }

  Future<void> _retakePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => _PhotoReviewPage(
              photoPath: photo.path,
              onItemCompleted: widget.onItemCompleted,
              onMemoryCreated: widget.onMemoryCreated,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.couldNotAccessCamera),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: Colors.white,
        title: Text(
          l10n.joyDeclutterCaptureTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: _joyMintPurpleGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _buildJoyProgressIndicator(1),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    children: [
                      _buildJoySurface(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: AspectRatio(
                                aspectRatio: 4 / 3,
                                child: widget.photoPath.isEmpty
                                    ? Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.photo_camera_outlined,
                                          size: 80,
                                          color: Colors.black45,
                                        ),
                                      )
                                    : Image.file(
                                        File(widget.photoPath),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                labelText: l10n.itemName,
                                hintText: _itemName ?? l10n.itemName,
                                suffixIcon: _isIdentifying
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Padding(
                                          padding: EdgeInsets.all(12),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : _isAISuggested
                                    ? Tooltip(
                                        message: l10n.aiSuggested,
                                        child: const Icon(
                                          Icons.auto_awesome,
                                          size: 20,
                                        ),
                                      )
                                    : null,
                              ),
                              onChanged: (_) {
                                if (_isAISuggested) {
                                  setState(() => _isAISuggested = false);
                                }
                              },
                            ),
                            const SizedBox(height: 16),
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildJoySurface(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.doesItSparkJoy,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.joyQuestionDescription,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF4B5563),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _retakePicture,
                              child: Text(l10n.retakePhoto),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => _JoyQuestionPage(
                                      photoPath: widget.photoPath,
                                      itemName:
                                          _nameController.text.trim().isEmpty
                                          ? (_itemName ?? l10n.itemName)
                                          : _nameController.text.trim(),
                                      category: _selectedCategory,
                                      onItemCompleted: widget.onItemCompleted,
                                      onMemoryCreated: widget.onMemoryCreated,
                                    ),
                                  ),
                                );
                              },
                              child: Text(l10n.nextStep),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isAISuggested
                            ? l10n.aiSuggested
                            : l10n.captureItemToStart,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JoyQuestionPage extends StatefulWidget {
  final String photoPath;
  final String itemName;
  final DeclutterCategory category;
  final Function(DeclutterItem) onItemCompleted;
  final Function(Memory) onMemoryCreated;

  const _JoyQuestionPage({
    required this.photoPath,
    required this.itemName,
    required this.category,
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
            photoPath: widget.photoPath,
            itemName: item.name,
          ),
        ),
      );

      if (memory != null) {
        widget.onMemoryCreated(memory);
      }
    }

    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _handleKeep() async {
    final l10n = AppLocalizations.of(context)!;
    final item = DeclutterItem(
      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
      name: widget.itemName,
      category: widget.category,
      createdAt: DateTime.now(),
      status: DeclutterStatus.keep,
      photoPath: widget.photoPath,
    );

    widget.onItemCompleted(item);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.itemSaved)));
    Navigator.of(context).popUntil((route) => route.isFirst);
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
        final theme = Theme.of(sheetContext);
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.joyQuestionDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 20),
                _LetGoOption(
                  icon: Icons.delete_outline,
                  label: l10n.routeDiscard,
                  onTap: () =>
                      Navigator.of(sheetContext).pop(DeclutterStatus.discard),
                ),
                _LetGoOption(
                  icon: Icons.volunteer_activism_outlined,
                  label: l10n.routeDonation,
                  onTap: () =>
                      Navigator.of(sheetContext).pop(DeclutterStatus.donate),
                ),
                _LetGoOption(
                  icon: Icons.recycling_outlined,
                  label: l10n.routeRecycle,
                  onTap: () =>
                      Navigator.of(sheetContext).pop(DeclutterStatus.recycle),
                ),
                _LetGoOption(
                  icon: Icons.attach_money_outlined,
                  label: l10n.routeResell,
                  onTap: () =>
                      Navigator.of(sheetContext).pop(DeclutterStatus.resell),
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

    if (status == null || !mounted) {
      return;
    }

    final item = DeclutterItem(
      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
      name: widget.itemName,
      category: widget.category,
      createdAt: DateTime.now(),
      status: status,
      photoPath: widget.photoPath,
    );

    widget.onItemCompleted(item);

    await _showMemoryPrompt(item);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: Colors.white,
        title: Text(
          l10n.doesItSparkJoy,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: _joyMintPurpleGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _buildJoyProgressIndicator(2),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    children: [
                      _buildJoySurface(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: AspectRatio(
                                aspectRatio: 4 / 3,
                                child: widget.photoPath.isEmpty
                                    ? Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.photo_outlined,
                                          size: 80,
                                          color: Colors.black45,
                                        ),
                                      )
                                    : Image.file(
                                        File(widget.photoPath),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              widget.itemName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Chip(
                              backgroundColor: const Color(0xFFEFF4FF),
                              label: Text(
                                widget.category.label(context),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF374151),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildJoySurface(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.doesItSparkJoy,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.joyQuestionDescription,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF4B5563),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: _handleKeep,
                        child: Text(l10n.yes),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _handleLetGo,
                        child: Text(l10n.no),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LetGoOption extends StatelessWidget {
  const _LetGoOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFF3F4F6),
        ),
        child: Icon(icon, color: const Color(0xFF374151)),
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }
}
