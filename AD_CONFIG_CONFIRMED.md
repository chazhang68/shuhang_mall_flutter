# 广告配置确认

## ✅ 配置信息已确认

### 应用信息
- **应用名称**: 数航商道
- **应用ID**: Z0062563231
- **包名**: com.shuhangshangdao.app

### 广告位配置

| 广告类型 | 广告位ID | 广告位名称 | 配置文件常量 |
|---------|---------|----------|------------|
| 开屏广告 | J8120762208 | 开屏广告 | `AdConfig.splashAdId` |
| 激励视频 | J3449837410 | 激励视频 | `AdConfig.rewardVideoAdId` |
| 插屏广告 | J6396345907 | 插屏广告 | `AdConfig.interstitialAdId` |
| 信息流 | J2377787779 | 信息流-左右图文（静音） | `AdConfig.feedAdId` |
| 横幅广告 | J2377787779 | 信息流-左右图文（静音） | `AdConfig.bannerAdId` |

### 配置文件位置

1. **广告配置**: `lib/app/config/ad_config.dart`
   ```dart
   static const String appId = 'Z0062563231';
   static const String appName = '数航商道';
   static const String splashAdId = 'J8120762208';
   static const String rewardVideoAdId = 'J3449837410';
   static const String interstitialAdId = 'J6396345907';
   static const String feedAdId = 'J2377787779';
   static const String bannerAdId = 'J2377787779';
   ```

2. **Android 包名**: `android/app/build.gradle.kts`
   ```kotlin
   namespace = "com.shuhangshangdao.app"
   applicationId = "com.shuhangshangdao.app"
   ```

3. **iOS 包名**: `ios/Runner.xcodeproj/project.pbxproj`
   - Bundle Identifier: com.shuhangshangdao.app

## 🎯 配置状态

- ✅ 应用ID正确
- ✅ 包名正确
- ✅ 开屏广告位ID正确
- ✅ 激励视频广告位ID正确
- ✅ 插屏广告位ID正确
- ✅ 信息流广告位ID正确
- ✅ 横幅广告位ID正确

## 🚀 可以直接使用

所有配置都已经正确设置，你现在可以：

1. **运行应用测试**
   ```bash
   flutter run -d <device_id>
   ```

2. **测试开屏广告**
   - 应用启动时会自动展示开屏广告

3. **测试其他广告**
   - 使用 `AdTestPage` 测试激励视频和插屏广告
   - 在页面中使用 `ZJBannerAdWidget` 和 `ZJFeedAdWidget`

## 📱 测试步骤

### 1. 启动应用
```bash
# 清理缓存
flutter clean

# 获取依赖
flutter pub get

# 运行到设备
flutter run -d 662eb639  # 你的小米手机
```

### 2. 观察开屏广告
- 应用启动时应该显示开屏广告
- 查看控制台日志确认广告加载状态

### 3. 测试激励视频
在代码中调用：
```dart
await AdManager.instance.showRewardedVideoAd(
  onShow: () => print('激励视频展示'),
  onReward: () => print('获得奖励'),
  onClose: () => print('激励视频关闭'),
  onError: (error) => print('错误: $error'),
);
```

### 4. 测试插屏广告
在代码中调用：
```dart
await AdManager.instance.showInterstitialAd(
  onShow: () => print('插屏广告展示'),
  onClose: () => print('插屏广告关闭'),
  onError: (error) => print('错误: $error'),
);
```

### 5. 测试信息流广告
在页面中使用：
```dart
ZJFeedAdWidget(
  width: double.infinity,
  height: 280,
  videoSoundEnable: false, // 静音
  onShow: () => print('信息流广告展示'),
  onError: (error) => print('错误: $error'),
)
```

## 🔍 日志关键字

运行时注意查看以下日志：

### 成功日志
```
✅ ZJSDK广告SDK初始化成功（未启动）
✅ ZJSDK Android SDK启动成功
✅ 开屏广告展示
✅ 激励视频展示
✅ 激励视频发奖
✅ 插全屏广告展示
```

### 错误日志
```
❌ ZJSDK广告SDK初始化失败
❌ 开屏广告错误
❌ 激励视频错误
❌ 插全屏广告错误
```

## ⚠️ 注意事项

### 1. 网络要求
- 确保设备联网
- 广告需要从服务器加载

### 2. 真机测试
- 必须在真机上测试
- 模拟器可能无法加载广告

### 3. 调试模式
- 当前 `isDebug = true`，会输出详细日志
- 正式发布前改为 `false`

### 4. 隐私政策
- SDK 已在应用启动时初始化
- 如需等待用户同意隐私政策，可以修改 `main.dart` 中的初始化时机

## 📊 预期行为

### 开屏广告
1. 应用启动
2. 显示 Logo 和应用名称
3. 加载开屏广告（约1-2秒）
4. 展示开屏广告（3-5秒）
5. 用户点击跳过或自动关闭
6. 进入主页

### 激励视频
1. 用户触发激励视频
2. 显示加载提示
3. 播放视频广告（15-30秒）
4. 用户观看完整视频
5. 回调 `onReward`，发放奖励
6. 广告关闭

### 插屏广告
1. 用户触发插屏广告
2. 全屏展示广告
3. 用户点击或关闭
4. 返回应用

### 信息流广告
1. 页面加载
2. 广告位显示加载状态
3. 广告加载成功，展示内容
4. 用户可以滚动浏览
5. 广告自动刷新（如果配置）

## 🐛 问题排查

### 如果广告不显示

1. **检查日志**
   - 查看是否有错误信息
   - 确认 SDK 是否启动成功

2. **检查网络**
   - 确保设备联网
   - 尝试切换网络（WiFi/4G）

3. **检查配置**
   - 确认广告位ID正确
   - 确认包名正确

4. **重新安装**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### 如果出现错误码

| 错误码 | 说明 | 解决方法 |
|-------|------|---------|
| 40000 | 参数错误 | 检查广告位ID和AppId |
| 40009 | 媒体ID不合法 | 检查包名是否匹配 |
| 40010 | 广告位不存在 | 确认广告位ID正确 |
| 40011 | 广告位类型不匹配 | 使用正确的广告类型 |

## ✨ 下一步

1. ✅ 配置已确认，可以直接测试
2. 📱 运行应用到真机
3. 🎯 测试各种广告类型
4. 📊 监控广告展示效果
5. 🚀 准备正式发布

## 📞 需要帮助？

如果遇到问题：
1. 查看控制台日志
2. 参考 `ZJSDK_INTEGRATION_GUIDE.md`
3. 查看 `AD_SDK_CHECKLIST.md`
4. 联系广告平台技术支持

---

**配置确认时间**: 2024-02-03  
**配置状态**: ✅ 已确认，可以使用  
**包名**: com.shuhangshangdao.app  
**应用ID**: Z0062563231
