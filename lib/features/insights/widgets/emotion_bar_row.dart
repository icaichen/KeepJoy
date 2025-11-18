import 'package:flutter/material.dart';
import 'package:keepjoy_app/models/memory.dart';

class EmotionBarRow extends StatelessWidget {
  final List<Map<String, Object>> emotions;
  final Map<MemorySentiment, int> sentimentCounts;

  const EmotionBarRow({
    super.key,
    required this.emotions,
    required this.sentimentCounts,
  });

  @override
  Widget build(BuildContext context) {
    final maxCount = sentimentCounts.values.isEmpty
        ? 1
        : sentimentCounts.values.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: emotions.map((emotion) {
        final sentiment = emotion['sentiment'] as MemorySentiment;
        final count = sentimentCounts[sentiment] ?? 0;
        final color = emotion['color'] as Color;
        final label = emotion['label'] as String;
        final percent = maxCount == 0 ? 0.0 : (count / maxCount).clamp(0.05, 1.0);

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Stack(
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F1F5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: percent,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
