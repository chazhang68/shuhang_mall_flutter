/// API 服务类
/// 基于WIKI文档生成的API接口封装
/// 包含所有从原uni-app项目迁移过来的API接口
library;

import 'package:dio/dio.dart';

/// API 响应模型
class ApiResponse<T> {
  final int status;
  final String msg;
  final T? data;

  ApiResponse({required this.status, required this.msg, this.data});

  bool get isSuccess => status == 200;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(Map<String, dynamic>)? parser,
  }) {
    return ApiResponse(
      status: json['status'] ?? 0,
      msg: json['msg'] ?? '',
      data: json['data'] != null && parser != null ? parser(json['data']) : json['data'] as T?,
    );
  }
}

/// API 服务提供者
class ApiService {
  late Dio _dio;

  ApiService(String baseUrl) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );
  }

  /// 设置认证令牌
  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// 用户相关接口
  /// 登录注册
  Future<ApiResponse> loginMobile(Map<String, dynamic> data) async {
    final response = await _dio.post('/login/mobile', data: data);
    return ApiResponse.fromJson(response.data);
  }

  Future<ApiResponse> phoneRegister(Map<String, dynamic> data) async {
    final response = await _dio.post('/register', data: data);
    return ApiResponse.fromJson(response.data);
  }

  Future<ApiResponse> getUserInfo() async {
    final response = await _dio.get('/user');
    return ApiResponse.fromJson(response.data);
  }

  /// 商品相关接口
  Future<ApiResponse> getProductDetail(int id) async {
    final response = await _dio.get('/product/detail/$id');
    return ApiResponse.fromJson(response.data);
  }

  Future<ApiResponse> getProductsList([Map<String, dynamic>? params]) async {
    final response = await _dio.get('/products', queryParameters: params);
    return ApiResponse.fromJson(response.data);
  }

  Future<ApiResponse> getCategoryList() async {
    final response = await _dio.get('/category');
    return ApiResponse.fromJson(response.data);
  }

  Future<ApiResponse> addToCart(Map<String, dynamic> data) async {
    final response = await _dio.post('/cart/add', data: data);
    return ApiResponse.fromJson(response.data);
  }

  Future<ApiResponse> getCartList([Map<String, dynamic>? params]) async {
    final response = await _dio.get('/cart/list', queryParameters: params);
    return ApiResponse.fromJson(response.data);
  }

  /// 订单相关接口
  Future<ApiResponse> getOrderList([Map<String, dynamic>? params]) async {
    final response = await _dio.get('/order/list', queryParameters: params);
    return ApiResponse.fromJson(response.data);
  }

  Future<ApiResponse> createOrder(String key, Map<String, dynamic> data) async {
    final response = await _dio.post('/order/create/$key', data: data);
    return ApiResponse.fromJson(response.data);
  }

  Future<ApiResponse> getOrderDetail(String orderId) async {
    final response = await _dio.get('/order/detail/$orderId');
    return ApiResponse.fromJson(response.data);
  }

  /// 收藏相关接口
  Future<ApiResponse> addToFavorites(int productId, String category) async {
    final response = await _dio.post('/collect/add', data: {'id': productId, 'product': category});
    return ApiResponse.fromJson(response.data);
  }

  /// 文章相关接口
  Future<ApiResponse> getArticleHotList() async {
    final response = await _dio.get('/article/hot/list');
    return ApiResponse.fromJson(response.data);
  }

  Future<ApiResponse> getArticleDetails(int id) async {
    final response = await _dio.get('/article/details/$id');
    return ApiResponse.fromJson(response.data);
  }

  /// 系统配置相关接口
  Future<ApiResponse> getSiteConfig() async {
    final response = await _dio.get('/site_config');
    return ApiResponse.fromJson(response.data);
  }

  /// 验证码相关接口
  Future<ApiResponse> getVerifyCode() async {
    final response = await _dio.get('/verify_code');
    return ApiResponse.fromJson(response.data);
  }

  Future<ApiResponse> sendVerificationCode(Map<String, dynamic> data) async {
    final response = await _dio.post('/register/verify', data: data);
    return ApiResponse.fromJson(response.data);
  }

  /// 积分商城相关接口
  Future<ApiResponse> getPointsMall([Map<String, dynamic>? params]) async {
    final response = await _dio.get('/store_integral/index', queryParameters: params);
    return ApiResponse.fromJson(response.data);
  }

  /// 管理员相关接口
  Future<ApiResponse> getAdminStatistics() async {
    final response = await _dio.get('/admin/order/statistics');
    return ApiResponse.fromJson(response.data);
  }

  Future<ApiResponse> getAdminOrderList([Map<String, dynamic>? params]) async {
    final response = await _dio.get('/admin/order/list', queryParameters: params);
    return ApiResponse.fromJson(response.data);
  }

  /// 通用GET请求
  Future<ApiResponse> get(String path, {Map<String, dynamic>? params}) async {
    final response = await _dio.get(path, queryParameters: params);
    return ApiResponse.fromJson(response.data);
  }

  /// 通用POST请求
  Future<ApiResponse> post(String path, {dynamic data}) async {
    final response = await _dio.post(path, data: data);
    return ApiResponse.fromJson(response.data);
  }

  /// 通用PUT请求
  Future<ApiResponse> put(String path, {dynamic data}) async {
    final response = await _dio.put(path, data: data);
    return ApiResponse.fromJson(response.data);
  }

  /// 通用DELETE请求
  Future<ApiResponse> delete(String path, {dynamic data}) async {
    final response = await _dio.delete(path, data: data);
    return ApiResponse.fromJson(response.data);
  }
}

/// API 服务实例管理器
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  static ApiService? _apiService;

  static void init(String baseUrl) {
    _apiService = ApiService(baseUrl);
  }

  static ApiService get api => _apiService!;

  static void setToken(String token) {
    _apiService!.setToken(token);
  }
}
