# 广告高度修复

## 问题

日志显示：
```
📐 ZJFeedAdWidget: width=387.42857142857144, height=0.0, adId=J2377787779
```

广告高度为0，导致广告不显示。

## 原因

之前的代码设置了自适应高度（height=0），但ZJSDK可能需要一个明确的高度值才能正常渲染广告。

## 解决方案

### 1. 首页广告设置明确高度

**文件**: `lib/app/modules/home/home_page.dart`

```dart
Widget _buildAdView() {
  // 计算广告高度：宽度的0.6倍（常见的信息流广告比例）
  final adWidth = MediaQuery.of(context).size.width - 24;
  final adHeight = adWidth * 0.6; // 约230dp
  
  return Container(
    padding: const EdgeInsets.only(top: 12, bottom: 12),
    child: ZJFeedAdWidget(
      width: adWidth,
      height: adHeight, // 设置明确的高度
      videoSoundEnable: false,
      // ...
    ),
  );
}
```

### 2. 广告组件默认高度

**文件**: `lib/widgets/zj_feed_ad_widget.dart`

```dart
@override
Widget build(BuildContext context) {
  // 使用明确的高度，如果传入的height为null或0，使用默认高度
  final adHeight = (widget.height == null || widget.height == 0) 
      ? widget.width * 0.6  // 默认高度为宽度的0.6倍
      : widget.height!;
  
  return ZJNativeExpressView(
    AdConfig.feedAdId,
    width: widget.width,
    height: adHeight, // 明确的高度值
    // ...
  );
}
```

## 高度计算

### 信息流广告常见比例

| 比例 | 说明 | 适用场景 |
|------|------|---------|
| 0.5 | 2:1 | 横向广告 |
| 0.6 | 5:3 | **推荐** - 常见信息流广告 |
| 0.75 | 4:3 | 方形广告 |
| 1.0 | 1:1 | 正方形广告 |

我们选择 **0.6** 作为默认比例，因为：
- 这是信息流广告最常见的比例
- 不会占用太多屏幕空间
- 适合大多数广告素材

### 实际高度示例

假设屏幕宽度为375dp（iPhone标准宽度）：

```
广告宽度 = 375 - 24 = 351dp
广告高度 = 351 * 0.6 = 210.6dp
```

这个高度足够显示：
- 广告图片
- 广告标题
- 广告描述
- 行动按钮

## 修改前后对比

### 修改前
```dart
// ❌ 高度为0，广告不显示
ZJFeedAdWidget(
  width: MediaQuery.of(context).size.width - 24,
  // height未设置，默认为0
)
```

日志输出：
```
📐 ZJFeedAdWidget: width=387.4, height=0.0
```

### 修改后
```dart
// ✅ 明确的高度，广告正常显示
final adWidth = MediaQuery.of(context).size.width - 24;
final adHeight = adWidth * 0.6;

ZJFeedAdWidget(
  width: adWidth,
  height: adHeight,
)
```

日志输出：
```
📐 ZJFeedAdWidget: width=387.4, height=232.4
```

## 测试

运行应用后，查看日志：

```bash
flutter run
```

期望看到：
```
🎯 首页广告：开始构建广告组件
🎯 ZJFeedAdWidget: 开始构建，_hasError=false
📐 ZJFeedAdWidget: width=387.4, height=232.4, adId=J2377787779
📢 ZJFeedAdWidget: 收到广告事件 - action=onAdShow, msg=null
✅ 信息流广告展示成功
```

## 其他广告类型的高度设置

### 横幅广告（Banner）
```dart
ZJBannerAdWidget(
  width: screenWidth,
  height: 50, // 固定高度50dp
)
```

### 开屏广告（Splash）
```dart
// 开屏广告通常全屏显示，由SDK自动处理
ZJAndroid.loadSplashAd(adId)
```

### 激励视频广告（Reward Video）
```dart
// 激励视频广告全屏显示，不需要设置尺寸
ZJAndroid.showRewardVideo()
```

## 注意事项

### 1. 响应式设计

广告高度应该根据屏幕宽度动态计算：

```dart
// ✅ 好的做法
final adHeight = adWidth * 0.6;

// ❌ 不好的做法
final adHeight = 200; // 固定高度，不适配不同屏幕
```

### 2. 最小/最大高度

可以设置高度限制，避免广告过大或过小：

```dart
final adHeight = (adWidth * 0.6).clamp(150.0, 300.0);
```

### 3. 不同设备适配

```dart
// 平板设备可能需要不同的比例
final isTablet = MediaQuery.of(context).size.width > 600;
final adHeight = isTablet 
    ? adWidth * 0.5  // 平板使用更扁平的比例
    : adWidth * 0.6; // 手机使用标准比例
```

## 总结

修复了广告高度为0的问题：

1. ✅ 首页广告设置明确高度（宽度的0.6倍）
2. ✅ 广告组件添加默认高度逻辑
3. ✅ 使用响应式设计，适配不同屏幕

现在广告应该能正常显示了！查看日志确认高度不再是0。
