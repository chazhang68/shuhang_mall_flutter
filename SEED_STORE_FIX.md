# 种子商店修复说明

## 问题描述
种子商店弹窗的布局和样式与uni-app版本不一致。

## 参考实现
参考了 `shuhang_mall_uniapp/pages/task/task.vue` 中的种子商店弹窗实现。

## 主要修改

### 1. 弹窗布局优化
- **内容区域定位**：参考uni-app的定位方式
  - top: 27% → `popupWidth * 0.38`
  - left/right: 5% → `popupWidth * 0.05`
  - 固定高度：`popupWidth * 0.9`，确保内容可滚动
  
- **背景图适配**：使用 `BoxFit.fitWidth` 确保背景图正确显示

### 2. 种子卡片优化
简化了 `_buildSeedItem` 方法，使用固定尺寸而非动态计算：

#### 布局结构（与uni-app一致）
```
种子名称 (13px, 粗体)
    ↓
种子图片 (50x50)
    ↓
种子信息 (11px)
- 预计获得XX积分
- 活跃度：XX
- 种子数量：XX/XX个
    ↓
购买按钮 (32px高, 绿色渐变)
```

#### 样式细节
- **卡片背景**：渐变色 `#FFFEF8` → `#FFF9E6`
- **圆角**：12px
- **内边距**：水平8px，垂直12px
- **间距**：各元素之间使用 `SizedBox(height: 6)` 分隔
- **购买按钮**：
  - 高度：32px
  - 圆角：16px
  - 渐变：`#7DD87D` → `#4EB84E`
  - 阴影：绿色半透明

### 3. 网格布局
```dart
SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,           // 2列
  childAspectRatio: 0.7,       // 宽高比
  crossAxisSpacing: 8,         // 列间距
  mainAxisSpacing: 8,          // 行间距
)
```

## 对比uni-app实现

### uni-app样式
```css
.seed-item {
  background: linear-gradient(180deg, #fffef8 0%, #fff9e6 100%);
  border-radius: 16rpx;
  padding: 16rpx 12rpx;
}

.seed-name {
  font-size: 24rpx;
  font-weight: bold;
}

.seed-icon {
  width: 80rpx;
  height: 80rpx;
}

.seed-detail {
  font-size: 20rpx;
  color: #666;
}

.seed-buy-btn {
  height: 48rpx;
  background: linear-gradient(180deg, #7dd87d 0%, #4eb84e 100%);
  border-radius: 24rpx;
}
```

### Flutter实现
完全对应uni-app的样式，使用固定像素值确保一致性。

## 测试要点
1. ✅ 弹窗正确居中显示
2. ✅ 背景图正确加载和显示
3. ✅ 种子列表2列网格布局
4. ✅ 种子卡片内容完整显示（名称、图片、信息、按钮）
5. ✅ 列表可以正常滚动
6. ✅ 点击购买按钮弹出密码输入框
7. ✅ 点击关闭按钮或遮罩层关闭弹窗

## 文件修改
- `lib/app/modules/home/task_page.dart`
  - `_buildShopPopup()` - 优化弹窗布局
  - `_buildSeedItem()` - 简化种子卡片实现
