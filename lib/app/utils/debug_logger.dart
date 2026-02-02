import 'package:shuhang_mall_flutter/app/services/log_service.dart';

/// 调试日志工具
/// 用于在开发过程中测试日志功能
class DebugLogger {
  /// 测试日志功能
  static void testLogging() {
    LogService.d('=== 开始测试日志功能 ===');
    LogService.i('这是信息日志');
    LogService.w('这是警告日志');
    LogService.e('这是错误日志');
    LogService.apiRequest('GET', '/test/api', data: {'test': 'data'});
    LogService.apiResponse('/test/api', {'result': 'success'});
    LogService.error('TestTag', '这是一个测试错误');
    LogService.d('=== 日志功能测试完成 ===');
  }
}