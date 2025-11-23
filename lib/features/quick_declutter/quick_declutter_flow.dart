import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../l10n/app_localizations.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/services/auth_service.dart';
import '../../services/ai_identification_service.dart';
import '../../utils/navigation.dart';

// Quick Declutter styling constants to match Joy Declutter
const LinearGradient _quickPinkOrangeGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFEC4899), Color(0xFFF97316)],
);

const Color _quickBackgroundColor = Color(0xFFF5F5F7);
const Color _quickPrimaryColor = Color(0xFF111827);
const Color _quickCardShadow = Color(0x11000000);

Widget _buildQuickTopBar(
  BuildContext context, {
  required int currentStep,
  required int totalSteps,
  required String title,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
              letterSpacing: -0.4,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => popToHome(context),
            splashRadius: 20,
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          totalSteps,
          (index) => Container(
            width: 24,
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: index <= currentStep
                  ? _quickPrimaryColor
                  : const Color(0xFFE0E5EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
      const SizedBox(height: 24),
    ],
  );
}

BoxDecoration _quickCardDecoration({Color? color}) {
  return BoxDecoration(
    color: color ?? Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: const [
      BoxShadow(color: _quickCardShadow, blurRadius: 20, offset: Offset(0, 12)),
    ],
  );
}

Widget _buildQuickSurface({
  required Widget child,
  EdgeInsetsGeometry margin = EdgeInsets.zero,
  EdgeInsetsGeometry padding = const EdgeInsets.all(24),
}) {
  return Container(
    margin: margin,
    decoration: _quickCardDecoration(),
    child: Padding(padding: padding, child: child),
  );
}

class QuickDeclutterFlowPage extends StatefulWidget {
  const QuickDeclutterFlowPage({
    super.key,
    required this.onItemCreated,
    this.pendingItems = const [],
  });

  final void Function(DeclutterItem item) onItemCreated;
  final List<DeclutterItem> pendingItems;

  @override
  State<QuickDeclutterFlowPage> createState() => _QuickDeclutterFlowPageState();
}

class _QuickDeclutterFlowPageState extends State<QuickDeclutterFlowPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  int _itemsCaptured = 0;

  Future<String?> _saveImagePermanently(String tempPath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final itemsDir = Directory('${appDir.path}/items');
      if (!await itemsDir.exists()) {
        await itemsDir.create(recursive: true);
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(tempPath)}';
      final permanentPath = path.join(itemsDir.path, fileName);

      final tempFile = File(tempPath);
      await tempFile.copy(permanentPath);

      return permanentPath;
    } catch (e) {
      debugPrint('❌ Failed to save image permanently: $e');
      return null;
    }
  }

  Future<void> _takePicture() async {
    setState(() => _isProcessing = true);

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        // Save to permanent storage
        final permanentPath = await _saveImagePermanently(photo.path);
        if (permanentPath != null) {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => _QuickItemReviewPage(
                photoPath: permanentPath,
                onItemCreated: widget.onItemCreated,
                pendingItems: widget.pendingItems,
              ),
            ),
          );
          if (result == true && mounted) {
            setState(() => _itemsCaptured += 1);
          }
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
    final theme = Theme.of(context);
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    return Scaffold(
      backgroundColor: _quickBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickTopBar(
                context,
                currentStep: 0,
                totalSteps: 2,
                title: l10n.quickDeclutterTitle,
              ),
              Expanded(
                child: _buildQuickSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isChinese ? '批量整理物品' : 'Batch Declutter Items',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _quickPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.captureItemToStart,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Items captured counter
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.inbox_outlined,
                              size: 24,
                              color: Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.itemsCaptured,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '$_itemsCaptured',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: _quickPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: _quickPinkOrangeGradient,
                            boxShadow: const [
                              BoxShadow(
                                color: _quickCardShadow,
                                blurRadius: 24,
                                offset: Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.camera_alt_rounded,
                              size: 72,
                              color: Colors.white.withOpacity(0.92),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isProcessing ? null : _takePicture,
                          style: FilledButton.styleFrom(
                            backgroundColor: _quickPrimaryColor,
                          ),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickItemReviewPage extends StatefulWidget {
  const _QuickItemReviewPage({
    required this.photoPath,
    required this.onItemCreated,
    this.pendingItems = const [],
  });

  final String photoPath;
  final void Function(DeclutterItem item) onItemCreated;
  final List<DeclutterItem> pendingItems;

  @override
  State<_QuickItemReviewPage> createState() => _QuickItemReviewPageState();
}

class _QuickItemReviewPageState extends State<_QuickItemReviewPage> {
  final _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  DeclutterCategory _selectedCategory = DeclutterCategory.miscellaneous;
  final AIIdentificationService _aiService = AIIdentificationService();

  bool _isIdentifying = false;
  bool _isAISuggested = false;
  AIIdentificationResult? _aiResult;
  bool _hasInitialized = false;

  // Joy decision state
  int? _joyLevel;
  DeclutterStatus?
  _decision; // null = not decided, keep/discard/donate/etc = decided

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
      final locale = Localizations.localeOf(context);
      print(
        '🎯 Quick Declutter: Starting Qwen AI identification, locale: ${locale.languageCode}',
      );

      // Use Qwen VL Plus for detailed identification
      final result = await _aiService.identifyDetailed(widget.photoPath, locale);

      print(
        '🎯 Quick Declutter: Qwen AI result received: ${result != null ? "name=${result.itemName}, category=${result.suggestedCategory}" : "null"}',
      );

      if (result != null && mounted) {
        setState(() {
          _aiResult = result;
          _nameController.text = result.nameForLocale(locale);
          _selectedCategory = result.suggestedCategory;
          _isAISuggested = true;
        });
        print('🎯 Quick Declutter: UI updated with Qwen AI result');
      }
    } catch (e) {
      print('❌ Quick Declutter: Qwen AI identification error: $e');
      // Silently fail - user can still enter manually
    } finally {
      if (mounted) {
        setState(() => _isIdentifying = false);
      }
    }
  }

  Future<void> _getDetailedInfo() async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    setState(() => _isIdentifying = true);

    try {
      final result = await _aiService.identifyDetailed(
        widget.photoPath,
        locale,
      );
      if (result != null && mounted) {
        setState(() {
          _aiResult = result;
          _nameController.text = result.nameForLocale(locale);
          _selectedCategory = result.suggestedCategory;
          _isAISuggested = true;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.aiIdentificationFailed)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.aiIdentificationFailed)));
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

  Future<void> _handleKeep() async {
    final userId = _currentUserIdOrWarn();
    if (userId == null) return;

    final locale = Localizations.localeOf(context);
    final name = _nameController.text.trim().isEmpty
        ? _unnamedPlaceholder(locale)
        : _nameController.text.trim();
    final nameLocalizations = _buildNameLocalizations(locale, name);

    final item = DeclutterItem(
      id: const Uuid().v4(),
      userId: userId,
      name: name,
      nameLocalizations: nameLocalizations,
      category: _selectedCategory,
      createdAt: DateTime.now(),
      status: DeclutterStatus.keep,
      localPhotoPath: widget.photoPath,
      remotePhotoPath: null,
      joyLevel: 8, // Set joy level to 8 for "Yes, it sparks joy"
    );

    widget.onItemCreated(item);

    setState(() {
      _decision = DeclutterStatus.keep;
      _joyLevel = 8;
    });
  }

  Future<void> _handleLetGo() async {
    final l10n = AppLocalizations.of(context)!;
    final userId = _currentUserIdOrWarn();
    if (userId == null) return;

    final status = await showModalBottomSheet<DeclutterStatus>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final isChinese = Localizations.localeOf(
          sheetContext,
        ).languageCode.toLowerCase().startsWith('zh');
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SingleChildScrollView(
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
                  _buildLetGoOption(
                    sheetContext,
                    icon: Icons.delete_outline,
                    label: l10n.routeDiscard,
                    onTap: () =>
                        Navigator.of(sheetContext).pop(DeclutterStatus.discard),
                  ),
                  _buildLetGoOption(
                    sheetContext,
                    icon: Icons.volunteer_activism_outlined,
                    label: l10n.routeDonation,
                    onTap: () =>
                        Navigator.of(sheetContext).pop(DeclutterStatus.donate),
                  ),
                  _buildLetGoOption(
                    sheetContext,
                    icon: Icons.recycling_outlined,
                    label: l10n.routeRecycle,
                    onTap: () =>
                        Navigator.of(sheetContext).pop(DeclutterStatus.recycle),
                  ),
                  _buildLetGoOption(
                    sheetContext,
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
          ),
        );
      },
    );

    if (status == null || !mounted) {
      return;
    }

    final locale = Localizations.localeOf(context);
    final name = _nameController.text.trim().isEmpty
        ? _unnamedPlaceholder(locale)
        : _nameController.text.trim();
    final nameLocalizations = _buildNameLocalizations(locale, name);

    final item = DeclutterItem(
      id: const Uuid().v4(),
      userId: userId,
      name: name,
      nameLocalizations: nameLocalizations,
      category: _selectedCategory,
      createdAt: DateTime.now(),
      status: status,
      localPhotoPath: widget.photoPath,
      remotePhotoPath: null,
      joyLevel: 3, // Set joy level to 3 for "No, doesn't spark joy"
    );

    widget.onItemCreated(item);

    setState(() {
      _decision = status;
      _joyLevel = 3;
    });
  }

  String? _currentUserIdOrWarn() {
    final userId = _authService.currentUserId;
    if (userId == null) {
      final isChinese = Localizations.localeOf(
        context,
      ).languageCode.toLowerCase().startsWith('zh');
      final message = isChinese
          ? '请先登录以保存数据'
          : 'Please sign in to save your data.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    return userId;
  }

  Widget _buildLetGoOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
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

  Future<void> _continue() async {
    // Pop and return to take another photo
    Navigator.of(context).pop(true);
  }

  String _unnamedPlaceholder(Locale locale) {
    return locale.languageCode.toLowerCase().startsWith('zh')
        ? '未命名物品'
        : 'Unnamed item';
  }

  Map<String, String>? _buildNameLocalizations(Locale locale, String name) {
    final map = <String, String>{};

    if (_aiResult?.localizedNames.isNotEmpty ?? false) {
      map.addAll(_aiResult!.localizedNames);
    }

    final normalized = _localeKey(locale);
    map[locale.languageCode.toLowerCase()] = name;
    map[normalized] = name;

    map.removeWhere((key, value) => value.isEmpty);
    return map.isEmpty ? null : map;
  }

  String _localeKey(Locale locale) {
    final language = locale.languageCode.toLowerCase();
    final country = locale.countryCode?.toLowerCase();
    if (country == null || country.isEmpty) {
      return language;
    }
    return '$language-$country';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Text(l10n.quickDeclutterTitle),
        centerTitle: false,
        backgroundColor: const Color(0xFFF5F5F7),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ListView(
            children: [
              // Photo and item details wrapped in single card - Match Joy Declutter style
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
                        decoration: InputDecoration(
                          labelText: l10n.itemName,
                          hintText: l10n.itemName,
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
                        expandedInsets: EdgeInsets.zero,
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
              ),
              const SizedBox(height: 32),

              // Joy Decision Section (only show if not decided yet)
              if (_decision == null) ...[
                Center(
                  child: Text(
                    isChinese ? '这件物品让你心动吗？' : 'Does it spark joy?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Joy Yes/No buttons - Simple icon design
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _handleLetGo,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: const Icon(
                              Icons.heart_broken_rounded,
                              color: Colors.white,
                              size: 72,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isChinese ? '不心动' : 'No',
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 60),
                    GestureDetector(
                      onTap: _handleKeep,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: Colors.white,
                              size: 72,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isChinese ? '心动' : 'Yes',
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Retake button (only before decision)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _retake,
                    child: Text(l10n.retakePhoto),
                  ),
                ),
              ],

              // After decision: Show Continue button
              if (_decision != null) ...[
                Card(
                  color: const Color(0xFFF0FDF4),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          _decision == DeclutterStatus.keep
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          size: 48,
                          color: _decision == DeclutterStatus.keep
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _decision == DeclutterStatus.keep
                              ? (isChinese ? '已保留' : 'Kept')
                              : (isChinese ? '已决定放手' : 'Decided to let go'),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _continue,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF5ECFB8),
                      minimumSize: const Size.fromHeight(52),
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      isChinese ? '拍摄下一件' : 'Capture Next Item',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => popToHome(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    child: Text(
                      isChinese ? '完成整理' : 'Finish Organizing',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Quick Decision Page - Shows "Does it spark joy?" for pending items
class _QuickDecisionPage extends StatefulWidget {
  const _QuickDecisionPage({
    required this.item,
    required this.onItemCompleted,
    this.pendingItems = const [],
  });

  final DeclutterItem item;
  final Function(DeclutterItem) onItemCompleted;
  final List<DeclutterItem> pendingItems;

  @override
  State<_QuickDecisionPage> createState() => _QuickDecisionPageState();
}

class _QuickDecisionPageState extends State<_QuickDecisionPage> {
  int? _joyLevel;

  Future<void> _handleKeep() async {
    final l10n = AppLocalizations.of(context)!;

    final updatedItem = DeclutterItem(
      id: widget.item.id,
      userId: widget.item.userId,
      name: widget.item.name,
      nameLocalizations: widget.item.nameLocalizations,
      category: widget.item.category,
      createdAt: widget.item.createdAt,
      status: DeclutterStatus.keep,
      localPhotoPath: widget.item.localPhotoPath,
      remotePhotoPath: widget.item.remotePhotoPath,
      joyLevel: _joyLevel,
    );

    widget.onItemCompleted(updatedItem);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.itemSaved)));

    // If there are more pending items, show continue option
    if (widget.pendingItems.isNotEmpty) {
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) {
          final isChinese = Localizations.localeOf(
            context,
          ).languageCode.toLowerCase().startsWith('zh');
          return AlertDialog(
            title: Text(isChinese ? '继续整理？' : 'Continue?'),
            content: Text(
              isChinese
                  ? '还有 ${widget.pendingItems.length} 件物品需要处理'
                  : '${widget.pendingItems.length} item${widget.pendingItems.length > 1 ? 's' : ''} remaining',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(isChinese ? '完成' : 'Done'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.continueButton),
              ),
            ],
          );
        },
      );

      if (mounted) {
        if (shouldContinue == true) {
          // Replace current page with next item
          final nextItem = widget.pendingItems.first;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => _QuickDecisionPage(
                item: nextItem,
                onItemCompleted: widget.onItemCompleted,
                pendingItems: widget.pendingItems.skip(1).toList(),
              ),
            ),
          );
        } else {
          popToHome(context);
        }
      }
    } else {
      if (mounted) {
        popToHome(context);
      }
    }
  }

  Future<void> _handleLetGo() async {
    final l10n = AppLocalizations.of(context)!;

    final status = await showModalBottomSheet<DeclutterStatus>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final isChinese = Localizations.localeOf(
          sheetContext,
        ).languageCode.toLowerCase().startsWith('zh');
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SingleChildScrollView(
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
                  _buildLetGoOption(
                    sheetContext,
                    icon: Icons.delete_outline,
                    label: l10n.routeDiscard,
                    onTap: () =>
                        Navigator.of(sheetContext).pop(DeclutterStatus.discard),
                  ),
                  _buildLetGoOption(
                    sheetContext,
                    icon: Icons.volunteer_activism_outlined,
                    label: l10n.routeDonation,
                    onTap: () =>
                        Navigator.of(sheetContext).pop(DeclutterStatus.donate),
                  ),
                  _buildLetGoOption(
                    sheetContext,
                    icon: Icons.recycling_outlined,
                    label: l10n.routeRecycle,
                    onTap: () =>
                        Navigator.of(sheetContext).pop(DeclutterStatus.recycle),
                  ),
                  _buildLetGoOption(
                    sheetContext,
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
          ),
        );
      },
    );

    if (status == null || !mounted) {
      return;
    }

    final updatedItem = DeclutterItem(
      id: widget.item.id,
      userId: widget.item.userId,
      name: widget.item.name,
      nameLocalizations: widget.item.nameLocalizations,
      category: widget.item.category,
      createdAt: DateTime.now(),
      status: status,
      localPhotoPath: widget.item.localPhotoPath,
      remotePhotoPath: widget.item.remotePhotoPath,
      joyLevel: _joyLevel,
    );

    widget.onItemCompleted(updatedItem);

    if (!mounted) return;

    // If there are more pending items, show continue option
    if (widget.pendingItems.isNotEmpty) {
      final isChinese = Localizations.localeOf(
        context,
      ).languageCode.toLowerCase().startsWith('zh');
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(isChinese ? '继续整理？' : 'Continue?'),
          content: Text(
            isChinese
                ? '还有 ${widget.pendingItems.length} 件物品需要处理'
                : '${widget.pendingItems.length} item${widget.pendingItems.length > 1 ? 's' : ''} remaining',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(isChinese ? '完成' : 'Done'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.continueButton),
            ),
          ],
        ),
      );

      if (mounted) {
        if (shouldContinue == true) {
          final nextItem = widget.pendingItems.first;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => _QuickDecisionPage(
                item: nextItem,
                onItemCompleted: widget.onItemCompleted,
                pendingItems: widget.pendingItems.skip(1).toList(),
              ),
            ),
          );
        } else {
          popToHome(context);
        }
      }
    } else {
      if (mounted) {
        popToHome(context);
      }
    }
  }

  Widget _buildLetGoOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
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

  @override
  Widget build(BuildContext context) {
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _quickBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickTopBar(
                context,
                currentStep: 1,
                totalSteps: 2,
                title: isChinese ? '快速整理' : 'Quick Declutter',
              ),
              Expanded(
                child: ListView(
                  children: [
                    _buildQuickSurface(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Photo
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: AspectRatio(
                              aspectRatio: 4 / 3,
                              child: () {
                                  final photoPath = widget.item.localPhotoPath ?? widget.item.remotePhotoPath;
                                  if (photoPath == null || photoPath.isEmpty) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.photo_camera_outlined,
                                        size: 80,
                                        color: Colors.black45,
                                      ),
                                    );
                                  }
                                  return Image.file(
                                    File(photoPath),
                                    fit: BoxFit.cover,
                                  );
                                }(),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Item name
                          Text(
                            widget.item.displayName(context),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _quickPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Category
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.item.category.label(context),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // "Does it spark joy?" question
                          Text(
                            isChinese ? '这件物品让你心动吗？' : 'Does it spark joy?',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _quickPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Joy level slider
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isChinese ? '不心动' : 'No Joy',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  Text(
                                    isChinese ? '很心动' : 'Sparks Joy',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: _joyLevel?.toDouble() ?? 5,
                                min: 0,
                                max: 10,
                                divisions: 10,
                                label: _joyLevel?.toString() ?? '5',
                                activeColor: const Color(0xFF5ECFB8),
                                onChanged: (value) {
                                  setState(() => _joyLevel = value.toInt());
                                },
                              ),
                              if (_joyLevel != null)
                                Center(
                                  child: Text(
                                    '${isChinese ? '心动指数' : 'Joy Level'}: $_joyLevel/10',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: _quickPrimaryColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Keep/Let Go buttons
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _handleKeep,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              minimumSize: const Size.fromHeight(48),
                            ),
                            icon: const Icon(Icons.favorite_rounded),
                            label: Text(isChinese ? '保留' : 'Keep'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handleLetGo,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEF4444),
                              side: const BorderSide(color: Color(0xFFEF4444)),
                              minimumSize: const Size.fromHeight(48),
                            ),
                            icon: const Icon(Icons.close_rounded),
                            label: Text(isChinese ? '放手' : 'Let Go'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
