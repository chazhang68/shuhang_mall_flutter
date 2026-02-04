# 广告调试指南

## 问题描述

1. **首页信息流广告不显示**
2. **开屏广告加载时黑屏**

## 重要说明

### uni-app vs Flutter 广告平台差异

- **uni-app**: 使用 DCloud 广告联盟（`<ad adpid="1300417835">`）
- **Flutter**: 使用 ZJSDK 广告平台（AppId: `Z0062563231`）

这是两个**完全不同的广告平台**，广告ID和SDK都不同。

## 已完成的优化

### 1. 首页信息流广告优化

**文件**: `lib/widgets/zj_feed_ad_widget.dart`

**修改内容**:
- ✅ 添加详细的调试日志（使用emoji标记）
- ✅ 添加异常捕获，防止广告组件创建失败导致崩溃
- ✅ 记录所有广告事件（onAdShow, onAdClick, onAdClose, onAdError等）

**日志标记**:
- 🎯 = 开始构建
- ✅ = 成功
- ❌ = 关闭/失败
- ⚠️ = 错误
- 📐 = 尺寸信息
- 📢 = 事件回调
- ℹ️ = 其他信息

### 2. 开屏广告黑屏优化

**文件**: `lib/app/modules/splash/splash_page.dart`

**修改内容**:
- ✅ 添加 `_adLoading` 状态，仅在广告加载时显示进度条
- ✅ 广告展示后隐藏进度条，避免遮挡广告
- ✅ 超时时间调整为3秒（从2秒增加）
- ✅ 添加详细的广告事件日志
- ✅ 白色背景始终显示，避免黑屏

**日志标记**:
- 🚀 = 开始加载
- ✅ = 广告展示
- ❌ = 广告关闭
- ⚠️ = 广告错误
- 👆 = 广告点击
- ⏰ = 超时
- 📢 = 事件回调
- ℹ️ = 其他事件

### 3. 广告SDK启动优化

**文件**: `lib/app/services/ad_manager.dart`

**修改内容**:
- ✅ 添加详细的初始化和启动日志
- ✅ 启动等待时间从500ms增加到800ms，确保SDK完全启动
- ✅ 添加重复启动检查，避免多次初始化
- ✅ 记录SDK状态（initialized, started）

**文件**: `lib/main.dart`

**修改内容**:
- ✅ 在应用启动时提前启动广告SDK
- ✅ 添加SDK状态日志

## 调试步骤

### 1. 查看启动日志

运行应用后，查看控制台日志：

```bash
flutter run
```

**期望看到的日志**:

```
🔧 开始初始化ZJSDK广告SDK...
📱 AppId: Z0062563231
🐛 Debug模式: true
✅ ZJSDK广告SDK初始化成功（未启动）
🚀 启动ZJSDK广告SDK...
📢 ZJSDK启动回调: action=startSuccess, msg=...
✅ ZJSDK SDK启动成功
⏰ ZJSDK启动等待完成，当前状态: true
🎯 广告SDK状态: initialized=true, started=true
```

### 2. 查看开屏广告日志

**期望看到的日志**:

```
🚀 开屏页面：广告SDK已启动，立即加载开屏广告
📢 开屏广告事件: action=onAdShow, msg=...
✅ 开屏广告展示
```

**如果广告加载失败**:

```
📢 开屏广告事件: action=onAdError, msg=...
⚠️ 开屏广告错误: [错误信息]
```

### 3. 查看首页信息流广告日志

**期望看到的日志**:

```
🎯 首页广告：Visibility.visible = true
🎯 首页广告：开始构建广告组件，_showAd=true
🎯 ZJFeedAdWidget: 开始构建，_hasError=false
📐 ZJFeedAdWidget: width=351.0, height=0, adId=J2377787779
📢 ZJFeedAdWidget: 收到广告事件 - action=onAdShow, msg=...
✅ 信息流广告展示成功
```

**如果广告加载失败**:

```
📢 ZJFeedAdWidget: 收到广告事件 - action=onAdError, msg=...
⚠️ 信息流广告错误: [错误信息]
❌ ZJFeedAdWidget: 广告加载失败，返回空容器
```

## 可能的问题和解决方案

### 问题1: SDK启动失败

**症状**: 看到 `⚠️ ZJSDK SDK启动失败` 日志

**可能原因**:
1. AppId 不正确
2. 网络连接问题
3. 设备权限不足

**解决方案**:
1. 检查 `lib/app/config/ad_config.dart` 中的 `appId`
2. 确保设备有网络连接
3. 检查应用权限（网络、存储等）

### 问题2: 广告ID不正确

**症状**: 看到 `⚠️ 信息流广告错误: 广告位ID不存在` 或类似错误

**可能原因**:
- 广告位ID配置错误

**解决方案**:
检查 `lib/app/config/ad_config.dart` 中的广告位ID：

```dart
/// 开屏广告位ID
static const String splashAdId = 'J8120762208';

/// 激励视频广告位ID
static const String rewardVideoAdId = 'J3449837410';

/// 信息流广告位ID
static const String feedAdId = 'J2377787779';
```

### 问题3: 广告填充率低

**症状**: 广告偶尔显示，但大部分时间不显示

**可能原因**:
- 广告平台没有足够的广告填充
- 测试环境广告较少

**解决方案**:
1. 确认 `isDebug = true` 以获取测试广告
2. 联系ZJSDK客服确认广告位配置
3. 检查广告平台后台的填充率数据

### 问题4: 开屏广告黑屏

**症状**: 启动时看到黑屏，然后才显示内容

**可能原因**:
- 广告加载时间过长
- SDK启动延迟

**解决方案**:
1. 已优化：白色背景始终显示
2. 已优化：仅在广告加载时显示进度条
3. 已优化：超时时间设为3秒
4. 如果仍有问题，可以考虑：
   - 增加超时时间
   - 预加载广告
   - 跳过开屏广告选项

## 广告配置文件

**文件**: `lib/app/config/ad_config.dart`

```dart
class AdConfig {
  /// ZJSDK 应用ID
  static const String appId = 'Z0062563231';

  /// 开屏广告位ID
  static const String splashAdId = 'J8120762208';

  /// 激励视频广告位ID
  static const String rewardVideoAdId = 'J3449837410';

  /// 信息流广告位ID
  static const String feedAdId = 'J2377787779';

  /// 是否为测试模式
  static const bool isDebug = true;
}
```

## 测试清单

- [ ] 应用启动时查看SDK初始化日志
- [ ] 开屏广告是否正常显示
- [ ] 开屏广告是否有黑屏现象
- [ ] 首页信息流广告是否显示
- [ ] 查看广告错误日志（如果有）
- [ ] 测试广告点击和关闭功能
- [ ] 测试激励视频广告（农场浇水功能）

## 下一步

如果广告仍然不显示，请提供以下信息：

1. **完整的启动日志**（从应用启动到首页加载完成）
2. **广告错误信息**（如果有）
3. **设备信息**（Android版本、设备型号）
4. **网络状态**（是否连接网络）

这些信息将帮助我们进一步诊断问题。
