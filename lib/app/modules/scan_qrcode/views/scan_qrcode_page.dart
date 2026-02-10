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

          // 扫描线动画（宽度全屏，高度避开顶部AppBar和底部控件）
          Positioned(
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
            bottom: 300,
            left: 0,
            right: 0,
            child: const _ScanLineAnimation(),
          ),

          // 手电筒按钮（扫描框下方居中）
          Positioned(
            bottom: 200,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: controller.toggleTorch,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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

/// 全屏扫描线动画
class _ScanLineAnimation extends StatefulWidget {
  const _ScanLineAnimation();

  @override
  State<_ScanLineAnimation> createState() => _ScanLineAnimationState();
}

class _ScanLineAnimationState extends State<_ScanLineAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ScanLinePainter(progress: _animation.value),
          size: Size.infinite,
        );
      },
    );
  }
}

/// 扫描线绘制器 - 带渐变光效
class _ScanLinePainter extends CustomPainter {
  final double progress;

  _ScanLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * progress;
    final lineWidth = size.width - 20;
    final startX = 10.0;

    // 绘制扫描线的光晕效果
    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0x0000C853),
          const Color(0x3300C853),
          const Color(0x8800C853),
          const Color(0x3300C853),
          const Color(0x0000C853),
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(startX, y - 20, lineWidth, 40));

    canvas.drawRect(
      Rect.fromLTWH(startX, y - 20, lineWidth, 40),
      glowPaint,
    );

    // 绘制扫描线本身
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0x0000C853),
          const Color(0xFF00C853),
          const Color(0xFF00C853),
          const Color(0x0000C853),
        ],
        stops: const [0.0, 0.2, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(startX, y, lineWidth, 2));

    canvas.drawRect(
      Rect.fromLTWH(startX, y - 1, lineWidth, 2),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
