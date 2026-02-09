import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';

/// 消费券二维码控制器
class CouponQrcodeController extends GetxController {
  final qrcodeData = ''.obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadQrcodeData();
  }

  /// 加载二维码数据
  void _loadQrcodeData() {
    try {
      final appController = Get.find<AppController>();
      final userInfo = appController.userInfo;

      if (userInfo == null || userInfo.phone.isEmpty) {
        debugPrint('用户信息或手机号为空');
        isLoading.value = false;
        return;
      }

      // 添加前缀 "COUPON:" 用于识别和跳转
      qrcodeData.value = 'COUPON:${userInfo.phone}';
      debugPrint('生成二维码数据: ${qrcodeData.value}');
      isLoading.value = false;
    } catch (e) {
      debugPrint('加载二维码数据失败: $e');
      isLoading.value = false;
    }
  }

  /// 刷新二维码
  void refresh() {
    isLoading.value = true;
    _loadQrcodeData();
  }
}
