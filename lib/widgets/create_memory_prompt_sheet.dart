import 'package:flutter/material.dart';
import 'package:keepjoy_app/l10n/app_localizations.dart';
import 'package:keepjoy_app/widgets/gradient_button.dart';

Future<bool?> showCreateMemoryPromptSheet({
  required BuildContext context,
  required AppLocalizations l10n,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFFB794F6),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.createMemoryQuestion,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.createMemoryPrompt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              GradientButton(
                onPressed: () => Navigator.of(sheetContext).pop(true),
                child: Text(l10n.createMemory),
              ),
              TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(false),
                child: Text(
                  l10n.skipMemory,
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
