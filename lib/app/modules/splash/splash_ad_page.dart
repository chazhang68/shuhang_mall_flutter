import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/services/ad_manager.dart';
import 'package:shuhang_mall_flutter/app/config/ad_config.dart';
import 'package:zjsdk_android/zj_android.dart';
import 'package:zjsdk_android/event/zj_event.dart';
import 'package:zjsdk_android/event/event_action.dart';

/// 开屏广告页面（独立页面）
class SplashAdPage extends StatefulWidget {
  const SplashAdPage({super.key});

  @override
  State<SplashAdPage> createState() => _SplashAdPageState();
}

class _SplashAdPageState extends State<SplashAdPage> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    try {
      bool sdkReady = AdManager.instance.isStarted;
      if (!sdkReady) {
        sdkReady = await AdManager.instance.start();
      }

      if (!mounted) return;

      if (sdkReady) {
        ZJAndroid.loadSplashAd(
          AdConfig.splashAdId,
          bgResType: 'default',
          splashListener: (ZJEvent ret) {
            debugPrint('开屏广告事件: action=${ret.action}, msg=${ret.msg}');
            if (ret.action == ZJEventAction.onAdClose ||
                ret.action == ZJEventAction.onAdError) {
              _navigateToMain();
            }
          },
        );
      } else {
        _navigateToMain();
        return;
      }
    } catch (e) {
      debugPrint('开屏广告加载异常: $e');
      _navigateToMain();
      return;
    }

    // 5秒超时，强制跳转
    Future.delayed(const Duration(seconds: 5), () {
      if (!_hasNavigated && mounted) {
        _navigateToMain();
      }
    });
  }

  void _navigateToMain() {
    if (_hasNavigated) return;
    _hasNavigated = true;
    if (!mounted) return;
    Get.offAllNamed(AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.shrink(),
    );
  }
}
