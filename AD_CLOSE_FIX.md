# 广告关闭后空白问题修复

## 问题描述
首页的信息流广告关闭后，广告位置留下空白区域，商品列表没有自动上移到搜索栏下面。

## 解决方案

### 1. 添加广告显示状态控制
在 `home_page.dart` 中添加 `_showAd` 状态变量：
```dart
bool _showAd = true; // 控制广告显示
```

### 2. 条件渲染广告
使用 `if` 条件来控制广告是否渲染：
```dart
// 广告位 - 对应uni-app的APP-PLUS广告组件
if (_showAd)
  SliverToBoxAdapter(child: _buildAdView()),
```

### 3. 监听广告关闭和错误事件
在广告关闭或加载失败时，隐藏广告区域：
```dart
ZJFeedAdWidget(
  width: MediaQuery.of(context).size.width - 24,
  height: 280,
  videoSoundEnable: false,
  onShow: () => debugPrint('信息流广告展示'),
  onClose: () {
    debugPrint('信息流广告关闭');
    setState(() {
      _showAd = false; // 广告关闭后隐藏
    });
  },
  onError: (error) {
    debugPrint('信息流广告错误: $error');
    setState(() {
      _showAd = false; // 广告加载失败也隐藏
    });
  },
)
```

### 4. 优化广告组件
修改 `ZJFeedAdWidget`，在加载失败时返回空容器：
```dart
if (_hasError) {
  return const SizedBox.shrink(); // 不占用空间
}
```

## 效果
- ✅ 广告正常展示时占用空间
- ✅ 广告关闭后自动隐藏，商品列表上移
- ✅ 广告加载失败时不显示，不占用空间
- ✅ 页面布局流畅，无空白区域

## 修改的文件
- `lib/app/modules/home/home_page.dart` - 添加状态控制和事件监听
- `lib/widgets/zj_feed_ad_widget.dart` - 优化失败时的显示

## 测试建议
1. 正常加载广告 - 应该显示在搜索栏下方
2. 关闭广告 - 商品列表应该自动上移
3. 广告加载失败 - 不应该有空白区域
4. 下拉刷新 - 广告应该重新加载（如果需要）
