import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';

class QuickDeclutterItem {
  QuickDeclutterItem({
    required this.photoPath,
    required this.name,
    required this.category,
  });

  final String photoPath;
  final String name;
  final QuickDeclutterCategory category;
}

enum QuickDeclutterCategory {
  clothes,
  books,
  papers,
  miscellaneous,
  sentimental,
  beauty;

  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case QuickDeclutterCategory.clothes:
        return l10n.categoryClothes;
      case QuickDeclutterCategory.books:
        return l10n.categoryBooks;
      case QuickDeclutterCategory.papers:
        return l10n.categoryPapers;
      case QuickDeclutterCategory.miscellaneous:
        return l10n.categoryMiscellaneous;
      case QuickDeclutterCategory.sentimental:
        return l10n.categorySentimental;
      case QuickDeclutterCategory.beauty:
        return l10n.categoryBeauty;
    }
  }
}

class QuickDeclutterFlowPage extends StatefulWidget {
  const QuickDeclutterFlowPage({super.key});

  @override
  State<QuickDeclutterFlowPage> createState() => _QuickDeclutterFlowPageState();
}

class _QuickDeclutterFlowPageState extends State<QuickDeclutterFlowPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  int _keptCount = 0;
  int _letGoCount = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C5C66),
        foregroundColor: Colors.white,
        title: Text(l10n.quickDeclutterTitle),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Session summary card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      l10n.declutterSession,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '$_keptCount',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.teal.shade300,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.kept,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '$_letGoCount',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.pink.shade200,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.letGo,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Scan card
            GestureDetector(
              onTap: _isProcessing ? null : _scanItem,
              child: Card(
                elevation: 0,
                color: const Color(0xFFE8F4F4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 80,
                        color: Colors.teal.shade200,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.scanYourNextItem,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.readyWhenYouAre,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Finish session button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_keptCount + _letGoCount) > 0 ? _finishSession : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4D4D8),
                  foregroundColor: Colors.black54,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.finishSession,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanItem() async {
    try {
      setState(() => _isProcessing = true);

      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (picked == null) {
        setState(() => _isProcessing = false);
        return;
      }

      // TODO: Show item review page
      // For now, just increment kept count
      setState(() {
        _keptCount++;
        _isProcessing = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotAccessCamera)),
      );
    }
  }

  void _finishSession() {
    Navigator.of(context).pop();
  }
}
