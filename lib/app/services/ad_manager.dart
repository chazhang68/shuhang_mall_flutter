import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:zjsdk_android/zj_android.dart';
import 'package:zjsdk_android/zj_custom_controller.dart';
import 'package:zjsdk_android/event/zj_event.dart';
import 'package:zjsdk_android/event/event_action.dart';
import 'package:shuhang_mall_flutter/app/config/ad_config.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';

/// ZJSDK 广告管理器 (Android)
/// 统一管理广告SDK
class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  static AdManager get instance => _instance;

  bool _isInitialized = false;
  bool _isStarted = false;
  bool _isAdLoading = false;
  bool _isAdShowing = false; // 新增：标记广告是否正在展示
  bool _hasRetryOnExpired =
      false; // 标记当前这一轮展示是否已经针对“广告过期”重试过一次

  /// 获取当前用户ID，用于激励视频 userId
  String _getCurrentUserId() {
    try {
      final app = AppController.to;
      final uid = app.userInfo?.uid ?? app.uid;
      debugPrint('📱 激励视频用户ID: uid=$uid');
      if (uid != 0) {
        return uid.toString();
      }
    } catch (e) {
      debugPrint('⚠️ 获取当前用户ID失败: $e');
    }
    // 未登录时使用设备OAID或空字符串，不使用固定测试ID
    return '';
  }

  /// 初始化广告SDK（不启动）
  /// 可以在用户同意隐私政策前调用
  Future<void> initWithoutStart() async {
    if (_isInitialized) {
      debugPrint('✅ ZJSDK广告SDK已经初始化，无需重复初始化');
      return;
    }

    try {
      debugPrint('🔧 开始初始化ZJSDK广告SDK...');
      debugPrint('📱 AppId: ${AdConfig.appId}');
      debugPrint('🐛 Debug模式: ${AdConfig.isDebug}');

      ZJAndroid.initWithoutStart(
        AdConfig.appId,
        isDebug: AdConfig.isDebug,
        gdpr: AdConfig.gdpr,
        coppa: AdConfig.coppa,
        ccpa: AdConfig.ccpa,
        age: AdConfig.age,
        customController: ZJCustomController(
          canUseAndroidId: true,
          canUsePhoneState: true,
          canUseOaid: true,
          canReadLocation: true,
          canUseNetworkState: true,
          canUseStoragePermission: true,
        ),
      );

      _isInitialized = true;
      debugPrint('✅ ZJSDK广告SDK初始化成功（未启动）');
    } catch (e) {
      debugPrint('❌ ZJSDK广告SDK初始化失败: $e');
    }
  }

  /// 启动广告SDK
  /// 需要在用户同意隐私政策后调用
  Future<bool> start() async {
    if (!_isInitialized) {
      await initWithoutStart();
    }

    if (_isStarted) {
      debugPrint('✅ ZJSDK广告SDK已经启动，无需重复启动');
      return true;
    }

    try {
      debugPrint('🚀 启动ZJSDK广告SDK...');

      final completer = Completer<bool>();

      ZJAndroid.start(
        onStartListener: (ret) {
          debugPrint('📢 ZJSDK启动回调: action=${ret.action}, msg=${ret.msg}');

          if (ret.action == ZJEventAction.startSuccess) {
            debugPrint('✅ ZJSDK SDK启动成功');
            _isStarted = true;
            if (!completer.isCompleted) completer.complete(true);
          } else {
            debugPrint('⚠️ ZJSDK SDK启动失败: ${ret.msg}');
            if (!completer.isCompleted) completer.complete(false);
          }
        },
      );

      // 等待回调，最多等3秒
      final result = await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('⏰ ZJSDK启动超时（3秒），当前状态: $_isStarted');
          return _isStarted;
        },
      );

      debugPrint('⏰ ZJSDK启动完成，结果: $result, 当前状态: $_isStarted');
      return result;
    } catch (e) {
      debugPrint('❌ ZJSDK广告SDK启动异常: $e');
      return false;
    }
  }

  /// 预加载激励视频广告
  ///
  /// 显示激励视频广告
  Future<bool> showRewardedVideoAd({
    Function()? onShow,
    Function()? onClick,
    Function()? onReward,
    Function()? onClose,
    Function(String)? onError,
  }) async {
    // 防止重复调用
    if (_isAdShowing) {
      debugPrint('⚠️ 广告正在展示中，忽略重复调用');
      return false;
    }

    if (_isAdLoading) {
      debugPrint('⚠️ 广告正在加载中，忽略重复调用');
      return false;
    }

    if (!_isStarted) {
      final started = await start();
      if (!started) {
        onError?.call('广告SDK未启动');
        return false;
      }
    }

    try {
      // 开启新一轮展示时，重置“过期重试”标记
      _hasRetryOnExpired = false;
      _loadAndShowRewardVideo(onShow, onClick, onReward, onClose, onError);
      return true;
    } catch (e) {
      debugPrint('显示激励视频广告失败: $e');
      _isAdLoading = false;
      _isAdShowing = false;
      onError?.call(e.toString());
      return false;
    }
  }

  /// 内部方法：加载并展示激励视频广告
  void _loadAndShowRewardVideo(
    Function()? onShow,
    Function()? onClick,
    Function()? onReward,
    Function()? onClose,
    Function(String)? onError,
  ) {
    final userId = _getCurrentUserId();
    debugPrint('准备加载并显示激励视频广告，userId=$userId');
    _isAdLoading = true;

    // 先加载广告，加载成功后自动显示
    ZJAndroid.loadRewardVideo(
      AdConfig.rewardVideoAdId,
      userId,
      (ret) {
        _handleRewardVideoCallback(
          ret,
          onShow,
          onClick,
          onReward,
          onClose,
          onError,
        );
      },
      isPreLoad: false, // 不是预加载，加载完成后立即显示
    );
  }

  /// 处理激励视频回调
  void _handleRewardVideoCallback(
    ZJEvent ret,
    Function()? onShow,
    Function()? onClick,
    Function()? onReward,
    Function()? onClose,
    Function(String)? onError,
  ) {
    debugPrint('📢 激励视频事件: ${ret.action}, msg: ${ret.msg}');

    if (ret.action == ZJEventAction.onAdLoaded) {
      debugPrint('✅ 激励视频加载成功');
      _isAdLoading = false;
    } else if (ret.action == ZJEventAction.onAdShow) {
      debugPrint('✅ 激励视频展示');
      _isAdLoading = false;
      _isAdShowing = true; // 标记广告正在展示
      onShow?.call();
    } else if (ret.action == ZJEventAction.onAdClick) {
      debugPrint('👆 激励视频点击');
      onClick?.call();
    } else if (ret.action == ZJEventAction.onAdRewardVerify) {
      debugPrint('🎁 激励视频发奖');
      onReward?.call();
    } else if (ret.action == ZJEventAction.onAdClose) {
      debugPrint('❌ 激励视频关闭');
      _isAdLoading = false;
      _isAdShowing = false; // 重置展示状态
      _hasRetryOnExpired = false; // 这一轮展示已结束，重置过期重试标记
      onClose?.call();
    } else if (ret.action == ZJEventAction.onAdError) {
      final msg = ret.msg ?? '未知错误';
      debugPrint('⚠️ 激励视频错误: $msg');
      _isAdLoading = false;
      _isAdShowing = false; // 重置展示状态
      // 特殊处理：预加载超过20分钟后会返回“广告已过期，请重新加载”
      if (msg.contains('广告已过期，请重新加载')) {
        if (_hasRetryOnExpired) {
          debugPrint('⚠️ 激励视频已过期且已重试一次，本次不再继续重试');
          onError?.call(msg);
        } else {
          debugPrint('🔁 激励视频已过期，开始重新加载并展示');
          _hasRetryOnExpired = true;
          // 直接重新加载并展示一次（等同于重新调用加载和展示的方法）
          _loadAndShowRewardVideo(
            onShow,
            onClick,
            onReward,
            onClose,
            onError,
          );
        }
      } else {
        onError?.call(msg);
      }
    }
  }

  /// 加载并显示插全屏广告
  Future<bool> showInterstitialAd({
    Function()? onShow,
    Function()? onClick,
    Function()? onClose,
    Function(String)? onError,
  }) async {
    if (!_isStarted) {
      final started = await start();
      if (!started) {
        onError?.call('广告SDK未启动');
        return false;
      }
    }

    try {
      debugPrint('准备显示插全屏广告');

      ZJAndroid.interstitial(
        AdConfig.interstitialAdId,
        videoSoundEnable: true,
        interstitialListener: (ret) {
          _handleInterstitialCallback(ret, onShow, onClick, onClose, onError);
        },
      );

      return true;
    } catch (e) {
      debugPrint('显示插全屏广告失败: $e');
      onError?.call(e.toString());
      return false;
    }
  }

  /// 处理插全屏广告回调
  void _handleInterstitialCallback(
    ZJEvent ret,
    Function()? onShow,
    Function()? onClick,
    Function()? onClose,
    Function(String)? onError,
  ) {
    if (ret.action == ZJEventAction.onAdShow) {
      debugPrint('插全屏广告展示');
      onShow?.call();
    } else if (ret.action == ZJEventAction.onAdClick) {
      debugPrint('插全屏广告点击');
      onClick?.call();
    } else if (ret.action == ZJEventAction.onAdClose) {
      debugPrint('插全屏广告关闭');
      onClose?.call();
    } else if (ret.action == ZJEventAction.onAdError) {
      debugPrint('插全屏广告错误: ${ret.msg}');
      onError?.call(ret.msg ?? '未知错误');
    }
  }

  /// 检查SDK是否已初始化
  bool get isInitialized => _isInitialized;

  /// 检查SDK是否已启动
  bool get isStarted => _isStarted;

  /// 检查是否正在加载
  bool get isAdLoading => _isAdLoading;

  /// 检查广告是否正在展示
  bool get isAdShowing => _isAdShowing;
}
