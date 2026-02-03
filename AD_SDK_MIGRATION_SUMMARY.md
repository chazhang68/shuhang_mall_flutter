# 广告 SDK 迁移总结

## 迁移概述
已将项目从旧的 `flutter_unionad` (穿山甲SDK) 迁移到 `zjsdk_android` + `zjsdk_flutter` (ZJSDK)。

## 主要变更

### 1. 依赖变更
**删除：**
```yaml
flutter_unionad: ^2.2.5
```

**新增：**
```yaml
zjsdk_android: ^2.5.61  # Android SDK
zjsdk_flutter: ^0.2.5   # iOS SDK
```

### 2. 文件变更

#### 新增文件
- `lib/app/services/ad_manager.dart` - 重写的广告管理器
- `lib/widgets/zj_banner_ad_widget.dart` - 横幅广告组件
- `lib/widgets/zj_feed_ad_widget.dart` - 信息流广告组件
- `lib/app/modules/test/ad_test_page.dart` - 广告测试页面
- `ZJSDK_INTEGRATION_GUIDE.md` - 集成指南
- `AD_SDK_MIGRATION_SUMMARY.md` - 本文档

#### 修改文件
- `pubspec.yaml` - 更新依赖
- `lib/app/config/ad_config.dart` - 更新配置
- `lib/main.dart` - 更新初始化逻辑
- `lib/app/modules/splash/splash_page.dart` - 重写开屏广告

#### 删除文件
- `lib/widgets/feed_ad_widget.dart` - 旧的广告组件

### 3. API 变更对比

#### 初始化
**旧 SDK:**
```dart
await FlutterUnionad.register(
  androidAppId: appId,
  iosAppId: appId,
  debug: true,
);
```

**新 SDK:**
```dart
// 初始化（不启动）
await AdManager.instance.initWithoutStart();

// 启动（用户同意隐私政策后）
await AdManager.instance.start();
```

#### 激励视频
**旧 SDK:**
```dart
await FlutterUnionad.loadRewardVideoAd(
  androidCodeId: adId,
  iosCodeId: adId,
);
await FlutterUnionad.showRewardVideoAd();
```

**新 SDK:**
```dart
await AdManager.instance.showRewardedVideoAd(
  onReward: () {
    // 发放奖励
  },
);
```

#### 开屏广告
**旧 SDK:**
```dart
FlutterUnionad.splashAdView(
  androidCodeId: adId,
  iosCodeId: adId,
  callBack: FlutterUnionadSplashCallBack(...),
)
```

**新 SDK:**
```dart
// Android
ZJAndroid.loadSplashAd(
  adId,
  splashListener: (ret) { ... },
);

// iOS
ZJiOS.loadSplashAd(
  adId,
  splashListener: (ret) { ... },
);
```

## 新 SDK 优势

### 1. 更好的隐私合规
- 支持初始化和启动分离
- 可在用户同意隐私政策前初始化
- 符合最新隐私政策要求

### 2. 更丰富的广告类型
- 开屏广告
- 激励视频
- 插全屏广告（合并了插屏和全屏）
- 横幅广告
- 信息流广告
- 视频流广告
- 视频内容
- 短剧
- 新闻资讯
- H5页面

### 3. 更好的跨平台支持
- Android 和 iOS 使用统一的 API
- 平台差异由 AdManager 自动处理

### 4. 更灵活的广告加载
- 支持预加载
- 支持加载并展示
- 更细粒度的回调控制

## 使用指南

### 快速开始

1. **安装依赖**
```bash
flutter pub get
```

2. **初始化 SDK**
在 `main.dart` 中已自动初始化

3. **显示广告**
```dart
// 激励视频
await AdManager.instance.showRewardedVideoAd(
  onReward: () => print('获得奖励'),
);

// 插全屏
await AdManager.instance.showInterstitialAd(
  onClose: () => print('广告关闭'),
);
```

4. **使用广告组件**
```dart
// 横幅广告
ZJBannerAdWidget(
  width: double.infinity,
  height: 120,
)

// 信息流广告
ZJFeedAdWidget(
  width: double.infinity,
  height: 280,
)
```

### 测试广告

访问测试页面：
```dart
Get.to(() => const AdTestPage());
```

或在路由中添加：
```dart
GetPage(
  name: '/ad-test',
  page: () => const AdTestPage(),
),
```

## 注意事项

### 1. 包名配置
如果使用示例中的测试广告位ID，需要修改包名为 `com.zj.daylottery.demo`。

修改位置：`android/app/build.gradle.kts`
```kotlin
applicationId = "com.zj.daylottery.demo"
```

### 2. 广告位ID
当前使用的广告位ID：
- AppId: `Z0062563231`
- 开屏: `J8120762208`
- 激励视频: `J3449837410`
- 插全屏: `J6396345907`
- 信息流/横幅: `J2377787779`

正式上线前需要替换为自己申请的广告位ID。

### 3. 隐私政策
确保在用户同意隐私政策后才调用 `AdManager.instance.start()`。

### 4. 错误处理
所有广告方法都有错误回调，建议记录日志便于排查问题。

## 下一步

1. **测试广告功能**
   - 运行应用到真机
   - 访问广告测试页面
   - 测试各种广告类型

2. **申请正式广告位**
   - 联系广告平台申请正式广告位ID
   - 替换配置文件中的测试ID

3. **优化广告策略**
   - 合理控制广告展示频率
   - 在合适的时机展示广告
   - 监控广告收益和用户体验

4. **性能优化**
   - 预加载激励视频
   - 避免频繁请求广告
   - 监控广告加载时间

## 常见问题

### Q: 广告加载失败，错误码 40009
A: 媒体ID不合法，检查广告位ID和包名是否匹配。

### Q: SDK 初始化失败
A: 检查网络连接和 AppId 是否正确。

### Q: 开屏广告不显示
A: 确保 SDK 已启动，检查广告位ID。

### Q: 如何调试广告
A: 在 `AdConfig` 中设置 `isDebug = true`，查看日志输出。

## 技术支持

- [ZJSDK Android 文档](https://pub.dev/packages/zjsdk_android)
- [ZJSDK iOS 文档](https://pub.dev/packages/zjsdk_flutter)
- [详细集成指南](./ZJSDK_INTEGRATION_GUIDE.md)

## 更新记录

- 2024-02-03: 完成 SDK 迁移
- 2024-02-03: 添加广告测试页面
- 2024-02-03: 创建集成文档
