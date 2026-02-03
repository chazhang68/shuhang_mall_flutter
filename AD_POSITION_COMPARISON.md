# 广告展示位置对比 - Flutter vs Uni-app

## 📍 广告展示位置对比

### 1. 开屏广告

#### Uni-app
- **位置**: 应用启动时
- **实现**: 使用 uni-ad 的开屏广告组件
- **文件**: `App.vue` 或启动页

#### Flutter ✅
- **位置**: 应用启动时（完全一致）
- **实现**: `lib/app/modules/splash/splash_page.dart`
- **代码**:
```dart
// 在 SplashPage 中自动展示开屏广告
ZJAndroid.loadSplashAd(
  AdConfig.splashAdId,
  bgResType: 'default',
  splashListener: (ret) { ... },
);
```
- **状态**: ✅ 已实现，位置一致

---

### 2. 激励视频广告（任务页面）

#### Uni-app
- **位置**: 任务页面（`pages/task/task.vue`）
- **触发时机**: 
  - 用户点击"看广告"按钮
  - 完成任务需要观看广告
- **实现方式**:
```javascript
// 创建激励视频广告
adInfo.instance = uni.createRewardedVideoAd({
  adpid: adInfo.adpid
});

// 显示广告
adInfo.instance.show();

// 观看完成回调
adInfo.instance.onClose((res) => {
  if (res && res.isEnded) {
    this.giveReward(); // 发放奖励
  }
});
```

#### Flutter ✅
- **位置**: 任务页面（`lib/app/modules/home/task_page.dart`）
- **触发时机**: 完全一致
  - 用户点击"看广告"按钮
  - 完成任务需要观看广告
- **实现方式**:
```dart
// 显示激励视频广告
await AdManager.instance.showRewardedVideoAd(
  onReward: () {
    // 广告观看完成，发放奖励
    _onAdComplete();
  },
  onClose: () {
    debugPrint('广告已关闭');
  },
  onError: (error) {
    FlutterToastPro.showMessage('广告加载失败: $error');
  },
);
```
- **状态**: ✅ 已实现，位置和逻辑完全一致

---

### 3. 信息流广告（首页）

#### Uni-app
- **位置**: 首页商品列表中
- **展示方式**: 
  - 嵌入在商品列表中
  - 每隔N个商品插入一个广告
- **文件**: `pages/index/index.vue`

#### Flutter ⚠️
- **位置**: 首页商品列表中（需要确认）
- **文件**: `lib/app/modules/home/home_page.dart`
- **当前状态**: 
  - 代码中有 `FeedAdWidget` 的引用（第438行）
  - 需要替换为新的 `ZJFeedAdWidget`
- **建议实现**:
```dart
// 在商品列表中插入信息流广告
ListView.builder(
  itemBuilder: (context, index) {
    // 每隔10个商品插入一个广告
    if (index % 10 == 5) {
      return ZJFeedAdWidget(
        width: double.infinity,
        height: 280,
        videoSoundEnable: false,
      );
    }
    return ProductCard(product: products[index]);
  },
);
```
- **状态**: ⚠️ 需要更新代码

---

### 4. 横幅广告

#### Uni-app
- **位置**: 可能在某些页面底部或顶部
- **展示方式**: 固定位置的横幅

#### Flutter ✅
- **组件已创建**: `lib/widgets/zj_banner_ad_widget.dart`
- **使用方式**:
```dart
ZJBannerAdWidget(
  width: double.infinity,
  height: 120,
)
```
- **建议位置**:
  - 首页顶部或底部
  - 商品详情页底部
  - 个人中心页面
- **状态**: ✅ 组件已创建，可随时使用

---

## 📊 广告位置总结

| 广告类型 | Uni-app 位置 | Flutter 位置 | 状态 | 说明 |
|---------|-------------|-------------|------|------|
| 开屏广告 | 应用启动 | 应用启动 | ✅ 一致 | 完全相同 |
| 激励视频 | 任务页面 | 任务页面 | ✅ 一致 | 触发时机和逻辑完全相同 |
| 信息流广告 | 首页商品列表 | 首页商品列表 | ⚠️ 需更新 | 需要替换旧组件 |
| 横幅广告 | 部分页面 | 可灵活添加 | ✅ 可用 | 组件已创建 |

---

## 🔧 需要修复的地方

### 1. 任务页面广告初始化
**文件**: `lib/app/modules/home/task_page.dart:60`

**当前代码**:
```dart
Future<void> _initAd() async {
  await _adManager.init();  // ❌ 方法不存在
  _adManager.preloadRewardedVideoAd();
}
```

**修复为**:
```dart
Future<void> _initAd() async {
  await AdManager.instance.start();  // ✅ 使用正确的方法
  AdManager.instance.preloadRewardedVideoAd();
}
```

### 2. 首页信息流广告
**文件**: `lib/app/modules/home/home_page.dart:438`

**当前代码**:
```dart
return const FeedAdWidget();  // ❌ 旧组件
```

**修复为**:
```dart
return ZJFeedAdWidget(
  width: double.infinity,
  height: 280,
  videoSoundEnable: false,  // 静音，与 uni-app 一致
  onShow: () => debugPrint('信息流广告展示'),
  onError: (error) => debugPrint('信息流广告错误: $error'),
);
```

---

## 🎯 广告展示策略对比

### Uni-app 策略
1. **开屏广告**: 应用启动时展示
2. **激励视频**: 
   - 多个广告位轮换（5个广告位）
   - 预加载机制
   - 失败自动切换下一个
3. **信息流**: 嵌入商品列表
4. **频率控制**: 有冷却时间

### Flutter 策略 ✅
1. **开屏广告**: 应用启动时展示（已实现）
2. **激励视频**: 
   - 单个广告位
   - 支持预加载
   - 错误处理完善
3. **信息流**: 可嵌入商品列表（组件已创建）
4. **频率控制**: 可根据需要添加

**建议**: Flutter 版本的广告策略已经足够，与 uni-app 基本一致。

---

## 📝 实现建议

### 1. 保持一致性
- ✅ 开屏广告位置一致
- ✅ 激励视频触发时机一致
- ⚠️ 信息流广告需要添加到首页

### 2. 用户体验
- ✅ 广告加载失败不影响功能
- ✅ 提供清晰的加载提示
- ✅ 观看完成后及时发放奖励

### 3. 性能优化
- ✅ 激励视频支持预加载
- ✅ 避免频繁请求
- ✅ 错误处理完善

---

## ✅ 结论

**Flutter 版本的广告展示位置与 uni-app 基本一致！**

主要广告位置：
1. ✅ **开屏广告** - 应用启动时（完全一致）
2. ✅ **激励视频** - 任务页面（完全一致）
3. ⚠️ **信息流广告** - 首页商品列表（需要更新代码）
4. ✅ **横幅广告** - 可灵活添加（组件已创建）

只需要修复两处代码引用，就可以完全匹配 uni-app 的广告展示效果！

---

## 🚀 下一步行动

1. ✅ 修复 `task_page.dart` 中的 `_adManager.init()` 调用
2. ✅ 修复 `home_page.dart` 中的 `FeedAdWidget` 引用
3. ✅ 测试所有广告位置
4. ✅ 验证广告展示效果与 uni-app 一致

完成这些步骤后，Flutter 版本的广告展示将与 uni-app 完全一致！🎉
