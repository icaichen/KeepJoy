import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

/// Service for analyzing room messiness using Google ML Kit
///
/// This service analyzes photos of rooms and calculates a messiness score (0-10)
/// based on the number and types of objects detected.
class MessinessAnalysisService {
  ImageLabeler? _imageLabeler;

  /// Initialize the ML Kit image labeler
  Future<void> initialize() async {
    try {
      final options = ImageLabelerOptions(confidenceThreshold: 0.5);
      _imageLabeler = ImageLabeler(options: options);
    } catch (e) {
      print('Failed to initialize MessinessAnalysisService: $e');
    }
  }

  /// Analyze messiness of a room photo
  ///
  /// Returns a score from 0-10 where:
  /// - 0-2: Very clean/minimal
  /// - 3-4: Clean
  /// - 5-6: Moderate messiness
  /// - 7-8: Messy
  /// - 9-10: Very messy
  Future<double> analyzeMessiness(String imagePath) async {
    if (_imageLabeler == null) {
      await initialize();
    }

    if (_imageLabeler == null) {
      print('Image labeler not initialized');
      return 5.0; // Return neutral score if analysis fails
    }

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final labels = await _imageLabeler!.processImage(inputImage);

      if (labels.isEmpty) {
        return 2.0; // If no objects detected, assume clean/minimal
      }

      // Calculate messiness score based on multiple factors
      final objectCount = labels.length;
      final clutterScore = _calculateClutterScore(labels);
      final confidenceScore = _calculateConfidenceScore(labels);
      final densityScore = _calculateDensityScore(objectCount);

      // Weighted combination of factors
      final rawScore = (
        densityScore * 0.4 +        // Object density (40%)
        clutterScore * 0.35 +       // Clutter vs furniture ratio (35%)
        confidenceScore * 0.25      // Low confidence objects (25%)
      );

      // Normalize to 0-10 scale
      final normalizedScore = rawScore.clamp(0.0, 10.0);

      print('Messiness Analysis:');
      print('  Objects detected: $objectCount');
      print('  Clutter score: ${clutterScore.toStringAsFixed(2)}');
      print('  Confidence score: ${confidenceScore.toStringAsFixed(2)}');
      print('  Density score: ${densityScore.toStringAsFixed(2)}');
      print('  Final messiness: ${normalizedScore.toStringAsFixed(1)}');

      return double.parse(normalizedScore.toStringAsFixed(1));
    } catch (e) {
      print('Error analyzing messiness: $e');
      return 5.0; // Return neutral score on error
    }
  }

  /// Calculate clutter score based on object types
  ///
  /// Higher score = more clutter items vs furniture/structure
  double _calculateClutterScore(List<ImageLabel> labels) {
    // Define clutter categories (items that make a room look messy)
    const clutterKeywords = [
      'clothing', 'clothes', 'shirt', 'pants', 'shoe', 'sock',
      'paper', 'document', 'book', 'magazine', 'newspaper',
      'box', 'package', 'bag', 'plastic',
      'bottle', 'can', 'cup', 'plate', 'dish',
      'toy', 'game', 'electronic', 'cable', 'wire',
      'tool', 'equipment', 'container',
      'trash', 'waste', 'garbage',
    ];

    // Define structure/furniture (expected items, less messy)
    const structureKeywords = [
      'furniture', 'table', 'chair', 'desk', 'bed', 'sofa', 'couch',
      'shelf', 'cabinet', 'dresser', 'wardrobe',
      'wall', 'floor', 'ceiling', 'window', 'door',
      'lamp', 'light', 'plant', 'picture', 'frame',
    ];

    int clutterCount = 0;
    int structureCount = 0;

    for (final label in labels) {
      final labelText = label.label.toLowerCase();

      if (clutterKeywords.any((keyword) => labelText.contains(keyword))) {
        clutterCount++;
      } else if (structureKeywords.any((keyword) => labelText.contains(keyword))) {
        structureCount++;
      }
    }

    // Calculate ratio: more clutter = higher score
    if (structureCount == 0) {
      return clutterCount > 0 ? 10.0 : 2.0;
    }

    final ratio = clutterCount / (clutterCount + structureCount);
    return ratio * 10.0;
  }

  /// Calculate score based on detection confidence
  ///
  /// Lower confidence = harder to identify = more cluttered/messy
  double _calculateConfidenceScore(List<ImageLabel> labels) {
    if (labels.isEmpty) return 0.0;

    // Count objects with low confidence (harder to identify = messier)
    final lowConfidenceCount = labels.where((label) => label.confidence < 0.7).length;
    final lowConfidenceRatio = lowConfidenceCount / labels.length;

    return lowConfidenceRatio * 10.0;
  }

  /// Calculate score based on object density
  ///
  /// More objects detected = higher messiness
  double _calculateDensityScore(int objectCount) {
    // Scale: 0-5 objects = clean, 6-15 = moderate, 16+ = messy
    if (objectCount <= 5) {
      return objectCount * 0.8; // 0-4
    } else if (objectCount <= 15) {
      return 4 + (objectCount - 5) * 0.4; // 4-8
    } else {
      return 8 + (objectCount - 15) * 0.2; // 8-10+
    }
  }

  /// Dispose resources
  void dispose() {
    _imageLabeler?.close();
    _imageLabeler = null;
  }
}
