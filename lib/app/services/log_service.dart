import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:talker/talker.dart';

class LogService {
  static LogService? _instance;
  Logger? _logger;
  Talker? _talker;

  LogService._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2, // Number of method calls to be displayed
        errorMethodCount: 8, // Number of method calls if stacktrace is provided
        lineLength: 120, // Width of the output
        colors: true, // Colorful log messages
        printEmojis: true, // Print an emoji for each log message
        // printTime: true, // 已弃用，使用 dateTimeFormat 代替
      ),
    );

    _talker = Talker();
  }

  static LogService get instance {
    _instance ??= LogService._internal();
    return _instance!;
  }

  static Logger get logger {
    _instance ??= LogService._internal();
    return _instance!._logger!;
  }

  static Talker get talker {
    _instance ??= LogService._internal();
    return _instance!._talker!;
  }

  /// Debug日志
  static void d(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      instance._logger?.d(message, error: error, stackTrace: stackTrace);
      // 同时打印到控制台以确保可见
      print('[DEBUG] $message');
      if (error != null) print('[ERROR] $error');
      if (stackTrace != null) print('[STACKTRACE] $stackTrace');
    }
  }

  /// Info日志
  static void i(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      instance._logger?.i(message, error: error, stackTrace: stackTrace);
      // 同时打印到控制台以确保可见
      print('[INFO] $message');
      if (error != null) print('[ERROR] $error');
    }
  }

  /// Warning日志
  static void w(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      instance._logger?.w(message, error: error, stackTrace: stackTrace);
      // 同时打印到控制台以确保可见
      print('[WARN] $message');
      if (error != null) print('[ERROR] $error');
    }
  }

  /// Error日志
  static void e(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      instance._logger?.e(message, error: error, stackTrace: stackTrace);
      // 同时打印到控制台以确保可见
      print('[ERROR] $message');
      if (error != null) print('[ERROR DETAILS] $error');
      if (stackTrace != null) print('[STACKTRACE] $stackTrace');
    }
  }

  /// 输出完整的API请求日志
  static void apiRequest(String method, String url, {dynamic data}) {
    if (kDebugMode) {
      final logMsg = 'API Request: $method $url\nData: $data';
      instance._logger?.i(logMsg);
      // 同时打印到控制台以确保可见
      print('[API REQUEST] $logMsg');
    }
  }

  /// 输出完整的API响应日志
  static void apiResponse(String url, dynamic response) {
    if (kDebugMode) {
      final logMsg = 'API Response: $url\nResponse: $response';
      instance._logger?.i(logMsg);
      // 同时打印到控制台以确保可见
      print('[API RESPONSE] $logMsg');
    }
  }

  /// 输出错误日志
  static void error(String tag, dynamic error, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      final logMsg = '$tag Error: $error';
      instance._logger?.e(logMsg, error: error, stackTrace: stackTrace);
      // 同时打印到控制台以确保可见
      print('[APP ERROR] $logMsg');
      if (error != null) print('[ERROR DETAILS] $error');
      if (stackTrace != null) print('[STACKTRACE] $stackTrace');
    }
  }

  /// 记录Navigator相关错误
  static void navigatorError(
    String operation, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      final logMsg = 'Navigator $operation failed: $error';
      instance._logger?.e(logMsg, error: error, stackTrace: stackTrace);
      print('[NAVIGATOR ERROR] $logMsg');
      if (error != null) print('[ERROR DETAILS] $error');
      if (stackTrace != null) print('[STACKTRACE] $stackTrace');
    }
  }
}
