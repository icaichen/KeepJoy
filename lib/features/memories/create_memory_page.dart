import 'dart:io';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/memory.dart';

class CreateMemoryPage extends StatefulWidget {
  const CreateMemoryPage({super.key, this.item, this.photoPath, this.itemName});

  final DeclutterItem? item;
  final String? photoPath;
  final String? itemName;

  @override
  State<CreateMemoryPage> createState() => _CreateMemoryPageState();
}

class _CreateMemoryPageState extends State<CreateMemoryPage> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DeclutterCategory? _selectedCategory;
  MemorySentiment? _selectedSentiment;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill if item is provided
    if (widget.item != null) {
      _itemNameController.text = widget.item!.name;
      _selectedCategory = widget.item!.category;
    } else if (widget.itemName != null) {
      _itemNameController.text = widget.itemName!;
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? get _photoPath {
    if (widget.item != null) {
      return widget.item!.photoPath;
    }
    return widget.photoPath;
  }

  void _createMemory() {
    final l10n = AppLocalizations.of(context)!;

    if (_itemNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an item name')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    if (_selectedSentiment == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.whatDidThisItemBring)));
      return;
    }

    setState(() => _isLoading = true);

    final memory = Memory.fromDeclutteredItem(
      id: 'memory_${DateTime.now().millisecondsSinceEpoch}',
      userId:
          'temp-user-id', // TODO: Replace with actual userId from AuthService
      itemName: _itemNameController.text.trim(),
      category: _selectedCategory!.name,
      createdAt: DateTime.now(),
      photoPath: _photoPath,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      sentiment: _selectedSentiment,
    );

    // Return the memory to the caller
    Navigator.of(context).pop(memory);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.createMemoryTitle,
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xDE000000),
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xDE000000)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (_photoPath != null && _photoPath!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(_photoPath!),
                        height: screenHeight * 0.25,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      height: screenHeight * 0.25,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.photo_outlined,
                        size: 64,
                        color: Color(0xFFBDBDBD),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Item Name Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item Name',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xDE000000),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _itemNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter item name',
                      hintStyle: const TextStyle(color: Color(0x61000000)),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xDE000000),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Category Selection Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xDE000000),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: DeclutterCategory.values.map((category) {
                      final isSelected = _selectedCategory == category;
                      return FilterChip(
                        label: Text(category.label(context)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : null;
                          });
                        },
                        backgroundColor: const Color(0xFFF5F5F7),
                        selectedColor: const Color(0xFF414B5A),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xDE000000),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide.none,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.memoryDescription,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xDE000000),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: l10n.describeYourMemory,
                      hintStyle: const TextStyle(color: Color(0x61000000)),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    maxLines: 4,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xDE000000),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Emotion Selection Section - Now at bottom
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.whatDidThisItemBring,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xDE000000),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...MemorySentiment.values.map((sentiment) {
                    final isSelected = _selectedSentiment == sentiment;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: isSelected
                            ? ElevatedButton(
                                onPressed: () {
                                  setState(
                                    () => _selectedSentiment = sentiment,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF414B5A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  sentiment.label(context),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : OutlinedButton(
                                onPressed: () {
                                  setState(
                                    () => _selectedSentiment = sentiment,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xDE000000),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFFE0E0E0),
                                    width: 1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  sentiment.label(context),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Create Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createMemory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF414B5A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: const Color(0xFF9E9E9E),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.createMemory,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
