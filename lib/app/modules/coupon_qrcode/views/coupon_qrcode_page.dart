import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import '../controllers/coupon_qrcode_controller.dart';

/// 消费券二维码页面
class CouponQrcodePage extends GetView<CouponQrcodeController> {
  const CouponQrcodePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final userInfo = appController.userInfo;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('消费券二维码'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.qrcodeData.value.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  '无法获取用户信息',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: controller.refresh,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: RepaintBoundary(
              key: controller.qrcodeKey,
              child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 用户头像
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: userInfo?.avatar.isNotEmpty == true
                        ? CachedNetworkImage(
                            imageUrl: userInfo!.avatar,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              width: 64,
                              height: 64,
                              color: Colors.grey[200],
                              child: const Icon(Icons.person, color: Colors.grey),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              width: 64,
                              height: 64,
                              color: Colors.grey[200],
                              child: const Icon(Icons.person, color: Colors.grey),
                            ),
                          )
                        : Container(
                            width: 64,
                            height: 64,
                            color: Colors.grey[200],
                            child: const Icon(Icons.person, color: Colors.grey),
                          ),
                  ),
                  const SizedBox(height: 12),
                  // 用户昵称
                  Text(
                    userInfo?.nickname ?? '用户',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 二维码（带中间logo）
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      QrImageView(
                        data: controller.qrcodeData.value,
                        version: QrVersions.auto,
                        size: 240,
                        backgroundColor: Colors.white,
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                      ),
                      // 中间头像
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: userInfo?.avatar.isNotEmpty == true
                              ? CachedNetworkImage(
                                  imageUrl: userInfo!.avatar,
                                  width: 42,
                                  height: 42,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Image.asset(
                                    'assets/images/logos.png',
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/logos.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 提示文字
                  const Text(
                    '扫一扫上面的二维码',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 底部操作按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.qr_code_scanner,
                        label: '扫一扫',
                        onTap: () => Get.toNamed('/scan-qrcode'),
                      ),
                      _buildActionButton(
                        icon: Icons.save_alt,
                        label: '保存图片',
                        onTap: () => controller.saveQrcode(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: const Color(0xFF333333), size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}
