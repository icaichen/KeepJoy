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

const Color _joyBackgroundColor = Color(0xFFF5F5F7);
const Color _joyPrimaryColor = Color(0xFF111827);
const Color _joyCardShadow = Color(0x11000000);

Widget _buildJoyTopBar(
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
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
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
              color: index <= currentStep ? _joyPrimaryColor : const Color(0xFFE0E5EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
      const SizedBox(height: 24),
    ],
  );
}

BoxDecoration _joyCardDecoration({Color? color}) {
  return BoxDecoration(
    color: color ?? Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: const [
      BoxShadow(
        color: _joyCardShadow,
        blurRadius: 20,
        offset: Offset(0, 12),
      ),
    ],
  );
}

Widget _buildJoySurface({
  required Widget child,
  EdgeInsetsGeometry margin = EdgeInsets.zero,
  EdgeInsetsGeometry padding = const EdgeInsets.all(24),
}) {
  return Container(
    margin: margin,
    decoration: _joyCardDecoration(),
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
    final isChinese = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('zh');

    return Scaffold(
      backgroundColor: _joyBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildJoyTopBar(
                context,
                currentStep: 0,
                totalSteps: 8,
                title: l10n.joyDeclutterTitle,
              ),
              Expanded(
                child: _buildJoySurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.joyDeclutterCaptureTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _joyPrimaryColor,
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
                      const SizedBox(height: 24),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: _joyMintPurpleGradient,
                            boxShadow: const [
                              BoxShadow(
                                color: _joyCardShadow,
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
                            backgroundColor: _joyPrimaryColor,
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
              const SizedBox(height: 16),
              Text(
                isChinese
                    ? '拍攝物品，我們會陪你完成怦然心動檢查。'
                    : 'Capture one item—we will guide you through the decision.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Store answers for the 5 questions
class _JoyAnswers {
  String? lastUsed; // "< 1 month", "1-6 months", "6-12 months", "> 1 year"
  bool? hasDuplicate; // true/false
  bool? wouldBuyAgain; // true/false
  bool? fitsLifestyle; // true/false
  bool? sunkCost; // true/false
}

const int _joyQuestionCount = 5;

class _JoyQuestionDefinition {
  final int questionNumber;
  final int currentStep;
  final String Function(AppLocalizations) promptBuilder;
  final List<_JoyQuestionOption> options;
  final void Function(_JoyAnswers, Object value) saveAnswer;

  const _JoyQuestionDefinition({
    required this.questionNumber,
    required this.currentStep,
    required this.promptBuilder,
    required this.options,
    required this.saveAnswer,
  });
}

class _JoyQuestionOption {
  final Object value;
  final String Function(AppLocalizations) labelBuilder;

  const _JoyQuestionOption(this.value, this.labelBuilder);
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

  void _startQuestions() {
    final l10n = AppLocalizations.of(context)!;
    final itemName = _nameController.text.trim().isEmpty
        ? (_itemName ?? l10n.itemName)
        : _nameController.text.trim();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _createJoyQuestionPage(
          questionIndex: 0,
          answers: _JoyAnswers(),
          photoPath: widget.photoPath,
          itemName: itemName,
          category: _selectedCategory,
          onItemCompleted: widget.onItemCompleted,
          onMemoryCreated: widget.onMemoryCreated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _joyBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildJoyTopBar(
                context,
                currentStep: 1,
                totalSteps: 8,
                title: l10n.joyDeclutterTitle,
              ),
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
                    OutlinedButton(
                      onPressed: _retakePicture,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _joyPrimaryColor,
                        side: BorderSide(
                          color: _joyPrimaryColor.withValues(alpha: 0.4),
                        ),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(l10n.retakePhoto),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _startQuestions,
                      style: FilledButton.styleFrom(
                        backgroundColor: _joyPrimaryColor,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(l10n.continueButton),
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

Widget _createJoyQuestionPage({
  required int questionIndex,
  required _JoyAnswers answers,
  required String photoPath,
  required String itemName,
  required DeclutterCategory category,
  required Function(DeclutterItem) onItemCompleted,
  required Function(Memory) onMemoryCreated,
}) {
  final definition = _joyQuestionDefinition(questionIndex);
  return _JoyQuestionPage(
    definition: definition,
    totalQuestions: _joyQuestionCount,
    onNext: (context, value) {
      definition.saveAnswer(answers, value);
      if (questionIndex + 1 < _joyQuestionCount) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _createJoyQuestionPage(
              questionIndex: questionIndex + 1,
              answers: answers,
              photoPath: photoPath,
              itemName: itemName,
              category: category,
              onItemCompleted: onItemCompleted,
              onMemoryCreated: onMemoryCreated,
            ),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _SummaryPage(
              photoPath: photoPath,
              itemName: itemName,
              category: category,
              answers: answers,
              onItemCompleted: onItemCompleted,
              onMemoryCreated: onMemoryCreated,
            ),
          ),
        );
      }
    },
  );
}

class _JoyQuestionPage extends StatefulWidget {
  final _JoyQuestionDefinition definition;
  final int totalQuestions;
  final void Function(BuildContext context, Object value) onNext;

  const _JoyQuestionPage({
    required this.definition,
    required this.totalQuestions,
    required this.onNext,
  });

  @override
  State<_JoyQuestionPage> createState() => _JoyQuestionPageState();
}

class _JoyQuestionPageState extends State<_JoyQuestionPage> {
  Object? _selectedValue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _joyBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildJoyTopBar(
                context,
                currentStep: widget.definition.currentStep,
                totalSteps: 8,
                title: l10n.joyDeclutterTitle,
              ),
              Expanded(
                child: _buildJoySurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.joyQuestionProgress(
                          widget.definition.questionNumber,
                          widget.totalQuestions,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.definition.promptBuilder(l10n),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _joyPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...widget.definition.options.map(
                        (option) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _OptionButton(
                            label: option.labelBuilder(l10n),
                            isSelected: option.value == _selectedValue,
                            onTap: () {
                              setState(() {
                                _selectedValue = option.value;
                              });
                            },
                          ),
                        ),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: _selectedValue == null
                            ? null
                            : () => widget.onNext(context, _selectedValue!),
                        style: FilledButton.styleFrom(
                          backgroundColor: _joyPrimaryColor,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: Text(l10n.next),
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

_JoyQuestionDefinition _joyQuestionDefinition(int questionIndex) {
  switch (questionIndex) {
    case 0:
      return _JoyQuestionDefinition(
        questionNumber: 1,
        currentStep: 2,
        promptBuilder: (l10n) => l10n.joyQuestion1Prompt,
        options: [
          _JoyQuestionOption(
            '< 1 month',
            (l10n) => l10n.joyQuestionOptionLessThanMonth,
          ),
          _JoyQuestionOption(
            '1-6 months',
            (l10n) => l10n.joyQuestionOption1To6Months,
          ),
          _JoyQuestionOption(
            '6-12 months',
            (l10n) => l10n.joyQuestionOption6To12Months,
          ),
          _JoyQuestionOption(
            '> 1 year',
            (l10n) => l10n.joyQuestionOptionMoreThanYear,
          ),
        ],
        saveAnswer: (answers, value) {
          answers.lastUsed = value as String;
        },
      );
    case 1:
      return _JoyQuestionDefinition(
        questionNumber: 2,
        currentStep: 3,
        promptBuilder: (l10n) => l10n.joyQuestion2Prompt,
        options: [
          _JoyQuestionOption(true, (l10n) => l10n.joyQuestion2Yes),
          _JoyQuestionOption(false, (l10n) => l10n.joyQuestion2No),
        ],
        saveAnswer: (answers, value) {
          answers.hasDuplicate = value as bool;
        },
      );
    case 2:
      return _JoyQuestionDefinition(
        questionNumber: 3,
        currentStep: 4,
        promptBuilder: (l10n) => l10n.joyQuestion3Prompt,
        options: [
          _JoyQuestionOption(true, (l10n) => l10n.joyQuestion3Yes),
          _JoyQuestionOption(false, (l10n) => l10n.joyQuestion3No),
        ],
        saveAnswer: (answers, value) {
          answers.wouldBuyAgain = value as bool;
        },
      );
    case 3:
      return _JoyQuestionDefinition(
        questionNumber: 4,
        currentStep: 5,
        promptBuilder: (l10n) => l10n.joyQuestion4Prompt,
        options: [
          _JoyQuestionOption(true, (l10n) => l10n.joyQuestion4Yes),
          _JoyQuestionOption(false, (l10n) => l10n.joyQuestion4No),
        ],
        saveAnswer: (answers, value) {
          answers.fitsLifestyle = value as bool;
        },
      );
    case 4:
      return _JoyQuestionDefinition(
        questionNumber: 5,
        currentStep: 6,
        promptBuilder: (l10n) => l10n.joyQuestion5Prompt,
        options: [
          _JoyQuestionOption(true, (l10n) => l10n.joyQuestion5Yes),
          _JoyQuestionOption(false, (l10n) => l10n.joyQuestion5No),
        ],
        saveAnswer: (answers, value) {
          answers.sunkCost = value as bool;
        },
      );
    default:
      throw ArgumentError('Unsupported joy question index: $questionIndex');
  }
}






// Summary page showing objective insights
class _SummaryPage extends StatelessWidget {
  final String photoPath;
  final String itemName;
  final DeclutterCategory category;
  final _JoyAnswers answers;
  final Function(DeclutterItem) onItemCompleted;
  final Function(Memory) onMemoryCreated;

  const _SummaryPage({
    required this.photoPath,
    required this.itemName,
    required this.category,
    required this.answers,
    required this.onItemCompleted,
    required this.onMemoryCreated,
  });

  List<String> _getInsights(bool isChinese) {
    final insights = <String>[];

    // Last used insight
    if (answers.lastUsed == '> 1 year') {
      insights.add(isChinese ? '• 超过一年未使用' : '• Unused for over a year');
    } else if (answers.lastUsed == '6-12 months') {
      insights.add(isChinese ? '• 6-12个月未使用' : '• Unused for 6-12 months');
    }

    // Duplicate insight
    if (answers.hasDuplicate == true) {
      insights.add(isChinese ? '• 有其他类似物品可用' : '• Similar items available');
    }

    // Would buy again insight
    if (answers.wouldBuyAgain == false) {
      insights.add(isChinese ? '• 不会再次购买' : '• Would not purchase again');
    }

    // Lifestyle fit insight
    if (answers.fitsLifestyle == false) {
      insights.add(isChinese ? '• 不符合当前生活方式' : '• Does not fit current lifestyle');
    }

    // Sunk cost insight
    if (answers.sunkCost == true) {
      insights.add(isChinese ? '• 因沉没成本而保留' : '• Keeping due to sunk cost');
    }

    return insights;
  }

  Future<void> _handleKeep(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final item = DeclutterItem(
      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
      name: itemName,
      category: category,
      createdAt: DateTime.now(),
      status: DeclutterStatus.keep,
      photoPath: photoPath,
    );

    onItemCompleted(item);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.itemSaved)),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _handleLetGo(BuildContext context) async {
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

    if (status == null || !context.mounted) {
      return;
    }

    final item = DeclutterItem(
      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
      name: itemName,
      category: category,
      createdAt: DateTime.now(),
      status: status,
      photoPath: photoPath,
    );

    onItemCompleted(item);

    if (!context.mounted) return;

    // Show memory prompt
    final shouldCreateMemory = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.createMemoryQuestion),
        content: Text(l10n.createMemoryPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.skipMemory),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.createMemory),
          ),
        ],
      ),
    );

    if (shouldCreateMemory == true && context.mounted) {
      final memory = await Navigator.of(context).push<Memory>(
        MaterialPageRoute(
          builder: (_) => CreateMemoryPage(
            item: item,
            photoPath: photoPath,
            itemName: itemName,
          ),
        ),
      );

      if (memory != null) {
        onMemoryCreated(memory);
      }
    }

    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isChinese = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('zh');
    final theme = Theme.of(context);
    final insights = _getInsights(isChinese);

    return Scaffold(
      backgroundColor: _joyBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildJoyTopBar(
                context,
                currentStep: 7,
                totalSteps: 8,
                title: isChinese ? '心动整理' : 'Joy Declutter',
              ),
              Expanded(
                child: ListView(
                  children: [
                    _buildJoySurface(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: AspectRatio(
                              aspectRatio: 4 / 3,
                              child: photoPath.isEmpty
                                  ? Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.photo_camera_outlined,
                                        size: 60,
                                        color: Colors.black45,
                                      ),
                                    )
                                  : Image.file(
                                      File(photoPath),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            itemName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _joyPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            isChinese ? '根据你的回答' : 'Based on your answers',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (insights.isEmpty)
                            Text(
                              isChinese ? '这件物品似乎对你很有价值' : 'This item seems valuable to you',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF374151),
                                height: 1.5,
                              ),
                            )
                          else
                            ...insights.map((insight) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    insight,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF374151),
                                      height: 1.5,
                                    ),
                                  ),
                                )),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.auto_awesome_outlined,
                                  size: 20,
                                  color: Color(0xFF6B7280),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    isChinese
                                        ? '感谢过去的自己选择了它，现在可以怀着感激之心放手了。'
                                        : 'Thank the item for its service, and let it go with gratitude.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF6B7280),
                                      height: 1.4,
                                    ),
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
                            onPressed: () => _handleKeep(context),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: Text(isChinese ? '保留' : 'Keep'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _handleLetGo(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEF4444),
                              side: const BorderSide(
                                color: Color(0xFFEF4444),
                              ),
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: Text(isChinese ? '放手' : 'Let Go'),
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

// Option button widget
class _OptionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _joyPrimaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _joyPrimaryColor : const Color(0xFFE5E7EB),
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF374151),
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
