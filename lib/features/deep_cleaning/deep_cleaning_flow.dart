import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../l10n/app_localizations.dart';
import '../../models/deep_cleaning_session.dart';
import '../../services/messiness_analysis_service.dart';
import '../../utils/navigation.dart';

const Color _deepCleaningBackgroundColor = Color(0xFFF5F5F7);
const Color _deepCleaningPrimaryColor = Color(0xFF111827);
const Color _deepCleaningCardShadow = Color(0x14000000);
const int _deepCleaningTotalSteps = 5;

Widget _buildDeepCleaningTopBar(
  BuildContext context, {
  required int currentStep,
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
          _deepCleaningTotalSteps,
          (index) => Container(
            width: 24,
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: index <= currentStep
                  ? _deepCleaningPrimaryColor
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

BoxDecoration _deepCleaningCardDecoration({Color? color}) {
  return BoxDecoration(
    color: color ?? Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [
      BoxShadow(
        color: _deepCleaningCardShadow,
        blurRadius: 16,
        offset: Offset(0, 8),
      ),
    ],
  );
}

class DeepCleaningFlowPage extends StatefulWidget {
  final Function(String area, {String? beforePhotoPath}) onStartSession;
  final void Function({
    String? afterPhotoPath,
    int? elapsedSeconds,
    int? itemsCount,
    int? focusIndex,
    int? moodIndex,
    double? beforeMessinessIndex,
    double? afterMessinessIndex,
  })
  onStopSession;

  const DeepCleaningFlowPage({
    super.key,
    required this.onStartSession,
    required this.onStopSession,
  });

  @override
  State<DeepCleaningFlowPage> createState() => _DeepCleaningFlowPageState();
}

class _DeepCleaningFlowPageState extends State<DeepCleaningFlowPage> {
  final TextEditingController _areaController = TextEditingController();

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    // Get all cleaning areas from enum
    final areas = CleaningArea.values;

    final selectedAreaText = _areaController.text.trim();

    return Scaffold(
      backgroundColor: _deepCleaningBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.025,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDeepCleaningTopBar(
                context,
                currentStep: 0,
                title: l10n.deepCleaningTitle,
              ),
              Text(
                isChinese
                    ? '今天你想专注哪些区域？'
                    : 'Which areas do you want to focus on today?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _deepCleaningPrimaryColor,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: screenWidth * 0.08,
                        runSpacing: screenHeight * 0.05,
                        children: areas
                            .map(
                              (area) => _buildCircle(
                                context,
                                screenWidth,
                                area,
                                isSelected:
                                    area.label(context) == selectedAreaText,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 28),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              isChinese ? '输入整理区域' : 'Enter the Area',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _deepCleaningPrimaryColor,
                                  ),
                            ),
                          ),
                          TextField(
                            controller: _areaController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: '',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE1E7EF),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE1E7EF),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: _deepCleaningPrimaryColor,
                                  width: 1.5,
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _deepCleaningPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final area = _areaController.text.trim();
                    if (area.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isChinese ? '请输入区域名称' : 'Please enter an area name',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BeforePhotoPage(
                          area: area,
                          onStartSession: widget.onStartSession,
                          onStopSession: widget.onStopSession,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    l10n.continueButton,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircle(
    BuildContext context,
    double screenWidth,
    CleaningArea area, {
    required bool isSelected,
  }) {
    final diameter = screenWidth * 0.22;

    // Map areas to icons
    IconData getIconForArea(CleaningArea area) {
      switch (area) {
        case CleaningArea.livingRoom:
          return Icons.weekend_outlined;
        case CleaningArea.bedroom:
          return Icons.bed_outlined;
        case CleaningArea.wardrobe:
          return Icons.checkroom_outlined;
        case CleaningArea.bookshelf:
          return Icons.book_outlined;
        case CleaningArea.kitchen:
          return Icons.kitchen_outlined;
        case CleaningArea.desk:
          return Icons.desk_outlined;
      }
    }

    final label = area.label(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _areaController.text = area.label(
                context,
              ); // Store the localized label
            });
          },
          borderRadius: BorderRadius.circular(diameter / 2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? _deepCleaningPrimaryColor : Colors.white,
              border: Border.all(
                color: isSelected
                    ? _deepCleaningPrimaryColor
                    : const Color(0xFFE1E7EF),
                width: 1.5,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              getIconForArea(area),
              size: 26,
              color: isSelected ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: diameter,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? _deepCleaningPrimaryColor
                  : const Color(0xFF6B7280),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Before Photo Page
class BeforePhotoPage extends StatefulWidget {
  final String area;
  final Function(String area, {String? beforePhotoPath}) onStartSession;
  final void Function({
    String? afterPhotoPath,
    int? elapsedSeconds,
    int? itemsCount,
    int? focusIndex,
    int? moodIndex,
    double? beforeMessinessIndex,
    double? afterMessinessIndex,
  })
  onStopSession;

  const BeforePhotoPage({
    super.key,
    required this.area,
    required this.onStartSession,
    required this.onStopSession,
  });

  @override
  State<BeforePhotoPage> createState() => _BeforePhotoPageState();
}

class _BeforePhotoPageState extends State<BeforePhotoPage> {
  final ImagePicker _picker = ImagePicker();
  String? _photoPath;
  bool _isProcessing = false;

  Future<String?> _saveImagePermanently(String tempPath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final sessionsDir = Directory('${appDir.path}/sessions');
      if (!await sessionsDir.exists()) {
        await sessionsDir.create(recursive: true);
      }

      final fileName =
          'before_${DateTime.now().millisecondsSinceEpoch}${path.extension(tempPath)}';
      final permanentPath = path.join(sessionsDir.path, fileName);

      final tempFile = File(tempPath);
      await tempFile.copy(permanentPath);

      return permanentPath;
    } catch (e) {
      debugPrint('❌ Failed to save image permanently: $e');
      return null;
    }
  }

  Future<void> _takePicture() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        // Save to permanent storage
        final permanentPath = await _saveImagePermanently(photo.path);
        if (permanentPath != null) {
          setState(() {
            _photoPath = permanentPath;
          });
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
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _continue() {
    // Start session with before photo - the session start time is managed by parent
    widget.onStartSession(widget.area, beforePhotoPath: _photoPath);

    // Navigate to timer - pass the current time as start time for new sessions
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeepCleaningTimerPage(
          area: widget.area,
          beforePhotoPath: _photoPath,
          onStopSession: widget.onStopSession,
          sessionStartTime: DateTime.now(), // New session starts now
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _deepCleaningBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.025,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDeepCleaningTopBar(
                context,
                currentStep: 1,
                title: l10n.deepCleaningTitle,
              ),
              Text(
                l10n.beforePhoto,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _deepCleaningPrimaryColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.area,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _deepCleaningPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.captureBeforeState,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Expanded(
                child: Container(
                  decoration: _deepCleaningCardDecoration(),
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: _photoPath != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  File(_photoPath!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: IconButton.filledTonal(
                                  onPressed: _takePicture,
                                  icon: const Icon(Icons.refresh),
                                  tooltip: l10n.retakePhoto,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 44,
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noPhotoTaken,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _deepCleaningPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.captureBeforeState,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              if (_photoPath == null) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _isProcessing ? null : _takePicture,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(l10n.takeBeforePhoto),
                    style: FilledButton.styleFrom(
                      backgroundColor: _deepCleaningPrimaryColor,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _continue,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _deepCleaningPrimaryColor,
                      side: BorderSide(
                        color: _deepCleaningPrimaryColor.withOpacity(0.4),
                      ),
                    ),
                    child: Text(l10n.skipPhoto),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _continue,
                    style: FilledButton.styleFrom(
                      backgroundColor: _deepCleaningPrimaryColor,
                    ),
                    child: Text(l10n.continueButton),
                  ),
                ),
              ],
              SizedBox(height: screenHeight * 0.01),
            ],
          ),
        ),
      ),
    );
  }
}

// Timer page
class DeepCleaningTimerPage extends StatefulWidget {
  final String area;
  final String? beforePhotoPath;
  final void Function({
    String? afterPhotoPath,
    int? elapsedSeconds,
    int? itemsCount,
    int? focusIndex,
    int? moodIndex,
    double? beforeMessinessIndex,
    double? afterMessinessIndex,
  })
  onStopSession;
  final DateTime? sessionStartTime; // Add start time from active session

  const DeepCleaningTimerPage({
    super.key,
    required this.area,
    this.beforePhotoPath,
    required this.onStopSession,
    this.sessionStartTime,
  });

  @override
  State<DeepCleaningTimerPage> createState() => _DeepCleaningTimerPageState();
}

class _DeepCleaningTimerPageState extends State<DeepCleaningTimerPage>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  bool _isRunning = false;
  late AnimationController _pulseController;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    // Use provided start time or create new one
    _startTime = widget.sessionStartTime ?? DateTime.now();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Auto-start timer if resuming from an existing session
    if (widget.sessionStartTime != null) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  int get _elapsedSeconds {
    // Calculate elapsed time from start time to now
    return DateTime.now().difference(_startTime).inSeconds;
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Just trigger rebuild to update elapsed time
        });
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
  }

  void _showFinishConfirmation(AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: _deepCleaningCardShadow,
                blurRadius: 20,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFFAF3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.task_alt_rounded,
                  color: _deepCleaningPrimaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.finishCleaning,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _deepCleaningPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.finishCleaningConfirm,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4B5563),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _deepCleaningPrimaryColor,
                        side: BorderSide(
                          color: _deepCleaningPrimaryColor.withOpacity(0.3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _finishCleaning();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: _deepCleaningPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(l10n.finish),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _finishCleaning() {
    // Pause timer first
    _pauseTimer();

    // Navigate to After Photo page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AfterPhotoPage(
          area: widget.area,
          beforePhotoPath: widget.beforePhotoPath,
          elapsedSeconds: _elapsedSeconds,
          onStopSession: widget.onStopSession,
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _deepCleaningBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.025,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDeepCleaningTopBar(
                context,
                currentStep: 2,
                title: l10n.deepCleaningTitle,
              ),
              Text(
                l10n.deepCleaningTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _deepCleaningPrimaryColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.area,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _deepCleaningPrimaryColor,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Expanded(
                child: Container(
                  decoration: _deepCleaningCardDecoration(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.6,
                        height: screenWidth * 0.6,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_isRunning)
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  final expansion = _pulseController.value * 20;
                                  return Container(
                                    width: screenWidth * 0.6 + expansion,
                                    height: screenWidth * 0.6 + expansion,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.2),
                                        width: 2,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            Container(
                              width: screenWidth * 0.58,
                              height: screenWidth * 0.58,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.primary.withOpacity(
                                  0.08,
                                ),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.28,
                                  ),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _formatTime(_elapsedSeconds),
                                    style: theme.textTheme.displaySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.primary,
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _isRunning
                                        ? (Localizations.localeOf(
                                                    context,
                                                  ).languageCode ==
                                                  'zh'
                                              ? '专注整理中'
                                              : 'Cleaning in progress')
                                        : (_elapsedSeconds > 0
                                              ? (Localizations.localeOf(
                                                          context,
                                                        ).languageCode ==
                                                        'zh'
                                                    ? '已暂停'
                                                    : 'Paused')
                                              : (Localizations.localeOf(
                                                          context,
                                                        ).languageCode ==
                                                        'zh'
                                                    ? '准备开始'
                                                    : 'Ready to start')),
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: _isRunning
                            ? FilledButton.icon(
                                onPressed: _pauseTimer,
                                icon: const Icon(Icons.pause),
                                label: Text(
                                  Localizations.localeOf(
                                            context,
                                          ).languageCode ==
                                          'zh'
                                      ? '暂停'
                                      : 'Pause',
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: _deepCleaningPrimaryColor,
                                  textStyle: const TextStyle(fontSize: 18),
                                ),
                              )
                            : FilledButton.icon(
                                onPressed: _startTimer,
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: Text(
                                  _elapsedSeconds > 0
                                      ? (Localizations.localeOf(
                                                  context,
                                                ).languageCode ==
                                                'zh'
                                            ? '继续'
                                            : 'Resume')
                                      : (Localizations.localeOf(
                                                  context,
                                                ).languageCode ==
                                                'zh'
                                            ? '开始'
                                            : 'Start'),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: _deepCleaningPrimaryColor,
                                  textStyle: const TextStyle(fontSize: 18),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        popToHome(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _deepCleaningPrimaryColor,
                        side: BorderSide(
                          color: _deepCleaningPrimaryColor.withOpacity(0.4),
                        ),
                      ),
                      child: Text(l10n.minimize),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _showFinishConfirmation(l10n),
                      style: FilledButton.styleFrom(
                        backgroundColor: _deepCleaningPrimaryColor,
                      ),
                      child: Text(l10n.finish),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
            ],
          ),
        ),
      ),
    );
  }
}

// After Photo Page
class AfterPhotoPage extends StatefulWidget {
  final String area;
  final String? beforePhotoPath;
  final int elapsedSeconds;
  final void Function({
    String? afterPhotoPath,
    int? elapsedSeconds,
    int? itemsCount,
    int? focusIndex,
    int? moodIndex,
    double? beforeMessinessIndex,
    double? afterMessinessIndex,
  })
  onStopSession;

  const AfterPhotoPage({
    super.key,
    required this.area,
    this.beforePhotoPath,
    required this.elapsedSeconds,
    required this.onStopSession,
  });

  @override
  State<AfterPhotoPage> createState() => _AfterPhotoPageState();
}

class _AfterPhotoPageState extends State<AfterPhotoPage> {
  final ImagePicker _picker = ImagePicker();
  String? _photoPath;
  bool _isProcessing = false;

  Future<String?> _saveImagePermanently(String tempPath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final sessionsDir = Directory('${appDir.path}/sessions');
      if (!await sessionsDir.exists()) {
        await sessionsDir.create(recursive: true);
      }

      final fileName =
          'after_${DateTime.now().millisecondsSinceEpoch}${path.extension(tempPath)}';
      final permanentPath = path.join(sessionsDir.path, fileName);

      final tempFile = File(tempPath);
      await tempFile.copy(permanentPath);

      return permanentPath;
    } catch (e) {
      debugPrint('❌ Failed to save image permanently: $e');
      return null;
    }
  }

  Future<void> _takePicture() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        // Save to permanent storage
        final permanentPath = await _saveImagePermanently(photo.path);
        if (permanentPath != null) {
          setState(() {
            _photoPath = permanentPath;
          });
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
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _continue() {
    // Navigate to User Input page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserInputPage(
          area: widget.area,
          beforePhotoPath: widget.beforePhotoPath,
          afterPhotoPath: _photoPath,
          elapsedSeconds: widget.elapsedSeconds,
          onStopSession: widget.onStopSession,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _deepCleaningBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.025,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDeepCleaningTopBar(
                context,
                currentStep: 3,
                title: l10n.deepCleaningTitle,
              ),
              Text(
                l10n.afterPhoto,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _deepCleaningPrimaryColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.area,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _deepCleaningPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.captureAfterState,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Expanded(
                child: Container(
                  decoration: _deepCleaningCardDecoration(),
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: _photoPath != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  File(_photoPath!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: IconButton.filledTonal(
                                  onPressed: _takePicture,
                                  icon: const Icon(Icons.refresh),
                                  tooltip: l10n.retakePhoto,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 44,
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noPhotoTaken,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _deepCleaningPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.captureAfterState,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              if (_photoPath == null) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _isProcessing ? null : _takePicture,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(l10n.takeAfterPhoto),
                    style: FilledButton.styleFrom(
                      backgroundColor: _deepCleaningPrimaryColor,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _continue,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _deepCleaningPrimaryColor,
                      side: BorderSide(
                        color: _deepCleaningPrimaryColor.withOpacity(0.4),
                      ),
                    ),
                    child: Text(l10n.skipPhoto),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _continue,
                    style: FilledButton.styleFrom(
                      backgroundColor: _deepCleaningPrimaryColor,
                    ),
                    child: Text(l10n.continueButton),
                  ),
                ),
              ],
              SizedBox(height: screenHeight * 0.01),
            ],
          ),
        ),
      ),
    );
  }
}

// User Input Page
class UserInputPage extends StatefulWidget {
  final String area;
  final String? beforePhotoPath;
  final String? afterPhotoPath;
  final int elapsedSeconds;
  final void Function({
    String? afterPhotoPath,
    int? elapsedSeconds,
    int? itemsCount,
    int? focusIndex,
    int? moodIndex,
    double? beforeMessinessIndex,
    double? afterMessinessIndex,
  })
  onStopSession;

  const UserInputPage({
    super.key,
    required this.area,
    this.beforePhotoPath,
    this.afterPhotoPath,
    required this.elapsedSeconds,
    required this.onStopSession,
  });

  @override
  State<UserInputPage> createState() => _UserInputPageState();
}

class _UserInputPageState extends State<UserInputPage> {
  final TextEditingController _itemsController = TextEditingController(
    text: '0',
  );
  double _focusIndex = 3.0; // Changed to 0-5 scale, starting at middle
  double _moodIndex = 3.0; // Changed to 0-5 scale, starting at middle

  @override
  void dispose() {
    _itemsController.dispose();
    super.dispose();
  }

  void _continue() {
    final itemsCount = int.tryParse(_itemsController.text) ?? 0;

    // Navigate to Summary page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SummaryPage(
          area: widget.area,
          beforePhotoPath: widget.beforePhotoPath,
          afterPhotoPath: widget.afterPhotoPath,
          elapsedSeconds: widget.elapsedSeconds,
          itemsCount: itemsCount,
          focusIndex: _focusIndex.round(),
          moodIndex: _moodIndex.round(),
          onStopSession: widget.onStopSession,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _deepCleaningBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.025,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDeepCleaningTopBar(
                context,
                currentStep: 4,
                title: l10n.deepCleaningTitle,
              ),
              Text(
                widget.area,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _deepCleaningPrimaryColor,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Container(
                decoration: _deepCleaningCardDecoration(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.howManyItems,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _deepCleaningPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _itemsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: l10n.enterItemsCount,
                        prefixIcon: const Icon(Icons.inventory_2_outlined),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE1E7EF),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: _deepCleaningPrimaryColor.withOpacity(0.6),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.035),
                    Text(
                      l10n.focusIndex,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _deepCleaningPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.focusIndexDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _focusIndex,
                            min: 0,
                            max: 5,
                            divisions: 5,
                            label: _focusIndex.round().toString(),
                            onChanged: (value) {
                              setState(() => _focusIndex = value);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 52,
                          child: Text(
                            _focusIndex.round().toString(),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.035),
                    Text(
                      l10n.moodIndex,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _deepCleaningPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.moodIndexDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _moodIndex,
                            min: 0,
                            max: 5,
                            divisions: 5,
                            label: _moodIndex.round().toString(),
                            onChanged: (value) {
                              setState(() => _moodIndex = value);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 52,
                          child: Text(
                            _moodIndex.round().toString(),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _continue,
                  style: FilledButton.styleFrom(
                    backgroundColor: _deepCleaningPrimaryColor,
                  ),
                  child: Text(l10n.continueButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Summary Page
class SummaryPage extends StatefulWidget {
  final String area;
  final String? beforePhotoPath;
  final String? afterPhotoPath;
  final int elapsedSeconds;
  final int itemsCount;
  final int focusIndex;
  final int moodIndex;
  final void Function({
    String? afterPhotoPath,
    int? elapsedSeconds,
    int? itemsCount,
    int? focusIndex,
    int? moodIndex,
    double? beforeMessinessIndex,
    double? afterMessinessIndex,
  })
  onStopSession;

  const SummaryPage({
    super.key,
    required this.area,
    this.beforePhotoPath,
    this.afterPhotoPath,
    required this.elapsedSeconds,
    required this.itemsCount,
    required this.focusIndex,
    required this.moodIndex,
    required this.onStopSession,
  });

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final MessinessAnalysisService _messinessService = MessinessAnalysisService();
  double? _beforeMessiness;
  double? _afterMessiness;
  bool _isAnalyzing = true;

  @override
  void initState() {
    super.initState();
    _analyzePhotos();
  }

  @override
  void dispose() {
    _messinessService.dispose();
    super.dispose();
  }

  Future<void> _analyzePhotos() async {
    try {
      await _messinessService.initialize();

      // Analyze before photo if available
      if (widget.beforePhotoPath != null) {
        _beforeMessiness = await _messinessService.analyzeMessiness(
          widget.beforePhotoPath!,
        );
      }

      // Analyze after photo if available
      if (widget.afterPhotoPath != null) {
        _afterMessiness = await _messinessService.analyzeMessiness(
          widget.afterPhotoPath!,
        );
      }

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      print('Error analyzing photos: $e');
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          // Don't use fallback values - leave as null
        });
      }
    }
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    }
    return '${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    // Calculate improvement percentage only if we have messiness data
    final hasMessinessData =
        _beforeMessiness != null && _afterMessiness != null;
    final improvement = hasMessinessData
        ? ((_beforeMessiness! - _afterMessiness!) / _beforeMessiness! * 100)
              .round()
        : 0;

    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F7),
        elevation: 0,
        title: Text(
          l10n.summary,
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: _isAnalyzing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.analyzing, style: theme.textTheme.bodyLarge),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Area name
                  Center(
                    child: Text(
                      widget.area,
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Before & After Photos (always show)
                  Text(
                    l10n.beforeAndAfter,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              l10n.beforePhoto,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: widget.beforePhotoPath != null
                                  ? Image.file(
                                      File(widget.beforePhotoPath!),
                                      height: screenHeight * 0.2,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      height: screenHeight * 0.2,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE5E7EA),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 40,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              l10n.afterPhoto,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: widget.afterPhotoPath != null
                                  ? Image.file(
                                      File(widget.afterPhotoPath!),
                                      height: screenHeight * 0.2,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      height: screenHeight * 0.2,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE5E7EA),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 40,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // AI Analysis
                  Text(
                    l10n.aiAnalysis,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EA)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: hasMessinessData
                        ? Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.messinessBefore,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF6B7280),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _beforeMessiness!.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFF59E0B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 32,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        l10n.messinessAfter,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF6B7280),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _afterMessiness!.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF10B981),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      l10n.improvement,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF6B7280),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$improvement%',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Icon(
                                Icons.analytics_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isChinese ? '无照片分析' : 'No Photo Analysis',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isChinese
                                    ? '未提供前后照片'
                                    : 'Before and after photos not provided',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF9CA3AF),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  // Session Stats
                  Text(
                    l10n.summary,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EA)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _StatRow(
                          icon: Icons.timer_outlined,
                          label: l10n.timeSpent,
                          value: _formatTime(widget.elapsedSeconds),
                        ),
                        const Divider(height: 24, color: Color(0xFFE5E7EA)),
                        _StatRow(
                          icon: Icons.inventory_2_outlined,
                          label: l10n.itemsDecluttered,
                          value: widget.itemsCount.toString(),
                        ),
                        const Divider(height: 24, color: Color(0xFFE5E7EA)),
                        _StatRow(
                          icon: Icons.psychology_outlined,
                          label: l10n.focusIndex,
                          value: '${widget.focusIndex}/5',
                        ),
                        const Divider(height: 24, color: Color(0xFFE5E7EA)),
                        _StatRow(
                          icon: Icons.mood_outlined,
                          label: l10n.moodIndex,
                          value: '${widget.moodIndex}/5',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  // Done button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: () {
                        // Complete the session with all metrics
                        widget.onStopSession(
                          afterPhotoPath: widget.afterPhotoPath,
                          elapsedSeconds: widget.elapsedSeconds,
                          itemsCount: widget.itemsCount,
                          focusIndex: widget.focusIndex,
                          moodIndex: widget.moodIndex,
                          beforeMessinessIndex: _beforeMessiness,
                          afterMessinessIndex: _afterMessiness,
                        );
                        // Pop all the way back to home
                        popToHome(context);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF414B5A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.done,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6B7280), size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}
