// AI API Configuration
//
// IMPORTANT:
// 1. Get your API key from Alibaba Cloud DashScope
// 2. Configure via one of these methods:
//    a) Pass via --dart-define: flutter run --dart-define=QWEN_API_KEY=...
//    b) Create lib/config/ai_config_local.dart (gitignored) with your credentials for development
//       See ai_config_local.dart.example for template
//
// SECURITY NOTE: Never commit API keys to version control

// Import local config (for development convenience)
// This file is gitignored - create it from ai_config_local.dart.example
import 'ai_config_local.dart' as local_config;

class AIConfig {
  // First try local config (for development), then fall back to --dart-define
  static String get qwenApiKey {
    // Check if local config has values (not empty)
    if (local_config.AIConfigLocal.apiKey.isNotEmpty) {
      return local_config.AIConfigLocal.apiKey;
    }
    // Fall back to environment variable
    return const String.fromEnvironment('QWEN_API_KEY');
  }

  static const String qwenBaseUrl =
      'https://dashscope-intl.aliyuncs.com/compatible-mode/v1';

  static bool get isConfigured => qwenApiKey.isNotEmpty;
}

