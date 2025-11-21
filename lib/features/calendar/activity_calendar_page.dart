import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import 'package:keepjoy_app/models/planned_session.dart';
import 'package:keepjoy_app/services/data_repository.dart';

/// Declutter planning calendar page
class ActivityCalendarPage extends StatefulWidget {
  const ActivityCalendarPage({
    super.key,
    required this.plannedSessions,
    required this.onSessionsChanged,
  });

  final List<PlannedSession> plannedSessions;
  final VoidCallback onSessionsChanged;

  @override
  State<ActivityCalendarPage> createState() => _ActivityCalendarPageState();
}

class _ActivityCalendarPageState extends State<ActivityCalendarPage> {
  final _repository = DataRepository();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<PlannedSession> _getSessionsForDay(DateTime day) {
    return widget.plannedSessions.where((session) {
      final compareDate = DateTime(day.year, day.month, day.day);

      // Priority 1: Show scheduled sessions on their scheduled date
      if (session.scheduledDate != null) {
        final sessionDate = DateTime(
          session.scheduledDate!.year,
          session.scheduledDate!.month,
          session.scheduledDate!.day,
        );
        return sessionDate == compareDate;
      }

      // Priority 2: Show completed unscheduled sessions on their completion date
      if (session.isCompleted && session.completedAt != null) {
        final completedDate = DateTime(
          session.completedAt!.year,
          session.completedAt!.month,
          session.completedAt!.day,
        );
        return completedDate == compareDate;
      }

      // Priority 3: Show unscheduled, non-completed goals on their creation date
      final createdDate = DateTime(
        session.createdAt.year,
        session.createdAt.month,
        session.createdAt.day,
      );
      return createdDate == compareDate;
    }).toList();
  }

  List<PlannedSession> _getUnscheduledSessions() {
    return widget.plannedSessions
        .where(
          (session) => !session.isCompleted && session.scheduledDate == null,
        )
        .toList();
  }

  Future<void> _addNewPlan() async {
    final l10n = AppLocalizations.of(context)!;
    final titleController = TextEditingController();
    final areaController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.calendarAddNewPlan),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: l10n.calendarPlanTitleLabel,
                hintText: l10n.calendarPlanTitleHint,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: areaController,
              decoration: InputDecoration(
                labelText: l10n.calendarPlanAreaLabel,
                hintText: l10n.calendarPlanAreaHint,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.add),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      try {
        final newSession = PlannedSession(
          id: const Uuid().v4(),
          title: titleController.text,
          area: areaController.text.isNotEmpty
              ? areaController.text
              : titleController.text,
          createdAt: DateTime.now(),
          priority: TaskPriority.someday,
        );

        await _repository.createPlannedSession(newSession);
        widget.onSessionsChanged();
      } catch (e) {
        // Handle error
      }
    }

    titleController.dispose();
    areaController.dispose();
  }

  Future<void> _toggleSessionCompletion(PlannedSession session) async {
    try {
      await _repository.toggleTaskCompletion(session);
      widget.onSessionsChanged();
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeName = l10n.localeName;
    final topPadding = MediaQuery.of(context).padding.top;

    final scheduledSessions = widget.plannedSessions
        .where((s) => s.isScheduled)
        .toList();
    final unscheduledSessions = _getUnscheduledSessions();
    final hasAnySessions =
        scheduledSessions.isNotEmpty || unscheduledSessions.isNotEmpty;

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
              children: [
                // Header space
                const SizedBox(height: 120),

                // Content
                if (!hasAnySessions)
                  // Empty state
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 48,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBE6F5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.startPlanningDeclutter,
                              style: const TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFB8D9F5),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  // Calendar and sessions
                  Column(
                    children: [
                      // Calendar
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _SimpleCalendar(
                            focusedDay: _focusedDay,
                            selectedDay: _selectedDay,
                            onDaySelected: (day) {
                              setState(() {
                                _selectedDay = day;
                              });
                            },
                            onMonthChanged: (month) {
                              setState(() {
                                _focusedDay = month;
                              });
                            },
                            getSessionsForDay: _getSessionsForDay,
                            localeName: localeName,
                          ),
                        ),
                      ),

                      // Sessions for selected day
                      if (_selectedDay != null) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              DateFormat.MMMEd(
                                localeName,
                              ).format(_selectedDay!),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                        ),
                        ..._getSessionsForDay(_selectedDay!).map(
                          (session) => _SessionTile(
                            session: session,
                            onToggle: () => _toggleSessionCompletion(session),
                          ),
                        ),
                      ],

                      // Unscheduled tasks
                      if (unscheduledSessions.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                          child: Row(
                            children: [
                              Text(
                                l10n.calendarUnscheduled,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${unscheduledSessions.length}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...unscheduledSessions.map(
                          (session) => _SessionTile(
                            session: session,
                            onToggle: () => _toggleSessionCompletion(session),
                          ),
                        ),
                      ],

                      const SizedBox(height: 80),
                    ],
                  ),
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
                  child: Text(
                    l10n.calendarTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Original header - allows touches to pass through
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: true,
              child: Opacity(
                opacity: headerOpacity,
                child: Container(
                  height: 120,
                  color: Colors.transparent,
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 16,
                    top: topPadding + 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        l10n.calendarTitle,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          letterSpacing: -0.5,
                        ),
                      ),
                      IgnorePointer(
                        ignoring: false,
                        child: GestureDetector(
                          onTap: _addNewPlan,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.calendarAddNewPlan,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
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
}

class _SessionTile extends StatelessWidget {
  final PlannedSession session;
  final VoidCallback onToggle;

  const _SessionTile({required this.session, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Larger tap area for checkbox
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: session.isCompleted
                      ? const Color(0xFFB794F6)
                      : Colors.white,
                  border: Border.all(
                    color: session.isCompleted
                        ? const Color(0xFFB794F6)
                        : const Color(0xFFD1D5DB),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: session.isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: session.isCompleted
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF111827),
                    decoration: session.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (session.scheduledTime != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      session.scheduledTime!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Simple calendar widget
class _SimpleCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime) onDaySelected;
  final Function(DateTime) onMonthChanged;
  final List<PlannedSession> Function(DateTime) getSessionsForDay;
  final String localeName;

  const _SimpleCalendar({
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onMonthChanged,
    required this.getSessionsForDay,
    required this.localeName,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final lastDayOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final weekdayLabels = List.generate(7, (index) {
      final referenceDate = DateTime(2020, 1, 5 + index);
      return DateFormat.E(localeName).format(referenceDate);
    });

    return Column(
      children: [
        // Month header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                onMonthChanged(DateTime(focusedDay.year, focusedDay.month - 1));
              },
            ),
            Text(
              DateFormat.yMMMM(localeName).format(focusedDay),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                onMonthChanged(DateTime(focusedDay.year, focusedDay.month + 1));
              },
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Weekday headers
        Row(
          children: weekdayLabels.map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        // Calendar days
        ...List.generate(
          ((daysInMonth + firstWeekday + 6) ~/ 7),
          (weekIndex) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;

                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 40));
                }

                final date = DateTime(
                  focusedDay.year,
                  focusedDay.month,
                  dayNumber,
                );
                final sessions = getSessionsForDay(date);
                final hasSessions = sessions.isNotEmpty;
                final isToday =
                    date.year == todayDate.year &&
                    date.month == todayDate.month &&
                    date.day == todayDate.day;
                final isSelected =
                    selectedDay != null &&
                    date.year == selectedDay!.year &&
                    date.month == selectedDay!.month &&
                    date.day == selectedDay!.day;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onDaySelected(date),
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFB794F6)
                            : isToday
                            ? const Color(0xFFB794F6).withValues(alpha: 0.2)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              '$dayNumber',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: hasSessions || isToday
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF111827),
                              ),
                            ),
                          ),
                          if (hasSessions && !isSelected)
                            Positioned(
                              bottom: 4,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF5ECFB8),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }
}
