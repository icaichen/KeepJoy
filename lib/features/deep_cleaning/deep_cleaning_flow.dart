import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';
import '../../services/messiness_analysis_service.dart';

class DeepCleaningFlowPage extends StatefulWidget {
  final Function(String area) onStartSession;
  final VoidCallback onStopSession;

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
  bool _placeholderInitialized = false;

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
    if (!_placeholderInitialized) {
      final isChinese = Localizations.localeOf(
        context,
      ).languageCode.toLowerCase().startsWith('zh');
      _areaController.text = isChinese
          ? '输入整理区域'
          : 'Please enter the area to declutter';
      _placeholderInitialized = true;
    }

    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');
    final areas = isChinese
        ? ['客厅', '卧室', '衣柜', '书柜', '厨房', '书桌']
        : [
            'Living Room',
            'Bedroom',
            'Wardrobe',
            'Bookshelf',
            'Kitchen',
            'Desk',
          ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.deepCleaningTitle)),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            Spacer(),
            // Section with 6 circles and input
            Card(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  children: [
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: screenWidth * 0.04,
                      runSpacing: screenHeight * 0.02,
                      children: areas
                          .map((label) => _buildCircle(screenWidth, label))
                          .toList(),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Input area under all 6 circles
                    TextField(
                      controller: _areaController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: isChinese
                            ? '输入整理区域'
                            : 'Please enter the area to declutter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final area = _areaController.text.trim();
                  if (area.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter an area name')),
                    );
                    return;
                  }

                  // Navigate to Before Photo page
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
                child: Text(l10n.continueButton),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildCircle(double screenWidth, String label) {
    final diameter = screenWidth * 0.22;
    return InkWell(
      onTap: () {
        _areaController.text = label;
      },
      borderRadius: BorderRadius.circular(diameter / 2),
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade400, width: 1.5),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

// Before Photo Page
class BeforePhotoPage extends StatefulWidget {
  final String area;
  final Function(String area) onStartSession;
  final VoidCallback onStopSession;

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
        setState(() {
          _photoPath = photo.path;
        });
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
    // Start session with before photo
    widget.onStartSession(widget.area);

    // Navigate to timer
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeepCleaningTimerPage(
          area: widget.area,
          beforePhotoPath: _photoPath,
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
      appBar: AppBar(title: Text(l10n.beforePhoto), centerTitle: false),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            // Area name
            Text(
              widget.area,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              l10n.captureBeforeState,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.04),
            // Photo preview or placeholder
            Expanded(
              child: Center(
                child: _photoPath != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(_photoPath!),
                              fit: BoxFit.contain,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton.filled(
                              onPressed: _takePicture,
                              icon: const Icon(Icons.refresh),
                              tooltip: l10n.retakePhoto,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 100,
                            color: theme.colorScheme.primary.withOpacity(0.3),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            l10n.noPhotoTaken,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            // Action buttons
            if (_photoPath == null) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _isProcessing ? null : _takePicture,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(l10n.takeBeforePhoto),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _continue,
                  child: Text(l10n.skipPhoto),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _continue,
                  child: Text(l10n.continueButton),
                ),
              ),
            ],
            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }
}

// Timer page
class DeepCleaningTimerPage extends StatefulWidget {
  final String area;
  final String? beforePhotoPath;
  final VoidCallback onStopSession;

  const DeepCleaningTimerPage({
    super.key,
    required this.area,
    this.beforePhotoPath,
    required this.onStopSession,
  });

  @override
  State<DeepCleaningTimerPage> createState() => _DeepCleaningTimerPageState();
}

class _DeepCleaningTimerPageState extends State<DeepCleaningTimerPage>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
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
      appBar: AppBar(title: Text(l10n.deepCleaningTitle), centerTitle: false),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            // Area name
            Text(
              widget.area,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            // Timer section
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Circular timer display
                    SizedBox(
                      width: screenWidth * 0.6,
                      height: screenWidth * 0.6,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Animated pulse ring when running
                          if (_isRunning)
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  width:
                                      screenWidth * 0.6 +
                                      (_pulseController.value * 20),
                                  height:
                                      screenWidth * 0.6 +
                                      (_pulseController.value * 20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.colorScheme.primary
                                          .withOpacity(
                                            0.3 -
                                                (_pulseController.value * 0.3),
                                          ),
                                      width: 2,
                                    ),
                                  ),
                                );
                              },
                            ),
                          // Main circle
                          Container(
                            width: screenWidth * 0.6,
                            height: screenWidth * 0.6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primaryContainer,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.3,
                                  ),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _formatTime(_elapsedSeconds),
                                    style: theme.textTheme.displayLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme
                                              .colorScheme
                                              .onPrimaryContainer,
                                          fontSize: screenWidth * 0.12,
                                        ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    _isRunning
                                        ? (Localizations.localeOf(
                                                    context,
                                                  ).languageCode ==
                                                  'zh'
                                              ? '进行中...'
                                              : 'In Progress...')
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
                                                    : 'Ready to Start')),
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme
                                          .colorScheme
                                          .onPrimaryContainer
                                          .withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.06),
                    // Control button
                    SizedBox(
                      width: screenWidth * 0.5,
                      height: 56,
                      child: _isRunning
                          ? FilledButton.icon(
                              onPressed: _pauseTimer,
                              icon: const Icon(Icons.pause),
                              label: Text(
                                Localizations.localeOf(context).languageCode ==
                                        'zh'
                                    ? '暂停'
                                    : 'Pause',
                                style: const TextStyle(fontSize: 18),
                              ),
                            )
                          : FilledButton.icon(
                              onPressed: _startTimer,
                              icon: Icon(
                                _elapsedSeconds > 0
                                    ? Icons.play_arrow
                                    : Icons.play_arrow,
                              ),
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
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: Text(l10n.minimize),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.finishCleaning),
                          content: Text(l10n.finishCleaningConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(l10n.cancel),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _finishCleaning();
                              },
                              child: Text(l10n.finish),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(l10n.finish),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
          ],
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
  final VoidCallback onStopSession;

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
        setState(() {
          _photoPath = photo.path;
        });
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
      appBar: AppBar(title: Text(l10n.afterPhoto), centerTitle: false),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            Text(
              widget.area,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              l10n.captureAfterState,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.04),
            Expanded(
              child: Center(
                child: _photoPath != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(_photoPath!),
                              fit: BoxFit.contain,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton.filled(
                              onPressed: _takePicture,
                              icon: const Icon(Icons.refresh),
                              tooltip: l10n.retakePhoto,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 100,
                            color: theme.colorScheme.primary.withOpacity(0.3),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            l10n.noPhotoTaken,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            if (_photoPath == null) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _isProcessing ? null : _takePicture,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(l10n.takeAfterPhoto),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _continue,
                  child: Text(l10n.skipPhoto),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _continue,
                  child: Text(l10n.continueButton),
                ),
              ),
            ],
            SizedBox(height: screenHeight * 0.02),
          ],
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
  final VoidCallback onStopSession;

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
  double _focusIndex = 5.0;
  double _moodIndex = 5.0;

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
      appBar: AppBar(title: Text(widget.area), centerTitle: false),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.02),
            // Items count
            Text(
              l10n.howManyItems,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            TextField(
              controller: _itemsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: l10n.enterItemsCount,
                suffixIcon: const Icon(Icons.inventory_2_outlined),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            // Focus Index
            Text(
              l10n.focusIndex,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              l10n.focusIndexDescription,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _focusIndex,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: _focusIndex.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _focusIndex = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    _focusIndex.round().toString(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.04),
            // Mood Index
            Text(
              l10n.moodIndex,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              l10n.moodIndexDescription,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _moodIndex,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: _moodIndex.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _moodIndex = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    _moodIndex.round().toString(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.06),
            // Continue button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _continue,
                child: Text(l10n.continueButton),
              ),
            ),
          ],
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
  final VoidCallback onStopSession;

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
          // Use fallback values on error
          _beforeMessiness = 5.0;
          _afterMessiness = 5.0;
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

    // Calculate improvement percentage
    final beforeMessiness = _beforeMessiness ?? 5.0;
    final afterMessiness = _afterMessiness ?? 5.0;
    final improvement = beforeMessiness > 0
        ? ((beforeMessiness - afterMessiness) / beforeMessiness * 100).round()
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.summary),
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
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Area name
                  Center(
                    child: Text(
                      widget.area,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  // Before & After Photos
                  if (widget.beforePhotoPath != null ||
                      widget.afterPhotoPath != null) ...[
                    Text(
                      l10n.beforeAndAfter,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
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
                                style: theme.textTheme.titleSmall,
                              ),
                              SizedBox(height: 8),
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
                                        color: theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 40,
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                l10n.afterPhoto,
                                style: theme.textTheme.titleSmall,
                              ),
                              SizedBox(height: 8),
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
                                        color: theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 40,
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),
                  ],
                  // AI Analysis
                  Text(
                    l10n.aiAnalysis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.messinessBefore,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  Text(
                                    beforeMessiness.toStringAsFixed(1),
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                  ),
                                ],
                              ),
                              const Icon(Icons.arrow_forward, size: 32),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    l10n.messinessAfter,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  Text(
                                    afterMessiness.toStringAsFixed(1),
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.improvement,
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$improvement%',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  // Session Stats
                  Text(
                    l10n.summary,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Column(
                        children: [
                          _StatRow(
                            icon: Icons.timer_outlined,
                            label: l10n.timeSpent,
                            value: _formatTime(widget.elapsedSeconds),
                          ),
                          const Divider(height: 24),
                          _StatRow(
                            icon: Icons.inventory_2_outlined,
                            label: l10n.itemsDecluttered,
                            value: widget.itemsCount.toString(),
                          ),
                          const Divider(height: 24),
                          _StatRow(
                            icon: Icons.psychology_outlined,
                            label: l10n.focusIndex,
                            value: '${widget.focusIndex}/10',
                          ),
                          const Divider(height: 24),
                          _StatRow(
                            icon: Icons.mood_outlined,
                            label: l10n.moodIndex,
                            value: '${widget.moodIndex}/10',
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  // Done button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: () {
                        // Complete the session (clears active session and creates memory)
                        widget.onStopSession();
                        // Pop all the way back to home
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      child: Text(l10n.done),
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
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
