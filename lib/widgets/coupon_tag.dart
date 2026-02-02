import 'package:flutter/material.dart';

/// 消费券票券样式标签组件
/// 左右两边有内凹弧度，类似优惠券撕裂口
class CouponTag extends StatelessWidget {
  /// 文字内容
  final String text;

  /// 文字大小
  final double fontSize;

  /// 边框和文字颜色
  final Color color;

  /// 背景颜色
  final Color backgroundColor;

  /// 水平内边距
  final double horizontalPadding;

  /// 垂直内边距
  final double verticalPadding;

  const CouponTag({
    super.key,
    this.text = '消费券',
    this.fontSize = 10,
    this.color = const Color(0xFFFF6B6B),
    this.backgroundColor = Colors.white,
    this.horizontalPadding = 8,
    this.verticalPadding = 3,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CouponTagPainter(
        borderColor: color,
        backgroundColor: backgroundColor,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: color,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

/// 票券形状绘制器 - 左右两边有内凹弧度
class _CouponTagPainter extends CustomPainter {
  final Color borderColor;
  final Color backgroundColor;

  _CouponTagPainter({
    required this.borderColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    const radius = 4.0; // 内凹圆弧半径
    final path = Path();

    // 左上角
    path.moveTo(radius, 0);
    // 顶边
    path.lineTo(size.width - radius, 0);
    // 右上角圆弧
    path.arcToPoint(
      Offset(size.width, radius),
      radius: const Radius.circular(radius),
      clockwise: true,
    );
    // 右边到中间内凹
    path.lineTo(size.width, size.height / 2 - radius);
    // 右边内凹弧
    path.arcToPoint(
      Offset(size.width, size.height / 2 + radius),
      radius: const Radius.circular(radius),
      clockwise: false,
    );
    // 右边到右下角
    path.lineTo(size.width, size.height - radius);
    // 右下角圆弧
    path.arcToPoint(
      Offset(size.width - radius, size.height),
      radius: const Radius.circular(radius),
      clockwise: true,
    );
    // 底边
    path.lineTo(radius, size.height);
    // 左下角圆弧
    path.arcToPoint(
      Offset(0, size.height - radius),
      radius: const Radius.circular(radius),
      clockwise: true,
    );
    // 左边到中间内凹
    path.lineTo(0, size.height / 2 + radius);
    // 左边内凹弧
    path.arcToPoint(
      Offset(0, size.height / 2 - radius),
      radius: const Radius.circular(radius),
      clockwise: false,
    );
    // 左边到左上角
    path.lineTo(0, radius);
    // 左上角圆弧
    path.arcToPoint(
      const Offset(radius, 0),
      radius: const Radius.circular(radius),
      clockwise: true,
    );

    path.close();

    // 先填充背景，再画边框
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CouponTagPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
