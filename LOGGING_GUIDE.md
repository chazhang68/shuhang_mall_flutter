# 日志功能使用指南

## 说明
为了增强应用的日志功能，我们在项目中添加了完整的日志系统，包括以下特性：
- 使用 `logger` 包提供结构化日志输出
- 在调试模式下输出彩色日志
- 在控制台输出日志确保可见性
- 通过 `Talker` 提供高级日志功能

## 日志服务类
- [lib/app/services/log_service.dart](file:///Users/a8833/Documents/GitHub/shuhang_mall_flutter/lib/app/services/log_service.dart) - 主要的日志服务类

## 使用方法

### 1. 导入日志服务
```dart
import 'package:shuhang_mall_flutter/app/services/log_service.dart';
```

### 2. 在代码中使用日志
```dart
// Debug日志
LogService.d('调试信息');

// Info日志
LogService.i('一般信息');

// Warning日志
LogService.w('警告信息');

// Error日志
LogService.e('错误信息');

// API请求日志
LogService.apiRequest('GET', '/api/users', data: {'id': 1});

// API响应日志
LogService.apiResponse('/api/users', {'status': 'success'});

// 错误日志
LogService.error('UserStore', 'Failed to load user data');
```

## 已更新的文件
- [lib/main.dart](file:///Users/a8833/Documents/GitHub/shuhang_mall_flutter/lib/main.dart) - 在应用启动时添加了日志初始化
- [lib/app/data/providers/api_provider.dart](file:///Users/a8833/Documents/GitHub/shuhang_mall_flutter/lib/app/data/providers/api_provider.dart) - 更新了API提供者使用新的日志服务
- [lib/app/controllers/app_controller.dart](file:///Users/a8833/Documents/GitHub/shuhang_mall_flutter/lib/app/controllers/app_controller.dart) - 在关键操作中添加了日志

## 日志可见性改进
为了解决原始问题（运行 `flutter run -d 662eb639` 时看不到日志），我们做了以下改进：
1. 在日志服务中增加了 `print()` 调用，确保日志同时输出到控制台
2. 保持了原有的logger库功能，提供结构化日志输出
3. 在应用启动时添加了测试日志，验证日志功能正常工作

## 依赖项
- `logger`: 提供结构化日志输出
- `talker`: 提供高级日志功能
- `talker_logger`: Talker的logger插件
- `talker_dio_logger`: 用于HTTP请求日志

现在运行 `flutter run` 命令应该能看到清晰的日志输出。