// API 使用示例
// 展示如何使用从WIKI生成的API接口

import 'package:flutter/foundation.dart';

import 'api_service.dart';

/// 示例：用户服务类
class UserService {
  /// 用户登录
  Future<ApiResponse> login(String phone, String code) async {
    return await ApiClient.api.loginMobile({'phone': phone, 'captcha': code});
  }

  /// 获取用户信息
  Future<ApiResponse> fetchUserInfo() async {
    return await ApiClient.api.getUserInfo();
  }

  /// 用户注册
  Future<ApiResponse> register(String account, String captcha, String password) async {
    return await ApiClient.api.phoneRegister({
      'account': account,
      'captcha': captcha,
      'password': password,
    });
  }
}

/// 示例：商品服务类
class ProductService {
  /// 获取商品列表
  Future<ApiResponse> fetchProducts({int page = 1, int limit = 10}) async {
    return await ApiClient.api.getProductsList({'page': page, 'limit': limit});
  }

  /// 获取商品详情
  Future<ApiResponse> fetchProductDetail(int productId) async {
    return await ApiClient.api.getProductDetail(productId);
  }

  /// 获取商品分类
  Future<ApiResponse> fetchCategories() async {
    return await ApiClient.api.getCategoryList();
  }

  /// 添加到购物车
  Future<ApiResponse> addToCart({
    required int productId,
    required int skuId,
    required int quantity,
  }) async {
    return await ApiClient.api.addToCart({
      'productId': productId,
      'skuId': skuId,
      'quantity': quantity,
    });
  }

  /// 获取购物车列表
  Future<ApiResponse> fetchCartList() async {
    return await ApiClient.api.getCartList();
  }

  /// 添加到收藏
  Future<ApiResponse> addToFavorites(int productId) async {
    return await ApiClient.api.addToFavorites(productId, 'product');
  }
}

/// 示例：订单服务类
class OrderService {
  /// 获取订单列表
  Future<ApiResponse> fetchOrders({int page = 1, int limit = 10, String? status}) async {
    Map<String, dynamic> params = {'page': page, 'limit': limit};
    if (status != null) {
      params['status'] = status;
    }
    return await ApiClient.api.getOrderList(params);
  }

  /// 创建订单
  Future<ApiResponse> createOrder(String cartIds, Map<String, dynamic> orderData) async {
    return await ApiClient.api.createOrder(cartIds, orderData);
  }

  /// 获取订单详情
  Future<ApiResponse> fetchOrderDetail(String orderId) async {
    return await ApiClient.api.getOrderDetail(orderId);
  }
}

/// 示例：文章/资讯服务类
class ArticleService {
  /// 获取热门文章列表
  Future<ApiResponse> fetchHotArticles() async {
    return await ApiClient.api.getArticleHotList();
  }

  /// 获取文章详情
  Future<ApiResponse> fetchArticleDetail(int articleId) async {
    return await ApiClient.api.getArticleDetails(articleId);
  }
}

/// 示例：系统服务类
class SystemService {
  /// 获取站点配置
  Future<ApiResponse> fetchSiteConfig() async {
    return await ApiClient.api.getSiteConfig();
  }

  /// 获取验证码
  Future<ApiResponse> fetchVerifyCode() async {
    return await ApiClient.api.getVerifyCode();
  }

  /// 发送验证码
  Future<ApiResponse> sendVerificationCode(String phone) async {
    return await ApiClient.api.sendVerificationCode({'phone': phone, 'type': 'register'});
  }
}

/// 示例：积分商城服务类
class PointsMallService {
  /// 获取积分商城商品列表
  Future<ApiResponse> fetchPointsMallProducts({int page = 1, int limit = 10}) async {
    return await ApiClient.api.getPointsMall({'page': page, 'limit': limit});
  }
}

/// 使用示例
class ApiUsageExample {
  final userService = UserService();
  final productService = ProductService();
  final orderService = OrderService();
  final articleService = ArticleService();
  final systemService = SystemService();
  final pointsMallService = PointsMallService();

  /// 初始化API客户端
  void initializeApiClient() {
    // 在应用启动时初始化
    ApiClient.init('https://your-api-domain.com/api/');
  }

  /// 示例：登录流程
  Future<void> loginFlow(String phone, String code) async {
    try {
      final response = await userService.login(phone, code);
      if (response.isSuccess) {
        debugPrint('登录成功');
        // 存储token
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String?;
        if (token != null) {
          ApiClient.setToken(token);
        }

        // 获取用户信息
        final userInfoResponse = await userService.fetchUserInfo();
        if (userInfoResponse.isSuccess) {
          debugPrint('获取用户信息成功');
        }
      } else {
        debugPrint('登录失败: ${response.msg}');
      }
    } catch (e) {
      debugPrint('登录异常: $e');
    }
  }

  /// 示例：获取商品列表
  Future<void> fetchProductsExample() async {
    try {
      final response = await productService.fetchProducts(page: 1, limit: 20);
      if (response.isSuccess) {
        debugPrint('获取商品列表成功');
        // 处理商品数据
        final data = response.data as Map<String, dynamic>;
        final products = data['list'] as List<dynamic>?;
        debugPrint('商品数量: ${products?.length ?? 0}');
      } else {
        debugPrint('获取商品列表失败: ${response.msg}');
      }
    } catch (e) {
      debugPrint('获取商品列表异常: $e');
    }
  }

  /// 示例：添加商品到购物车
  Future<void> addToCartExample(int productId, int skuId, int quantity) async {
    try {
      final response = await productService.addToCart(
        productId: productId,
        skuId: skuId,
        quantity: quantity,
      );
      if (response.isSuccess) {
        debugPrint('添加到购物车成功');
      } else {
        debugPrint('添加到购物车失败: ${response.msg}');
      }
    } catch (e) {
      debugPrint('添加到购物车异常: $e');
    }
  }

  /// 示例：获取订单列表
  Future<void> fetchOrdersExample() async {
    try {
      final response = await orderService.fetchOrders();
      if (response.isSuccess) {
        debugPrint('获取订单列表成功');
      } else {
        debugPrint('获取订单列表失败: ${response.msg}');
      }
    } catch (e) {
      debugPrint('获取订单列表异常: $e');
    }
  }

  /// 示例：获取文章列表
  Future<void> fetchArticlesExample() async {
    try {
      final response = await articleService.fetchHotArticles();
      if (response.isSuccess) {
        debugPrint('获取文章列表成功');
      } else {
        debugPrint('获取文章列表失败: ${response.msg}');
      }
    } catch (e) {
      debugPrint('获取文章列表异常: $e');
    }
  }

  /// 示例：获取系统配置
  Future<void> fetchSiteConfigExample() async {
    try {
      final response = await systemService.fetchSiteConfig();
      if (response.isSuccess) {
        debugPrint('获取系统配置成功');
      } else {
        debugPrint('获取系统配置失败: ${response.msg}');
      }
    } catch (e) {
      debugPrint('获取系统配置异常: $e');
    }
  }
}
