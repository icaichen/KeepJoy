import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker _picker = ImagePicker();
  DeclutterCategory? _selectedCategory;
  MemorySentiment? _selectedSentiment;
  bool _isLoading = false;
  String? _capturedPhotoPath;

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
    // Prioritize captured photo, then widget photo
    if (_capturedPhotoPath != null) {
      return _capturedPhotoPath;
    }
    if (widget.item != null) {
      return widget.item!.photoPath;
    }
    return widget.photoPath;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        setState(() {
          _capturedPhotoPath = photo.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFFB794F6)),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Color(0xFFB794F6)),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFB794F6), Color(0xFFC8A9F5)],
            ),
          ),
        ),
        title: Text(
          l10n.createMemoryTitle,
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo Section with gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFB794F6), Color(0xFFF5F5F7)],
                  stops: [0.0, 0.3],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: GestureDetector(
                onTap: _showImageSourceDialog,
                child: _photoPath != null && _photoPath!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(_photoPath!),
                          height: screenHeight * 0.35,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        height: screenHeight * 0.35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: const Color(0xFFB794F6).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 36,
                                color: Color(0xFFB794F6),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Take photo or upload photo',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Capture this special moment',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),

            // Compact white card containing all form fields
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Name
                    const Text(
                      'Item Name',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _itemNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter item name',
                        hintStyle: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 15,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFB794F6),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Category Dropdown
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<DeclutterCategory>(
                          value: _selectedCategory,
                          hint: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'Select a category',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 15,
                              ),
                            ),
                          ),
                          isExpanded: true,
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 14),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF6B7280),
                              size: 20,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(10),
                          dropdownColor: Colors.white,
                          items: DeclutterCategory.values.map((category) {
                            return DropdownMenuItem<DeclutterCategory>(
                              value: category,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  category.label(context),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Description
                    Text(
                      l10n.memoryDescription,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: l10n.describeYourMemory,
                        hintStyle: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 15,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFB794F6),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Emotion/Sentiment
                    Text(
                      l10n.whatDidThisItemBring,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...MemorySentiment.values.map((sentiment) {
                      final isSelected = _selectedSentiment == sentiment;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: isSelected
                              ? Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [Color(0xFFB794F6), Color(0xFFC8A9F5)],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() => _selectedSentiment = sentiment);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      sentiment.label(context),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                              : OutlinedButton(
                                  onPressed: () {
                                    setState(() => _selectedSentiment = sentiment);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF6B7280),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: const BorderSide(
                                      color: Color(0xFFE5E7EB),
                                      width: 1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    sentiment.label(context),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Create Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: SizedBox(
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFB794F6), Color(0xFFC8A9F5)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB794F6).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createMemory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: const Color(0xFF9E9E9E),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            l10n.createMemory,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
