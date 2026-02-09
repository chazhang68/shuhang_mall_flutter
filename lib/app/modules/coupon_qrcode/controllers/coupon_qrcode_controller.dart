import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:gal/gal.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';

/// 消费券二维码控制器
class CouponQrcodeController extends GetxController {
  final qrcodeData = ''.obs;
  final isLoading = true.obs;
  final GlobalKey qrcodeKey = GlobalKey();

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

  /// 保存二维码图片到相册
  Future<void> saveQrcode() async {
    try {
      final boundary = qrcodeKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        FlutterToastPro.showMessage('保存失败');
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        FlutterToastPro.showMessage('保存失败');
        return;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      await Gal.putImageBytes(pngBytes, name: 'coupon_qrcode_${DateTime.now().millisecondsSinceEpoch}');
      FlutterToastPro.showMessage('已保存到相册');
    } catch (e) {
      debugPrint('保存二维码失败: $e');
      FlutterToastPro.showMessage('保存失败: $e');
    }
  }
}
