import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import '../controllers/scan_qrcode_controller.dart';

/// 扫一扫页面
class ScanQrcodePage extends GetView<ScanQrcodeController> {
  const ScanQrcodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('扫一扫', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // 扫码区域
          MobileScanner(
            controller: controller.scannerController,
            onDetect: controller.onDetect,
          ),

          // 扫描框
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // 手电筒按钮（扫描框下方居中）
          Positioned(
            bottom: 200,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: controller.toggleTorch,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.flashlight_on_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(height: 6),
                  Text(
                    '轻触照亮',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 底部操作按钮
          Positioned(
            bottom: 100,
            left: 40,
            right: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 我的二维码
                _buildActionButton(
                  icon: Icons.qr_code,
                  label: '我的二维码',
                  onTap: () => Get.toNamed(AppRoutes.couponQrcode),
                ),

                // 相册
                _buildActionButton(
                  icon: Icons.photo_library_outlined,
                  label: '相册',
                  onTap: controller.pickFromGallery,
                ),
              ],
            ),
          ),

          // 底部tab指示
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      '扫一扫',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    CircleAvatar(
                      radius: 3,
                      backgroundColor: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
