# ZJSDK 广告集成指南

## 概述
本项目已集成 ZJSDK 广告 SDK，支持 Android 和 iOS 双平台。

## 已集成的功能

### 1. SDK 依赖
在 `pubspec.yaml` 中添加：
```yaml
dependencies:
  zjsdk_android: ^2.4.16  # Android SDK
  zjsdk_flutter: ^0.2.5   # iOS SDK
```

### 2. 广告配置
配置文件：`lib/app/config/ad_config.dart`

```dart
class AdConfig {
  static const String appId = 'Z0062563231';           // 应用ID
  static const String splashAdId = 'J8120762208';      // 开屏广告位
  static const String rewardVideoAdId = 'J3449837410'; // 激励视频
  static const String interstitialAdId = 'J6396345907';// 插全屏
  static const String feedAdId = 'J2377787779';        // 信息流
  static const String bannerAdId = 'J2377787779';      // 横幅
}
```

### 3. 广告管理器
文件：`lib/app/services/ad_manager.dart`

提供统一的广告管理接口：
- `initWithoutStart()` - 初始化SDK（不启动）
- `start()` - 启动SDK（需用户同意隐私政策后调用）
- `preloadRewardedVideoAd()` - 预加载激励视频
- `showRewardedVideoAd()` - 显示激励视频
- `showInterstitialAd()` - 显示插全屏广告

## 使用方法

### 1. 应用启动时初始化
在 `main.dart` 中：
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化广告SDK（不启动）
  await AdManager.instance.initWithoutStart();
  
  runApp(const MyApp());
}
```

### 2. 用户同意隐私政策后启动
```dart
// 用户同意隐私政策后
await AdManager.instance.start();
```

### 3. 显示开屏广告
开屏广告使用原生方式加载，在 `SplashPage` 中自动展示。

### 4. 显示激励视频广告
```dart
// 方式1：直接加载并显示
await AdManager.instance.showRewardedVideoAd(
  onShow: () => print('广告展示'),
  onClick: () => print('广告点击'),
  onReward: () => print('获得奖励'),
  onClose: () => print('广告关闭'),
  onError: (error) => print('广告错误: $error'),
);

// 方式2：预加载 + 显示
await AdManager.instance.preloadRewardedVideoAd();
// ... 稍后显示
await AdManager.instance.showRewardedVideoAd(
  onReward: () {
    // 发放奖励
  },
);
```

### 5. 显示插全屏广告
```dart
await AdManager.instance.showInterstitialAd(
  onShow: () => print('广告展示'),
  onClick: () => print('广告点击'),
  onClose: () => print('广告关闭'),
  onError: (error) => print('广告错误: $error'),
);
```

### 6. 使用横幅广告组件
```dart
import 'package:shuhang_mall_flutter/widgets/zj_banner_ad_widget.dart';

// 在页面中使用
ZJBannerAdWidget(
  width: double.infinity,
  height: 120,
  onShow: () => print('横幅广告展示'),
  onClick: () => print('横幅广告点击'),
  onClose: () => print('横幅广告关闭'),
  onError: (error) => print('横幅广告错误: $error'),
)
```

### 7. 使用信息流广告组件
```dart
import 'package:shuhang_mall_flutter/widgets/zj_feed_ad_widget.dart';

// 在页面中使用
ZJFeedAdWidget(
  width: double.infinity,
  height: 280,
  videoSoundEnable: false, // 是否开启视频声音
  onShow: () => print('信息流广告展示'),
  onClick: () => print('信息流广告点击'),
  onClose: () => print('信息流广告关闭'),
  onError: (error) => print('信息流广告错误: $error'),
)
```

## 广告类型说明

### 1. 开屏广告
- 应用启动时自动展示
- 使用原生方式加载，性能更好
- 支持跳过和倒计时

### 2. 激励视频广告
- 用户观看完整视频后获得奖励
- 支持预加载，提升展示速度
- 回调 `onReward` 时发放奖励

### 3. 插全屏广告
- 全屏展示，支持视频和图片
- 可在关键节点展示（如任务完成、关卡通过等）

### 4. 横幅广告
- 固定在页面顶部或底部
- 支持自动刷新
- 适合长时间停留的页面

### 5. 信息流广告
- 嵌入内容流中
- 样式丰富，与内容融合度高
- 支持视频和图片

## 注意事项

### 1. 隐私合规
- 必须在用户同意隐私政策后才能调用 `start()` 方法
- 可以在同意前调用 `initWithoutStart()` 进行预初始化

### 2. 广告位ID
- 测试时使用示例中的广告位ID
- 正式上线前需要替换为自己申请的广告位ID
- 广告位ID与包名绑定，使用错误的包名会导致请求失败

### 3. Android 配置
如果使用示例中的测试ID，需要修改 `android/app/build.gradle.kts` 中的 `applicationId` 为 `com.zj.daylottery.demo`

### 4. 错误处理
- 所有广告方法都有错误回调
- 建议在错误回调中记录日志，便于排查问题
- 广告加载失败不应影响主要功能

### 5. 性能优化
- 激励视频建议预加载，提升用户体验
- 避免频繁请求广告
- 合理控制广告展示频率

## 常见问题

### Q1: 广告请求失败，返回错误码 40009
A: 媒体ID不合法，检查广告位ID是否正确，包名是否与广告位绑定的包名一致。

### Q2: 广告SDK初始化失败
A: 检查网络连接，确认 AppId 是否正确。

### Q3: 激励视频预加载成功但播放失败
A: 预加载的广告有效期为20分钟，过期后需要重新加载。

### Q4: 开屏广告不显示
A: 确保 SDK 已启动（调用了 `start()` 方法），检查广告位ID是否正确。

## 更新日志

### v1.0.0 (2024-02-03)
- 集成 ZJSDK Android SDK v2.4.16
- 集成 ZJSDK iOS SDK v0.2.5
- 支持开屏、激励视频、插全屏、横幅、信息流广告
- 提供统一的广告管理器
- 提供便捷的广告组件

## 相关链接

- [ZJSDK Android 文档](https://pub.dev/packages/zjsdk_android)
- [ZJSDK iOS 文档](https://pub.dev/packages/zjsdk_flutter)
- [Flutter 对接文档](https://static-1318684143.cos-website.ap-shanghai.myqcloud.com/sdk-downloads/docs/flutter/)
