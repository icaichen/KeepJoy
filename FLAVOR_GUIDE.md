# Flutter Flavor 使用指南

## 概述

本项目配置了两个 flavor 用于不同市场：
- **china**: 中国市场版本
- **global**: 国际市场版本

## 配置信息

### Application ID
- China: `com.keepjoy.app.china`
- Global: `com.keepjoy.app`

### 应用名称
- 两个版本目前都使用 "KeepJoy"

## 如何运行

### 使用命令行

**运行中国版本：**
```bash
flutter run --flavor china -t lib/main_china.dart
```

**运行国际版本：**
```bash
flutter run --flavor global -t lib/main_global.dart
```

### 使用 VS Code

在 VS Code 中：
1. 按 `F5` 或点击 "Run and Debug"
2. 选择以下配置之一：
   - `KeepJoy (China)` - 中国版本
   - `KeepJoy (Global)` - 国际版本

## 构建 APK/Bundle

### Debug 版本

**中国版本：**
```bash
flutter build apk --flavor china -t lib/main_china.dart
```

**国际版本：**
```bash
flutter build apk --flavor global -t lib/main_global.dart
```

### Release 版本

**中国版本：**
```bash
flutter build apk --release --flavor china -t lib/main_china.dart
```

**国际版本：**
```bash
flutter build apk --release --flavor global -t lib/main_global.dart
```

### App Bundle（Google Play）

```bash
flutter build appbundle --release --flavor global -t lib/main_global.dart
```

## 在代码中使用 Flavor

你可以在代码中检查当前运行的 flavor：

```dart
import 'package:keepjoy_app/config/flavor_config.dart';

// 检查是否是中国版本
if (FlavorConfig.instance.isChina) {
  // 中国版本特定的代码
  // 例如：集成微信支付、支付宝等
}

// 检查是否是国际版本
if (FlavorConfig.instance.isGlobal) {
  // 国际版本特定的代码
}

// 获取 flavor 名称
print('Current flavor: ${FlavorConfig.instance.name}');
```

## 未来扩展

### 添加特定配置

如果需要为某个 flavor 添加特定的 Android 配置：

1. 在 `android/app/src/china/` 或 `android/app/src/global/` 中创建文件
2. 例如添加特定的权限或配置：

```
android/app/src/china/AndroidManifest.xml
android/app/src/china/res/values/strings.xml
```

### 不同的 API 端点

在 `flavor_config.dart` 中添加不同的 API 配置：

```dart
class FlavorConfig {
  final String apiBaseUrl;

  // China: https://api.keepjoy.cn
  // Global: https://api.keepjoy.com
}
```

### 不同的应用图标

可以在各自的 flavor 目录中放置不同的图标资源。

## 注意事项

1. 每次切换 flavor 时，建议先运行 `flutter clean`
2. 确保在正确的 flavor 目录中添加特定配置
3. 中国版本的 Application ID 会自动添加 `.china` 后缀
4. 版本号会自动添加 `-china` 后缀
