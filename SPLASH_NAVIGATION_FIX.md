# 启动页跳转修复

## 问题

日志显示"🏠 跳转到主页"，但实际没有跳转，停留在黑屏状态。

## 原因分析

从日志可以看出：
```
I/flutter (29736): ⏰ 启动页最小显示时间（5秒）已到
I/flutter (29736): ⚠️ 启动页显示超过6秒，强制跳转主页
I/flutter (29736): 🏠 跳转到主页
```

跳转命令已执行，但没有实际跳转。可能的原因：
1. `Get.offAllNamed(AppRoutes.main)` 没有生效
2. 路由配置问题
3. Widget生命周期问题

## 解决方案

### 1. 使用addPostFrameCallback

确保在UI更新完成后再执行跳转：

```dart
void _navigateToMain() {
  if (_hasNavigated) return;
  _hasNavigated = true;

  // 延迟一帧，确保UI更新完成
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    
    // 执行跳转
    Get.offAll(() => const MainPage());
  });
}
```

### 2. 直接使用MainPage实例

不使用路由名称，直接跳转到MainPage实例：

```dart
// ❌ 之前：使用路由名称
Get.offAllNamed(AppRoutes.main);

// ✅ 现在：直接使用实例
Get.offAll(() => const MainPage());
```

### 3. 添加备用跳转方案

如果Get跳转失败，使用Navigator作为备用：

```dart
try {
  Get.offAll(() => const MainPage());
} catch (e) {
  // 备用方案
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const MainPage()),
    (route) => false,
  );
}
```

### 4. 添加详细日志

记录跳转的每一步，便于调试：

```dart
debugPrint('🏠 准备跳转到主页');
debugPrint('📍 当前路由: ${Get.currentRoute}');
debugPrint('🚀 开始跳转到MainPage...');
debugPrint('✅ 跳转命令已执行');
```

## 修改前后对比

### 修改前

```dart
void _navigateToMain() {
  if (_hasNavigated) return;
  _hasNavigated = true;

  if (mounted) {
    Get.offAllNamed(AppRoutes.main); // 可能不生效
  }
}
```

### 修改后

```dart
void _navigateToMain() {
  if (_hasNavigated) return;
  _hasNavigated = true;

  // 延迟一帧执行
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    
    try {
      // 直接使用MainPage实例
      Get.offAll(
        () => const MainPage(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );
    } catch (e) {
      // 备用方案：使用Navigator
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainPage()),
        (route) => false,
      );
    }
  });
}
```

## 期望的日志输出

运行应用后，应该看到：

```
🚀 开屏页面：开始加载开屏广告
📱 广告位ID: J8120762208
📱 应用ID: Z0062563231
⏰ 启动页最小显示时间（5秒）已到
⚠️ 启动页显示超过6秒，强制跳转主页
🏠 准备跳转到主页
📍 当前路由: /splash
🚀 开始跳转到MainPage...
✅ 跳转命令已执行
(应用跳转到主页)
```

如果跳转失败，会看到：

```
❌ Get.offAll跳转失败: xxx
✅ 使用Navigator跳转成功
```

## 其他可能的问题

### 1. GetX未正确初始化

检查 `main.dart` 中是否使用了 `GetMaterialApp`：

```dart
// ✅ 正确
GetMaterialApp(
  initialRoute: AppRoutes.splash,
  getPages: AppPages.pages,
)

// ❌ 错误
MaterialApp(
  // 不能使用Get的路由功能
)
```

### 2. MainPage导入错误

确保正确导入MainPage：

```dart
import 'package:shuhang_mall_flutter/app/modules/home/main_page.dart';
```

### 3. Widget已销毁

如果Widget在跳转前已销毁，跳转会失败。使用 `addPostFrameCallback` 可以避免这个问题。

## 测试步骤

1. **清理并重新运行**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **查看日志**
   - 是否看到"🚀 开始跳转到MainPage..."
   - 是否看到"✅ 跳转命令已执行"
   - 是否有错误信息

3. **观察界面**
   - 启动页是否显示（白色背景 + Logo）
   - 5-6秒后是否跳转到主页
   - 是否还停留在黑屏

4. **Debug模式**
   - 左上角是否显示状态信息
   - "已跳转"是否变为"是"

## 如果仍然无法跳转

请提供以下信息：

1. **完整的日志**（从启动到卡住）
2. **是否看到启动页**（白色背景 + Logo）
3. **是否看到Debug信息**（左上角）
4. **是否有任何错误信息**

## 总结

修复了启动页跳转问题：

1. ✅ 使用 `addPostFrameCallback` 确保UI更新完成
2. ✅ 直接使用 `MainPage` 实例而不是路由名称
3. ✅ 添加备用跳转方案（Navigator）
4. ✅ 添加详细的调试日志

现在应该能正常跳转到主页了！
