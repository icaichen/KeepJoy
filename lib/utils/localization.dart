import 'package:flutter/widgets.dart';

String localizedText(BuildContext context, String english, String chinese) {
  final locale = Localizations.maybeLocaleOf(context);
  final code = locale?.languageCode.toLowerCase();
  if (code == 'zh' ||
      code == 'zh-hans' ||
      code == 'zh-hant' ||
      (code != null && code.startsWith('zh'))) {
    return chinese;
  }
  return english;
}

bool isChineseLocale(BuildContext context) {
  final locale = Localizations.maybeLocaleOf(context);
  final code = locale?.languageCode.toLowerCase();
  return code == 'zh' ||
      code == 'zh-hans' ||
      code == 'zh-hant' ||
      (code != null && code.startsWith('zh'));
}
