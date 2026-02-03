# ZJSDK 广告集成检查清单

## ✅ 已完成的工作

### 1. 依赖配置
- [x] 删除旧的 `flutter_unionad` 依赖
- [x] 添加 `zjsdk_android: ^2.5.61`
- [x] 添加 `zjsdk_flutter: ^0.2.5`
- [x] 运行 `flutter pub get`

### 2. 配置文件
- [x] 更新 `lib/app/config/ad_config.dart`
  - [x] 配置 AppId
  - [x] 配置各广告位ID
  - [x] 配置调试模式

### 3. 核心代码
- [x] 重写 `lib/app/services/ad_manager.dart`
  - [x] 实现 `initWithoutStart()` 方法
  - [x] 实现 `start()` 方法
  - [x] 实现激励视频广告
  - [x] 实现插全屏广告
  - [x] Android 和 iOS 平台适配

### 4. 广告组件
- [x] 创建 `lib/widgets/zj_banner_ad_widget.dart`
- [x] 创建 `lib/widgets/zj_feed_ad_widget.dart`
- [x] 删除旧的 `lib/widgets/feed_ad_widget.dart`

### 5. 页面更新
- [x] 更新 `lib/main.dart` 初始化逻辑
- [x] 重写 `lib/app/modules/splash/splash_page.dart`
- [x] 创建 `lib/app/modules/test/ad_test_page.dart`

### 6. 文档
- [x] 创建 `ZJSDK_INTEGRATION_GUIDE.md`
- [x] 创建 `AD_SDK_MIGRATION_SUMMARY.md`
- [x] 创建 `AD_SDK_CHECKLIST.md`

## 📋 需要手动完成的工作

### 1. Android 配置（如果使用测试ID）
- [ ] 修改 `android/app/build.gradle.kts`
  ```kotlin
  android {
      defaultConfig {
          applicationId = "com.zj.daylottery.demo"  // 改为测试包名
      }
  }
  ```

### 2. iOS 配置（如果需要）
- [ ] 检查 `ios/Runner/Info.plist` 权限配置
- [ ] 确保 ATT 权限描述已添加

### 3. 测试
- [ ] 在真机上运行应用
- [ ] 测试开屏广告
- [ ] 测试激励视频广告
- [ ] 测试插全屏广告
- [ ] 测试横幅广告组件
- [ ] 测试信息流广告组件

### 4. 正式上线前
- [ ] 申请正式广告位ID
- [ ] 替换 `AdConfig` 中的测试ID
- [ ] 修改包名为正式包名
- [ ] 设置 `isDebug = false`
- [ ] 测试正式环境广告

## 🔍 验证步骤

### 步骤 1: 编译检查
```bash
flutter clean
flutter pub get
flutter build apk --debug  # Android
flutter build ios --debug  # iOS
```

### 步骤 2: 运行应用
```bash
flutter run -d <device_id>
```

### 步骤 3: 测试广告
1. 打开应用，查看开屏广告是否展示
2. 进入广告测试页面（如果已添加路由）
3. 依次测试：
   - SDK 初始化
   - SDK 启动
   - 激励视频广告
   - 插全屏广告

### 步骤 4: 检查日志
查看控制台输出，确认：
- SDK 初始化成功
- SDK 启动成功
- 广告请求成功
- 广告展示成功

## ⚠️ 常见问题排查

### 问题 1: 编译错误
**症状：** 找不到 zjsdk 相关的类

**解决：**
```bash
flutter clean
flutter pub get
```

### 问题 2: 广告加载失败（错误码 40009）
**症状：** 媒体ID不合法

**解决：**
1. 检查广告位ID是否正确
2. 检查包名是否与广告位绑定的包名一致
3. 如果使用测试ID，包名必须是 `com.zj.daylottery.demo`

### 问题 3: SDK 初始化失败
**症状：** SDK 启动返回 false

**解决：**
1. 检查网络连接
2. 检查 AppId 是否正确
3. 查看日志输出的详细错误信息

### 问题 4: 开屏广告不显示
**症状：** 启动页空白或直接跳转

**解决：**
1. 确保 SDK 已启动（调用了 `start()` 方法）
2. 检查广告位ID是否正确
3. 查看日志中的错误信息

### 问题 5: iOS 编译错误
**症状：** iOS 平台编译失败

**解决：**
```bash
cd ios
pod install
cd ..
flutter clean
flutter run
```

## 📱 测试设备要求

### Android
- Android 5.0 (API 21) 及以上
- 真机测试（模拟器可能无法加载广告）
- 网络连接正常

### iOS
- iOS 10.0 及以上
- 真机测试（模拟器可能无法加载广告）
- 网络连接正常

## 📊 性能监控

### 需要监控的指标
- [ ] SDK 初始化时间
- [ ] 广告加载时间
- [ ] 广告展示成功率
- [ ] 广告点击率
- [ ] 应用启动时间（开屏广告影响）

### 监控方法
1. 在 `AdManager` 中添加时间戳记录
2. 使用 Firebase Analytics 或其他分析工具
3. 定期查看广告平台后台数据

## 🎯 优化建议

### 1. 预加载策略
```dart
// 在合适的时机预加载激励视频
await AdManager.instance.preloadRewardedVideoAd();
```

### 2. 错误处理
```dart
// 所有广告调用都应该有错误处理
await AdManager.instance.showRewardedVideoAd(
  onError: (error) {
    // 记录错误日志
    LogService.e('广告错误: $error');
    // 不影响主要功能
  },
);
```

### 3. 用户体验
- 不要在关键操作时展示广告
- 控制广告展示频率
- 提供跳过选项（如果可能）
- 广告加载失败不应阻塞功能

### 4. 收益优化
- 在高价值场景展示广告
- 合理设置激励视频奖励
- 监控广告填充率
- A/B 测试不同广告位置

## 📞 技术支持

如遇到问题，可以：
1. 查看 [ZJSDK Android 文档](https://pub.dev/packages/zjsdk_android)
2. 查看 [ZJSDK iOS 文档](https://pub.dev/packages/zjsdk_flutter)
3. 查看 [详细集成指南](./ZJSDK_INTEGRATION_GUIDE.md)
4. 联系广告平台技术支持

## ✨ 下一步计划

- [ ] 完成所有测试
- [ ] 申请正式广告位
- [ ] 优化广告展示策略
- [ ] 监控广告收益
- [ ] 收集用户反馈
- [ ] 持续优化用户体验
