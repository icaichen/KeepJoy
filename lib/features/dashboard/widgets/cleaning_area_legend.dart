import 'package:flutter/material.dart';

class CleaningAreaLegend {
  CleaningAreaLegend._();

  static const Color none = Color(0xFFE5E7EB);
  static const Color level1 = Color(0xFFDBF2EE);
  static const Color level2 = Color(0xFFBCE7DA);
  static const Color level3 = Color(0xFF8DD9C1);
  static const Color level4 = Color(0xFF4BC59A);
  static const Color level5 = Color(0xFF1B8E6B);

  static const List<_CleaningLegendEntry> entries = [
    _CleaningLegendEntry(
      min: 0,
      max: 0,
      color: none,
      labelEn: '0 sessions • not started',
      labelZh: '0 次：尚未开始',
    ),
    _CleaningLegendEntry(
      min: 1,
      max: 2,
      color: level1,
      labelEn: '1-2 sessions • light touch',
      labelZh: '1-2 次：轻度整理',
    ),
    _CleaningLegendEntry(
      min: 3,
      max: 4,
      color: level2,
      labelEn: '3-4 sessions • getting momentum',
      labelZh: '3-4 次：逐步推进',
    ),
    _CleaningLegendEntry(
      min: 5,
      max: 7,
      color: level3,
      labelEn: '5-7 sessions • steady groove',
      labelZh: '5-7 次：稳步推进',
    ),
    _CleaningLegendEntry(
      min: 8,
      max: 10,
      color: level4,
      labelEn: '8-10 sessions • high focus',
      labelZh: '8-10 次：高频整理',
    ),
    _CleaningLegendEntry(
      min: 11,
      max: null,
      color: level5,
      labelEn: '11+ sessions • maintenance mode',
      labelZh: '11 次以上：持续维护',
    ),
  ];

  static _CleaningLegendEntry forCount(int count) {
    return entries.firstWhere(
      (entry) =>
          count >= entry.min &&
          (entry.max == null ? true : count <= entry.max!),
      orElse: () => entries.first,
    );
  }

  static Widget badge({
    required BuildContext context,
    required bool isChinese,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE5E7EA)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.legend_toggle_rounded,
              color: Color(0xFF6B7280),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              isChinese ? '颜色说明' : 'Legend',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget dialog({
    required BuildContext context,
    required bool isChinese,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final labelStyle = textTheme.bodyMedium?.copyWith(
      color: const Color(0xFF111827),
      fontWeight: FontWeight.w600,
    );
    final descriptionStyle = textTheme.bodySmall?.copyWith(
      color: const Color(0xFF4B5563),
      height: 1.2,
    );

    return Dialog(
      backgroundColor: Colors.white,
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isChinese ? '整理区域颜色说明' : 'Cleaning Areas Legend',
                  style: labelStyle,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: const Color(0xFF9CA3AF),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...entries.map((entry) {
              final label = isChinese ? entry.labelZh : entry.labelEn;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: entry.color,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE5E7EA)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(label, style: descriptionStyle)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CleaningLegendEntry {
  const _CleaningLegendEntry({
    required this.min,
    required this.max,
    required this.color,
    required this.labelEn,
    required this.labelZh,
  });

  final int min;
  final int? max;
  final Color color;
  final String labelEn;
  final String labelZh;

  Color get textColor =>
      color.computeLuminance() < 0.45 ? Colors.white : const Color(0xFF111827);
}
