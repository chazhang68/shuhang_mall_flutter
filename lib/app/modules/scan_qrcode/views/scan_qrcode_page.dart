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

          // 半透明遮罩 + 扫描框
          _ScanOverlay(scanSize: 250),

          // 扫描线动画
          const Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: _ScanLineAnimation(),
            ),
          ),

          // 扫描框四角装饰
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: CustomPaint(
                painter: _CornerPainter(
                  color: const Color(0xFF00C853),
                  cornerLength: 20,
                  cornerWidth: 3,
                ),
              ),
            ),
          ),

          // 提示文字
          Positioned(
            top: MediaQuery.of(context).size.height / 2 + 145,
            left: 0,
            right: 0,
            child: const Text(
              '将二维码放入框内，即可自动扫描',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
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

/// 半透明遮罩，中间扫描框区域透明
class _ScanOverlay extends StatelessWidget {
  final double scanSize;

  const _ScanOverlay({required this.scanSize});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.sizeOf(context),
      painter: _OverlayPainter(scanSize: scanSize),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final double scanSize;

  _OverlayPainter({required this.scanSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withAlpha(140);
    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanSize,
      height: scanSize,
    );

    // 绘制四周遮罩
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(12))),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 扫描框四角装饰
class _CornerPainter extends CustomPainter {
  final Color color;
  final double cornerLength;
  final double cornerWidth;

  _CornerPainter({
    required this.color,
    required this.cornerLength,
    required this.cornerWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = cornerWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final cl = cornerLength;

    // 左上角
    canvas.drawLine(const Offset(0, 0), Offset(cl, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, cl), paint);

    // 右上角
    canvas.drawLine(Offset(w, 0), Offset(w - cl, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, cl), paint);

    // 左下角
    canvas.drawLine(Offset(0, h), Offset(cl, h), paint);
    canvas.drawLine(Offset(0, h), Offset(0, h - cl), paint);

    // 右下角
    canvas.drawLine(Offset(w, h), Offset(w - cl, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - cl), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 微信风格扫描线动画
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
