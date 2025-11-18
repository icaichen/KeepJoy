import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:keepjoy_app/features/deep_cleaning/deep_cleaning_flow.dart';
import 'package:keepjoy_app/features/insights/memory_lane_report_screen.dart';
import 'package:keepjoy_app/features/insights/resell_analysis_report_screen.dart';
import 'package:keepjoy_app/features/insights/yearly_reports_screen.dart';
import 'package:keepjoy_app/features/profile/profile_page.dart';
import 'package:keepjoy_app/features/memories/create_memory_page.dart';
import 'package:keepjoy_app/features/dashboard/widgets/declutter_results_distribution_card.dart';
import 'package:keepjoy_app/l10n/app_localizations.dart';
import 'package:keepjoy_app/models/activity_entry.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/deep_cleaning_session.dart';
import 'package:keepjoy_app/models/memory.dart';
import 'package:keepjoy_app/models/resell_item.dart';
import 'package:keepjoy_app/models/planned_session.dart';
import 'package:keepjoy_app/theme/typography.dart';
import 'package:keepjoy_app/widgets/gradient_button.dart';
import 'package:keepjoy_app/widgets/auto_scale_text.dart';
import 'package:keepjoy_app/features/insights/deep_cleaning_analysis_card.dart';

class _ModeMeta {
  final IconData icon;
  final List<Color> colors;
  final String title;
  final String subtitle;

  const _ModeMeta({
    required this.icon,
    required this.colors,
    required this.title,
    required this.subtitle,
  });
}

class DashboardScreen extends StatefulWidget {
  final DeepCleaningSession? activeSession;
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
  final Function(String area, {String? beforePhotoPath}) onStartSession;
  final VoidCallback onOpenQuickDeclutter;
  final VoidCallback onOpenJoyDeclutter;
  final void Function(Locale) onLocaleChange;
  final int streak;
  final int declutteredCount;
  final double newValue;
  final List<DeclutterItem> declutteredItems;
  final List<Memory> memories;
  final List<PlannedSession> plannedSessions;
  final void Function(PlannedSession) onAddPlannedSession;
  final void Function(PlannedSession) onDeletePlannedSession;
  final void Function(PlannedSession) onTogglePlannedSession;
  final List<ActivityEntry> activityHistory;
  final List<ResellItem> resellItems;
  final List<DeepCleaningSession> deepCleaningSessions;
  final Function(Memory) onMemoryCreated;
  final bool hasFullAccess;
  final VoidCallback onRequestUpgrade;

  const DashboardScreen({
    super.key,
    required this.activeSession,
    required this.onStopSession,
    required this.onStartSession,
    required this.onOpenQuickDeclutter,
    required this.onOpenJoyDeclutter,
    required this.onLocaleChange,
    required this.streak,
    required this.declutteredCount,
    required this.newValue,
    required this.declutteredItems,
    required this.memories,
    required this.plannedSessions,
    required this.onAddPlannedSession,
    required this.onDeletePlannedSession,
    required this.onTogglePlannedSession,
    required this.activityHistory,
    required this.resellItems,
    required this.deepCleaningSessions,
    required this.onMemoryCreated,
    required this.hasFullAccess,
    required this.onRequestUpgrade,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _timer;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    if (widget.activeSession != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeSession != null && _timer == null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {});
        }
      });
    } else if (widget.activeSession == null && _timer != null) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  String _getQuoteOfDay(AppLocalizations l10n) {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final quoteIndex = (dayOfYear % 15) + 1;

    switch (quoteIndex) {
      case 1:
        return l10n.quote1;
      case 2:
        return l10n.quote2;
      case 3:
        return l10n.quote3;
      case 4:
        return l10n.quote4;
      case 5:
        return l10n.quote5;
      case 6:
        return l10n.quote6;
      case 7:
        return l10n.quote7;
      case 8:
        return l10n.quote8;
      case 9:
        return l10n.quote9;
      case 10:
        return l10n.quote10;
      case 11:
        return l10n.quote11;
      case 12:
        return l10n.quote12;
      case 13:
        return l10n.quote13;
      case 14:
        return l10n.quote14;
      case 15:
        return l10n.quote15;
      default:
        return l10n.quote1;
    }
  }

  String _formatQuote(String quote) {
    final emDashIndex = quote.indexOf(' —');
    if (emDashIndex != -1) {
      return quote.substring(0, emDashIndex);
    }
    return quote;
  }

  String _getQuoteAttribution(String quote) {
    final emDashIndex = quote.indexOf(' —');
    if (emDashIndex != -1) {
      return quote.substring(emDashIndex + 3);
    }
    return '';
  }

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return l10n.goodMorning;
    } else if (hour < 18) {
      return l10n.goodAfternoon;
    } else {
      return l10n.goodEvening;
    }
  }

  String _getElapsedTime(DateTime startTime) {
    final duration = DateTime.now().difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString()}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showAddGoalDialog(BuildContext context, AppLocalizations l10n) {
    final TextEditingController goalController = TextEditingController();
    DateTime? selectedDate;
    final isChineseLocale = l10n.localeName.toLowerCase().startsWith('zh');

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 12,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.dashboardCreateGoalTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Free-form goal input
                    TextField(
                      controller: goalController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: l10n.dashboardGoalLabel,
                        hintText: l10n.dashboardGoalHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Optional date
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE5E7EA)),
                      ),
                      leading: const Icon(Icons.calendar_today),
                      title: Text(l10n.dashboardDateOptional),
                      subtitle: Text(
                        selectedDate != null
                            ? DateFormat(
                                isChineseLocale ? 'yyyy年M月d日' : 'MMM d, yyyy',
                              ).format(selectedDate!)
                            : l10n.dashboardTapToSelectDate,
                      ),
                      trailing: selectedDate != null
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                setModalState(() {
                                  selectedDate = null;
                                });
                              },
                            )
                          : null,
                      onTap: () async {
                        final picked = await _showStyledDatePicker(
                          context: builderContext,
                          initialDate: selectedDate,
                          l10n: l10n,
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFFE5E7EA)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(l10n.cancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (goalController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.dashboardEnterGoalPrompt,
                                    ),
                                  ),
                                );
                                return;
                              }

                              final newSession = PlannedSession(
                                id: DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                                title: goalController.text.trim(),
                                area: 'General',
                                scheduledDate: selectedDate,
                                scheduledTime: null,
                                createdAt: DateTime.now(),
                                priority: TaskPriority.thisWeek,
                                mode: SessionMode.quickDeclutter,
                                goal: goalController.text.trim(),
                              );

                              widget.onAddPlannedSession(newSession);
                              Navigator.pop(sheetContext);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.dashboardGoalCreated),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF414B5A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(l10n.dashboardCreateAction),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<DateTime?> _showStyledDatePicker({
    required BuildContext context,
    required DateTime? initialDate,
    required AppLocalizations l10n,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final DateTime initial =
        (initialDate != null && !initialDate.isBefore(today))
        ? initialDate
        : today;
    final lastDate = today.add(const Duration(days: 365));

    DateTime tempDate = initial;

    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.dashboardSelectDate,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: const Color(0xFF414B5A),
                          onPrimary: Colors.white,
                        ),
                      ),
                      child: CalendarDatePicker(
                        initialDate: tempDate,
                        firstDate: today,
                        lastDate: lastDate,
                        onDateChanged: (value) {
                          setSheetState(() {
                            tempDate = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF414B5A),
                              side: const BorderSide(color: Color(0xFFD1D5DB)),
                            ),
                            child: Text(l10n.cancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () =>
                                Navigator.pop(sheetContext, tempDate),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF414B5A),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(l10n.done),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<TimeOfDay?> _showStyledTimePicker({
    required BuildContext context,
    required TimeOfDay? initialTime,
    required AppLocalizations l10n,
  }) async {
    final now = TimeOfDay.now();
    final mediaQuery = MediaQuery.of(context);
    DateTime tempDateTime = DateTime(
      0,
      1,
      1,
      initialTime?.hour ?? now.hour,
      initialTime?.minute ?? now.minute,
    );

    return showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.dashboardSelectTimeOptional,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        use24hFormat: mediaQuery.alwaysUse24HourFormat,
                        initialDateTime: tempDateTime,
                        onDateTimeChanged: (value) {
                          setSheetState(() {
                            tempDateTime = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF414B5A),
                              side: const BorderSide(color: Color(0xFFD1D5DB)),
                            ),
                            child: Text(l10n.cancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              Navigator.pop(
                                sheetContext,
                                TimeOfDay(
                                  hour: tempDateTime.hour,
                                  minute: tempDateTime.minute,
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF414B5A),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(l10n.done),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<String?> _showAreaPicker({
    required BuildContext context,
    required List<String> areas,
    required String? selectedArea,
    required bool isChinese,
  }) async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isChinese ? '选择区域' : 'Pick an area',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: areas.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final label = areas[index];
                      final isSelected = label == selectedArea;
                      return ListTile(
                        title: Text(label),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: Color(0xFF414B5A),
                              )
                            : null,
                        onTap: () => Navigator.pop(sheetContext, label),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddSessionDialog(BuildContext context, AppLocalizations l10n) {
    final TextEditingController areaController = TextEditingController();
    DateTime? selectedDate = DateTime.now();
    TimeOfDay? selectedTime;
    SessionMode selectedMode = SessionMode.deepCleaning;
    final isChineseLocale = l10n.localeName.toLowerCase().startsWith('zh');

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setModalState) {
            final modeOrder = [
              SessionMode.quickDeclutter,
              SessionMode.joyDeclutter,
              SessionMode.deepCleaning,
            ];
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 12,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.dashboardCreateSessionTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        l10n.dashboardModeLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await _showModePicker(
                            context: builderContext,
                            selectedMode: selectedMode,
                            modeOrder: modeOrder,
                            l10n: l10n,
                          );
                          if (picked != null) {
                            setModalState(() {
                              selectedMode = picked;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EA)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _modeMeta(selectedMode, l10n).title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _modeMeta(selectedMode, l10n).subtitle,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF9CA3AF),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Area selection - only for deep cleaning
                      if (selectedMode == SessionMode.deepCleaning) ...[
                        Text(
                          l10n.area,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildAreaSelection(
                          context,
                          areaController,
                          isChineseLocale,
                          selectedMode == SessionMode.deepCleaning,
                          setModalState,
                        ),
                        const SizedBox(height: 16),
                      ],

                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFE5E7EA)),
                        ),
                        leading: const Icon(Icons.calendar_today),
                        title: Text(l10n.date),
                        subtitle: Text(
                          selectedDate != null
                              ? DateFormat(
                                  isChineseLocale ? 'yyyy年M月d日' : 'MMM d, yyyy',
                                ).format(selectedDate!)
                              : l10n.dashboardSelectDate,
                        ),
                        onTap: () async {
                          final picked = await _showStyledDatePicker(
                            context: builderContext,
                            initialDate: selectedDate,
                            l10n: l10n,
                          );
                          if (picked != null) {
                            setModalState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFE5E7EA)),
                        ),
                        leading: const Icon(Icons.access_time),
                        title: Text(l10n.time),
                        subtitle: Text(
                          selectedTime != null
                              ? selectedTime!.format(builderContext)
                              : l10n.dashboardSelectTimeOptional,
                        ),
                        onTap: () async {
                          final picked = await _showStyledTimePicker(
                            context: builderContext,
                            initialTime: selectedTime,
                            l10n: l10n,
                          );
                          if (picked != null) {
                            setModalState(() {
                              selectedTime = picked;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(sheetContext),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFFE5E7EA),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(l10n.cancel),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Only require area for deep cleaning
                                if (selectedMode == SessionMode.deepCleaning &&
                                    areaController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10n.dashboardEnterAreaPrompt,
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final newSession = PlannedSession(
                                  id: DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                                  title:
                                      selectedMode == SessionMode.deepCleaning
                                      ? '${areaController.text} ${selectedMode.displayName(l10n)}'
                                      : selectedMode.displayName(l10n),
                                  area: selectedMode == SessionMode.deepCleaning
                                      ? areaController.text.trim()
                                      : 'General',
                                  scheduledDate: selectedDate,
                                  scheduledTime: selectedTime?.format(
                                    builderContext,
                                  ),
                                  createdAt: DateTime.now(),
                                  priority: TaskPriority.thisWeek,
                                  mode: selectedMode,
                                  goal: null,
                                );

                                widget.onAddPlannedSession(newSession);
                                Navigator.pop(sheetContext);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.dashboardSessionCreated),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF414B5A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(l10n.dashboardCreateAction),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAllSessionsCalendar(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setModalState) {
            DateTime focusedDay = DateTime.now();
            DateTime selectedDay = DateTime.now();

            // Group sessions by date
            Map<DateTime, List<PlannedSession>> getEventsForCalendar() {
              Map<DateTime, List<PlannedSession>> events = {};
              for (var session in widget.plannedSessions) {
                if (session.scheduledDate == null) continue;
                final date = DateTime(
                  session.scheduledDate!.year,
                  session.scheduledDate!.month,
                  session.scheduledDate!.day,
                );
                if (events[date] == null) {
                  events[date] = [];
                }
                events[date]!.add(session);
              }
              return events;
            }

            final events = getEventsForCalendar();

            List<PlannedSession> getEventsForDay(DateTime day) {
              final normalized = DateTime(day.year, day.month, day.day);
              return events[normalized] ?? [];
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.7,
              maxChildSize: 0.95,
              expand: false,
              builder: (builderContext2, scrollController) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.dashboardCalendarTitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              Navigator.pop(sheetContext);
                              _showAddSessionDialog(context, l10n);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Calendar
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE5E7EA)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TableCalendar(
                          firstDay: DateTime.now(),
                          lastDay: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          focusedDay: focusedDay,
                          selectedDayPredicate: (day) =>
                              isSameDay(selectedDay, day),
                          eventLoader: getEventsForDay,
                          calendarFormat: CalendarFormat.month,
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                            leftChevronIcon: const Icon(
                              Icons.chevron_left,
                              color: Color(0xFF414B5A),
                            ),
                            rightChevronIcon: const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF414B5A),
                            ),
                          ),
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: const Color(
                                0xFF414B5A,
                              ).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: Color(0xFF414B5A),
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: const BoxDecoration(
                              color: Color(0xFF6B5CE7),
                              shape: BoxShape.circle,
                            ),
                            markersMaxCount: 3,
                            markersAlignment: Alignment.bottomCenter,
                            markerSize: 6,
                            markerMargin: const EdgeInsets.symmetric(
                              horizontal: 1,
                            ),
                          ),
                          onDaySelected: (selected, focused) {
                            setModalState(() {
                              selectedDay = selected;
                              focusedDay = focused;
                            });
                          },
                          onPageChanged: (focused) {
                            setModalState(() {
                              focusedDay = focused;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Sessions for selected day
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final sessionsForDay = getEventsForDay(selectedDay);
                            if (sessionsForDay.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.event_available,
                                      size: 48,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      l10n.dashboardNoSessionsForDay,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              controller: scrollController,
                              itemCount: sessionsForDay.length,
                              itemBuilder: (context, index) {
                                final session = sessionsForDay[index];
                                return Dismissible(
                                  key: Key('${session.id}_cal'),
                                  background: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (direction) {
                                    widget.onDeletePlannedSession(session);
                                    setModalState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          l10n.dashboardSessionDeleted,
                                        ),
                                      ),
                                    );
                                  },
                                  child: _buildSessionCard(
                                    session,
                                    l10n,
                                    context,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAreaSelection(
    BuildContext context,
    TextEditingController areaController,
    bool isChinese,
    bool isEnabled,
    void Function(void Function()) setState,
  ) {
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

    final selectedArea = areaController.text.trim().isEmpty
        ? null
        : areaController.text.trim();

    return Column(
      children: [
        InkWell(
          onTap: isEnabled
              ? () async {
                  final picked = await _showAreaPicker(
                    context: context,
                    areas: areas,
                    selectedArea: selectedArea,
                    isChinese: isChinese,
                  );
                  if (picked != null) {
                    setState(() {
                      areaController.text = picked;
                    });
                  }
                }
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EA)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.place_rounded,
                  color: isEnabled
                      ? const Color(0xFF414B5A)
                      : const Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedArea ??
                        (isChinese ? '请选择区域' : 'Tap to choose an area'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selectedArea != null
                          ? const Color(0xFF111827)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<SessionMode?> _showModePicker({
    required BuildContext context,
    required SessionMode selectedMode,
    required List<SessionMode> modeOrder,
    required AppLocalizations l10n,
  }) async {
    return showModalBottomSheet<SessionMode>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.dashboardModeLabel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...modeOrder.map((mode) {
                  final meta = _modeMeta(mode, l10n);
                  final isSelected = mode == selectedMode;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: meta.colors),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(meta.icon, color: Colors.white),
                    ),
                    title: Text(
                      meta.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      meta.subtitle,
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFF414B5A),
                          )
                        : null,
                    onTap: () => Navigator.pop(sheetContext, mode),
                  );
                }).toList(),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: Text(l10n.cancel),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _ModeMeta _modeMeta(SessionMode mode, AppLocalizations l10n) {
    switch (mode) {
      case SessionMode.quickDeclutter:
        return _ModeMeta(
          icon: Icons.flash_on_rounded,
          colors: const [Color(0xFFFF8A65), Color(0xFFFFB74D)],
          title: mode.displayName(l10n),
          subtitle: l10n.quickDeclutterFlowDescription,
        );
      case SessionMode.joyDeclutter:
        return _ModeMeta(
          icon: Icons.auto_awesome_rounded,
          colors: const [Color(0xFF5B8CFF), Color(0xFF61D1FF)],
          title: mode.displayName(l10n),
          subtitle: l10n.joyDeclutterFlowDescription,
        );
      case SessionMode.deepCleaning:
        return _ModeMeta(
          icon: Icons.cleaning_services_rounded,
          colors: const [Color(0xFF34E27A), Color(0xFF0BBF75)],
          title: mode.displayName(l10n),
          subtitle: l10n.deepCleaningFlowDescription,
        );
    }
  }

  Widget _buildSessionCard(
    PlannedSession session,
    AppLocalizations l10n,
    BuildContext context,
  ) {
    // Get color based on session mode
    Color getModeColor() {
      switch (session.mode) {
        case SessionMode.deepCleaning:
          return const Color(0xFF10B981); // Green
        case SessionMode.joyDeclutter:
          return const Color(0xFF3B82F6); // Blue
        case SessionMode.quickDeclutter:
          return const Color(0xFFF59E0B); // Orange
      }
    }

    final modeColor = getModeColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: session.isCompleted
              ? modeColor.withOpacity(0.3)
              : const Color(0xFFE5E7EA),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Color indicator bar
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: modeColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: session.isCompleted
                  ? modeColor.withOpacity(0.2)
                  : modeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              session.isCompleted
                  ? Icons.check_circle_rounded
                  : _getIconForMode(session.mode),
              color: modeColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${session.mode.displayName(l10n)} - ${session.area}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C1C1E),
                    decoration: session.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (session.isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: modeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.completed,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: modeColor,
                          ),
                        ),
                      ),
                    if (session.isCompleted && session.goal != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• ${session.goal}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                    if (!session.isCompleted) ...[
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatSessionDate(
                            session.scheduledDate,
                            session.scheduledTime,
                            l10n,
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Checkbox
          Checkbox(
            value: session.isCompleted,
            onChanged: (value) {
              widget.onTogglePlannedSession(session);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            activeColor: modeColor,
          ),
        ],
      ),
    );
  }

  IconData _getIconForMode(SessionMode mode) {
    switch (mode) {
      case SessionMode.deepCleaning:
        return Icons.spa_rounded;
      case SessionMode.joyDeclutter:
        return Icons.auto_awesome_rounded;
      case SessionMode.quickDeclutter:
        return Icons.bolt_rounded;
    }
  }

  String _formatSessionDate(
    DateTime? date,
    String? time,
    AppLocalizations l10n,
  ) {
    if (date == null) {
      return l10n.dashboardNotScheduled;
    }

    final isChineseLocale = l10n.localeName.toLowerCase().startsWith('zh');

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(date.year, date.month, date.day);

    String dateStr;
    if (sessionDate == today) {
      dateStr = l10n.dashboardToday;
    } else if (sessionDate == today.add(const Duration(days: 1))) {
      dateStr = l10n.dashboardTomorrow;
    } else {
      dateStr = isChineseLocale
          ? DateFormat('M月d日', 'zh_CN').format(date)
          : DateFormat('MMM d').format(date);
    }

    if (time != null && time.isNotEmpty) {
      return '$dateStr $time';
    } else {
      return dateStr;
    }
  }

  void _startSessionFromPlanned(PlannedSession session) {
    switch (session.mode) {
      case SessionMode.deepCleaning:
        if (!widget.hasFullAccess) {
          widget.onRequestUpgrade();
          return;
        }
        // For deep cleaning, navigate directly to before photo page with area pre-filled
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BeforePhotoPage(
              area: session.area,
              onStartSession: widget.onStartSession,
              onStopSession: widget.onStopSession,
            ),
          ),
        );
        break;
      case SessionMode.joyDeclutter:
        // For joy declutter, navigate to joy declutter flow
        widget.onOpenJoyDeclutter();
        break;
      case SessionMode.quickDeclutter:
        // For quick declutter, navigate to quick declutter flow
        widget.onOpenQuickDeclutter();
        break;
    }
  }

  void _showActivityHistory(BuildContext context, AppLocalizations l10n) {
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');
    final activities = widget.activityHistory.take(5).toList();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.recentActivities,
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                if (activities.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      isChinese
                          ? '近期还没有活动记录，继续加油！'
                          : 'No recent activity yet—keep going!',
                      style: Theme.of(sheetContext).textTheme.bodyMedium
                          ?.copyWith(
                            color: const Color(0xFF6B7280),
                            height: 1.4,
                          ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activities.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 24, color: Color(0xFFE5E7EB)),
                    itemBuilder: (_, index) {
                      final entry = activities[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _iconForActivity(entry.type),
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _activityTitle(entry, l10n),
                                  style: Theme.of(sheetContext)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF111827),
                                      ),
                                ),
                                if (entry.description != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    entry.description!,
                                    style: Theme.of(sheetContext)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: const Color(0xFF4B5563),
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _iconForActivity(ActivityType type) {
    switch (type) {
      case ActivityType.deepCleaning:
        return Icons.cleaning_services_rounded;
      case ActivityType.joyDeclutter:
        return Icons.favorite_border_rounded;
      case ActivityType.quickDeclutter:
        return Icons.flash_on_rounded;
    }
  }

  String _activityTitle(ActivityEntry entry, AppLocalizations l10n) {
    switch (entry.type) {
      case ActivityType.deepCleaning:
        return l10n.deepCleaning;
      case ActivityType.joyDeclutter:
        return l10n.joyDeclutterTitle;
      case ActivityType.quickDeclutter:
        return l10n.quickDeclutterTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;

    final quoteOfDay = _getQuoteOfDay(l10n);

    // Calculate monthly metrics
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);

    final sessionsThisMonth = widget.deepCleaningSessions
        .where(
          (session) =>
              !session.startTime.isBefore(monthStart) &&
              session.startTime.isBefore(nextMonthStart),
        )
        .length;

    final soldItems = widget.resellItems.where(
      (item) => item.soldPrice != null,
    );
    final totalValue = soldItems.isEmpty
        ? 0.0
        : soldItems.map((item) => item.soldPrice!).reduce((a, b) => a + b);

    // Calculate scroll-based animations
    const headerHeight = 100.0;
    final scrollProgress = (_scrollOffset / headerHeight).clamp(0.0, 1.0);
    final headerOpacity = (1.0 - scrollProgress).clamp(0.0, 1.0);
    final collapsedHeaderOpacity = scrollProgress >= 1.0 ? 1.0 : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 120),

                // Inspirational Section
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(color: Color(0xFFF5F5F7)),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Streak Achievement (if exists)
                      if (widget.streak > 0) ...[
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _showActivityHistory(context, l10n),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFE4E8EF),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x08000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            child: Column(
                              children: [
                                // Header with title and fire icon
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n.dashboardCurrentStreakTitle,
                                      style: const TextStyle(
                                        fontFamily: 'SF Pro Display',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF3F4F6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.local_fire_department_rounded,
                                        color: Color(0xFFFDB022),
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Large streak number
                                Text(
                                  '${widget.streak}',
                                  style: const TextStyle(
                                    fontFamily: 'SF Pro Display',
                                    fontSize: 48,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Subtitle
                                Text(
                                  l10n.dashboardStreakSubtitle,
                                  style: const TextStyle(
                                    fontFamily: 'SF Pro Text',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Dots visualization (max 7 dots)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:
                                      List.generate(
                                        widget.streak > 7 ? 7 : widget.streak,
                                        (index) => Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 3,
                                          ),
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF6B7280),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      )..addAll(
                                        widget.streak > 7
                                            ? [
                                                const SizedBox(width: 6),
                                                Text(
                                                  '+${widget.streak - 7}',
                                                  style: const TextStyle(
                                                    fontFamily:
                                                        'SF Pro Display',
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ]
                                            : [],
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Quote Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE4E8EF)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Transform.scale(
                                  scaleX: -1,
                                  child: const Icon(
                                    Icons.format_quote_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _formatQuote(quoteOfDay),
                                style: const TextStyle(
                                  fontFamily: 'SF Pro Text',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xDE000000),
                                  letterSpacing: 0,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '- ${_getQuoteAttribution(quoteOfDay)}',
                                style: AppTypography.quoteAttribution.copyWith(
                                  color: const Color(0xFF757575),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Joy Check Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE4E8EF)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 22,
                          ),
                          child: Column(
                            children: [
                              Text(
                                l10n.joyCheck,
                                style: AppTypography.cardTitle.black87,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.whatBroughtYouJoy,
                                style: AppTypography.subtitle,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 18),
                              GradientButton(
                                onPressed: () async {
                                  if (!widget.hasFullAccess) {
                                    widget.onRequestUpgrade();
                                    return;
                                  }
                                  final memory = await Navigator.of(context)
                                      .push<Memory>(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const CreateMemoryPage(),
                                        ),
                                      );

                                  if (memory != null && context.mounted) {
                                    widget.onMemoryCreated(memory);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.memoryCreated),
                                      ),
                                    );

                                    // Ask if user wants to let go of the item
                                    await _showLetGoPrompt(context, memory);
                                  }
                                },
                                width: double.infinity,
                                height: 44,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    const Icon(
                                      Icons.sentiment_satisfied_alt,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.createMemory,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            letterSpacing: 0,
                                          ),
                                      overflow: TextOverflow.visible,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Active Session (if exists)
                if (widget.activeSession != null) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                    ),
                    child: Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE1E7EF)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.dashboardActiveSessionTitle,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF111827),
                                      ),
                                ),
                                Text(
                                  l10n.deepCleaningTitle,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF6B7280),
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getElapsedTime(
                                          widget.activeSession!.startTime,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF111827),
                                          height: 1.05,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${widget.activeSession!.area} - ${l10n.inProgress}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => DeepCleaningTimerPage(
                                            area: widget.activeSession!.area,
                                            beforePhotoPath: widget
                                                .activeSession!
                                                .beforePhotoPath,
                                            onStopSession: widget.onStopSession,
                                            sessionStartTime: widget
                                                .activeSession!
                                                .startTime, // Pass start time
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.play_arrow,
                                      size: 18,
                                    ),
                                    label: Text(l10n.resume),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF414B5A),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      // Show confirmation dialog for stopping
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(l10n.finishCleaning),
                                          content: Text(
                                            l10n.finishCleaningConfirm,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text(l10n.cancel),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                // Navigate to finish page
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (_) => AfterPhotoPage(
                                                      area: widget
                                                          .activeSession!
                                                          .area,
                                                      beforePhotoPath: widget
                                                          .activeSession!
                                                          .beforePhotoPath,
                                                      elapsedSeconds:
                                                          DateTime.now()
                                                              .difference(
                                                                widget
                                                                    .activeSession!
                                                                    .startTime,
                                                              )
                                                              .inSeconds,
                                                      onStopSession:
                                                          widget.onStopSession,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Text(l10n.stop),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(l10n.stop),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // To Do Section (always show)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.dashboardTodoTitle,
                            style: const TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                              letterSpacing: 0,
                              height: 1.0,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              _showAllSessionsCalendar(context, l10n);
                            },
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(l10n.dashboardViewCalendar),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF6B5CE7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Builder(
                        builder: (context) {
                          final todoSessions = widget.plannedSessions
                              .where(
                                (session) =>
                                    session.area == 'General' ||
                                    !session.isCompleted,
                              )
                              .toList();
                          final displaySessions = todoSessions.take(3).toList();

                          if (displaySessions.isEmpty) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EA),
                                ),
                              ),
                              padding: const EdgeInsets.all(32),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      l10n.dashboardNoTodosTitle,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.dashboardNoTodosSubtitle,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE5E7EA),
                              ),
                            ),
                            child: Column(
                              children: displaySessions.map((session) {
                                return Dismissible(
                                  key: Key(session.id),
                                  background: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (direction) {
                                    widget.onDeletePlannedSession(session);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          l10n.dashboardSessionDeleted,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: const Color(0xFFE5E7EA),
                                          width: displaySessions.last == session
                                              ? 0
                                              : 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color:
                                                session.area == 'General' &&
                                                    session.isCompleted
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFF3F4F6),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border:
                                                session.area == 'General' &&
                                                    session.isCompleted
                                                ? null
                                                : Border.all(
                                                    color: const Color(
                                                      0xFFE5E7EA,
                                                    ),
                                                  ),
                                          ),
                                          child: Icon(
                                            session.area == 'General'
                                                ? (session.isCompleted
                                                      ? Icons.check_rounded
                                                      : Icons.flag_outlined)
                                                : Icons.calendar_month_rounded,
                                            color:
                                                session.area == 'General' &&
                                                    session.isCompleted
                                                ? Colors.white
                                                : const Color(0xFF6B7280),
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                session.goal ?? session.area,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(
                                                    0xFF1C1C1E,
                                                  ),
                                                  decoration:
                                                      session.area ==
                                                              'General' &&
                                                          session.isCompleted
                                                      ? TextDecoration
                                                            .lineThrough
                                                      : null,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _formatSessionDate(
                                                  session.scheduledDate,
                                                  session.scheduledTime,
                                                  l10n,
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF6B7280),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (session.area == 'General')
                                          Checkbox(
                                            value: session.isCompleted,
                                            onChanged: (value) {
                                              widget.onTogglePlannedSession(
                                                session,
                                              );
                                            },
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            activeColor: const Color(
                                              0xFF10B981,
                                            ),
                                          )
                                        else
                                          GradientButton(
                                            onPressed: () {
                                              _startSessionFromPlanned(session);
                                            },
                                            height: 36,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 6,
                                            ),
                                            child: Text(l10n.dashboardStartNow),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),

                      // Create Goal and Create Session buttons
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _showAddGoalDialog(context, l10n);
                              },
                              icon: const Icon(Icons.flag_outlined, size: 20),
                              label: Text(l10n.dashboardCreateGoalTitle),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFFE5E7EA),
                                ),
                                foregroundColor: const Color(0xFF6B7280),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _showAddSessionDialog(context, l10n);
                              },
                              icon: const Icon(
                                Icons.add_circle_outline,
                                size: 20,
                              ),
                              label: Text(l10n.dashboardCreateSessionTitle),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFFE5E7EA),
                                ),
                                foregroundColor: const Color(0xFF6B7280),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),

                // Monthly Progress Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dashboardMonthlyProgress,
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          letterSpacing: 0,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Metrics Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              icon: Icons.cleaning_services_rounded,
                              iconColor: const Color(0xFFB794F6),
                              value: sessionsThisMonth.toString(),
                              label: l10n.deepCleaning,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              icon: Icons.inventory_2_rounded,
                              iconColor: const Color(0xFF5ECFB8),
                              value: widget.declutteredItems.length.toString(),
                              label: l10n.dashboardDeclutteredLabel,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              icon: Icons.attach_money_rounded,
                              iconColor: const Color(0xFFFFD93D),
                              value: totalValue.toStringAsFixed(0),
                              label: l10n.dashboardResellLabel,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Declutter Results Distribution Card
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: DeclutterResultsDistributionCard(
                    items: widget.declutteredItems,
                    title: l10n.dashboardLettingGoDetailsTitle,
                    subtitle: l10n.dashboardLettingGoDetailsSubtitle,
                    keptLabel: l10n.dashboardKeptLabel,
                    resellLabel: l10n.routeResell,
                    recycleLabel: l10n.routeRecycle,
                    donateLabel: l10n.routeDonation,
                    discardLabel: l10n.routeDiscard,
                    totalItemsLabel: l10n.totalItemsDecluttered,
                    isChinese: isChinese,
                  ),
                ),

                const SizedBox(height: 24),

                // Monthly Report Card
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: _buildMonthlyReportCard(context, isChinese),
                ),

                const SizedBox(height: 24),

                // Reports Cards
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Column(
                    children: [
                      _wrapPremiumCard(
                        context,
                        _buildReportCard(
                          context,
                          icon: Icons.trending_up_rounded,
                          iconColor: const Color(0xFFFFD93D),
                          bgColors: const [
                            Color(0xFFFFF9E6),
                            Color(0xFFFFECB3),
                          ],
                          title: l10n.dashboardResellReportTitle,
                          subtitle: l10n.dashboardResellReportSubtitle,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ResellAnalysisReportScreen(
                                      resellItems: widget.resellItems,
                                      declutteredItems: widget.declutteredItems,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _wrapPremiumCard(
                        context,
                        _buildReportCard(
                          context,
                          icon: Icons.photo_library_rounded,
                          iconColor: const Color(0xFFFF9AA2),
                          bgColors: const [
                            Color(0xFFFFEEF0),
                            Color(0xFFFFDDE0),
                          ],
                          title: l10n.dashboardMemoryLaneTitle,
                          subtitle: l10n.dashboardMemoryLaneSubtitle,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MemoryLaneReportScreen(
                                  memories: widget.memories,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _wrapPremiumCard(
                        context,
                        _buildReportCard(
                          context,
                          icon: Icons.calendar_today_rounded,
                          iconColor: const Color(0xFF89CFF0),
                          bgColors: const [
                            Color(0xFFE6F4F9),
                            Color(0xFFD4E9F3),
                          ],
                          title: l10n.dashboardYearlyReportsTitle,
                          subtitle: l10n.dashboardYearlyReportsSubtitle,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => YearlyReportsScreen(
                                  declutteredItems: widget.declutteredItems,
                                  resellItems: widget.resellItems,
                                  deepCleaningSessions:
                                      widget.deepCleaningSessions,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),

          // Collapsed header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: collapsedHeaderOpacity < 0.5,
              child: Opacity(
                opacity: collapsedHeaderOpacity,
                child: Container(
                  height: topPadding + kToolbarHeight,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F7),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE5E5EA), width: 0.5),
                    ),
                  ),
                  padding: EdgeInsets.only(top: topPadding),
                  alignment: Alignment.center,
                  child: const Text(
                    'KeepJoy',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Original header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 120,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 16,
                  top: topPadding + 12,
                ),
                child: Opacity(
                  opacity: headerOpacity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getGreeting(l10n),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                              letterSpacing: -0.5,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.startYourDeclutterJourney,
                            style: const TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6B7280),
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProfilePage(
                                onLocaleChange: widget.onLocaleChange,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFB794F6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EA)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required List<Color> bgColors,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgColors,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wrapPremiumCard(BuildContext context, Widget child) {
    if (widget.hasFullAccess == true) {
      return child;
    }

    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Opacity(opacity: 0.6, child: child),
        Positioned.fill(
          child: Material(
            color: Colors.black.withOpacity(0.45),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: widget.onRequestUpgrade,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, color: Colors.white, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    l10n.premiumLockedOverlay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.upgradeToPremium,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyReportCard(BuildContext context, bool isChinese) {
    final l10n = AppLocalizations.of(context)!;

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);

    final sessionsThisMonth = widget.deepCleaningSessions
        .where(
          (session) =>
              !session.startTime.isBefore(monthStart) &&
              session.startTime.isBefore(nextMonthStart),
        )
        .toList();

    return DeepCleaningAnalysisCard(
      sessions: sessionsThisMonth,
      title: l10n.deepCleaningAnalysisTitle,
      emptyStateMessage: isChinese
          ? '本月还没有深度整理记录，开始一次专注的整理吧。'
          : 'No deep cleaning records yet this month. Start your first focused session.',
    );
  }

  Future<void> _showLetGoPrompt(BuildContext context, Memory memory) async {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = l10n.localeName.toLowerCase().startsWith('zh');

    final shouldLetGo = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isChinese ? '让物品离开？' : 'Let this item go?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isChinese
                      ? '既然已经记录了这份美好回忆，是否考虑让这件物品离开，给新的心动物品腾出空间？'
                      : 'Now that you\'ve captured this beautiful memory, would you consider letting this item go to make room for new joy?',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                        ),
                        child: Text(
                          isChinese ? '暂不' : 'Not Yet',
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: const Color(0xFFB794F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isChinese ? '是的' : 'Yes',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldLetGo == true && context.mounted) {
      await _showDeclutterRouteOptions(context, memory);
    }
  }

  Future<void> _showDeclutterRouteOptions(BuildContext context, Memory memory) async {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = l10n.localeName.toLowerCase().startsWith('zh');

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isChinese ? '选择离开方式' : 'Choose Route',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isChinese
                      ? '你想如何让这件物品离开？'
                      : 'How would you like to let this item go?',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildRouteOption(
                  context: dialogContext,
                  icon: Icons.shopping_bag_outlined,
                  title: isChinese ? '转卖' : 'Resell',
                  description: isChinese ? '通过二手平台出售' : 'Sell on secondhand platform',
                  color: const Color(0xFFFFD93D),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    // TODO: Navigate to resell item creation
                  },
                ),
                const SizedBox(height: 12),
                _buildRouteOption(
                  context: dialogContext,
                  icon: Icons.favorite_outline,
                  title: isChinese ? '赠送' : 'Gift',
                  description: isChinese ? '送给需要的人' : 'Give to someone who needs it',
                  color: const Color(0xFFFF9AA2),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    // TODO: Navigate to gift item creation
                  },
                ),
                const SizedBox(height: 12),
                _buildRouteOption(
                  context: dialogContext,
                  icon: Icons.recycling_outlined,
                  title: isChinese ? '捐赠/回收' : 'Donate/Recycle',
                  description: isChinese ? '捐给公益或回收' : 'Donate or recycle',
                  color: const Color(0xFF5ECFB8),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    // TODO: Navigate to donate/recycle item creation
                  },
                ),
                const SizedBox(height: 12),
                _buildRouteOption(
                  context: dialogContext,
                  icon: Icons.delete_outline,
                  title: isChinese ? '丢弃' : 'Discard',
                  description: isChinese ? '直接扔掉' : 'Throw away',
                  color: const Color(0xFF9CA3AF),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    // TODO: Navigate to discard item creation
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRouteOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
