import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/memory.dart';
import '../../services/ai_identification_service.dart';
import '../memories/create_memory_page.dart';

class JoyDeclutterFlowPage extends StatefulWidget {
  final Function(DeclutterItem) onItemCompleted;
  final Function(Memory) onMemoryCreated;

  const JoyDeclutterFlowPage({
    super.key,
    required this.onItemCompleted,
    required this.onMemoryCreated,
  });

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
              onMemoryCreated: widget.onMemoryCreated,
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
  final Function(Memory) onMemoryCreated;

  const _PhotoReviewPage({
    required this.photoPath,
    required this.onItemCompleted,
    required this.onMemoryCreated,
  });

  @override
  State<_PhotoReviewPage> createState() => _PhotoReviewPageState();
}

class _PhotoReviewPageState extends State<_PhotoReviewPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final AIIdentificationService _aiService = AIIdentificationService();

  DeclutterCategory _selectedCategory = DeclutterCategory.miscellaneous;
  bool _isIdentifying = false;
  bool _isAISuggested = false;
  String? _itemName;
  bool _hasInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      _identifyItem();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _identifyItem() async {
    setState(() => _isIdentifying = true);

    try {
      final locale = Localizations.localeOf(context).languageCode;
      print('🎯 Joy Declutter: Starting AI identification, locale: $locale');

      final result = await _aiService.identifyBasic(widget.photoPath, locale);

      print('🎯 Joy Declutter: AI result received: ${result != null ? "name=${result.itemName}, category=${result.suggestedCategory}" : "null"}');

      if (result != null && mounted) {
        setState(() {
          _itemName = result.itemName;
          _nameController.text = result.itemName;
          _selectedCategory = result.suggestedCategory;
          _isAISuggested = true;
        });
        print('🎯 Joy Declutter: UI updated with AI result');
      }
    } catch (e) {
      print('❌ Joy Declutter: AI identification error: $e');
    } finally {
      if (mounted) {
        setState(() => _isIdentifying = false);
      }
    }
  }

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
              onMemoryCreated: widget.onMemoryCreated,
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
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: l10n.itemName,
                            hintText: l10n.itemName,
                            suffixIcon: _isIdentifying
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : _isAISuggested
                                    ? Tooltip(
                                        message: l10n.aiSuggested,
                                        child: const Icon(Icons.auto_awesome, size: 20),
                                      )
                                    : null,
                          ),
                          onChanged: (_) {
                            // User edited, no longer AI suggested
                            if (_isAISuggested) {
                              setState(() => _isAISuggested = false);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownMenu<DeclutterCategory>(
                          initialSelection: _selectedCategory,
                          label: Text(l10n.category),
                          dropdownMenuEntries: DeclutterCategory.values
                              .map(
                                (category) => DropdownMenuEntry(
                                  value: category,
                                  label: category.label(context),
                                ),
                              )
                              .toList(),
                          onSelected: (value) {
                            if (value != null) {
                              setState(() => _selectedCategory = value);
                            }
                          },
                        ),
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
                                itemName: _nameController.text.trim().isEmpty
                                    ? 'Item'
                                    : _nameController.text.trim(),
                                category: _selectedCategory,
                                onItemCompleted: widget.onItemCompleted,
                                onMemoryCreated: widget.onMemoryCreated,
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
class _JoyQuestionPage extends StatefulWidget {
  final String photoPath;
  final String itemName;
  final DeclutterCategory category;
  final Function(DeclutterItem) onItemCompleted;
  final Function(Memory) onMemoryCreated;

  const _JoyQuestionPage({
    required this.photoPath,
    required this.itemName,
    required this.category,
    required this.onItemCompleted,
    required this.onMemoryCreated,
  });

  @override
  State<_JoyQuestionPage> createState() => _JoyQuestionPageState();
}

class _JoyQuestionPageState extends State<_JoyQuestionPage> {
  Future<void> _showMemoryPrompt(DeclutterItem item) async {
    final l10n = AppLocalizations.of(context)!;

    final shouldCreateMemory = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.createMemoryQuestion),
        content: Text(l10n.createMemoryPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.skipMemory),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.createMemory),
          ),
        ],
      ),
    );

    if (shouldCreateMemory == true && mounted) {
      final memory = await Navigator.of(context).push<Memory>(
        MaterialPageRoute(
          builder: (_) => CreateMemoryPage(
            item: item,
            photoPath: widget.photoPath,
            itemName: item.name,
          ),
        ),
      );

      if (memory != null) {
        widget.onMemoryCreated(memory);
      }
    }

    // Navigate back to home
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
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
                      child: widget.photoPath.isEmpty
                          ? Center(child: Text('Photo placeholder'))
                          : Image.file(
                              File(widget.photoPath),
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
                                name: widget.itemName,
                                category: widget.category,
                                createdAt: DateTime.now(),
                                status: DeclutterStatus.keep,
                                photoPath: widget.photoPath,
                              );

                              // Add item to app state
                              widget.onItemCompleted(item);

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
                                            onPressed: () async {
                                              // Create item with "discard" status
                                              final item = DeclutterItem(
                                                id: 'item_${DateTime.now().millisecondsSinceEpoch}',
                                                name: widget.itemName,
                                                category: widget.category,
                                                createdAt: DateTime.now(),
                                                status: DeclutterStatus.discard,
                                                photoPath: widget.photoPath,
                                              );

                                              // Add item to app state
                                              widget.onItemCompleted(item);

                                              // Close the let-go dialog
                                              Navigator.of(context).pop();

                                              // Show memory prompt
                                              await _showMemoryPrompt(item);
                                            },
                                            child: Text(l10n.routeDiscard),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              // Create item with "donate" status
                                              final item = DeclutterItem(
                                                id: 'item_${DateTime.now().millisecondsSinceEpoch}',
                                                name: widget.itemName,
                                                category: widget.category,
                                                createdAt: DateTime.now(),
                                                status: DeclutterStatus.donate,
                                                photoPath: widget.photoPath,
                                              );

                                              // Add item to app state
                                              widget.onItemCompleted(item);

                                              // Close the let-go dialog
                                              Navigator.of(context).pop();

                                              // Show memory prompt
                                              await _showMemoryPrompt(item);
                                            },
                                            child: Text(l10n.routeDonation),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              // Create item with "recycle" status
                                              final item = DeclutterItem(
                                                id: 'item_${DateTime.now().millisecondsSinceEpoch}',
                                                name: widget.itemName,
                                                category: widget.category,
                                                createdAt: DateTime.now(),
                                                status: DeclutterStatus.recycle,
                                                photoPath: widget.photoPath,
                                              );

                                              // Add item to app state
                                              widget.onItemCompleted(item);

                                              // Close the let-go dialog
                                              Navigator.of(context).pop();

                                              // Show memory prompt
                                              await _showMemoryPrompt(item);
                                            },
                                            child: Text(l10n.routeRecycle),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              // Create item with "resell" status
                                              final item = DeclutterItem(
                                                id: 'item_${DateTime.now().millisecondsSinceEpoch}',
                                                name: widget.itemName,
                                                category: widget.category,
                                                createdAt: DateTime.now(),
                                                status: DeclutterStatus.resell,
                                                photoPath: widget.photoPath,
                                              );

                                              // Add item to app state
                                              widget.onItemCompleted(item);

                                              // Close the let-go dialog
                                              Navigator.of(context).pop();

                                              // Show memory prompt
                                              await _showMemoryPrompt(item);
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
