import 'package:flutter/material.dart';
import 'package:flutter_unionad/flutter_unionad.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/config/ad_config.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/services/ad_manager.dart';

/// 启动页 - 开屏广告
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _hasNavigated = false;
  bool _sdkInitialized = false;

  @override
  void initState() {
    super.initState();
    _initAdAndShow();
  }

  /// 初始化广告SDK并显示开屏广告
  Future<void> _initAdAndShow() async {
    // 初始化广告SDK
    final success = await AdManager.instance.init();
    
    if (mounted) {
      if (success) {
        setState(() {
          _sdkInitialized = true;
        });
      } else {
        // 初始化失败，直接跳转主页
        _navigateToMain();
        return;
      }
    }

    // 设置超时保护，防止广告加载失败时卡住
    Future.delayed(const Duration(milliseconds: AdConfig.splashTimeout + 1000), () {
      if (!_hasNavigated && mounted) {
        _navigateToMain();
      }
    });
  }

  /// 跳转到主页
  void _navigateToMain() {
    if (_hasNavigated) return;
    _hasNavigated = true;
    Get.offAllNamed(AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 开屏广告容器 - 只有SDK初始化成功后才显示
          if (_sdkInitialized && !_hasNavigated)
            FlutterUnionad.splashAdView(
              // Android广告位ID
              androidCodeId: AdConfig.splashAdId,
              // iOS广告位ID
              iosCodeId: AdConfig.splashAdId,
              // 是否支持DeepLink
              supportDeepLink: true,
              // 广告超时时间（毫秒）
              timeout: AdConfig.splashTimeout,
              // 是否隐藏跳过按钮
              hideSkip: false,
              // 广告回调
              callBack: FlutterUnionadSplashCallBack(
                onShow: () {
                  debugPrint('开屏广告展示成功');
                },
                onClick: () {
                  debugPrint('开屏广告被点击');
                },
                onSkip: () {
                  debugPrint('开屏广告被跳过');
                  _navigateToMain();
                },
                onFinish: () {
                  debugPrint('开屏广告播放完成');
                  _navigateToMain();
                },
                onFail: (dynamic error) {
                  debugPrint('开屏广告加载失败: $error');
                  _navigateToMain();
                },
              ),
            ),

          // 底部Logo区域（可选）
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // 应用Logo
                Image.asset(
                  'assets/images/logo.png',
                  width: 80,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  '数航商道',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
