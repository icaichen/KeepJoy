import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/deep_cleaning_session.dart';

class DeepCleaningReportScreen extends StatelessWidget {
  final List<DeepCleaningSession> sessions;

  const DeepCleaningReportScreen({
    super.key,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final isChinese = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');

    // Filter sessions that have focus and mood data
    final sessionsWithData = sessions.where((s) =>
      s.focusIndex != null && s.moodIndex != null
    ).toList();

    if (sessionsWithData.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F5F7),
          elevation: 0,
          title: Text(
            isChinese ? '深度整理分析' : 'Deep Cleaning Analytics',
            style: const TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                isChinese ? '暂无数据' : 'No Data Available',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isChinese ? '完成更多深度整理任务以查看分析' : 'Complete more deep cleaning sessions to view analytics',
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

    // Calculate statistics
    final avgFocus = sessionsWithData.map((s) => s.focusIndex!).reduce((a, b) => a + b) / sessionsWithData.length;
    final avgMood = sessionsWithData.map((s) => s.moodIndex!).reduce((a, b) => a + b) / sessionsWithData.length;
    final totalItems = sessionsWithData.map((s) => s.itemsCount ?? 0).reduce((a, b) => a + b);
    final totalTime = sessionsWithData.map((s) => s.elapsedSeconds ?? 0).reduce((a, b) => a + b);

    // Find most productive session (highest focus + most items)
    DeepCleaningSession? mostProductive;
    double highestProductivity = 0;
    for (var session in sessionsWithData) {
      final itemCount = session.itemsCount ?? 0;
      final productivity = (session.focusIndex ?? 0).toDouble() + itemCount * 0.1;
      if (productivity > highestProductivity) {
        highestProductivity = productivity;
        mostProductive = session;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F7),
        elevation: 0,
        title: Text(
          isChinese ? '深度整理分析' : 'Deep Cleaning Analytics',
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Stats
            Text(
              isChinese ? '总览' : 'Overview',
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.cleaning_services_rounded,
                    iconColor: const Color(0xFFB794F6),
                    value: sessionsWithData.length.toString(),
                    label: isChinese ? '总任务' : 'Total Sessions',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.inventory_2_rounded,
                    iconColor: const Color(0xFF5ECFB8),
                    value: totalItems.toString(),
                    label: isChinese ? '总物品' : 'Total Items',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.timer_outlined,
                    iconColor: const Color(0xFF89CFF0),
                    value: _formatTotalTime(totalTime, isChinese),
                    label: isChinese ? '总时长' : 'Total Time',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.timeline_rounded,
                    iconColor: const Color(0xFFFFD93D),
                    value: avgFocus.toStringAsFixed(1),
                    label: isChinese ? '平均专注度' : 'Avg Focus',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Focus & Mood Analysis
            Text(
              isChinese ? '状态分析' : 'State Analysis',
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EA)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _AnalysisRow(
                    icon: Icons.psychology_outlined,
                    label: isChinese ? '平均专注度' : 'Average Focus Level',
                    value: avgFocus.toStringAsFixed(1),
                    maxValue: 5,
                    color: const Color(0xFFB794F6),
                  ),
                  const SizedBox(height: 20),
                  _AnalysisRow(
                    icon: Icons.mood_outlined,
                    label: isChinese ? '平均心情' : 'Average Mood',
                    value: avgMood.toStringAsFixed(1),
                    maxValue: 5,
                    color: const Color(0xFF5ECFB8),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Most Productive Session
            if (mostProductive != null) ...[
              Text(
                isChinese ? '最佳任务' : 'Most Productive Session',
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF3EBFF), Color(0xFFE6D5FF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB794F6).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFB794F6),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mostProductive.area,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              Text(
                                DateFormat(isChinese ? 'yyyy年M月d日' : 'MMM d, yyyy')
                                    .format(mostProductive.startTime),
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
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniStat(
                            label: isChinese ? '专注度' : 'Focus',
                            value: '${mostProductive.focusIndex}/5',
                          ),
                        ),
                        Expanded(
                          child: _MiniStat(
                            label: isChinese ? '心情' : 'Mood',
                            value: '${mostProductive.moodIndex}/5',
                          ),
                        ),
                        Expanded(
                          child: _MiniStat(
                            label: isChinese ? '物品' : 'Items',
                            value: (mostProductive.itemsCount ?? 0).toString(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Recent Sessions
            Text(
              isChinese ? '最近任务' : 'Recent Sessions',
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EA)),
              ),
              child: Column(
                children: sessionsWithData.take(5).map((session) {
                  final isLast = sessionsWithData.take(5).last == session;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: const Color(0xFFE5E7EA),
                          width: isLast ? 0 : 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.area,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat(isChinese ? 'M月d日' : 'MMM d')
                                    .format(session.startTime),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _Badge(
                              icon: Icons.psychology_outlined,
                              value: session.focusIndex.toString(),
                              color: const Color(0xFFB794F6),
                            ),
                            const SizedBox(width: 8),
                            _Badge(
                              icon: Icons.mood_outlined,
                              value: session.moodIndex.toString(),
                              color: const Color(0xFF5ECFB8),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _formatTotalTime(int seconds, bool isChinese) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return isChinese ? '$hours小时$minutes分' : '${hours}h ${minutes}m';
    } else {
      return isChinese ? '$minutes分钟' : '${minutes}m';
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EA)),
      ),
      padding: const EdgeInsets.all(16),
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
}

class _AnalysisRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final int maxValue;
  final Color color;

  const _AnalysisRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final numericValue = double.tryParse(value) ?? 0;
    final percentage = (numericValue / maxValue).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
            Text(
              '$value/$maxValue',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: const Color(0xFFF3F4F6),
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
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
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _Badge({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
