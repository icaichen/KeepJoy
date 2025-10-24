import 'dart:io';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class JoyDeclutterFlowPage extends StatefulWidget {
  const JoyDeclutterFlowPage({super.key});

  @override
  State<JoyDeclutterFlowPage> createState() => _JoyDeclutterFlowPageState();
}

class _JoyDeclutterFlowPageState extends State<JoyDeclutterFlowPage> {
  final bool _isProcessing = false;

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
        title: Text(l10n.joyDeclutterTitle),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            // Main section (no items captured section)
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
        title: Text(l10n.joyDeclutterTitle),
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
            // Retake and Next Step section
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
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const _JoyQuestionPage(photoPath: ''),
                            ),
                          );
                        },
                        child: Text(l10n.nextStep),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // No finish declutter button
          ],
        ),
      ),
    );
  }
}

// Joy question page
class _JoyQuestionPage extends StatelessWidget {
  final String photoPath;

  const _JoyQuestionPage({required this.photoPath});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.joyDeclutterTitle),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            // Photo section
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
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            // Question section
            Card(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  children: [
                    // Question area
                    Text(l10n.doesItSparkJoy),
                    SizedBox(height: screenHeight * 0.02),
                    // Two options
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  content: Text(AppLocalizations.of(context)!.itemSaved),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Text(l10n.yes),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  final l10n = AppLocalizations.of(context)!;
                                  return AlertDialog(
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(l10n.timeToLetGo),
                                        SizedBox(height: screenHeight * 0.02),
                                        // 4 options with consistent width
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  content: Text(l10n.itemMarkedAs(l10n.routeDiscard)),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text('OK'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: Text(l10n.routeDiscard),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  content: Text(l10n.itemMarkedAs(l10n.routeDonation)),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text('OK'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: Text(l10n.routeDonation),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  content: Text(l10n.itemMarkedAs(l10n.routeRecycle)),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text('OK'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: Text(l10n.routeRecycle),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  content: Text(l10n.itemMarkedAs(l10n.routeResell)),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text('OK'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: Text(l10n.routeResell),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Text(l10n.no),
                          ),
                        ),
                      ],
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
