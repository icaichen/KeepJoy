import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:keepjoy_app/features/deep_cleaning/deep_cleaning_flow.dart';
import 'package:keepjoy_app/features/insights/deep_cleaning_report_screen.dart';
import 'package:keepjoy_app/features/insights/memory_lane_report_screen.dart';
import 'package:keepjoy_app/features/insights/resell_analysis_report_screen.dart';
import 'package:keepjoy_app/features/insights/yearly_reports_screen.dart';
import 'package:keepjoy_app/features/insights/insights_screen.dart';
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

class DashboardScreen extends StatefulWidget {
  final DeepCleaningSession? activeSession;
  final VoidCallback onStopSession;
  final Function(String area) onStartSession;
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
      case 1: return l10n.quote1;
      case 2: return l10n.quote2;
      case 3: return l10n.quote3;
      case 4: return l10n.quote4;
      case 5: return l10n.quote5;
      case 6: return l10n.quote6;
      case 7: return l10n.quote7;
      case 8: return l10n.quote8;
      case 9: return l10n.quote9;
      case 10: return l10n.quote10;
      case 11: return l10n.quote11;
      case 12: return l10n.quote12;
      case 13: return l10n.quote13;
      case 14: return l10n.quote14;
      case 15: return l10n.quote15;
      default: return l10n.quote1;
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE5E7EA)),
                      ),
                      leading: const Icon(Icons.calendar_today),
                      title: Text(isChinese ? '日期（可选）' : 'Date (Optional)'),
                      subtitle: Text(
                        selectedDate != null
                            ? DateFormat(isChinese ? 'yyyy年M月d日' : 'MMM d, yyyy').format(selectedDate!)
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
                          lastDate: DateTime.now().add(const Duration(days: 365)),
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
                                    content: Text(isChinese ? '请输入目标' : 'Please enter a goal'),
                                  ),
                                );
                                return;
                              }

                              final newSession = PlannedSession(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
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
                                  content: Text(isChinese ? '目标已创建' : 'Goal created'),
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
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF414B5A) : Colors.white,
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF414B5A) : const Color(0xFFE5E7EA),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    mode.displayName(isChinese),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? Colors.white : const Color(0xFF6B7280),
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
                          hintText: isChinese ? '例如：厨房、卧室' : 'e.g., Kitchen, Bedroom',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFE5E7EA)),
                        ),
                        leading: const Icon(Icons.calendar_today),
                        title: Text(isChinese ? '日期' : 'Date'),
                        subtitle: Text(
                          selectedDate != null
                              ? DateFormat(isChinese ? 'yyyy年M月d日' : 'MMM d, yyyy').format(selectedDate!)
                              : (isChinese ? '选择日期' : 'Select date'),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: builderContext,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFE5E7EA)),
                        ),
                        leading: const Icon(Icons.access_time),
                        title: Text(isChinese ? '时间' : 'Time'),
                        subtitle: Text(
                          selectedTime != null
                              ? selectedTime!.format(builderContext)
                              : (isChinese ? '选择时间（可选）' : 'Select time (optional)'),
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
                                if (areaController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isChinese ? '请输入区域名称' : 'Please enter an area name'),
                                    ),
                                  );
                                  return;
                                }

                                final newSession = PlannedSession(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  title: '${areaController.text} ${selectedMode.displayName(isChinese)}',
                                  area: areaController.text.trim(),
                                  scheduledDate: selectedDate,
                                  scheduledTime: selectedTime?.format(builderContext),
                                  createdAt: DateTime.now(),
                                  priority: TaskPriority.thisWeek,
                                  mode: selectedMode,
                                  goal: null,
                                );

                                widget.onAddPlannedSession(newSession);
                                Navigator.pop(sheetContext);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isChinese ? '任务已创建' : 'Session created'),
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
                if (session.isCompleted || session.scheduledDate == null) continue;
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
                          lastDay: DateTime.now().add(const Duration(days: 365)),
                          focusedDay: focusedDay,
                          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
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
                            leftChevronIcon: const Icon(Icons.chevron_left, color: Color(0xFF414B5A)),
                            rightChevronIcon: const Icon(Icons.chevron_right, color: Color(0xFF414B5A)),
                          ),
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: const Color(0xFF414B5A).withValues(alpha: 0.2),
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
                            markerMargin: const EdgeInsets.symmetric(horizontal: 1),
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
                                      isChinese ? '这天没有计划任务' : 'No sessions on this day',
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
                                        content: Text(isChinese ? '任务已删除' : 'Session deleted'),
                                      ),
                                    );
                                  },
                                  child: _buildSessionCard(session, isChinese, context),
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

  Widget _buildSessionCard(PlannedSession session, bool isChinese, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EA)),
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
          Checkbox(
            value: session.isCompleted,
            onChanged: (value) {
              widget.onTogglePlannedSession(session);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF6B7280),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.area,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatSessionDate(session.scheduledDate, session.scheduledTime, isChinese),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close calendar modal
              widget.onStartSession(session.area);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF414B5A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(isChinese ? '开始' : 'Start'),
          ),
        ],
      ),
    );
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
    final isChinese = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');
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
                      isChinese ? '近期还没有活动记录，继续加油！' : 'No recent activity yet—keep going!',
                      style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
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
                    separatorBuilder: (_, __) => const Divider(height: 24, color: Color(0xFFE5E7EB)),
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
                                  style: Theme.of(sheetContext).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                if (entry.description != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    entry.description!,
                                    style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
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
      case ActivityType.deepCleaning: return Icons.cleaning_services_rounded;
      case ActivityType.joyDeclutter: return Icons.favorite_border_rounded;
      case ActivityType.quickDeclutter: return Icons.flash_on_rounded;
    }
  }

  String _activityTitle(ActivityEntry entry, AppLocalizations l10n) {
    switch (entry.type) {
      case ActivityType.deepCleaning: return l10n.deepCleaning;
      case ActivityType.joyDeclutter: return l10n.joyDeclutterTitle;
      case ActivityType.quickDeclutter: return l10n.quickDeclutterTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;

    final quoteOfDay = _getQuoteOfDay(l10n);

    // Calculate monthly metrics
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);

    final sessionsThisMonth = widget.deepCleaningSessions
        .where((session) =>
            !session.startTime.isBefore(monthStart) &&
            session.startTime.isBefore(nextMonthStart))
        .length;

    final soldItems = widget.resellItems.where((item) => item.soldPrice != null);
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
                              border: Border.all(color: const Color(0xFFE4E8EF)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x08000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                            child: Column(
                              children: [
                                // Header with title and fire icon
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isChinese ? '当前连击' : 'Current Streak',
                                      style: const TextStyle(
                                        fontFamily: 'SF Pro Display',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF3F4F6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.local_fire_department_rounded,
                                        color: Color(0xFFFDB022),
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Large streak number
                                Text(
                                  '${widget.streak}',
                                  style: const TextStyle(
                                    fontFamily: 'SF Pro Display',
                                    fontSize: 72,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Subtitle
                                Text(
                                  isChinese ? '天连续记录' : 'Days in a row',
                                  style: const TextStyle(
                                    fontFamily: 'SF Pro Text',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Dots visualization (max 7 dots)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    widget.streak > 7 ? 7 : widget.streak,
                                    (index) => Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF6B7280),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )..addAll(
                                    widget.streak > 7
                                        ? [
                                            const SizedBox(width: 8),
                                            Text(
                                              '+${widget.streak - 7}',
                                              style: const TextStyle(
                                                fontFamily: 'SF Pro Display',
                                                fontSize: 14,
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
                        constraints: const BoxConstraints(maxWidth: 600),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE4E8EF)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.format_quote_rounded,
                                color: const Color(0xFF9CA3AF),
                                size: 32,
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
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
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
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final memory = await Navigator.of(context).push<Memory>(
                                      MaterialPageRoute(
                                        builder: (_) => const CreateMemoryPage(),
                                      ),
                                    );

                                    if (memory != null && context.mounted) {
                                      widget.onMemoryCreated(memory);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(l10n.memoryCreated)),
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.sentiment_satisfied_alt,
                                    size: 18,
                                  ),
                                  label: Text(
                                    l10n.createMemory,
                                    style: const TextStyle(
                                      fontFamily: 'SF Pro Text',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF414B5A),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Active Session (if exists)
                if (widget.activeSession != null) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE1E7EF)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isChinese ? '进行中的任务' : 'Active Session',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                Text(
                                  isChinese ? '深度整理' : 'Deep Cleaning',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getElapsedTime(widget.activeSession!.startTime),
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
                                            beforePhotoPath: widget.activeSession!.beforePhotoPath,
                                            onStopSession: widget.onStopSession,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.play_arrow, size: 18),
                                    label: Text(isChinese ? '继续' : 'Resume'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF414B5A),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
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

                      // Empty state or list
                      if (widget.plannedSessions.isEmpty)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EA)),
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
                                  isChinese ? '点击下方按钮创建目标或任务' : 'Tap below to create a goal or session',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        // To do items container with swipe to delete
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EA)),
                          ),
                          child: Column(
                            children: widget.plannedSessions.take(3).map((session) {
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
                                      content: Text(isChinese ? '任务已删除' : 'Session deleted'),
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
                                        width: widget.plannedSessions.take(3).last == session ? 0 : 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F4F6),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.calendar_month_rounded,
                                          color: Color(0xFF6B7280),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              session.goal ?? session.area,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1C1C1E),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatSessionDate(session.scheduledDate, session.scheduledTime, isChinese),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          _startSessionFromPlanned(session);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF414B5A),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text(isChinese ? '开始' : 'Start Now'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
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
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: const BorderSide(color: Color(0xFFE5E7EA)),
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
                                icon: const Icon(Icons.add_circle_outline, size: 20),
                                label: Text(isChinese ? '创建任务' : 'Create Session'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: const BorderSide(color: Color(0xFFE5E7EA)),
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

                // Reports Cards
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Column(
                    children: [
                      _buildReportCard(
                        context,
                        icon: Icons.trending_up_rounded,
                        iconColor: const Color(0xFFFFD93D),
                        bgColors: [const Color(0xFFFFF9E6), const Color(0xFFFFECB3)],
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
                        bgColors: [const Color(0xFFE6F4F9), const Color(0xFFD4E9F3)],
                        title: isChinese ? '年度报告' : 'Yearly Reports',
                        subtitle: isChinese ? '查看年度总结' : 'View annual summary',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => YearlyReportsScreen(
                                declutteredItems: widget.declutteredItems,
                                resellItems: widget.resellItems,
                                deepCleaningSessions: widget.deepCleaningSessions,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildReportCard(
                        context,
                        icon: Icons.auto_graph_rounded,
                        iconColor: const Color(0xFFB794F6),
                        bgColors: [const Color(0xFFF3EBFF), const Color(0xFFE6D5FF)],
                        title: isChinese ? '深度整理分析' : 'Deep Cleaning Analytics',
                        subtitle: isChinese ? '查看专注度和心情统计' : 'View focus & mood statistics',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeepCleaningReportScreen(
                                sessions: widget.deepCleaningSessions,
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
                        bgColors: [const Color(0xFFFFEEF0), const Color(0xFFFFDDE0)],
                        title: isChinese ? '记忆长廊' : 'Memory Lane',
                        subtitle: isChinese ? '重温你的整理旅程' : 'Revisit your journey',
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
                      const SizedBox(height: 12),
                      _buildReportCard(
                        context,
                        icon: Icons.insights_rounded,
                        iconColor: const Color(0xFF5ECFB8),
                        bgColors: [const Color(0xFFE6F9F5), const Color(0xFFD4EAE4)],
                        title: isChinese ? '每月整理报告' : 'Monthly Report',
                        subtitle: isChinese ? '查看本月详细统计' : 'View monthly statistics',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InsightsScreen(
                                declutteredItems: widget.declutteredItems,
                                resellItems: widget.resellItems,
                                deepCleaningSessions: widget.deepCleaningSessions,
                                streak: widget.streak,
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
                      bottom: BorderSide(
                        color: Color(0xFFE5E5EA),
                        width: 0.5,
                      ),
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
                              builder: (_) => ProfilePage(onLocaleChange: widget.onLocaleChange),
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
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
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
}
