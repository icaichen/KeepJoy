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
import 'flavor_config.dart';

class AIConfig {
  // Select API key based on flavor (China vs Global)
  static String get qwenApiKey {
    final isChina = FlavorConfig.instance.isChina;

    // Check if local config has values (not empty)
    final localGlobalKey = local_config.AIConfigLocal.globalApiKey;
    final localChinaKey = local_config.AIConfigLocal.chinaApiKey;

    if (isChina && localChinaKey.isNotEmpty) {
      return localChinaKey;
    }
    if (!isChina && localGlobalKey.isNotEmpty) {
      return localGlobalKey;
    }

    // Fall back to environment variable
    return const String.fromEnvironment('QWEN_API_KEY');
  }

  // Select base URL based on flavor
  static String get qwenBaseUrl {
    final isChina = FlavorConfig.instance.isChina;
    return isChina
        ? 'https://dashscope.aliyuncs.com/compatible-mode/v1'  // China version
        : 'https://dashscope-intl.aliyuncs.com/compatible-mode/v1';  // International version
  }

  static bool get isConfigured => qwenApiKey.isNotEmpty;
}

