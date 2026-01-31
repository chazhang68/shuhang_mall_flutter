import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shuhang_mall_flutter/app/utils/cache.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/routes/app_pages.dart';
import 'package:shuhang_mall_flutter/app/bindings/app_binding.dart';
import 'package:shuhang_mall_flutter/app/theme/app_theme.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/theme/theme_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:media_kit/media_kit.dart';

/// 应用入口
/// 对应原 main.js
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  // 初始化缓存
  await Cache.init();

  // 设置状态栏样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 设置屏幕方向
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());

  // 配置 EasyLoading
  _configLoading();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: FlutterToastProWrapper(
        child: GetMaterialApp(
          title: '数航商道',
          debugShowCheckedModeBanner: false,

          // 初始路由
          initialRoute: AppRoutes.main,

          // 路由配置
          getPages: AppPages.pages,

          // 全局依赖注入
          initialBinding: AppBinding(),

          // 主题配置
          theme: AppTheme.defaultTheme,

          // 动态主题（响应式）
          builder: (context, child) {
            return GetBuilder<AppController>(
              builder: (controller) {
                return Theme(
                  data: AppTheme.getTheme(controller.themeColor),
                  child: FlutterEasyLoading(child: child),
                );
              },
            );
          },

          // 默认过渡动画
          defaultTransition: Transition.cupertino,

          // 语言设置
          locale: const Locale('zh', 'CN'),
          fallbackLocale: const Locale('zh', 'CN'),

          // 未知路由处理
          unknownRoute: GetPage(
            name: '/notfound',
            page: () => const Scaffold(body: Center(child: Text('页面未找到'))),
          ),
        ),
      ),
    );
  }
}

/// 配置 EasyLoading
void _configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = ThemeColors.red.primary
    ..backgroundColor = Colors.white
    ..indicatorColor = ThemeColors.red.primary
    ..textColor = const Color(0xFF333333)
    ..maskColor = Colors.black.withAlpha((0.5 * 255).round())
    ..userInteractions = false
    ..dismissOnTap = false;
}
