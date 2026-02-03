import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';

import '../data/providers/api_provider.dart';

/// Toast消息管理器
/// 统一管理应用中的消息提示
class ToastManager {
  static void showSuccess(String message) {
    FlutterToastPro.showMessage(message);
  }

  static void showError(String message) {
    FlutterToastPro.showMessage(message);
  }

  static void showWarning(String message) {
    FlutterToastPro.showMessage(message);
  }

  static void showInfo(String message) {
    FlutterToastPro.showMessage(message);
  }
}

/// API错误处理器
class ApiErrorHandler {
  /// 处理API响应错误
  static String getErrorMessage(ApiResponse response) {
    String message = response.msg;

    // 根据状态码提供友好提示
    switch (response.status) {
      case 110002:
      case 110003:
      case 110004:
        return '登录已过期，请重新登录';

      case 100103:
        return message; // 业务逻辑错误，使用原始消息

      case 400:
        return '请求参数错误';

      case 401:
        return '认证失败，请检查账号密码';

      case 403:
        return '权限不足，无法执行此操作';

      case 404:
        return '请求的资源不存在';

      case 429:
        return '请求过于频繁，请稍后再试';

      case 500:
        return '服务器内部错误，请稍后重试';

      case 502:
        return '网关错误，请检查网络连接';

      case 503:
        return '服务暂时不可用，请稍后重试';

      case 504:
        return '网关超时，请检查网络连接';

      default:
        return message.isNotEmpty ? message : '操作失败';
    }
  }

  /// 处理网络异常
  static String getNetworkErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return '连接超时，请检查网络设置';

        case DioExceptionType.receiveTimeout:
          return '响应超时，请稍后重试';

        case DioExceptionType.sendTimeout:
          return '发送超时，请检查网络连接';

        case DioExceptionType.badResponse:
          return '服务器响应异常: ${error.response?.statusCode}';

        case DioExceptionType.cancel:
          return '请求已被取消';

        case DioExceptionType.badCertificate:
          return '证书验证失败';

        case DioExceptionType.connectionError:
          return '网络连接错误，请检查网络设置';

        default:
          return '网络请求失败: ${error.message}';
      }
    }

    return '未知错误: ${error.toString()}';
  }

  /// 显示API错误
  static void showApiError(ApiResponse response) {
    final message = getErrorMessage(response);
    ToastManager.showError(message);
  }

  /// 显示网络错误
  static void showNetworkError(dynamic error) {
    final message = getNetworkErrorMessage(error);
    ToastManager.showError(message);
  }
}

/// 表单验证工具
class FormValidator {
  /// 验证手机号
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入手机号码';
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
      return '请输入正确的手机号码';
    }
    return null;
  }

  /// 验证密码
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 6) {
      return '密码长度不能少于6位';
    }
    if (RegExp(r'^[0-9a-zA-Z]{0,6}$').hasMatch(value)) {
      return '密码过于简单，请包含数字、字母或特殊字符';
    }
    return null;
  }

  /// 验证验证码
  static String? validateCaptcha(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入验证码';
    }
    if (!RegExp(r'^[\w\d]{4,6}$').hasMatch(value)) {
      return '请输入正确的验证码';
    }
    return null;
  }

  /// 验证支付密码
  static String? validatePayPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入支付密码';
    }
    if (value.length != 6) {
      return '支付密码必须为6位数字';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return '支付密码只能包含数字';
    }
    return null;
  }

  /// 验证邀请码
  static String? validateInviteCode(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邀请码';
    }
    if (value.length < 4) {
      return '邀请码长度不能少于4位';
    }
    return null;
  }
}

/// 登录状态管理器
class LoginStateManager {
  /// 安全的登录流程
  static Future<bool> safeLogin({
    required Future<ApiResponse> Function() loginFunction,
    required Future<ApiResponse> Function() userInfoFunction,
    required Function(String token, int uid, dynamic userInfo) onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      // 执行登录
      final loginResponse = await loginFunction();
      if (!loginResponse.isSuccess) {
        onError(ApiErrorHandler.getErrorMessage(loginResponse));
        return false;
      }

      final loginData = loginResponse.data as Map<String, dynamic>? ?? {};
      final token = loginData['token']?.toString() ?? '';
      // expiresTime 用于后续可能的token刷新逻辑
      // ignore: unused_local_variable
      final expiresTime = loginData['expires_time'] ?? 0;

      if (token.isEmpty) {
        onError('登录失败：token为空');
        return false;
      }

      // 延迟确保token生效
      await Future.delayed(const Duration(milliseconds: 100));

      // 获取用户信息
      final userResponse = await userInfoFunction();
      if (!userResponse.isSuccess) {
        onError(ApiErrorHandler.getErrorMessage(userResponse));
        return false;
      }

      final userInfo = userResponse.data;
      final uid = userInfo?.uid ?? 0;

      // 执行成功回调
      onSuccess(token, uid, userInfo);
      return true;
    } catch (e) {
      onError('登录过程中发生错误: ${e.toString()}');
      return false;
    }
  }

  /// 安全的登出流程
  static Future<void> safeLogout(Function() logoutFunction) async {
    try {
      await logoutFunction();
      ToastManager.showSuccess('已安全退出登录');
    } catch (e) {
      // 即使清理失败也要确保UI状态正确
      debugPrint('登出清理失败: $e');
    }
  }
}
