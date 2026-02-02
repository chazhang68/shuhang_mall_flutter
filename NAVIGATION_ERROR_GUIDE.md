# Navigator 错误处理指南

## 问题描述
你遇到的错误是：
```
I/flutter (20587): 获取用户信息失败: 'package:flutter/src/widgets/navigator.dart': Failed assertion: line 4628 pos 12: '!_debugLocked': is not true.
```

这是一个常见的Flutter框架错误，表示在Navigator被锁定时尝试进行导航操作。

## 错误原因
这个错误通常发生在以下情况：
1. 并发的导航操作（多个地方同时尝试导航）
2. 在异步操作完成前就尝试导航
3. 在widget构建过程中进行导航操作
4. 多个事件处理器同时触发导航

## 解决方案

### 1. 使用NavigationService
我们创建了一个安全的导航服务([NavigationService](file:///Users/a8833/Documents/GitHub/shuhang_mall_flutter/lib/app/services/navigation_service.dart))来处理所有导航操作，它包含错误处理和日志记录。

### 2. 日志增强
- [LogService](file:///Users/a8833/Documents/GitHub/shuhang_mall_flutter/lib/app/services/log_service.dart) 已经增强了对Navigator错误的捕获
- 新增了 `navigatorError` 方法来专门记录导航相关错误

### 3. 代码实践建议

#### 避免在异步操作中直接使用Get.to等导航方法
错误做法：
```dart
// 避免这样做
Future<void> getUserInfo() async {
  var userInfo = await api.getUserInfo();
  Get.to(SomePage(userInfo: userInfo)); // 可能与其他导航冲突
}
```

推荐做法：
```dart
// 推荐这样做
Future<void> getUserInfo() async {
  try {
    var userInfo = await api.getUserInfo();
    // 使用安全的导航服务
    await NavigationService.pushNamed('/somepage', arguments: userInfo);
  } catch (e, stack) {
    // 使用专门的错误日志方法
    DebugLogger.logUserInfoError(e.toString(), stackTrace: stack);
  }
}
```

#### 在用户信息获取失败时使用专门的日志方法
```dart
import 'package:shuhang_mall_flutter/app/utils/debug_logger.dart';

// 当获取用户信息失败时
if (result.hasError) {
  DebugLogger.logUserInfoError(result.errorMessage);
}
```

### 4. Flutter运行时日志增强
根据项目信息，运行Flutter应用时可以使用以下参数获得更详细的日志：
```bash
flutter run --verbose
# 或
flutter run --log-level=debug
```

## 已做的改进
1. ✅ 创建了 [NavigationService](file:///Users/a8833/Documents/GitHub/shuhang_mall_flutter/lib/app/services/navigation_service.dart) 用于安全的导航操作
2. ✅ 增强了 [LogService](file:///Users/a8833/Documents/GitHub/shuhang_mall_flutter/lib/app/services/log_service.dart) 以捕获Navigator错误
3. ✅ 添加了专门的用户信息错误日志方法
4. ✅ 在main.dart中集成了导航服务
5. ✅ 更新了所有相关依赖

## 使用方法
在你的控制器或页面中：
```dart
import 'package:shuhang_mall_flutter/app/services/navigation_service.dart';
import 'package:shuhang_mall_flutter/app/utils/debug_logger.dart';

// 安全导航
await NavigationService.pushNamed('/target-page');

// 记录用户信息错误
DebugLogger.logUserInfoError('网络请求失败', stackTrace: stackTrace);
```

这些改进应该能够帮助你更好地诊断和解决Navigator相关的错误。