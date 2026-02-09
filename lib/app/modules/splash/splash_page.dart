import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/core/constants/app_images.dart';
import 'package:shuhang_mall_flutter/app/modules/home/main_page.dart';
import 'package:shuhang_mall_flutter/app/services/ad_manager.dart';
import 'package:zjsdk_android/zj_android.dart';
import 'package:zjsdk_android/event/zj_event.dart';
import 'package:zjsdk_android/event/event_action.dart';
import 'package:shuhang_mall_flutter/app/config/ad_config.dart';

/// 启动页 - 开屏广告
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _hasNavigated = false;
  bool _adRequested = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    debugPrint('🚀 启动页初始化');
    debugPrint('📱 广告SDK状态: initialized=${AdManager.instance.isInitialized}, started=${AdManager.instance.isStarted}');

    // 延迟500ms确保页面渲染
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // 启动SDK（main.dart中只做了初始化，这里完成启动）
    bool sdkReady = AdManager.instance.isStarted;
    if (!sdkReady) {
      debugPrint('⏳ SDK尚未启动，开始启动...');
      try {
        sdkReady = await AdManager.instance.start();
        debugPrint('🎯 SDK启动结果: $sdkReady');
      } catch (e) {
        debugPrint('❌ SDK启动异常: $e');
        sdkReady = false;
      }
    }

    if (!mounted) return;

    if (sdkReady) {
      debugPrint('✅ SDK已就绪，加载开屏广告');
      _loadSplashAd();
    } else {
      debugPrint('⚠️ SDK启动失败，直接跳转首页');
      _navigateToMain();
      return;
    }

    // 5秒超时：如果广告没有任何回调（既没成功也没失败），强制跳转
    Future.delayed(const Duration(seconds: 5), () {
      if (!_hasNavigated && mounted) {
        debugPrint('⏰ 广告超时（5秒），强制跳转主页');
        _navigateToMain();
      }
    });
  }

  /// 加载开屏广告
  void _loadSplashAd() {
    if (_adRequested) return;
    _adRequested = true;

    debugPrint('📱 开始加载开屏广告，广告位ID: ${AdConfig.splashAdId}');

    try {
      ZJAndroid.loadSplashAd(
        AdConfig.splashAdId,
        bgResType: 'default',
        splashListener: (ret) {
          _handleSplashAdEvent(ret);
        },
      );
    } catch (e) {
      debugPrint('❌ 开屏广告加载异常: $e');
      _navigateToMain();
    }
  }

  /// 处理开屏广告事件
  void _handleSplashAdEvent(ZJEvent ret) {
    debugPrint('📢 开屏广告事件: action=${ret.action}, msg=${ret.msg}');

    if (ret.action == ZJEventAction.onAdShow) {
      debugPrint('✅ 开屏广告展示中');
    } else if (ret.action == ZJEventAction.onAdClick) {
      debugPrint('👆 开屏广告点击');
    } else if (ret.action == ZJEventAction.onAdClose) {
      debugPrint('❌ 开屏广告关闭');
      _navigateToMain();
    } else if (ret.action == ZJEventAction.onAdError) {
      debugPrint('⚠️ 开屏广告错误: ${ret.msg}');
      _navigateToMain();
    } else {
      debugPrint('ℹ️ 开屏广告其他事件: ${ret.action}');
    }
  }

  /// 跳转到主页
  void _navigateToMain() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    debugPrint('🏠 准备跳转到主页');
    debugPrint('📍 当前路由: ${Get.currentRoute}');
    debugPrint('📍 mounted状态: $mounted');

    if (!mounted) {
      debugPrint('❌ Widget已销毁，无法跳转');
      return;
    }

    // 方案1：使用路由名称跳转（推荐）
    try {
      debugPrint('🚀 方案1：使用Get.offAllNamed跳转到 ${AppRoutes.main}');
      Get.offAllNamed(AppRoutes.main, predicate: (route) => false);
      debugPrint('✅ Get.offAllNamed跳转命令已执行');
      return;
    } catch (e, stackTrace) {
      debugPrint('❌ Get.offAllNamed跳转失败: $e');
      debugPrint('❌ 堆栈: $stackTrace');
    }

    // 方案2：使用Get.offAll传递Widget实例
    try {
      debugPrint('🚀 方案2：使用Get.offAll跳转到MainPage实例');
      Get.offAll(
        () => const MainPage(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );
      debugPrint('✅ Get.offAll跳转命令已执行');
      return;
    } catch (e, stackTrace) {
      debugPrint('❌ Get.offAll跳转失败: $e');
      debugPrint('❌ 堆栈: $stackTrace');
    }

    // 方案3：使用Navigator（最后的备用方案）
    try {
      debugPrint('🚀 方案3：使用Navigator跳转');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainPage()),
        (route) => false,
      );
      debugPrint('✅ 使用Navigator跳转成功');
    } catch (e2, stackTrace2) {
      debugPrint('❌ Navigator跳转也失败: $e2');
      debugPrint('❌ 堆栈: $stackTrace2');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppImages.logo,
                    width: 120,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.image,
                          size: 60,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '数航商道',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '优质商品，品质生活',
                    style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
                  ),
                  const SizedBox(height: 30),
                  const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFFF5A5A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Text(
                '© 2024 数航商道',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
