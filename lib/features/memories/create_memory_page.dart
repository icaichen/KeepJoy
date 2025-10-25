import 'dart:io';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/declutter_item.dart';
import '../../models/memory.dart';

class CreateMemoryPage extends StatefulWidget {
  const CreateMemoryPage({
    super.key,
    this.item,
    this.photoPath,
    this.itemName,
  });

  final DeclutterItem? item;
  final String? photoPath;
  final String? itemName;

  @override
  State<CreateMemoryPage> createState() => _CreateMemoryPageState();
}

class _CreateMemoryPageState extends State<CreateMemoryPage> {
  final TextEditingController _descriptionController = TextEditingController();
  MemorySentiment? _selectedSentiment;
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  String get _itemName {
    if (widget.item != null) {
      return widget.item!.name;
    }
    return widget.itemName ?? 'Item';
  }

  String? get _photoPath {
    if (widget.item != null) {
      return widget.item!.photoPath;
    }
    return widget.photoPath;
  }

  void _createMemory() {
    final l10n = AppLocalizations.of(context)!;

    if (_selectedSentiment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.whatDidThisItemBring)),
      );
      return;
    }

    setState(() => _isLoading = true);

    final memory = Memory.fromDeclutteredItem(
      id: 'memory_${DateTime.now().millisecondsSinceEpoch}',
      itemName: _itemName,
      category: widget.item?.category.name ?? 'Miscellaneous',
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
      appBar: AppBar(
        title: Text(l10n.createMemoryTitle),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Photo
          if (_photoPath != null && _photoPath!.isNotEmpty)
            Card(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_photoPath!),
                  height: screenHeight * 0.3,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Card(
              child: Container(
                height: screenHeight * 0.3,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.photo,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: 20),
          // Item name
          Text(
            _itemName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Sentiment selection
          Text(
            l10n.whatDidThisItemBring,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...MemorySentiment.values.map((sentiment) {
            final isSelected = _selectedSentiment == sentiment;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: isSelected
                    ? FilledButton(
                        onPressed: () {
                          setState(() => _selectedSentiment = sentiment);
                        },
                        child: Text(sentiment.label(context)),
                      )
                    : OutlinedButton(
                        onPressed: () {
                          setState(() => _selectedSentiment = sentiment);
                        },
                        child: Text(sentiment.label(context)),
                      ),
              ),
            );
          }),
          const SizedBox(height: 24),
          // Description
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: l10n.memoryDescription,
              hintText: l10n.describeYourMemory,
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 32),
          // Create button
          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: _isLoading ? null : _createMemory,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.createMemory),
            ),
          ),
        ],
      ),
    );
  }
}
