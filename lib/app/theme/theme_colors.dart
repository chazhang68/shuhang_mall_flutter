import 'package:flutter/material.dart';

/// 主题色配置
/// 对应原 App.vue 中的 5 套主题色配置
enum ThemeColorType {
  blue,   // 蓝色主题
  green,  // 绿色主题
  red,    // 红色主题（默认）
  pink,   // 粉色主题
  orange, // 橙色主题
}

/// 主题色数据
class ThemeColorData {
  /// 主题主色
  final Color primary;
  /// 次要颜色
  final Color secondary;
  /// 价格颜色
  final Color price;
  /// 渐变起始色
  final Color gradientStart;
  /// 渐变结束色
  final Color gradientEnd;
  /// 按钮颜色
  final Color button;
  /// 10% 透明度
  final Color opacity10;
  /// 4% 透明度
  final Color opacity4;
  /// 50% 透明度
  final Color minorColor;
  /// 10% 透明度变体
  final Color minorColorT;

  const ThemeColorData({
    required this.primary,
    required this.secondary,
    required this.price,
    required this.gradientStart,
    required this.gradientEnd,
    required this.button,
    required this.opacity10,
    required this.opacity4,
    required this.minorColor,
    required this.minorColorT,
  });
}

/// 主题色集合
class ThemeColors {
  /// 蓝色主题
  static const ThemeColorData blue = ThemeColorData(
    primary: Color(0xFF1DB0FC),
    secondary: Color(0xFF1DB0FC),
    price: Color(0xFFFD502F),
    gradientStart: Color(0xFF40D1F4),
    gradientEnd: Color(0xFF1DB0FC),
    button: Color(0xFF22CAFD),
    opacity10: Color(0x1A1DB0FC),
    opacity4: Color(0x0A1DB0FC),
    minorColor: Color(0x803A8BEC),
    minorColorT: Color(0x1A098BF3),
  );

  /// 绿色主题
  static const ThemeColorData green = ThemeColorData(
    primary: Color(0xFF42CA4D),
    secondary: Color(0xFF42CA4D),
    price: Color(0xFFFF7600),
    gradientStart: Color(0xFF70E038),
    gradientEnd: Color(0xFF42CA4D),
    button: Color(0xFFFE960F),
    opacity10: Color(0x1A42CA4D),
    opacity4: Color(0x0A42CA4D),
    minorColor: Color(0x806CC65E),
    minorColorT: Color(0x1A42CA4D),
  );

  /// 红色主题（默认）
  static const ThemeColorData red = ThemeColorData(
    primary: Color(0xFFE93323),
    secondary: Color(0xFFE93323),
    price: Color(0xFFE93323),
    gradientStart: Color(0xFFFF6151),
    gradientEnd: Color(0xFFE93323),
    button: Color(0xFFFE960F),
    opacity10: Color(0x1AE93323),
    opacity4: Color(0x0AE93323),
    minorColor: Color(0x80E93323),
    minorColorT: Color(0x1AE93323),
  );

  /// 粉色主题
  static const ThemeColorData pink = ThemeColorData(
    primary: Color(0xFFFF448F),
    secondary: Color(0xFFFF448F),
    price: Color(0xFFFF448F),
    gradientStart: Color(0xFFFF67AD),
    gradientEnd: Color(0xFFFF448F),
    button: Color(0xFF282828),
    opacity10: Color(0x1AFF448F),
    opacity4: Color(0x0AFF448F),
    minorColor: Color(0x80FF448F),
    minorColorT: Color(0x1AFF448F),
  );

  /// 橙色主题
  static const ThemeColorData orange = ThemeColorData(
    primary: Color(0xFFFE5C2D),
    secondary: Color(0xFFFE5C2D),
    price: Color(0xFFFE5C2D),
    gradientStart: Color(0xFFFF9445),
    gradientEnd: Color(0xFFFE5C2D),
    button: Color(0xFFFDB000),
    opacity10: Color(0x1AFE5C2D),
    opacity4: Color(0x0AFE5C2D),
    minorColor: Color(0x80FE5C2D),
    minorColorT: Color(0x1AFE5C2D),
  );

  /// 根据类型获取主题色
  static ThemeColorData getByType(ThemeColorType type) {
    switch (type) {
      case ThemeColorType.blue:
        return blue;
      case ThemeColorType.green:
        return green;
      case ThemeColorType.red:
        return red;
      case ThemeColorType.pink:
        return pink;
      case ThemeColorType.orange:
        return orange;
    }
  }

  /// 根据状态码获取主题色（对应后台配置）
  static ThemeColorData getByStatus(int status) {
    switch (status) {
      case 1:
        return blue;
      case 2:
        return green;
      case 3:
        return red;
      case 4:
        return pink;
      case 5:
        return orange;
      default:
        return red;
    }
  }
}
