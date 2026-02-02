import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shuhang_mall_flutter/app/data/models/customer_model.dart';
import 'package:shuhang_mall_flutter/app/data/providers/public_provider.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';

/// 客服服务
/// 对应原 utils/index.js 中的 getCustomer 函数
class CustomerService {
  static final CustomerService _instance = CustomerService._internal();
  factory CustomerService() => _instance;
  CustomerService._internal();

  final PublicProvider _publicProvider = PublicProvider();

  /// 打开客服
  /// [url] 可选的跳转路径，用于站内客服
  /// [productId] 商品ID，用于传递给客服
  Future<void> openCustomer({String? url, int? productId}) async {
    debugPrint('=== 开始打开客服 ===');
    debugPrint('商品ID: $productId');
    
    try {
      // 获取客服配置
      debugPrint('正在获取客服配置...');
      final response = await _publicProvider.getCustomerType();
      
      if (!response.isSuccess || response.data == null) {
        // API 失败，直接跳转到客服页面（降级方案）
        debugPrint('API 失败，使用降级方案直接跳转客服页面');
        _openInternalChat(url: url, productId: productId);
        return;
      }

      debugPrint('API 响应成功: ${response.data}');
      final customerModel = CustomerModel.fromJson(response.data as Map<String, dynamic>);
      debugPrint('客服类型: ${customerModel.customerType}');

      // 根据客服类型处理
      if (customerModel.isInternalChat) {
        // 类型 0: 站内客服
        _openInternalChat(url: url, productId: productId);
      } else if (customerModel.isPhoneCall) {
        // 类型 1: 电话客服
        _makePhoneCall(customerModel.customerPhone);
      } else if (customerModel.isThirdParty) {
        // 类型 2: 第三方客服
        _openThirdPartyCustomer(customerModel);
      }
    } catch (e) {
      debugPrint('打开客服失败: $e');
      // 出错时直接跳转到客服页面（降级方案）
      debugPrint('使用降级方案直接跳转客服页面');
      _openInternalChat(url: url, productId: productId);
    }
  }

  /// 打开站内客服聊天
  void _openInternalChat({String? url, int? productId}) {
    // 使用现有的聊天页面
    Get.toNamed(
      AppRoutes.chat,
      arguments: {
        'productId': productId,
        'to_uid': 0, // 客服ID，根据实际情况设置
        'type': 1,
      },
    );
  }

  /// 拨打电话
  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      Get.snackbar(
        '提示',
        '客服电话未配置',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        Get.snackbar(
          '错误',
          '无法拨打电话',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('拨打电话失败: $e');
      Get.snackbar(
        '错误',
        '拨打电话失败',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  /// 打开第三方客服
  Future<void> _openThirdPartyCustomer(CustomerModel customerModel) async {
    final customerUrl = customerModel.customerUrl;

    if (customerUrl == null || customerUrl.isEmpty) {
      Get.snackbar(
        '提示',
        '客服链接未配置',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    // 判断是否是企业微信客服
    if (customerModel.isWeworkCustomer) {
      // 企业微信客服
      await _openWeworkCustomer(customerUrl, customerModel.customerCorpId);
    } else {
      // 其他第三方客服，通过 WebView 打开
      await _openWebView(customerUrl);
    }
  }

  /// 打开企业微信客服
  Future<void> _openWeworkCustomer(String url, String? corpId) async {
    // 在 Flutter 中，企业微信客服需要通过外部浏览器打开
    // 或者使用 WebView 打开
    final Uri uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // 使用外部浏览器打开
        );
      } else {
        Get.snackbar(
          '错误',
          '无法打开企业微信客服',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('打开企业微信客服失败: $e');
      // 如果外部打开失败，尝试使用 WebView
      await _openWebView(url);
    }
  }

  /// 通过 WebView 打开链接
  Future<void> _openWebView(String url) async {
    // 跳转到 WebView 页面
    // 需要在 app_routes.dart 中定义 webView 路由
    Get.toNamed(
      AppRoutes.webView, // 需要在 app_routes.dart 中定义
      parameters: {'url': url},
    );
  }

  /// 快速打开客服（带商品ID）
  Future<void> openCustomerWithProduct(int productId) async {
    await openCustomer(
      url: '/pages/extension/customer_list/chat',
      productId: productId,
    );
  }
}
