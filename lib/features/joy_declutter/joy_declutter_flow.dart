import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';
import '../../models/declutter_item.dart';

class JoyDeclutterFlowPage extends StatefulWidget {
  final Function(DeclutterItem) onItemCompleted;

  const JoyDeclutterFlowPage({super.key, required this.onItemCompleted});

  @override
  State<JoyDeclutterFlowPage> createState() => _JoyDeclutterFlowPageState();
}

class _JoyDeclutterFlowPageState extends State<JoyDeclutterFlowPage> {
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePicture() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _PhotoReviewPage(
              photoPath: photo.path,
              onItemCompleted: widget.onItemCompleted,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.couldNotAccessCamera),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
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
class _PhotoReviewPage extends StatefulWidget {
  final String photoPath;
  final Function(DeclutterItem) onItemCompleted;

  const _PhotoReviewPage({
    required this.photoPath,
    required this.onItemCompleted,
  });

  @override
  State<_PhotoReviewPage> createState() => _PhotoReviewPageState();
}

class _PhotoReviewPageState extends State<_PhotoReviewPage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _retakePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => _PhotoReviewPage(
              photoPath: photo.path,
              onItemCompleted: widget.onItemCompleted,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.couldNotAccessCamera),
          ),
        );
      }
    }
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
                      child: widget.photoPath.isEmpty
                          ? Center(child: Text('Photo placeholder'))
                          : Image.file(
                              File(widget.photoPath),
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
                        onPressed: _retakePicture,
                        child: Text(l10n.retakePhoto),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _JoyQuestionPage(
                                photoPath: widget.photoPath,
                                onItemCompleted: widget.onItemCompleted,
                              ),
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
  final Function(DeclutterItem) onItemCompleted;

  const _JoyQuestionPage({
    required this.photoPath,
    required this.onItemCompleted,
  });

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
                              // Create item with "keep" status
                              final item = DeclutterItem(
                                id: 'item_${DateTime.now().millisecondsSinceEpoch}',
                                name: 'Item',
                                category: DeclutterCategory.miscellaneous,
                                createdAt: DateTime.now(),
                                status: DeclutterStatus.keep,
                                photoPath: photoPath,
                              );

                              // Add item to app state
                              onItemCompleted(item);

                              // Show success dialog
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  content: Text(AppLocalizations.of(context)!.itemSaved),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        // Pop back to home (through PhotoReview and JoyDeclutterFlow)
                                        Navigator.of(context).popUntil((route) => route.isFirst);
                                      },
                                      child: Text(l10n.ok),
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
                                              // Create item with "discard" status
                                              final item = DeclutterItem(
                                                id: 'item_${DateTime.now().millisecondsSinceEpoch}',
                                                name: 'Item',
                                                category: DeclutterCategory.miscellaneous,
                                                createdAt: DateTime.now(),
                                                status: DeclutterStatus.discard,
                                                photoPath: photoPath,
                                              );

                                              // Add item to app state
                                              onItemCompleted(item);

                                              // Close both dialogs and navigate home
                                              Navigator.of(context).pop();
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  content: Text(l10n.itemMarkedAs(l10n.routeDiscard)),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                        Navigator.of(context).popUntil((route) => route.isFirst);
                                                      },
                                                      child: Text(l10n.ok),
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
                                              // Create item with "donate" status
                                              final item = DeclutterItem(
                                                id: 'item_${DateTime.now().millisecondsSinceEpoch}',
                                                name: 'Item',
                                                category: DeclutterCategory.miscellaneous,
                                                createdAt: DateTime.now(),
                                                status: DeclutterStatus.donate,
                                                photoPath: photoPath,
                                              );

                                              // Add item to app state
                                              onItemCompleted(item);

                                              // Close both dialogs and navigate home
                                              Navigator.of(context).pop();
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  content: Text(l10n.itemMarkedAs(l10n.routeDonation)),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                        Navigator.of(context).popUntil((route) => route.isFirst);
                                                      },
                                                      child: Text(l10n.ok),
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
                                              // Create item with "recycle" status
                                              final item = DeclutterItem(
                                                id: 'item_${DateTime.now().millisecondsSinceEpoch}',
                                                name: 'Item',
                                                category: DeclutterCategory.miscellaneous,
                                                createdAt: DateTime.now(),
                                                status: DeclutterStatus.recycle,
                                                photoPath: photoPath,
                                              );

                                              // Add item to app state
                                              onItemCompleted(item);

                                              // Close both dialogs and navigate home
                                              Navigator.of(context).pop();
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  content: Text(l10n.itemMarkedAs(l10n.routeRecycle)),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                        Navigator.of(context).popUntil((route) => route.isFirst);
                                                      },
                                                      child: Text(l10n.ok),
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
                                              // Create item with "resell" status
                                              final item = DeclutterItem(
                                                id: 'item_${DateTime.now().millisecondsSinceEpoch}',
                                                name: 'Item',
                                                category: DeclutterCategory.miscellaneous,
                                                createdAt: DateTime.now(),
                                                status: DeclutterStatus.resell,
                                                photoPath: photoPath,
                                              );

                                              // Add item to app state
                                              onItemCompleted(item);

                                              // Close both dialogs and navigate home
                                              Navigator.of(context).pop();
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  content: Text(l10n.itemMarkedAs(l10n.routeResell)),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                        Navigator.of(context).popUntil((route) => route.isFirst);
                                                      },
                                                      child: Text(l10n.ok),
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
