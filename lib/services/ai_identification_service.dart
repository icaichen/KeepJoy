import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:http/http.dart' as http;

import 'package:keepjoy_app/models/declutter_item.dart';

/// Result from AI identification
class AIIdentificationResult {
  final String itemName;
  final DeclutterCategory suggestedCategory;
  final double confidence; // 0-100
  final String method; // 'on-device' or 'cloud'
  final List<String> alternativeNames;

  AIIdentificationResult({
    required this.itemName,
    required this.suggestedCategory,
    required this.confidence,
    required this.method,
    this.alternativeNames = const [],
  });
}

/// AI-powered object and brand identification service
/// Uses Google ML Kit for both iOS and Android (70%+ accuracy, 1000+ objects)
/// Cloud: OpenRouter API (Qwen) for brand recognition (paid feature)
class AIIdentificationService {
  static final AIIdentificationService _instance = AIIdentificationService._internal();
  factory AIIdentificationService() => _instance;
  AIIdentificationService._internal();

  // Google ML Kit image labeler (both iOS and Android)
  ImageLabeler? _imageLabeler;

  // TODO: Add your OpenRouter API key here for cloud-based brand detection
  // Get your key from: https://openrouter.ai/keys
  static const String _openRouterApiKey = ''; // Leave empty for now - will be paid feature

  /// Initialize the service
  Future<void> initialize() async {
    try {
      // Initialize ML Kit
      final options = ImageLabelerOptions(confidenceThreshold: 0.5);
      _imageLabeler = ImageLabeler(options: options);
    } catch (e) {
      print('Failed to initialize ML Kit: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _imageLabeler?.close();
  }

  /// Quick on-device identification using Google ML Kit (both iOS & Android)
  Future<AIIdentificationResult?> identifyBasic(String imagePath, String locale) async {
    return _identifyWithMLKit(imagePath, locale);
  }

  /// ML Kit identification (iOS & Android)
  Future<AIIdentificationResult?> _identifyWithMLKit(String imagePath, String locale) async {
    try {
      print('🔍 ML Kit: Starting identification for $imagePath');

      if (_imageLabeler == null) {
        print('🔍 ML Kit: Initializing image labeler...');
        await initialize();
      }

      print('🔍 ML Kit: Creating input image from file path');
      final inputImage = InputImage.fromFilePath(imagePath);

      print('🔍 ML Kit: Processing image with ML Kit...');
      final labels = await _imageLabeler!.processImage(inputImage);
      print('🔍 ML Kit: Got ${labels.length} labels');

      if (labels.isEmpty) {
        print('🔍 ML Kit: No labels returned');
        return null;
      }

      final topLabel = labels.first;
      print('🔍 ML Kit: Top label - text: "${topLabel.label}", confidence: ${topLabel.confidence}');

      // Translate if Chinese locale
      final isZh = locale.toLowerCase().startsWith('zh');
      print('🔍 ML Kit: Locale: $locale, isZh: $isZh');

      final translatedName = isZh ? _translateToChinese(topLabel.label) : _cleanLabelName(topLabel.label);
      print('🔍 ML Kit: Translated name: "$translatedName"');

      final category = _mapLabelToCategory(topLabel.label);
      print('🔍 ML Kit: Mapped category: $category');

      final alternatives = labels
          .skip(1)
          .take(2)
          .map((l) => isZh ? _translateToChinese(l.label) : _cleanLabelName(l.label))
          .toList();

      print('🔍 ML Kit: Returning result - name: "$translatedName", category: $category, confidence: ${topLabel.confidence * 100}%');
      return AIIdentificationResult(
        itemName: translatedName,
        suggestedCategory: category,
        confidence: topLabel.confidence * 100,
        method: 'on-device',
        alternativeNames: alternatives,
      );
    } catch (e) {
      print('❌ ML Kit identification failed: $e');
      return null;
    }
  }

  /// Detailed identification using OpenRouter API (Qwen vision model)
  Future<AIIdentificationResult?> identifyDetailed(String imagePath, String locale) async {
    if (_openRouterApiKey.isEmpty) {
      print('OpenRouter API key not configured. This will be a paid feature.');
      return null;
    }

    try {
      final imageBytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final isZh = locale.toLowerCase().startsWith('zh');
      final language = isZh ? 'Chinese' : 'English';

      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openRouterApiKey',
          'HTTP-Referer': 'https://keepjoy.app',
        },
        body: jsonEncode({
          'model': 'qwen/qwen-2-vl-7b-instruct:free',
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image',
                  },
                },
                {
                  'type': 'text',
                  'text': '''Identify this item in $language. Include brand name if visible.
Respond in JSON format:
{
  "name": "specific item name with brand if visible",
  "category": "one of: clothes, books, papers, beauty, sentimental, miscellaneous",
  "confidence": 0-100
}'''
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final result = jsonDecode(content);

        return AIIdentificationResult(
          itemName: result['name'] ?? 'Unknown item',
          suggestedCategory: _parseCategoryFromString(result['category']),
          confidence: (result['confidence'] ?? 70).toDouble(),
          method: 'cloud',
        );
      } else {
        print('OpenRouter API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Detailed identification failed: $e');
      return null;
    }
  }

  /// English to Chinese translation for common items
  String _translateToChinese(String englishLabel) {
    final translations = {
      // Electronics
      'headphones': '耳机',
      'earbuds': '耳机',
      'airpods': 'AirPods',
      'phone': '手机',
      'laptop': '笔记本电脑',
      'computer': '电脑',
      'tablet': '平板电脑',
      'keyboard': '键盘',
      'mouse': '鼠标',
      'camera': '相机',
      'watch': '手表',
      'charger': '充电器',

      // Clothing
      'clothing': '衣物',
      'shirt': '衬衫',
      'pants': '裤子',
      'jeans': '牛仔裤',
      'dress': '连衣裙',
      'shoe': '鞋',
      'shoes': '鞋子',
      'hat': '帽子',
      'jacket': '夹克',
      'coat': '外套',
      'sweater': '毛衣',
      'sock': '袜子',
      'socks': '袜子',
      'scarf': '围巾',
      'tie': '领带',
      'skirt': '裙子',

      // Books & Paper
      'book': '书',
      'books': '书籍',
      'magazine': '杂志',
      'newspaper': '报纸',
      'paper': '纸张',
      'document': '文件',
      'notebook': '笔记本',
      'letter': '信件',

      // Beauty & Personal Care
      'cosmetic': '化妆品',
      'cosmetics': '化妆品',
      'makeup': '化妆品',
      'perfume': '香水',
      'lotion': '乳液',
      'cream': '面霜',
      'lipstick': '口红',
      'bottle': '瓶子',
      'shampoo': '洗发水',
      'soap': '肥皂',

      // Household Items
      'cup': '杯子',
      'mug': '马克杯',
      'glass': '玻璃杯',
      'plate': '盘子',
      'bowl': '碗',
      'box': '盒子',
      'bag': '包',
      'backpack': '背包',
      'wallet': '钱包',
      'key': '钥匙',

      // Misc
      'toy': '玩具',
      'photo': '照片',
      'picture': '照片',
      'gift': '礼物',
      'souvenir': '纪念品',
      'pen': '笔',
      'pencil': '铅笔',
      'sunglasses': '太阳镜',
      'umbrella': '雨伞',
      'clock': '时钟',
      'lamp': '灯',
    };

    final lower = englishLabel.toLowerCase().trim();
    return translations[lower] ?? _cleanLabelName(englishLabel);
  }

  /// Map label to category
  DeclutterCategory _mapLabelToCategory(String label) {
    final lower = label.toLowerCase();

    if (lower.contains('clothing') || lower.contains('shirt') ||
        lower.contains('pants') || lower.contains('dress') ||
        lower.contains('shoe') || lower.contains('hat') ||
        lower.contains('jacket') || lower.contains('sweater') ||
        lower.contains('garment') || lower.contains('apparel') ||
        lower.contains('coat') || lower.contains('jeans') ||
        lower.contains('skirt') || lower.contains('sock') ||
        lower.contains('scarf') || lower.contains('tie')) {
      return DeclutterCategory.clothes;
    }

    if (lower.contains('book') || lower.contains('novel') ||
        lower.contains('magazine') || lower.contains('publication') ||
        lower.contains('text') || lower.contains('reading')) {
      return DeclutterCategory.books;
    }

    if (lower.contains('paper') || lower.contains('document') ||
        lower.contains('receipt') || lower.contains('letter') ||
        lower.contains('card') || lower.contains('mail') ||
        lower.contains('envelope') || lower.contains('note')) {
      return DeclutterCategory.papers;
    }

    if (lower.contains('cosmetic') || lower.contains('makeup') ||
        lower.contains('perfume') || lower.contains('lotion') ||
        lower.contains('cream') || lower.contains('beauty') ||
        lower.contains('skincare') || lower.contains('fragrance') ||
        lower.contains('lipstick') || lower.contains('bottle') ||
        lower.contains('shampoo') || lower.contains('soap')) {
      return DeclutterCategory.beauty;
    }

    if (lower.contains('photo') || lower.contains('picture') ||
        lower.contains('gift') || lower.contains('memorabilia') ||
        lower.contains('souvenir') || lower.contains('keepsake') ||
        lower.contains('frame')) {
      return DeclutterCategory.sentimental;
    }

    return DeclutterCategory.miscellaneous;
  }

  /// Parse category from string
  DeclutterCategory _parseCategoryFromString(String? category) {
    if (category == null) return DeclutterCategory.miscellaneous;
    final lower = category.toLowerCase();

    if (lower.contains('cloth') || lower.contains('apparel')) return DeclutterCategory.clothes;
    if (lower.contains('book')) return DeclutterCategory.books;
    if (lower.contains('paper') || lower.contains('document')) return DeclutterCategory.papers;
    if (lower.contains('beauty') || lower.contains('cosmetic')) return DeclutterCategory.beauty;
    if (lower.contains('sentimental') || lower.contains('photo')) return DeclutterCategory.sentimental;

    return DeclutterCategory.miscellaneous;
  }

  /// Clean label name
  String _cleanLabelName(String label) {
    if (label.isEmpty) return label;
    // Remove technical prefixes like "n12345678_"
    final cleaned = label.replaceAll(RegExp(r'^[a-z]\d+_'), '');
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }
}
