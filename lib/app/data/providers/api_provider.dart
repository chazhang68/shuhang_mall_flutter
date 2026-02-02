import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart'
    show
        Dio,
        BaseOptions,
        Options,
        DioException,
        DioExceptionType,
        InterceptorsWrapper,
        RequestOptions,
        Response,
        RequestInterceptorHandler,
        ResponseInterceptorHandler,
        ErrorInterceptorHandler;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:shuhang_mall_flutter/app/services/log_service.dart';
import 'package:logger/logger.dart';
import 'package:shuhang_mall_flutter/app/utils/cache.dart';
import 'package:shuhang_mall_flutter/app/utils/config.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

/// API 响应模型
class ApiResponse<T> {
  final int status;
  final String msg;
  final T? data;

  ApiResponse({required this.status, required this.msg, this.data});

  /// 是否成功
  bool get isSuccess => status == 200;

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    final statusRaw = json['status'];
    final status = statusRaw is int ? statusRaw : int.tryParse(statusRaw?.toString() ?? '') ?? 0;

    return ApiResponse(
      status: status,
      msg: json['msg']?.toString() ?? '',
      data: fromJsonT != null && json['data'] != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
    );
  }
}

/// 网络请求封装
/// 对应原 utils/request.js
class ApiProvider {
  static ApiProvider? _instance;
  late Dio _dio;


  /// 需要跳转登录的状态码
  static const List<int> _loginRequiredCodes = [110002, 110003, 110004];

  ApiProvider._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiUrl,
        connectTimeout: Duration(milliseconds: AppConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
        headers: AppConfig.headers,
      ),
    );

    _initInterceptors();
  }

  static ApiProvider get instance {
    _instance ??= ApiProvider._();
    return _instance!;
  }

  /// 初始化拦截器
  void _initInterceptors() {
    _dio.interceptors.addAll([
      InterceptorsWrapper(onRequest: _onRequest, onResponse: _onResponse, onError: _onError),
      TalkerDioLogger(settings: TalkerDioLoggerSettings(printRequestHeaders: true)),
    ]);
  }

  /// 请求拦截
  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 添加 Token
    final token = Cache.getString(CacheKey.token);
    if (token != null && token.isNotEmpty) {
      options.headers[AppConfig.tokenName] = 'Bearer $token';
    }

    // 添加语言设置
    final locale = Cache.getString(CacheKey.locale);
    if (locale != null && locale.isNotEmpty) {
      options.headers['Cb-lang'] = locale;
    }

    if (AppConfig.isDebug) {
      debugPrint('[API Request] ${options.method} ${options.uri}');
      debugPrint('[API Headers] ${options.headers}');
      if (options.data != null) {
        debugPrint('[API Data] ${options.data}');
      }
    }

    handler.next(options);
  }

  /// 响应拦截
  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    if (AppConfig.isDebug) {
      debugPrint('[API Response] ${response.statusCode}');
      debugPrint('[API Response Data] ${response.data}');
    }
    handler.next(response);
  }

  /// 错误拦截
  void _onError(DioException error, ErrorInterceptorHandler handler) {
    debugPrint('[API Error] ${error.type}: ${error.message}');
    debugPrint('[API Error Response] ${error.response?.data}');
    handler.next(error);
  }

  /// GET 请求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool noAuth = false,
    bool noVerify = false,
    T Function(dynamic)? fromJsonT,
  }) async {
    return _request<T>(
      path,
      method: 'GET',
      queryParameters: queryParameters,
      noAuth: noAuth,
      noVerify: noVerify,
      fromJsonT: fromJsonT,
    );
  }

  /// POST 请求
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool noAuth = false,
    bool noVerify = false,
    T Function(dynamic)? fromJsonT,
  }) async {
    return _request<T>(
      path,
      method: 'POST',
      data: data,
      queryParameters: queryParameters,
      noAuth: noAuth,
      noVerify: noVerify,
      fromJsonT: fromJsonT,
    );
  }

  /// PUT 请求
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool noAuth = false,
    bool noVerify = false,
    T Function(dynamic)? fromJsonT,
  }) async {
    return _request<T>(
      path,
      method: 'PUT',
      data: data,
      queryParameters: queryParameters,
      noAuth: noAuth,
      noVerify: noVerify,
      fromJsonT: fromJsonT,
    );
  }

  /// DELETE 请求
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool noAuth = false,
    bool noVerify = false,
    T Function(dynamic)? fromJsonT,
  }) async {
    return _request<T>(
      path,
      method: 'DELETE',
      data: data,
      queryParameters: queryParameters,
      noAuth: noAuth,
      noVerify: noVerify,
      fromJsonT: fromJsonT,
    );
  }

  /// 通用请求方法
  Future<ApiResponse<T>> _request<T>(
    String path, {
    required String method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool noAuth = false,
    bool noVerify = false,
    T Function(dynamic)? fromJsonT,
  }) async {
    // 检查登录状态
    if (!noAuth) {
      final token = Cache.getString(CacheKey.token);
      if (token == null || token.isEmpty) {
        _toLogin();
        return ApiResponse<T>(status: -1, msg: '未登录');
      }
    }

    try {
      final response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method),
      );

      final responseData = response.data as Map<String, dynamic>;

      // 不验证响应，直接返回
      if (noVerify) {
        return ApiResponse<T>(status: 200, msg: 'success', data: responseData as T?);
      }

      final statusRaw = responseData['status'];
      final status = statusRaw is int ? statusRaw : int.tryParse(statusRaw?.toString() ?? '') ?? 0;
      final msg = responseData['msg']?.toString() ?? '';

      // 需要登录
      if (_loginRequiredCodes.contains(status)) {
        _toLogin();
        return ApiResponse<T>(status: status, msg: msg);
      }

      // 特殊状态码处理
      if (status == 100103) {
        Get.defaultDialog(
          title: '提示',
          middleText: msg,
          textConfirm: '我知道了',
          onConfirm: () => Get.back(),
        );
        return ApiResponse<T>(status: status, msg: msg);
      }

      // 成功响应
      if (status == 200) {
        return ApiResponse<T>.fromJson(responseData, fromJsonT);
      }

      // 其他错误
      return ApiResponse<T>(status: status, msg: msg.isNotEmpty ? msg : '系统错误');
    } on DioException catch (e) {
      String errorMsg = '请求失败';
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMsg = '连接超时';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMsg = '响应超时';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMsg = '服务器错误: ${e.response?.statusCode}';
      } else if (e.type == DioExceptionType.cancel) {
        errorMsg = '请求取消';
      }

      LogService.e('Request error: $errorMsg', error: e);
      return ApiResponse<T>(status: -1, msg: errorMsg);
    } catch (e) {
      LogService.e('Unknown error', error: e);
      return ApiResponse<T>(status: -1, msg: '未知错误');
    }
  }

  /// 上传文件
  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required String filePath,
    String fileKey = 'file',
    Map<String, dynamic>? extraData,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final formData = dio.FormData.fromMap({
        fileKey: await dio.MultipartFile.fromFile(filePath),
        ...?extraData,
      });

      final response = await _dio.post(path, data: formData);
      final responseData = response.data as Map<String, dynamic>;

      return ApiResponse<T>.fromJson(responseData, fromJsonT);
    } catch (e) {
      LogService.e('Upload error', error: e);
      return ApiResponse<T>(status: -1, msg: '上传失败');
    }
  }

  /// 跳转登录页
  void _toLogin() {
    // 保存当前页面URL，登录成功后返回
    // 对应 uni-app: that.$Cache.set(BACK_URL, currentUrl)
    final currentRoute = Get.currentRoute;
    if (currentRoute.isNotEmpty && !currentRoute.contains('/login')) {
      Cache.setString(CacheKey.backUrl, currentRoute);
    }

    // 清除登录信息
    Cache.remove(CacheKey.token);
    Cache.remove(CacheKey.userInfo);
    Cache.remove(CacheKey.uid);

    // 跳转登录页
    Get.offAllNamed(AppRoutes.login);
  }
}
