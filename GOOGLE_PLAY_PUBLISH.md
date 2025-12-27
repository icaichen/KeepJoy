# Google Play Store 发布清单

## ✅ 已修复的关键问题

### 1. ✅ INTERNET权限
- **问题**: AndroidManifest.xml缺少INTERNET权限
- **修复**: 已添加 `INTERNET` 和 `ACCESS_NETWORK_STATE` 权限
- **位置**: `android/app/src/main/AndroidManifest.xml:3-4`

### 2. ✅ 签名密钥安全
- **问题**: `key.properties` 没有在.gitignore中
- **修复**: 已添加到.gitignore，防止泄露签名密钥
- **位置**: `.gitignore:52-55`

### 3. ✅ ProGuard/R8配置
- **问题**: 缺少代码混淆规则
- **修复**: 创建了完整的ProGuard规则文件
- **位置**: `android/app/proguard-rules.pro`

## 📋 Google Play发布前检查清单

### 代码和配置 ✅

- [x] **互联网权限**: 已添加
- [x] **签名配置**: 已配置release signing
- [x] **代码混淆**: 已启用R8/ProGuard
- [x] **版本号**: 当前 `1.0.1+2` (pubspec.yaml)
- [x] **应用ID**: `com.keepjoy.app` (global) / `com.keepjoy.app.china` (china)

### 安全性 ✅

- [x] **API密钥保护**: ai_config_local.dart 在.gitignore中
- [x] **Supabase配置保护**: supabase_config_local.dart 在.gitignore中
- [x] **签名密钥保护**: key.properties 和 keystore 文件在.gitignore中
- [x] **HTTPS通信**: 所有API调用使用HTTPS

### 隐私和合规 ✅

- [x] **隐私政策**: 已存在 `PRIVACY_POLICY.md`
- [x] **服务条款**: 已存在 `TERMS_OF_SERVICE.md`
- [x] **数据删除**: 已实现完整的账户删除功能
- [x] **数据加密**: 使用Supabase加密传输

### 必需资源

#### 需要准备（你需要做）:

- [ ] **App图标**
  - 512x512 高分辨率图标 (PNG, 32位)
  - 位置: 在Google Play Console上传

- [ ] **Feature Graphic**
  - 1024x500 横幅图片
  - 用于应用商店展示

- [ ] **应用截图** (至少2张，最多8张)
  - 手机: 16:9 或 9:16 比例
  - 平板: 可选
  - 建议尺寸: 1080x1920或更高

- [ ] **应用描述**
  - 简短描述 (80字符以内)
  - 完整描述 (4000字符以内)
  - 包含主要功能说明

- [ ] **分类和标签**
  - 主要类别: 生产力/生活方式
  - 内容分级: 所有人

### Build验证

#### 测试Release Build:

```bash
# 1. 清理旧build
flutter clean

# 2. 获取依赖
flutter pub get

# 3. Build Release APK (测试用)
flutter build apk --release --flavor global

# 4. Build App Bundle (正式发布)
flutter build appbundle --release --flavor global
```

#### 生成的文件位置:

- APK: `build/app/outputs/flutter-apk/app-global-release.apk`
- AAB: `build/app/outputs/bundle/globalRelease/app-global-release.aab`

### 上传前检查

- [ ] **测试Release Build**
  ```bash
  # 安装并测试release APK
  flutter install --release --flavor global
  ```

- [ ] **验证功能**
  - [ ] 用户注册/登录
  - [ ] AI物品识别
  - [ ] 数据同步
  - [ ] 照片上传
  - [ ] 账户删除
  - [ ] 订阅功能 (如果有)

- [ ] **检查崩溃**
  - 在release模式运行30分钟
  - 测试所有主要功能
  - 检查logcat无严重错误

### Google Play Console配置

#### 应用设置:

1. **创建应用**
   - 登录 https://play.google.com/console
   - 创建新应用
   - 选择默认语言

2. **应用内容**
   - [ ] 隐私政策链接 (你需要上传PRIVACY_POLICY.md到网站)
   - [ ] 应用访问权限说明
   - [ ] 广告声明 (如果有广告)
   - [ ] 目标受众和内容分级

3. **Store listing**
   - [ ] 应用图标
   - [ ] Feature graphic
   - [ ] 截图
   - [ ] 应用描述
   - [ ] 分类

4. **发布**
   - [ ] 选择国家/地区
   - [ ] 价格设置 (免费/付费)
   - [ ] 上传AAB文件

## 🚀 发布步骤

### 步骤1: Build Release Bundle

```bash
# China版本
flutter build appbundle --release --flavor china \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key

# Global版本
flutter build appbundle --release --flavor global \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key
```

### 步骤2: 测试AAB

使用bundletool测试:
```bash
# 安装bundletool
brew install bundletool

# 测试AAB
bundletool build-apks \
  --bundle=build/app/outputs/bundle/globalRelease/app-global-release.aab \
  --output=test.apks \
  --mode=universal
```

### 步骤3: 上传到Google Play Console

1. 进入 **Production** > **Releases**
2. 点击 **Create new release**
3. 上传 `.aab` 文件
4. 填写 **Release notes**
5. 审核并发布

## ⚠️ 重要提醒

### 生产环境配置

**不要在代码中硬编码API密钥！**

正式发布时使用环境变量:

```bash
flutter build appbundle --release --flavor global \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key \
  --dart-define=QWEN_API_KEY=your_qwen_key
```

### 版本管理

每次发布前更新版本号:

```yaml
# pubspec.yaml
version: 1.0.2+3  # 格式: major.minor.patch+buildNumber
```

### 测试设备要求

- 至少在3台不同的Android设备上测试
- 覆盖Android 11, 12, 13, 14
- 测试不同屏幕尺寸

## 📊 发布后监控

### 在Play Console查看:

- [ ] **Crash reports**: 每天检查崩溃率
- [ ] **ANR率**: 应低于0.47%
- [ ] **用户评分**: 保持4.0+
- [ ] **卸载率**: 监控异常卸载

### 设置警报:

在Play Console > Alerts设置:
- Crash率超过1%
- ANR率超过0.5%
- 评分低于4.0

## 🔄 更新流程

### 发布更新:

1. 修改 `pubspec.yaml` 版本号
2. Build新的AAB
3. 在Play Console创建新版本
4. 上传AAB
5. 填写更新说明
6. 分阶段发布 (推荐)
   - 5% → 10% → 20% → 50% → 100%

## 📝 相关文件

- Android配置: `android/app/build.gradle.kts`
- 权限声明: `android/app/src/main/AndroidManifest.xml`
- ProGuard规则: `android/app/proguard-rules.pro`
- 隐私政策: `PRIVACY_POLICY.md`
- 服务条款: `TERMS_OF_SERVICE.md`
- 版本号: `pubspec.yaml`

## 🆘 常见问题

### Build失败

```bash
# 清理并重新build
flutter clean
flutter pub get
flutter build appbundle --release --flavor global
```

### 签名错误

检查 `android/key.properties`:
```properties
storePassword=your_password
keyPassword=your_password
keyAlias=your_alias
storeFile=../app/upload-keystore.jks
```

### ProGuard导致崩溃

在 `proguard-rules.pro` 添加keep规则:
```
-keep class your.crashing.class.** { *; }
```

## ✅ 最终检查

发布前最后确认:

- [ ] 所有敏感信息已从代码中移除
- [ ] Build在release模式运行无错误
- [ ] 所有功能测试通过
- [ ] 隐私政策和服务条款已准备
- [ ] App图标和截图已准备
- [ ] key.properties 不在Git仓库中
- [ ] 版本号已更新

---

**祝你发布顺利！** 🎉

有问题随时查看这个清单或咨询开发者社区。
