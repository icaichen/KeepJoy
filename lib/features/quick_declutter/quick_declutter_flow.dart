import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';

class QuickDeclutterFlowPage extends StatefulWidget {
  const QuickDeclutterFlowPage({super.key});

  @override
  State<QuickDeclutterFlowPage> createState() => _QuickDeclutterFlowPageState();
}

class _QuickDeclutterFlowPageState extends State<QuickDeclutterFlowPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  int _itemsCaptured = 0;

  void _takePicture() {
    // Temporary: Navigate to review page to see the layout
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _PhotoReviewPage(photoPath: ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quickDeclutterTitle),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            // Items captured section
            Card(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  children: [
                    Text(l10n.itemsCaptured),
                    Text('$_itemsCaptured'),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            // Main section
            Card(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 80,
                    ),
                    SizedBox(height: 20),
                    Text(l10n.captureItemToStart),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isProcessing ? null : _takePicture,
                      child: _isProcessing
                          ? const CircularProgressIndicator()
                          : Text(l10n.takePicture),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Photo review page
class _PhotoReviewPage extends StatelessWidget {
  final String photoPath;

  const _PhotoReviewPage({required this.photoPath});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quickDeclutterTitle),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            // Main section with photo and item details
            Card(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  children: [
                    // Photo area
                    Container(
                      width: double.infinity,
                      height: screenHeight * 0.3,
                      color: Colors.grey[300],
                      child: photoPath.isEmpty
                          ? Center(child: Text('Photo placeholder'))
                          : Image.file(
                              File(photoPath),
                              width: double.infinity,
                              height: screenHeight * 0.3,
                              fit: BoxFit.cover,
                            ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Item details area
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.itemName),
                        SizedBox(height: 8),
                        Text(l10n.category),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            // Retake and Next item section
            Card(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Text(l10n.retakePhoto),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Text(l10n.nextItem),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            // Finish declutter
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: Text(l10n.finishDeclutter),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
