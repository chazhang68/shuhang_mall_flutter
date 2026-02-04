# 农场页面优化总结

## 修改日期
2024年（根据上下文推断）

## 完成的优化项目

### 1. 田地显示修复 ✅
**问题**：登录成功后，API 返回 8 个地块数据，但页面不显示田地
**原因**：代码中 `if (plants.isEmpty) return const SizedBox.shrink()` 导致所有空田地被隐藏
**修复**：删除该条件判断，即使没有植物也显示田地背景
**文件**：`lib/app/modules/home/task_page.dart`

### 2. 右侧指示牌显示修复 ✅
**问题**：田地右侧的指示牌（right_icon0.png）不显示
**原因**：代码中 `if (rightIcon != 0)` 条件判断，但 API 返回的所有地块 `right: 0`
**修复**：删除条件判断，始终显示指示牌
**位置**：`right: fieldWidth * -0.04, top: fieldWidth * 0.04`
**宽度**：`fieldWidth * 0.24`

### 3. 实名认证跳转修复 ✅
**问题**：点击"浇水"按钮后提示"请先实名认证哦"，但没有跳转
**原因**：使用了 uni-app 的路径 `/pages/sign/sign`，而不是 Flutter 路由
**修复**：改为 `Get.toNamed(AppRoutes.realName)`

### 4. 田地尺寸和间距适配 ✅
**目标**：将所有尺寸从固定像素改为响应式布局，与 uni-app 的 rpx 比例一致
**实现**：
- 田块宽度：`screenWidth * 0.67`（500rpx / 750rpx）
- 指示牌宽度：`fieldWidth * 0.24`（120rpx / 500rpx）
- 植物宽度：`fieldWidth * 0.16`（80rpx / 500rpx）
- 进度条宽度：`fieldWidth * 0.2`（100rpx / 500rpx）
- 进度条高度：`fieldWidth * 0.024`（12rpx / 500rpx）
- 文字大小：放大到 `fieldWidth * 0.02` 和 `fieldWidth * 0.032`

### 5. 田地间距调整 ✅
**初始值**：`screenWidth * 0.02`（约 15rpx）
**最终值**：`screenWidth * 0.02 + 10`（增加 10px）

### 6. 农作物位置修复 ✅
**问题**：植物没有在田地位置上显示
**原因**：使用了 `Positioned.fill`，但田块高度是自适应的
**修复**：
- 使用固定尺寸的 `SizedBox(width: fieldWidth, height: fieldWidth)`
- 使用 `FractionalTranslation(translation: Offset(-0.5, -0.85))` 实现精确定位

### 7. 播种弹框样式修复 ✅
**问题**：弹框样式与 uni-app 不一致，底部被截断
**修复**：
- 使用 `popup_bg.png` 背景图
- 关闭按钮改为圆形白色背景，右上角显示
- 内容区域使用固定高度：`height: popupWidth * 1.0`
- 卡片比例调整为 `childAspectRatio: 0.8`

### 8. SWP 按钮修复 ✅
**问题**：按钮显示 "SWP"，应该显示"消费券"
**修复**：
- 图片从 `swp.png` 改为 `xfq.png`
- 文字标签从 `'SWP'` 改为 `'消费券'`

### 9. 积分和消费券跳转优化 ✅
**问题**：跳转后底部导航栏不显示
**修复**：
- 先使用 `Get.offAllNamed(AppRoutes.main, arguments: {'tab': 4})` 切换到"我的" tab
- 延迟 200ms 后再跳转到 RyzPage
- 创建了可复用的底部导航栏组件 `MainBottomNavigationBar`

### 10. 首页广告显示修复 ✅
**问题**：首页信息流广告不显示
**原因**：`Visibility(visible: !_showAd, ...)` 逻辑反了
**修复**：改为 `visible: _showAd`
**位置**：显示在公告栏和搜索栏之间

### 11. 开屏广告黑屏优化 ✅
**问题**：开屏广告加载时会黑屏一会
**优化**：
- 移除启动延迟，立即加载广告
- 缩短超时时间：从 5秒 降到 2秒
- 添加加载动画：圆形进度条
- 广告加载失败时立即跳转，不等待

## 技术要点

### 响应式布局
所有尺寸都基于屏幕宽度计算，确保在不同设备上显示一致：
```dart
final screenWidth = MediaQuery.of(context).size.width;
final fieldWidth = screenWidth * 0.67; // 田块宽度
```

### 植物定位
使用 `FractionalTranslation` 实现与 uni-app 完全一致的定位：
```dart
FractionalTranslation(
  translation: const Offset(-0.5, -0.85), // 水平居中，向上偏移85%
  child: Column(...),
)
```

### 广告集成
- 开屏广告：使用 `ZJAndroid.loadSplashAd`
- 信息流广告：使用 `ZJFeedAdWidget`
- 激励视频广告：使用 `AdManager.instance.showRewardedVideoAd`

## 文件修改清单

1. `lib/app/modules/home/task_page.dart` - 农场页面主文件
2. `lib/app/modules/home/home_page.dart` - 首页广告修复
3. `lib/app/modules/splash/splash_page.dart` - 开屏广告优化
4. `lib/app/modules/user/ryz_page.dart` - 添加底部导航栏
5. `lib/widgets/main_bottom_navigation_bar.dart` - 新建可复用导航栏组件

## 待验证项目

- [ ] 首页信息流广告是否正常显示（需要查看日志）
- [ ] 开屏广告黑屏时间是否缩短到可接受范围
- [ ] 所有田地间距是否一致
- [ ] 植物位置是否准确显示在田地上
- [ ] 积分和消费券页面是否显示底部导航栏

## 注意事项

1. **Token 请求头**：使用 `Authori-zation`（带连字符），不是标准的 `Authorization`
2. **路由跳转**：使用 Flutter 的 `AppRoutes` 常量，不要使用 uni-app 的路径格式
3. **空田地显示**：即使 plants 为空数组，也要显示田地背景和指示牌
4. **广告调试**：查看日志中的 emoji 标记（🎯 ✅ ❌ ⚠️）来排查问题
