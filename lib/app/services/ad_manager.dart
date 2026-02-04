import 'package:flutter/foundation.dart';
import 'package:zjsdk_android/zj_android.dart';
import 'package:zjsdk_android/zj_custom_controller.dart';
import 'package:zjsdk_android/event/zj_event.dart';
import 'package:zjsdk_android/event/event_action.dart';
import 'package:shuhang_mall_flutter/app/config/ad_config.dart';

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

      ZJAndroid.start(
        onStartListener: (ret) {
          debugPrint('📢 ZJSDK启动回调: action=${ret.action}, msg=${ret.msg}');

          if (ret.action == ZJEventAction.startSuccess) {
            debugPrint('✅ ZJSDK SDK启动成功');
            _isStarted = true;
          } else {
            debugPrint('⚠️ ZJSDK SDK启动失败: ${ret.msg}');
          }
        },
      );

      // Android 启动是异步的，等待一段时间确保启动完成
      await Future.delayed(const Duration(milliseconds: 800));
      debugPrint('⏰ ZJSDK启动等待完成，当前状态: $_isStarted');
      return true;
    } catch (e) {
      debugPrint('❌ ZJSDK广告SDK启动异常: $e');
      return false;
    }
  }

  /// 预加载激励视频广告
  Future<bool> preloadRewardedVideoAd() async {
    if (!_isStarted) {
      final started = await start();
      if (!started) return false;
    }

    if (_isAdLoading) return false;

    _isAdLoading = true;
    debugPrint('开始预加载激励视频广告...');

    try {
      bool success = false;

      ZJAndroid.loadRewardVideo(AdConfig.rewardVideoAdId, AdConfig.testUserId, (
        ret,
      ) {
        if (ret.action == ZJEventAction.onAdLoaded) {
          debugPrint('激励视频广告预加载成功');
          success = true;
        } else if (ret.action == ZJEventAction.onAdError) {
          debugPrint('激励视频广告预加载失败: ${ret.msg}');
        }
        _isAdLoading = false;
      }, isPreLoad: true);

      return success;
    } catch (e) {
      _isAdLoading = false;
      debugPrint('激励视频广告预加载失败: $e');
      return false;
    }
  }

  /// 显示激励视频广告
  Future<bool> showRewardedVideoAd({
    Function()? onShow,
    Function()? onClick,
    Function()? onReward,
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
      debugPrint('准备显示激励视频广告');

      ZJAndroid.showRewardVideo((ret) {
        _handleRewardVideoCallback(
          ret,
          onShow,
          onClick,
          onReward,
          onClose,
          onError,
        );
      });

      return true;
    } catch (e) {
      debugPrint('显示激励视频广告失败: $e');
      onError?.call(e.toString());
      return false;
    }
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
    if (ret.action == ZJEventAction.onAdShow) {
      debugPrint('激励视频展示');
      onShow?.call();
    } else if (ret.action == ZJEventAction.onAdClick) {
      debugPrint('激励视频点击');
      onClick?.call();
    } else if (ret.action == ZJEventAction.onAdRewardVerify) {
      debugPrint('激励视频发奖');
      onReward?.call();
    } else if (ret.action == ZJEventAction.onAdClose) {
      debugPrint('激励视频关闭');
      onClose?.call();
    } else if (ret.action == ZJEventAction.onAdError) {
      debugPrint('激励视频错误: ${ret.msg}');
      onError?.call(ret.msg ?? '未知错误');
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
}
