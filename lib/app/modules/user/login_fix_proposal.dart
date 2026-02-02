import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';

/// 登录获取用户信息失败的解决方案建议

/// 问题诊断:
/// 1. Token header名称可能存在拼写问题: 'Authori-zation' 应检查是否正确
/// 2. Token格式可能不正确: 'Bearer $token'
/// 3. 登录成功到获取用户信息之间的时间间隔可能太短
/// 4. 用户信息接口权限配置可能有问题

/// 建议的修复方案:

// 1. 增强调试信息
void debugLoginProcess() {
  // 在 _handleLoginSuccess 中添加详细的日志
  debugPrint('=== 登录流程调试 ===');
  debugPrint('Token: $_token');
  debugPrint('Expires: $_expiresTime');
  debugPrint('UID: $_uid');
  debugPrint('===================');
}

// 2. 优化请求时序
Future<void> _handleLoginSuccessWithRetry(dynamic data) async {
  // 先保存基本登录信息
  await appController.login(token: token, uid: uid, expiresTime: expiresTime);

  // 增加延迟确保token生效
  await Future.delayed(Duration(milliseconds: 100));

  // 重试机制
  int retryCount = 0;
  const maxRetries = 3;

  while (retryCount < maxRetries) {
    try {
      final userResponse = await _userProvider.getUserInfo();
      if (userResponse.isSuccess && userResponse.data != null) {
        final uid = userResponse.data?.uid ?? 0;
        await appController.login(
          token: token,
          uid: uid,
          userInfo: userResponse.data,
          expiresTime: expiresTime,
        );
        _navigateAfterLogin(backUrl);
        return;
      } else {
        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(Duration(milliseconds: 500 * retryCount));
        } else {
          throw Exception(userResponse.msg ?? '获取用户信息失败');
        }
      }
    } catch (e) {
      retryCount++;
      if (retryCount >= maxRetries) {
        debugPrint('获取用户信息最终失败: $e');
        await appController.logout();
        FlutterToastPro.showMessage('获取用户信息失败: $e');
        break;
      }
    }
  }
}

// 3. 检查并修复token header
// 在 api_provider.dart 中确认header名称
// static const String tokenName = 'Authorization'; // 去掉连字符

// 4. 增加详细的错误反馈
void _showDetailedError(String errorType, dynamic details) {
  Get.defaultDialog(
    title: '登录失败',
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('错误类型: $errorType'),
        if (details != null) Text('详情: ${details.toString().substring(0, 100)}...'),
        SizedBox(height: 10),
        Text('请稍后重试或联系客服', style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    ),
    textConfirm: '知道了',
    onConfirm: () => Get.back(),
  );
}

// 5. 添加网络状态检查
Future<bool> _checkNetworkStatus() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}
