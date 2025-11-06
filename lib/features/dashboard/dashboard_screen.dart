import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:keepjoy_app/features/deep_cleaning/deep_cleaning_flow.dart';
import 'package:keepjoy_app/features/insights/memory_lane_report_screen.dart';
import 'package:keepjoy_app/features/dashboard/widgets/cleaning_area_legend.dart';
import 'package:keepjoy_app/features/insights/resell_analysis_report_screen.dart';
import 'package:keepjoy_app/features/insights/yearly_reports_screen.dart';
import 'package:keepjoy_app/features/profile/profile_page.dart';
import 'package:keepjoy_app/features/memories/create_memory_page.dart';
import 'package:keepjoy_app/l10n/app_localizations.dart';
import 'package:keepjoy_app/models/activity_entry.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/deep_cleaning_session.dart';
import 'package:keepjoy_app/models/memory.dart';
import 'package:keepjoy_app/models/resell_item.dart';
import 'package:keepjoy_app/models/planned_session.dart';
import 'package:keepjoy_app/theme/typography.dart';
import 'package:keepjoy_app/widgets/gradient_button.dart';

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
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _timer;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

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

  void _showAddGoalDialog(BuildContext context, bool isChinese) {
    final TextEditingController goalController = TextEditingController();
    DateTime? selectedDate;

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
                      isChinese ? '创建新目标' : 'Create New Goal',
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
                        labelText: isChinese ? '目标' : 'Goal',
                        hintText: isChinese
                            ? '例如：12月底前整理50件物品\n或：清理厨房并拍照记录'
                            : 'e.g., Declutter 50 items by end of December\nor Clean kitchen and take photos',
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
                      title: Text(isChinese ? '日期（可选）' : 'Date (Optional)'),
                      subtitle: Text(
                        selectedDate != null
                            ? DateFormat(
                                isChinese ? 'yyyy年M月d日' : 'MMM d, yyyy',
                              ).format(selectedDate!)
                            : (isChinese ? '点击选择日期' : 'Tap to select date'),
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
                        final picked = await showDatePicker(
                          context: builderContext,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
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
                            child: Text(isChinese ? '取消' : 'Cancel'),
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
                                      isChinese
                                          ? '请输入目标'
                                          : 'Please enter a goal',
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
                                  content: Text(
                                    isChinese ? '目标已创建' : 'Goal created',
                                  ),
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
                            child: Text(isChinese ? '创建' : 'Create'),
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

  void _showAddSessionDialog(BuildContext context, bool isChinese) {
    final TextEditingController areaController = TextEditingController();
    DateTime? selectedDate = DateTime.now();
    TimeOfDay? selectedTime;
    SessionMode selectedMode = SessionMode.deepCleaning;

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
                        isChinese ? '创建新任务' : 'Create New Session',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Mode Selection
                      Text(
                        isChinese ? '模式' : 'Mode',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: SessionMode.values.map((mode) {
                          final isSelected = selectedMode == mode;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () {
                                  setModalState(() {
                                    selectedMode = mode;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF414B5A)
                                        : Colors.white,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF414B5A)
                                          : const Color(0xFFE5E7EA),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    mode.displayName(isChinese),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF6B7280),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: areaController,
                        decoration: InputDecoration(
                          labelText: isChinese ? '区域' : 'Area',
                          hintText: isChinese
                              ? '例如：厨房、卧室'
                              : 'e.g., Kitchen, Bedroom',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFE5E7EA)),
                        ),
                        leading: const Icon(Icons.calendar_today),
                        title: Text(isChinese ? '日期' : 'Date'),
                        subtitle: Text(
                          selectedDate != null
                              ? DateFormat(
                                  isChinese ? 'yyyy年M月d日' : 'MMM d, yyyy',
                                ).format(selectedDate!)
                              : (isChinese ? '选择日期' : 'Select date'),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: builderContext,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
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
                        title: Text(isChinese ? '时间' : 'Time'),
                        subtitle: Text(
                          selectedTime != null
                              ? selectedTime!.format(builderContext)
                              : (isChinese
                                    ? '选择时间（可选）'
                                    : 'Select time (optional)'),
                        ),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: builderContext,
                            initialTime: selectedTime ?? TimeOfDay.now(),
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
                              child: Text(isChinese ? '取消' : 'Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (areaController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isChinese
                                            ? '请输入区域名称'
                                            : 'Please enter an area name',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final newSession = PlannedSession(
                                  id: DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                                  title:
                                      '${areaController.text} ${selectedMode.displayName(isChinese)}',
                                  area: areaController.text.trim(),
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
                                    content: Text(
                                      isChinese ? '任务已创建' : 'Session created',
                                    ),
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
                              child: Text(isChinese ? '创建' : 'Create'),
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

  void _showAllSessionsCalendar(BuildContext context, bool isChinese) {
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
                            isChinese ? '计划日历' : 'Calendar',
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
                              _showAddSessionDialog(context, isChinese);
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
                                      isChinese
                                          ? '这天没有计划任务'
                                          : 'No sessions on this day',
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
                                          isChinese
                                              ? '任务已删除'
                                              : 'Session deleted',
                                        ),
                                      ),
                                    );
                                  },
                                  child: _buildSessionCard(
                                    session,
                                    isChinese,
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

  Widget _buildSessionCard(
    PlannedSession session,
    bool isChinese,
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
                  '${session.mode.displayName(isChinese)} - ${session.area}',
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
                          isChinese ? '已完成' : 'Done',
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
                            isChinese,
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

  String _formatSessionDate(DateTime? date, String? time, bool isChinese) {
    if (date == null) {
      return isChinese ? '未设定时间' : 'Not scheduled';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(date.year, date.month, date.day);

    String dateStr;
    if (sessionDate == today) {
      dateStr = isChinese ? '今天' : 'Today';
    } else if (sessionDate == today.add(const Duration(days: 1))) {
      dateStr = isChinese ? '明天' : 'Tomorrow';
    } else {
      dateStr = isChinese
          ? DateFormat('M月d日', 'zh_CN').format(date)
          : DateFormat('MMM d').format(date);
    }

    if (time != null && time.isNotEmpty) {
      return isChinese ? '$dateStr $time' : '$dateStr at $time';
    } else {
      return dateStr;
    }
  }

  void _startSessionFromPlanned(PlannedSession session) {
    switch (session.mode) {
      case SessionMode.deepCleaning:
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
    final l10n = AppLocalizations.of(context)!;
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
                                      isChinese ? '当前连击' : 'Current Streak',
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
                                  isChinese ? '天连续记录' : 'Days in a row',
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
                                  }
                                },
                                width: double.infinity,
                                height: 44,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.sentiment_satisfied_alt,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.createMemory,
                                      style: const TextStyle(
                                        fontFamily: 'SF Pro Text',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0,
                                        color: Colors.white,
                                      ),
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
                                  isChinese ? '进行中的任务' : 'Active Session',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF111827),
                                      ),
                                ),
                                Text(
                                  isChinese ? '深度整理' : 'Deep Cleaning',
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
                                    label: Text(isChinese ? '继续' : 'Resume'),
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
                                              child: Text(l10n.finish),
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
                                    child: Text(isChinese ? '停止' : 'Stop'),
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
                            isChinese ? '待办事项' : 'To Do',
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
                              _showAllSessionsCalendar(context, isChinese);
                            },
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(isChinese ? '查看日历' : 'View Calendar'),
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
                                      isChinese ? '暂无待办事项' : 'No items yet',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      isChinese
                                          ? '点击下方按钮创建目标或任务'
                                          : 'Tap below to create a goal or session',
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
                                          isChinese
                                              ? '任务已删除'
                                              : 'Session deleted',
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
                                                  isChinese,
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
                                            child: Text(
                                              isChinese ? '开始' : 'Start Now',
                                            ),
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
                                _showAddGoalDialog(context, isChinese);
                              },
                              icon: const Icon(Icons.flag_outlined, size: 20),
                              label: Text(isChinese ? '创建目标' : 'Create Goal'),
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
                                _showAddSessionDialog(context, isChinese);
                              },
                              icon: const Icon(
                                Icons.add_circle_outline,
                                size: 20,
                              ),
                              label: Text(
                                isChinese ? '创建任务' : 'Create Session',
                              ),
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
                        isChinese ? '本月进度' : 'Monthly Progress',
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
                              label: isChinese ? '深度整理' : 'Deep Cleaning',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              icon: Icons.inventory_2_rounded,
                              iconColor: const Color(0xFF5ECFB8),
                              value: widget.declutteredItems.length.toString(),
                              label: isChinese ? '已整理' : 'Decluttered',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              icon: Icons.attach_money_rounded,
                              iconColor: const Color(0xFFFFD93D),
                              value: totalValue.toStringAsFixed(0),
                              label: isChinese ? '转售' : 'Resell',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Letting Go Details Card
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: _buildLetGoDetailsCard(context, isChinese),
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
                      _buildReportCard(
                        context,
                        icon: Icons.trending_up_rounded,
                        iconColor: const Color(0xFFFFD93D),
                        bgColors: [
                          const Color(0xFFFFF9E6),
                          const Color(0xFFFFECB3),
                        ],
                        title: isChinese ? '转卖分析' : 'Resell Analysis',
                        subtitle: isChinese ? '查看完整报告' : 'View full report',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResellAnalysisReportScreen(
                                resellItems: widget.resellItems,
                                declutteredItems: widget.declutteredItems,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildReportCard(
                        context,
                        icon: Icons.calendar_today_rounded,
                        iconColor: const Color(0xFF89CFF0),
                        bgColors: [
                          const Color(0xFFE6F4F9),
                          const Color(0xFFD4E9F3),
                        ],
                        title: isChinese ? '年度报告' : 'Yearly Reports',
                        subtitle: isChinese ? '查看年度总结' : 'View annual summary',
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
                      const SizedBox(height: 12),
                      _buildReportCard(
                        context,
                        icon: Icons.photo_library_rounded,
                        iconColor: const Color(0xFFFF9AA2),
                        bgColors: [
                          const Color(0xFFFFEEF0),
                          const Color(0xFFFFDDE0),
                        ],
                        title: isChinese ? '记忆长廊' : 'Memory Lane',
                        subtitle: isChinese
                            ? '重温你的整理旅程'
                            : 'Revisit your journey',
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
                          const Text(
                            'ready to start your declutter joy',
                            style: TextStyle(
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

  Widget _buildMonthlyReportCard(BuildContext context, bool isChinese) {
    // Calculate THIS MONTH's metrics
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

    // 1. Deep cleaning sessions count
    final deepCleaningCount = sessionsThisMonth.length;

    // 2. Cleaned items count
    final cleanedItemsCount = sessionsThisMonth
        .where((session) => session.itemsCount != null)
        .fold(0, (sum, session) => sum + session.itemsCount!);

    // 3. Average focus
    final sessionsWithFocus = sessionsThisMonth
        .where((session) => session.focusIndex != null)
        .toList();
    final averageFocus = sessionsWithFocus.isEmpty
        ? 0.0
        : sessionsWithFocus
                  .map((session) => session.focusIndex!)
                  .reduce((a, b) => a + b) /
              sessionsWithFocus.length;

    // 4. Average joy
    final sessionsWithMood = sessionsThisMonth
        .where((session) => session.moodIndex != null)
        .toList();
    final averageJoy = sessionsWithMood.isEmpty
        ? 0.0
        : sessionsWithMood
                  .map((session) => session.moodIndex!)
                  .reduce((a, b) => a + b) /
              sessionsWithMood.length;

    // Group ALL sessions by area (not just this month)
    final sessionsByArea = <String, List<DeepCleaningSession>>{};
    for (final session in widget.deepCleaningSessions) {
      sessionsByArea.update(
        session.area,
        (list) => list..add(session),
        ifAbsent: () => [session],
      );
    }

    // Define common predefined areas
    final commonAreas = [
      isChinese ? '厨房' : 'Kitchen',
      isChinese ? '卧室' : 'Bedroom',
      isChinese ? '客厅' : 'Living Room',
      isChinese ? '浴室' : 'Bathroom',
      isChinese ? '书房' : 'Study',
      isChinese ? '衣柜' : 'Closet',
    ];

    // Combine common areas with custom areas
    final allAreas = <String>{...commonAreas, ...sessionsByArea.keys}.toList();

    // Calculate area counts for heatmap
    final areaCounts = <String, int>{};
    for (final area in allAreas) {
      areaCounts[area] = sessionsByArea[area]?.length ?? 0;
    }

    // Get max count for heatmap
    final maxAreaCount = areaCounts.values.isEmpty
        ? 1
        : areaCounts.values
              .reduce((a, b) => a > b ? a : b)
              .clamp(1, double.infinity)
              .toInt();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            isChinese ? '深度整理分析' : 'Deep Cleaning Analysis',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // Metrics Row
          Row(
            children: [
              Expanded(
                child: _buildDeepCleaningMetricItem(
                  context,
                  icon: Icons.cleaning_services_rounded,
                  color: const Color(0xFFB794F6),
                  value: deepCleaningCount.toString(),
                  label: isChinese ? '整理次数' : 'Sessions',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDeepCleaningMetricItem(
                  context,
                  icon: Icons.inventory_2_rounded,
                  color: const Color(0xFF5ECFB8),
                  value: cleanedItemsCount.toString(),
                  label: isChinese ? '清理物品' : 'Items',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDeepCleaningMetricItem(
                  context,
                  icon: Icons.spa_rounded,
                  color: const Color(0xFF89CFF0),
                  value: averageFocus.toStringAsFixed(1),
                  label: isChinese ? '平均专注度' : 'Avg Focus',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDeepCleaningMetricItem(
                  context,
                  icon: Icons.sentiment_satisfied_rounded,
                  color: const Color(0xFFFFD93D),
                  value: averageJoy.toStringAsFixed(1),
                  label: isChinese ? '平均愉悦度' : 'Avg Joy',
                ),
              ),
            ],
          ),

          const Divider(height: 40, thickness: 1, color: Color(0xFFE5E5EA)),

          // Cleaning Areas with heatmap (ALL areas)
          _buildReportSection(
            context,
            title: isChinese ? '整理区域' : 'Cleaning Areas',
            trailing: CleaningAreaLegend.badge(
              context: context,
              isChinese: isChinese,
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (dialogContext) => CleaningAreaLegend.dialog(
                    context: dialogContext,
                    isChinese: isChinese,
                  ),
                );
              },
            ),
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: allAreas.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final area = allAreas[index];
                  final count = areaCounts[area] ?? 0;
                  final entry = CleaningAreaLegend.forCount(count);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: entry.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '$area ($count)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: entry.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const Divider(height: 40, thickness: 1, color: Color(0xFFE5E5EA)),

          // Before & After - Area-based sessions (clickable)
          _buildReportSection(
            context,
            title: isChinese ? '整理前后对比' : 'Before & After',
            child: sessionsByArea.isEmpty
                ? Text(
                    isChinese
                        ? '还没有深度整理记录，开始第一次整理吧。'
                        : 'No deep cleaning records yet. Start your first session.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sessionsByArea.entries.map((entry) {
                      final area = entry.key;
                      final sessions = entry.value;
                      final sessionCount = sessions.length;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            _showAreaDeepCleaningReport(
                              context,
                              area,
                              isChinese,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$area ($sessionCount ${isChinese ? '次' : 'sessions'})',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection(
    BuildContext context, {
    required String title,
    String? subtitle,
    Widget? trailing,
    required Widget child,
  }) {
    final titleRow = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing],
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleRow,
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
        ],
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildDeepCleaningMetricItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black54,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showAreaDeepCleaningReport(
    BuildContext context,
    String area,
    bool isChinese,
  ) {
    // Get all sessions for this area, sorted by date (most recent first)
    final areaSessions =
        widget.deepCleaningSessions
            .where((session) => session.area == area)
            .toList()
          ..sort((a, b) => b.startTime.compareTo(a.startTime));

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.7,
          maxChildSize: 0.95,
          expand: false,
          builder: (builderContext, scrollController) {
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
                  Text(
                    '$area ${isChinese ? '整理记录' : 'Cleaning History'}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${areaSessions.length} ${isChinese ? '次整理' : 'sessions'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: areaSessions.length,
                      itemBuilder: (context, index) {
                        final session = areaSessions[index];
                        final dateStr = DateFormat(
                          isChinese ? 'yyyy年M月d日' : 'MMM d, yyyy',
                        ).format(session.startTime);

                        final improvement =
                            session.beforeMessinessIndex != null &&
                                session.afterMessinessIndex != null
                            ? ((session.beforeMessinessIndex! -
                                          session.afterMessinessIndex!) /
                                      session.beforeMessinessIndex! *
                                      100)
                                  .toStringAsFixed(0)
                            : null;

                        return GestureDetector(
                          onTap: () {
                            _showSessionDetail(context, session, isChinese);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE5E7EA),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      dateStr,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    if (improvement != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF10B981,
                                          ).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          isChinese
                                              ? '改善 $improvement%'
                                              : '$improvement% better',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF10B981),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    if (session.focusIndex != null) ...[
                                      Icon(
                                        Icons.spa_rounded,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${isChinese ? '专注度' : 'Focus'}: ${session.focusIndex}/5',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                    ],
                                    if (session.moodIndex != null) ...[
                                      Icon(
                                        Icons.sentiment_satisfied_rounded,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${isChinese ? '愉悦度' : 'Joy'}: ${session.moodIndex}/5',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (session.itemsCount != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '${isChinese ? '清理物品' : 'Items cleaned'}: ${session.itemsCount}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
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
  }

  void _showSessionDetail(
    BuildContext context,
    DeepCleaningSession session,
    bool isChinese,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (builderContext, scrollController) {
            // Calculate metrics
            final improvement =
                session.beforeMessinessIndex != null &&
                    session.afterMessinessIndex != null
                ? ((session.beforeMessinessIndex! -
                              session.afterMessinessIndex!) /
                          session.beforeMessinessIndex! *
                          100)
                      .toStringAsFixed(0)
                : null;

            final dateStr = DateFormat(
              isChinese ? 'yyyy年M月d日' : 'MMM d, yyyy',
            ).format(session.startTime);

            final hasPhotos =
                session.beforePhotoPath != null &&
                session.afterPhotoPath != null;

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      children: [
                        // Header with close button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session.area,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dateStr,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(sheetContext),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Section title
                        Text(
                          isChinese ? '整理数据' : 'Session Data',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Photo comparison slider
                        if (hasPhotos) ...[
                          Container(
                            height: 240,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.grey[200],
                            ),
                            child: PageView(
                              children: [
                                // Before photo
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(
                                        File(session.beforePhotoPath!),
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        top: 12,
                                        left: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.6,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            isChinese ? '整理前' : 'Before',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // After photo
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(
                                        File(session.afterPhotoPath!),
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        top: 12,
                                        left: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.6,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            isChinese ? '整理后' : 'After',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.swipe_left_rounded,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isChinese ? '左右滑动查看' : 'Swipe to compare',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Divider
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFE5E7EA),
                        ),
                        const SizedBox(height: 24),

                        // Metrics in simple list format
                        // Duration
                        if (session.elapsedSeconds != null)
                          _buildMetricRow(
                            label: isChinese ? '时长' : 'Duration',
                            value:
                                '${(session.elapsedSeconds! / 60).toStringAsFixed(0)} ${isChinese ? '分钟' : 'min'}',
                          ),

                        // Items decluttered
                        if (session.itemsCount != null)
                          _buildMetricRow(
                            label: isChinese ? '清理物品' : 'Items decluttered',
                            value: '${session.itemsCount}',
                          ),

                        // Messiness reduction
                        if (improvement != null &&
                            session.beforeMessinessIndex != null &&
                            session.afterMessinessIndex != null)
                          _buildMetricRow(
                            label: isChinese ? '整洁度提升' : 'Messiness reduced',
                            value:
                                '$improvement% (${isChinese ? '从' : 'from'} ${session.beforeMessinessIndex!.toStringAsFixed(0)} ${isChinese ? '到' : 'to'} ${session.afterMessinessIndex!.toStringAsFixed(0)})',
                          ),

                        // Focus
                        if (session.focusIndex != null)
                          _buildMetricRow(
                            label: isChinese ? '专注度' : 'Focus',
                            value: '${session.focusIndex}/5',
                          ),

                        // Joy
                        if (session.moodIndex != null)
                          _buildMetricRow(
                            label: isChinese ? '愉悦度' : 'Joy',
                            value: '${session.moodIndex}/5',
                          ),

                        // Show message if no metrics available
                        if (session.elapsedSeconds == null &&
                            session.itemsCount == null &&
                            improvement == null &&
                            session.focusIndex == null &&
                            session.moodIndex == null)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE5E7EA),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 32,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  isChinese ? '未记录详细数据' : 'No Detailed Metrics',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isChinese
                                      ? '这次整理只保存了照片记录\n下次整理时可以记录更多数据'
                                      : 'This session only saved photos\nNext time you can record more details',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF9CA3AF),
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMetricRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLetGoDetailsCard(BuildContext context, bool isChinese) {
    final theme = Theme.of(context);

    // Calculate counts for each disposal method
    final resellCount = widget.declutteredItems
        .where((item) => item.status == DeclutterStatus.resell)
        .length;
    final recycleCount = widget.declutteredItems
        .where((item) => item.status == DeclutterStatus.recycle)
        .length;
    final donateCount = widget.declutteredItems
        .where((item) => item.status == DeclutterStatus.donate)
        .length;
    final discardCount = widget.declutteredItems
        .where((item) => item.status == DeclutterStatus.discard)
        .length;

    final total = resellCount + recycleCount + donateCount + discardCount;

    // Define colors for each category
    const resellColor = Color(0xFFFFD93D); // Yellow
    const recycleColor = Color(0xFF5ECFB8); // Teal
    const donateColor = Color(0xFFFF9AA2); // Pink
    const discardColor = Color(0xFFC7A2FF); // Lavender

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isChinese ? '放手详情' : 'Letting Go Details',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isChinese ? '了解不同去向的放手占比' : 'See how items found their next home',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          // Pie chart
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: total > 0
                  ? CustomPaint(
                      painter: _DonutChartPainter(
                        resellCount: resellCount,
                        recycleCount: recycleCount,
                        donateCount: donateCount,
                        discardCount: discardCount,
                        total: total,
                        resellColor: resellColor,
                        recycleColor: recycleColor,
                        donateColor: donateColor,
                        discardColor: discardColor,
                      ),
                    )
                  : CustomPaint(painter: _EmptyDonutChartPainter()),
            ),
          ),
          const SizedBox(height: 24),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(
                color: resellColor,
                label: isChinese ? '出售' : 'Sell',
                count: resellCount,
                theme: theme,
                isChinese: isChinese,
              ),
              _buildLegendItem(
                color: recycleColor,
                label: isChinese ? '回收' : 'Recycle',
                count: recycleCount,
                theme: theme,
                isChinese: isChinese,
              ),
              _buildLegendItem(
                color: donateColor,
                label: isChinese ? '捐赠' : 'Donate',
                count: donateCount,
                theme: theme,
                isChinese: isChinese,
              ),
              _buildLegendItem(
                color: discardColor,
                label: isChinese ? '丢弃' : 'Discard',
                count: discardCount,
                theme: theme,
                isChinese: isChinese,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int count,
    required ThemeData theme,
    required bool isChinese,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: theme.textTheme.titleMedium?.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
        if (isChinese)
          Text(
            '件',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
          ),
      ],
    );
  }
}

// Custom painter for donut chart
class _DonutChartPainter extends CustomPainter {
  final int resellCount;
  final int recycleCount;
  final int donateCount;
  final int discardCount;
  final int total;
  final Color resellColor;
  final Color recycleColor;
  final Color donateColor;
  final Color discardColor;

  _DonutChartPainter({
    required this.resellCount,
    required this.recycleCount,
    required this.donateCount,
    required this.discardCount,
    required this.total,
    required this.resellColor,
    required this.recycleColor,
    required this.donateColor,
    required this.discardColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.6;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius - innerRadius;

    double startAngle = -90 * (3.14159 / 180); // Start from top

    // Draw resell segment
    if (resellCount > 0) {
      final sweepAngle = (resellCount / total) * 2 * 3.14159;
      paint.color = resellColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - paint.strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Draw recycle segment
    if (recycleCount > 0) {
      final sweepAngle = (recycleCount / total) * 2 * 3.14159;
      paint.color = recycleColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - paint.strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Draw donate segment
    if (donateCount > 0) {
      final sweepAngle = (donateCount / total) * 2 * 3.14159;
      paint.color = donateColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - paint.strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Draw discard segment
    if (discardCount > 0) {
      final sweepAngle = (discardCount / total) * 2 * 3.14159;
      paint.color = discardColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - paint.strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Empty donut chart painter (all gray)
class _EmptyDonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.6;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius - innerRadius
      ..color = const Color(0xFFE0E0E0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - paint.strokeWidth / 2),
      0,
      2 * 3.14159,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
