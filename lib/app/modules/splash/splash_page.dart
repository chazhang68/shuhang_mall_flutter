import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/services/ad_manager.dart';
import 'package:shuhang_mall_flutter/app/core/constants/app_images.dart';
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
  bool _showSplashAd = false;

  @override
  void initState() {
    super.initState();
    _initAndShowAd();
  }

  /// 初始化并显示开屏广告
  Future<void> _initAndShowAd() async {
    // 启动广告SDK（假设用户已同意隐私政策）
    final started = await AdManager.instance.start();

    if (!started) {
      debugPrint('广告SDK启动失败，直接进入主页');
      _navigateToMain();
      return;
    }

    // 延迟一下再显示广告，确保SDK完全启动
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _showSplashAd = true;
      });

      // 使用原生方式加载开屏广告
      _loadNativeSplashAd();
    }

    // 设置超时保护
    Future.delayed(const Duration(seconds: 5), () {
      if (!_hasNavigated && mounted) {
        debugPrint('开屏广告超时，跳转主页');
        _navigateToMain();
      }
    });
  }

  /// 加载原生开屏广告
  void _loadNativeSplashAd() {
    ZJAndroid.loadSplashAd(
      AdConfig.splashAdId,
      bgResType: 'default',
      splashListener: (ret) {
        _handleSplashAdEvent(ret);
      },
    );
  }

  /// 处理开屏广告事件
  void _handleSplashAdEvent(ZJEvent ret) {
    if (ret.action == ZJEventAction.onAdShow) {
      debugPrint('开屏广告展示');
    } else if (ret.action == ZJEventAction.onAdClick) {
      debugPrint('开屏广告点击');
    } else if (ret.action == ZJEventAction.onAdClose) {
      debugPrint('开屏广告关闭');
      _navigateToMain();
    } else if (ret.action == ZJEventAction.onAdError) {
      debugPrint('开屏广告错误: ${ret.msg}');
      _navigateToMain();
    }
  }

  /// 跳转到主页
  void _navigateToMain() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    if (mounted) {
      Get.offAllNamed(AppRoutes.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 背景
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 应用Logo
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
              ],
            ),
          ),

          // 底部版权信息
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 30,
            left: 0,
            right: 0,
            child: const Text(
              '© 2024 数航商道',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
            ),
          ),
        ],
      ),
    );
  }
}
