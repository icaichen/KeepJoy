import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:keepjoy_app/models/declutter_item.dart';

String _normalizeLocaleCode(String languageCode, String? countryCode) {
  final base = languageCode.toLowerCase();
  if (countryCode == null || countryCode.isEmpty) {
    return base;
  }
  return '$base-${countryCode.toLowerCase()}';
}

/// Result from AI identification
class AIIdentificationResult {
  final String itemName;
  final Map<String, String> localizedNames;
  final DeclutterCategory suggestedCategory;
  final double confidence; // 0-100
  final String method; // 'on-device' or 'cloud'
  final List<String> alternativeNames;

  AIIdentificationResult({
    required this.itemName,
    required this.localizedNames,
    required this.suggestedCategory,
    required this.confidence,
    required this.method,
    this.alternativeNames = const [],
  });

  String nameForLocale(Locale locale) {
    return nameForLocaleCode(
      _normalizeLocaleCode(locale.languageCode, locale.countryCode),
    );
  }

  String nameForLocaleCode(String? localeCode) {
    if (localeCode == null || localeCode.isEmpty) {
      return localizedNames['en'] ?? itemName;
    }

    final normalized = localeCode.toLowerCase();
    final languageOnly = normalized.split('-').first;

    return localizedNames[normalized] ??
        localizedNames[languageOnly] ??
        localizedNames['en'] ??
        itemName;
  }
}

/// AI-powered object identification service (ML Kit removed)
class AIIdentificationService {
  static final AIIdentificationService _instance =
      AIIdentificationService._internal();
  factory AIIdentificationService() => _instance;
  AIIdentificationService._internal();

  // Qwen VL Plus API (Singapore region)
  static const String _qwenApiKey = 'sk-cf4b75178c3245fd8b04e149af1a0d2a';
  static const String _qwenBaseUrl = 'https://dashscope-intl.aliyuncs.com/compatible-mode/v1';

  /// Initialize the service (no-op)
  Future<void> initialize() async {}

  /// Dispose resources (no-op)
  void dispose() {}

  /// Quick on-device identification - disabled (ML Kit removed)
  Future<AIIdentificationResult?> identifyBasic(
    String imagePath,
    Locale locale,
  ) async {
    return null;
  }

  /// Detailed identification using Qwen VL Plus API (Singapore)
  Future<AIIdentificationResult?> identifyDetailed(
    String imagePath,
    Locale locale,
  ) async {
    try {
      final imageBytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final localeCode = _normalizeLocaleCode(
        locale.languageCode,
        locale.countryCode,
      );
      final language = locale.languageCode == 'zh' ? 'Chinese' : 'English';

      final response = await http.post(
        Uri.parse('$_qwenBaseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_qwenApiKey',
        },
        body: jsonEncode({
          'model': 'qwen-vl-plus',
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
                },
                {
                  'type': 'text',
                  'text':
                      '''Identify this item in $language. Include brand name if visible.
Respond in JSON format:
{
  "name": "specific item name with brand if visible",
  "category": "one of: clothes, booksDocuments, electronics, beauty, sentimental, miscellaneous",
  "confidence": 0-100
}''',
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];

        // Extract JSON from response (handle markdown code blocks)
        String jsonStr = content.trim();
        if (jsonStr.contains('```json')) {
          jsonStr = jsonStr.split('```json')[1].split('```')[0].trim();
        } else if (jsonStr.contains('```')) {
          jsonStr = jsonStr.split('```')[1].split('```')[0].trim();
        }

        final result = jsonDecode(jsonStr);

        final localizedNames = _buildLocalizedNames(
          result['name'] ?? 'Unknown item',
        );
        final displayName = _nameForLocale(localizedNames, localeCode);

        return AIIdentificationResult(
          itemName: displayName,
          localizedNames: localizedNames,
          suggestedCategory: _parseCategoryFromString(result['category']),
          confidence: (result['confidence'] ?? 70).toDouble(),
          method: 'cloud',
        );
      } else {
        print('Qwen API error: ${response.statusCode} - ${response.body}');
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
      'tableware': '餐具',
      'utensil': '餐具',
      'utensils': '餐具',
      'cutlery': '刀叉',
      'silverware': '银器',
      'fork': '叉子',
      'spoon': '勺子',
      'knife': '刀子',
      'chopsticks': '筷子',
      'dish': '餐盘',
      'dishes': '餐具',
      'utensils set': '餐具套装',

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

  Map<String, String> _buildLocalizedNames(String label) {
    final english = _cleanLabelName(label);
    final chinese = _translateToChinese(label);
    final names = <String, String>{'en': english};
    if (chinese.isNotEmpty) {
      names['zh'] = chinese;
    }
    return names;
  }

  String _localeTag(Locale locale) {
    final components = [locale.languageCode];
    if (locale.scriptCode != null && locale.scriptCode!.isNotEmpty) {
      components.add(locale.scriptCode!);
    }
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      components.add(locale.countryCode!);
    }
    return components.join('-');
  }

  String _nameForLocale(Map<String, String> names, String? localeCode) {
    if (localeCode == null || localeCode.isEmpty) {
      return names['en'] ?? names.values.first;
    }
    final normalized = localeCode.toLowerCase();
    final languageOnly = normalized.split('-').first;
    return names[normalized] ??
        names[languageOnly] ??
        names['en'] ??
        names.values.first;
  }

  /// Map label to category
  DeclutterCategory _mapLabelToCategory(String label) {
    final lower = label.toLowerCase();

    if (lower.contains('clothing') ||
        lower.contains('shirt') ||
        lower.contains('pants') ||
        lower.contains('dress') ||
        lower.contains('shoe') ||
        lower.contains('hat') ||
        lower.contains('jacket') ||
        lower.contains('sweater') ||
        lower.contains('garment') ||
        lower.contains('apparel') ||
        lower.contains('coat') ||
        lower.contains('jeans') ||
        lower.contains('skirt') ||
        lower.contains('sock') ||
        lower.contains('scarf') ||
        lower.contains('tie')) {
      return DeclutterCategory.clothes;
    }

    if (lower.contains('book') ||
        lower.contains('novel') ||
        lower.contains('magazine') ||
        lower.contains('publication') ||
        lower.contains('text') ||
        lower.contains('reading') ||
        lower.contains('paper') ||
        lower.contains('document') ||
        lower.contains('receipt') ||
        lower.contains('letter') ||
        lower.contains('card') ||
        lower.contains('mail') ||
        lower.contains('envelope') ||
        lower.contains('note')) {
      return DeclutterCategory.booksDocuments;
    }

    if (lower.contains('phone') ||
        lower.contains('laptop') ||
        lower.contains('tablet') ||
        lower.contains('computer') ||
        lower.contains('camera') ||
        lower.contains('electronics') ||
        lower.contains('device') ||
        lower.contains('headphones') ||
        lower.contains('earbuds') ||
        lower.contains('charger') ||
        lower.contains('watch') ||
        lower.contains('console') ||
        lower.contains('keyboard') ||
        lower.contains('mouse') ||
        lower.contains('monitor') ||
        lower.contains('television') ||
        lower.contains('tv') ||
        lower.contains('speaker') ||
        lower.contains('projector')) {
      return DeclutterCategory.electronics;
    }

    if (lower.contains('cosmetic') ||
        lower.contains('makeup') ||
        lower.contains('perfume') ||
        lower.contains('lotion') ||
        lower.contains('cream') ||
        lower.contains('beauty') ||
        lower.contains('skincare') ||
        lower.contains('fragrance') ||
        lower.contains('lipstick') ||
        lower.contains('bottle') ||
        lower.contains('shampoo') ||
        lower.contains('soap')) {
      return DeclutterCategory.beauty;
    }

    if (lower.contains('photo') ||
        lower.contains('picture') ||
        lower.contains('gift') ||
        lower.contains('memorabilia') ||
        lower.contains('souvenir') ||
        lower.contains('keepsake') ||
        lower.contains('frame')) {
      return DeclutterCategory.sentimental;
    }

    return DeclutterCategory.miscellaneous;
  }

  /// Parse category from string
  DeclutterCategory _parseCategoryFromString(String? category) {
    if (category == null) return DeclutterCategory.miscellaneous;
    final lower = category.toLowerCase();

    if (lower.contains('cloth') || lower.contains('apparel')) {
      return DeclutterCategory.clothes;
    }
    if (lower.contains('book') ||
        lower.contains('paper') ||
        lower.contains('document')) {
      return DeclutterCategory.booksDocuments;
    }
    if (lower.contains('electronic') ||
        lower.contains('device') ||
        lower.contains('phone')) {
      return DeclutterCategory.electronics;
    }
    if (lower.contains('beauty') || lower.contains('cosmetic')) {
      return DeclutterCategory.beauty;
    }
    if (lower.contains('sentimental') || lower.contains('photo')) {
      return DeclutterCategory.sentimental;
    }

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
