import 'package:flutter/material.dart';
import 'package:shuhang_mall_flutter/app/theme/theme_colors.dart';

/// 应用主题配置
class AppTheme {
  /// 生成主题数据
  static ThemeData getTheme(ThemeColorData colorData) {
    return ThemeData(
      useMaterial3: true,
      primaryColor: colorData.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colorData.primary,
        primary: colorData.primary,
        secondary: colorData.secondary,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Color(0xFF333333),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: colorData.primary,
        unselectedItemColor: const Color(0xFF999999),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorData.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          minimumSize: const Size(double.infinity, 44),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorData.primary,
          side: BorderSide(color: colorData.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          minimumSize: const Size(double.infinity, 44),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorData.primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorData.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(color: Color(0xFF999999)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEEEEEE),
        thickness: 1,
        space: 1,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorData.primary,
        unselectedLabelColor: const Color(0xFF666666),
        indicatorColor: colorData.primary,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }

  /// 默认主题（红色）
  static ThemeData get defaultTheme => getTheme(ThemeColors.red);
}

/// 常用文本样式
class AppTextStyles {
  // 标题样式
  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF333333),
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFF333333),
  );

  // 正文样式
  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: Color(0xFF333333),
  );

  static const TextStyle bodyGrey = TextStyle(
    fontSize: 14,
    color: Color(0xFF666666),
  );

  static const TextStyle bodyLight = TextStyle(
    fontSize: 14,
    color: Color(0xFF999999),
  );

  // 小字样式
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: Color(0xFF999999),
  );

  static const TextStyle small = TextStyle(
    fontSize: 10,
    color: Color(0xFF999999),
  );

  // 价格样式
  static TextStyle price(Color color, {double size = 16}) => TextStyle(
    fontSize: size,
    fontWeight: FontWeight.w600,
    color: color,
  );
}

/// 常用间距
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  // 页面内边距
  static const EdgeInsets pagePadding = EdgeInsets.all(16);
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets pageVertical = EdgeInsets.symmetric(vertical: 16);
}

/// 常用圆角
class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double round = 999;
}
