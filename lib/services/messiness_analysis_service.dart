import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MessinessAnalysisResult {
  final double? beforeScore;
  final double? afterScore;
  final int? itemsRemoved;

  const MessinessAnalysisResult({
    this.beforeScore,
    this.afterScore,
    this.itemsRemoved,
  });
}

/// Service for analyzing room messiness and estimated decluttered items via Qwen VL Plus
class MessinessAnalysisService {
  static const String _qwenApiKey = 'sk-cf4b75178c3245fd8b04e149af1a0d2a';
  static const String _qwenBaseUrl =
      'https://dashscope-intl.aliyuncs.com/compatible-mode/v1';

  /// Initialize (no-op)
  Future<void> initialize() async {}

  /// Analyze messiness for a single photo (0-10, higher = messier)
  Future<double> analyzeMessiness(String imagePath) async {
    final result = await analyzeBeforeAfter(imagePath, null, const Locale('en'));
    return result.beforeScore ?? 5.0;
  }

  /// Analyze messiness for before/after and estimate removed items
  Future<MessinessAnalysisResult> analyzeBeforeAfter(
    String beforePath,
    String? afterPath,
    Locale locale,
  ) async {
    try {
      final beforeBytes = await File(beforePath).readAsBytes();
      final beforeBase64 = base64Encode(beforeBytes);
      String? afterBase64;
      if (afterPath != null) {
        afterBase64 = base64Encode(await File(afterPath).readAsBytes());
      }

      final language =
          locale.languageCode.toLowerCase().startsWith('zh') ? 'Chinese' : 'English';

      final messages = [
        {
          'role': 'user',
          'content': [
            {
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,$beforeBase64'},
            },
            if (afterBase64 != null)
              {
                'type': 'image_url',
                'image_url': {'url': 'data:image/jpeg;base64,$afterBase64'},
              },
            {
              'type': 'text',
              'text':
                  '''Compare the${afterBase64 != null ? ' two' : ''} room photo${afterBase64 != null ? 's' : ''} and rate visual messiness (0-10, 10 = very messy).${afterBase64 != null ? ' Also estimate how many items were removed between the before (first) and after (second) photo.' : ''} Respond in JSON:
{
  "messiness_before": number 0-10,
  ${afterBase64 != null ? '"messiness_after": number 0-10,' : '"messiness_after": null,'}
  ${afterBase64 != null ? '"items_removed": integer (0 or more)' : '"items_removed": null'}
}
Use concise $language names only.''',
            },
          ],
        },
      ];

      final response = await http.post(
        Uri.parse('$_qwenBaseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_qwenApiKey',
        },
        body: jsonEncode({
          'model': 'qwen-vl-plus',
          'messages': messages,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data['choices'][0]['message']['content'].toString();
        if (content.contains('```json')) {
          content = content.split('```json')[1].split('```')[0].trim();
        } else if (content.contains('```')) {
          content = content.split('```')[1].split('```')[0].trim();
        }
        final json = jsonDecode(content) as Map<String, dynamic>;

        double? beforeScore;
        double? afterScore;
        int? itemsRemoved;

        if (json['messiness_before'] != null) {
          beforeScore =
              (json['messiness_before'] as num).toDouble().clamp(0.0, 10.0);
        }
        if (json['messiness_after'] != null) {
          afterScore =
              (json['messiness_after'] as num).toDouble().clamp(0.0, 10.0);
        }
        if (json['items_removed'] != null) {
          itemsRemoved = (json['items_removed'] as num).round();
          if (itemsRemoved < 0) itemsRemoved = 0;
        }

        return MessinessAnalysisResult(
          beforeScore: beforeScore,
          afterScore: afterScore,
          itemsRemoved: itemsRemoved,
        );
      } else {
        debugPrint(
          'Messiness analysis failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Messiness analysis error: $e');
    }

    // Fallback neutral values
    return const MessinessAnalysisResult(
      beforeScore: 5.0,
      afterScore: null,
      itemsRemoved: null,
    );
  }

  /// Dispose (no-op)
  void dispose() {}
}
