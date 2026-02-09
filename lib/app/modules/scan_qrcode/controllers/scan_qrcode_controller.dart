import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';

/// 扫一扫控制器
class ScanQrcodeController extends GetxController {
  late MobileScannerController scannerController;
  final isScanning = true.obs;
  final hasScanned = false.obs;

  @override
  void onInit() {
    super.onInit();
    scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }

  /// 处理扫码结果
  void onDetect(BarcodeCapture capture) {
    if (hasScanned.value) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final String? code = barcode.rawValue;

    if (code == null || code.isEmpty) {
      EasyLoading.showError('无法识别二维码');
      return;
    }

    hasScanned.value = true;
    debugPrint('扫码结果: $code');

    // 根据二维码前缀判断跳转
    if (code.startsWith('COUPON:')) {
      // 消费券二维码，格式：COUPON:13800138000
      final phone = code.replaceFirst('COUPON:', '');
      _handleCouponQrcode(phone);
    } else {
      // 其他类型的二维码
      EasyLoading.showError('二维码无效');
      Future.delayed(const Duration(seconds: 1), () {
        hasScanned.value = false;
      });
    }
  }

  /// 处理消费券二维码
  void _handleCouponQrcode(String phone) {
    // 验证手机号格式
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      EasyLoading.showError('二维码无效');
      Future.delayed(const Duration(seconds: 1), () {
        hasScanned.value = false;
      });
      return;
    }

    // 跳转到积分转赠页面，并传递手机号
    Get.back(); // 关闭扫码页面
    Get.toNamed(
      AppRoutes.pointsTransfer,
      arguments: {'phone': phone},
    );
  }

  /// 切换闪光灯
  void toggleTorch() {
    scannerController.toggleTorch();
  }

  /// 切换摄像头
  void switchCamera() {
    scannerController.switchCamera();
  }

  /// 重新扫描
  void resetScanning() {
    hasScanned.value = false;
  }
}
