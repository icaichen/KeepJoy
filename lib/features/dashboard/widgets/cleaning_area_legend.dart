import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

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
      label: CleaningLegendLabel.none,
    ),
    _CleaningLegendEntry(
      min: 1,
      max: 2,
      color: level1,
      label: CleaningLegendLabel.light,
    ),
    _CleaningLegendEntry(
      min: 3,
      max: 4,
      color: level2,
      label: CleaningLegendLabel.momentum,
    ),
    _CleaningLegendEntry(
      min: 5,
      max: 7,
      color: level3,
      label: CleaningLegendLabel.steady,
    ),
    _CleaningLegendEntry(
      min: 8,
      max: 10,
      color: level4,
      label: CleaningLegendLabel.highFocus,
    ),
    _CleaningLegendEntry(
      min: 11,
      max: null,
      color: level5,
      label: CleaningLegendLabel.maintenance,
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
    required VoidCallback onTap,
  }) {
    final l10n = AppLocalizations.of(context)!;
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
              l10n.cleaningLegendButton,
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

  static Widget dialog({required BuildContext context}) {
    final l10n = AppLocalizations.of(context)!;
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
                Text(l10n.cleaningLegendTitle, style: labelStyle),
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
              final label = entry.localizedLabel(l10n);
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
    required this.label,
  });

  final int min;
  final int? max;
  final Color color;
  final CleaningLegendLabel label;

  String localizedLabel(AppLocalizations l10n) {
    switch (label) {
      case CleaningLegendLabel.none:
        return l10n.cleaningLegendNone;
      case CleaningLegendLabel.light:
        return l10n.cleaningLegendLight;
      case CleaningLegendLabel.momentum:
        return l10n.cleaningLegendMomentum;
      case CleaningLegendLabel.steady:
        return l10n.cleaningLegendSteady;
      case CleaningLegendLabel.highFocus:
        return l10n.cleaningLegendHighFocus;
      case CleaningLegendLabel.maintenance:
        return l10n.cleaningLegendMaintenance;
    }
  }

  Color get textColor =>
      color.computeLuminance() < 0.45 ? Colors.white : const Color(0xFF111827);
}

enum CleaningLegendLabel {
  none,
  light,
  momentum,
  steady,
  highFocus,
  maintenance,
}
