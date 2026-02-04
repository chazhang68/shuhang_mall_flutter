import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/core/constants/app_images.dart';
import 'package:shuhang_mall_flutter/app/modules/home/main_page.dart';
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
  bool _showSplashContent = true; // 显示启动页内容
  bool _adLoaded = false; // 广告是否加载完成
  bool _minTimeReached = false; // 最小显示时间是否已到
  DateTime? _startTime; // 启动时间

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initAndShowAd();
  }

  /// 初始化并显示开屏广告
  Future<void> _initAndShowAd() async {
    debugPrint('🚀 开屏页面：开始加载开屏广告');
    debugPrint('📱 广告位ID: ${AdConfig.splashAdId}');
    debugPrint('📱 应用ID: ${AdConfig.appId}');

    // 延迟一小段时间，确保SDK完全启动
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      _loadNativeSplashAd();
    }

    // 设置最小显示时间（5秒）- 启动页至少停留5秒
    Future.delayed(const Duration(seconds: 5), () {
      debugPrint('⏰ 启动页最小显示时间（5秒）已到');
      if (mounted) {
        setState(() {
          _minTimeReached = true;
        });
        // 如果广告已加载，显示广告；否则等待广告或超时
        if (_adLoaded) {
          debugPrint('✅ 广告已加载，准备显示');
          setState(() {
            _showSplashContent = false;
          });
        }
      }
    });

    // 设置强制跳转时间（6秒）- 如果6秒后还在启动页，强制跳转
    Future.delayed(const Duration(seconds: 6), () {
      if (!_hasNavigated && _showSplashContent && mounted) {
        debugPrint('⚠️ 启动页显示超过6秒，强制跳转主页');
        _navigateToMain();
      }
    });

    // 设置最大等待时间（8秒）- 总超时
    Future.delayed(const Duration(seconds: 8), () {
      if (!_hasNavigated && mounted) {
        debugPrint('⏰ 总超时（8秒），强制跳转主页');
        _navigateToMain();
      }
    });
  }

  /// 加载原生开屏广告
  void _loadNativeSplashAd() {
    debugPrint('📱 开始加载开屏广告，广告位ID: ${AdConfig.splashAdId}');

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
    debugPrint('📢 开屏广告事件: action=${ret.action}, msg=${ret.msg}');

    if (ret.action == ZJEventAction.onAdShow) {
      // 广告开始展示
      debugPrint('✅ 开屏广告展示中');
      if (mounted) {
        setState(() {
          _adLoaded = true;
          // 只有在最小时间已到时才隐藏启动页
          if (_minTimeReached) {
            _showSplashContent = false;
          }
        });
      }
    } else if (ret.action == ZJEventAction.onAdClick) {
      debugPrint('👆 开屏广告点击');
    } else if (ret.action == ZJEventAction.onAdClose) {
      debugPrint('❌ 开屏广告关闭');
      _navigateToMain();
    } else if (ret.action == ZJEventAction.onAdError) {
      debugPrint('⚠️ 开屏广告错误: ${ret.msg}');
      // 广告加载失败，等待最小显示时间后跳转
      _waitAndNavigate();
    } else {
      debugPrint('ℹ️ 开屏广告其他事件: ${ret.action}');
    }
  }

  /// 等待最小显示时间后跳转
  Future<void> _waitAndNavigate() async {
    if (_minTimeReached) {
      // 最小时间已到，立即跳转
      _navigateToMain();
    } else {
      // 等待最小时间（5秒）
      final elapsed = DateTime.now().difference(_startTime!).inMilliseconds;
      final remaining = 5000 - elapsed;
      if (remaining > 0) {
        debugPrint('⏰ 等待最小显示时间，剩余 ${remaining}ms');
        await Future.delayed(Duration(milliseconds: remaining));
      }
      _navigateToMain();
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
    // 确保背景始终是白色
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 启动页内容 - 简洁版本，不显示任何文字提示
            if (_showSplashContent)
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
                    const SizedBox(height: 30),
                    // 加载动画 - 不显示任何文字
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

            // 底部版权信息
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: const Text(
                '© 2024 数航商道',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
            ),

            // Debug模式：显示状态信息
            if (AdConfig.isDebug)
              Positioned(
                top: 50,
                left: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '启动页显示: ${_showSplashContent ? "是" : "否"}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        '最小时间: ${_minTimeReached ? "已到" : "未到"}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        '广告状态: ${_adLoaded ? "已加载" : "加载中"}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        '已跳转: ${_hasNavigated ? "是" : "否"}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
