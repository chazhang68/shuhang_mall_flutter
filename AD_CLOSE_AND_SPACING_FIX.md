# 广告关闭和间距修复

## 问题

1. **广告关闭后留空白**：用户关闭广告后，广告位置还占用空间，显示空白
2. **左右间距不对**：广告没有正确的左右间距

## 解决方案

### 1. 监听广告关闭事件

**文件**: `lib/app/modules/home/home_page.dart`

添加 `_showAd` 状态变量：
```dart
bool _showAd = true; // 控制广告显示，关闭后隐藏
```

监听广告关闭和错误事件：
```dart
ZJFeedAdWidget(
  onClose: () {
    debugPrint('❌ 首页广告：信息流广告关闭');
    // 广告关闭后隐藏，不占用空间
    setState(() {
      _showAd = false;
    });
  },
  onError: (error) {
    debugPrint('⚠️ 首页广告：信息流广告错误 - $error');
    // 广告加载失败也隐藏
    setState(() {
      _showAd = false;
    });
  },
)
```

### 2. 条件渲染广告

只在 `_showAd` 为 `true` 时显示广告：
```dart
// 广告位 - 对应uni-app的APP-PLUS广告组件
// 广告关闭后隐藏，不占用空间
if (_showAd)
  SliverToBoxAdapter(child: _buildAdView()),
```

### 3. 修复左右间距

使用 `margin` 而不是在宽度计算中减去间距：
```dart
Widget _buildAdView() {
  // 计算广告宽度：屏幕宽度 - 左右间距(12*2=24)
  final adWidth = MediaQuery.of(context).size.width - 24;
  final adHeight = adWidth * 0.6;

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 12), // 左右间距12dp
    padding: const EdgeInsets.only(top: 12, bottom: 12), // 上下间距
    child: ZJFeedAdWidget(
      width: adWidth,
      height: adHeight,
      // ...
    ),
  );
}
```

## 修改前后对比

### 修改前

**问题1：广告关闭后留空白**
```dart
// ❌ 广告关闭后仍然占用空间
SliverToBoxAdapter(child: _buildAdView()),

onClose: () {
  // 没有处理关闭事件
},
```

**问题2：间距不对**
```dart
// ❌ 没有左右间距
Container(
  padding: const EdgeInsets.only(top: 12, bottom: 12),
  child: ZJFeedAdWidget(
    width: MediaQuery.of(context).size.width - 24,
    // ...
  ),
)
```

### 修改后

**解决1：广告关闭后隐藏**
```dart
// ✅ 广告关闭后不占用空间
if (_showAd)
  SliverToBoxAdapter(child: _buildAdView()),

onClose: () {
  setState(() {
    _showAd = false; // 隐藏广告
  });
},
```

**解决2：正确的间距**
```dart
// ✅ 左右各12dp间距
Container(
  margin: const EdgeInsets.symmetric(horizontal: 12), // 左右间距
  padding: const EdgeInsets.only(top: 12, bottom: 12), // 上下间距
  child: ZJFeedAdWidget(
    width: adWidth, // 已经减去了左右间距
    // ...
  ),
)
```

## 间距说明

### 布局结构

```
屏幕边缘
│
├─ 12dp (左间距)
│
├─ 广告内容区域
│  ├─ 12dp (上间距)
│  ├─ 广告 (width: 屏幕宽度-24, height: width*0.6)
│  └─ 12dp (下间距)
│
├─ 12dp (右间距)
│
屏幕边缘
```

### 间距计算

假设屏幕宽度为 411dp：

```
广告宽度 = 411 - 24 = 387dp
  ├─ 左间距: 12dp
  ├─ 内容: 387dp
  └─ 右间距: 12dp

广告高度 = 387 * 0.6 = 232.2dp
```

## 用户体验

### 场景1：广告正常显示

```
┌─────────────────────┐
│     轮播图          │
├─────────────────────┤
│     公告栏          │
├─────────────────────┤
│  ┌───────────────┐  │ ← 左右各12dp间距
│  │   广告内容    │  │
│  └───────────────┘  │
├─────────────────────┤
│     搜索栏          │
├─────────────────────┤
│     商品列表        │
└─────────────────────┘
```

### 场景2：用户关闭广告

```
┌─────────────────────┐
│     轮播图          │
├─────────────────────┤
│     公告栏          │
├─────────────────────┤
│  (广告已关闭，不占空间) │ ← 不留空白
├─────────────────────┤
│     搜索栏          │
├─────────────────────┤
│     商品列表        │
└─────────────────────┘
```

### 场景3：广告加载失败

```
┌─────────────────────┐
│     轮播图          │
├─────────────────────┤
│     公告栏          │
├─────────────────────┤
│  (广告加载失败，不占空间) │ ← 不留空白
├─────────────────────┤
│     搜索栏          │
├─────────────────────┤
│     商品列表        │
└─────────────────────┘
```

## 测试

### 1. 测试广告显示

运行应用，查看首页：
- ✅ 广告左右各有12dp间距
- ✅ 广告上下各有12dp间距
- ✅ 广告宽度正确（屏幕宽度-24）

### 2. 测试广告关闭

点击广告的关闭按钮：
- ✅ 广告消失
- ✅ 不留空白
- ✅ 搜索栏紧跟公告栏

### 3. 测试广告加载失败

如果广告加载失败：
- ✅ 不显示广告
- ✅ 不留空白
- ✅ 页面布局正常

## 日志输出

### 广告正常显示
```
🎯 首页广告：开始构建广告组件
📐 ZJFeedAdWidget: width=387.0, height=232.2
✅ 首页广告：信息流广告展示成功
```

### 用户关闭广告
```
❌ 首页广告：信息流广告关闭
(广告组件被移除，不再占用空间)
```

### 广告加载失败
```
⚠️ 首页广告：信息流广告错误 - 广告位不存在
(广告组件被移除，不再占用空间)
```

## 注意事项

### 1. 刷新页面后广告重新显示

如果用户下拉刷新页面，广告会重新显示：

```dart
Future<void> _onRefresh() async {
  _page = 1;
  _loadEnd = false;
  _hotList.clear();
  setState(() {
    _showAd = true; // 重新显示广告
  });
  await _loadIndexData();
}
```

### 2. 与uni-app保持一致

uni-app的广告也是关闭后不占用空间：

```vue
<!-- uni-app -->
<view class="ad-view" v-if="showAd">
  <ad @close="showAd = false"></ad>
</view>
```

### 3. 响应式间距

如果需要在不同屏幕上使用不同的间距：

```dart
// 平板设备使用更大的间距
final isTablet = MediaQuery.of(context).size.width > 600;
final horizontalMargin = isTablet ? 24.0 : 12.0;

Container(
  margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
  // ...
)
```

## 总结

修复了两个问题：

1. ✅ **广告关闭后隐藏** - 监听 `onClose` 和 `onError` 事件，设置 `_showAd = false`
2. ✅ **正确的左右间距** - 使用 `margin: EdgeInsets.symmetric(horizontal: 12)`

现在广告关闭后不会留空白，左右间距也正确了！
