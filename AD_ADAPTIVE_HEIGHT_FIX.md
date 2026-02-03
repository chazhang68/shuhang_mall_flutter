# 首页广告自适应高度优化

## 问题描述
首页信息流广告需要根据实际加载的广告内容自适应高度，而不是固定高度。

## 解决方案

### 方案1: 广告自适应高度（主方案）

#### 修改广告组件
在 `ZJFeedAdWidget` 中，将 `height` 参数改为可选：

```dart
class ZJFeedAdWidget extends StatefulWidget {
  final double width;
  final double? height; // 改为可选，null时自适应
  
  const ZJFeedAdWidget({
    super.key,
    required this.width,
    this.height, // 可选高度，不传则自适应
    // ...
  });
}
```

#### 使用自适应高度
```dart
// 使用自适应高度：传0或不传height时，广告会根据内容自适应
final adHeight = widget.height ?? 0;

return ZJNativeExpressView(
  AdConfig.feedAdId,
  width: widget.width,
  height: adHeight, // 0表示自适应高度
  videoSoundEnable: widget.videoSoundEnable,
  nativeExpressListener: _handleAdEvent,
);
```

#### 首页调用
```dart
Widget _buildAdView() {
  return Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 12),
    child: ZJFeedAdWidget(
      width: MediaQuery.of(context).size.width - 24,
      // 不传height参数，使用自适应高度
      videoSoundEnable: false,
      onShow: () => debugPrint('信息流广告展示'),
      onClose: () {
        setState(() {
          _showAd = false; // 广告关闭后隐藏
        });
      },
      onError: (error) {
        setState(() {
          _showAd = false; // 广告加载失败也隐藏
        });
      },
    ),
  );
}
```

### 方案2: 添加间距（备选方案）

如果自适应高度不生效，通过添加间距确保布局合理：

```dart
// 搜索栏
SliverToBoxAdapter(child: _buildSearchBar(themeColor)),

// 广告位
if (_showAd)
  SliverToBoxAdapter(child: _buildAdView())
else
  // 广告关闭后添加间距，避免商品列表紧贴搜索栏
  const SliverToBoxAdapter(
    child: SizedBox(height: 12),
  ),

// 商品列表
```

## 实现效果

### 广告显示时
```
┌─────────────────┐
│   搜索栏        │
├─────────────────┤
│   (12px间距)    │
├─────────────────┤
│                 │
│   信息流广告    │ ← 自适应高度
│   (内容高度)    │
│                 │
├─────────────────┤
│   (12px间距)    │
├─────────────────┤
│   商品列表      │
└─────────────────┘
```

### 广告关闭后
```
┌─────────────────┐
│   搜索栏        │
├─────────────────┤
│   (12px间距)    │ ← 保持间距
├─────────────────┤
│   商品列表      │
└─────────────────┘
```

## 优势

### 方案1优势（自适应高度）
1. ✅ 广告高度根据内容自动调整
2. ✅ 不同广告样式都能完美展示
3. ✅ 节省空间，提升用户体验
4. ✅ 符合ZJSDK的设计理念

### 方案2优势（固定间距）
1. ✅ 简单可靠，兼容性好
2. ✅ 确保布局不会出现问题
3. ✅ 广告关闭后不留空白
4. ✅ 视觉效果统一

## 技术细节

### ZJSDK 自适应高度机制
根据 ZJSDK 文档，`ZJNativeExpressView` 支持自适应高度：
- 当 `height` 参数为 `0` 时，广告会根据内容自动调整高度
- 广告加载完成后，会自动计算并应用实际高度
- 不需要手动监听高度变化

### 边距设计
- 广告上下各 12px 边距，与页面整体风格一致
- 广告关闭后保持 12px 间距，避免商品列表紧贴搜索栏
- 使用 `Padding` 包裹广告组件，确保边距生效

## 测试要点

### 自适应高度测试
- [ ] 广告加载成功 - 高度自动调整
- [ ] 不同广告样式 - 高度不同但都正常显示
- [ ] 广告关闭 - 空间自动释放

### 间距测试
- [ ] 广告显示时 - 上下有12px间距
- [ ] 广告关闭后 - 商品列表与搜索栏有12px间距
- [ ] 广告加载失败 - 商品列表与搜索栏有12px间距

### 布局测试
- [ ] 滚动流畅 - 无卡顿
- [ ] 刷新正常 - 广告重新加载
- [ ] 切换页面 - 状态保持正确

## 兼容性

### 支持的广告类型
- ✅ 图片广告
- ✅ 视频广告
- ✅ 图文混合广告
- ✅ 左右图文广告

### 支持的场景
- ✅ 首次加载
- ✅ 下拉刷新
- ✅ 广告关闭
- ✅ 广告加载失败

## 总结

通过**自适应高度 + 固定间距**的组合方案，确保：
1. 广告显示时高度自适应，完美展示内容
2. 广告关闭后保持合理间距，布局不会塌陷
3. 用户体验流畅，视觉效果统一

两种方案互为补充，确保在任何情况下都能提供良好的用户体验！
