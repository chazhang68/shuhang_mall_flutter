import 'package:flutter/foundation.dart';
import 'package:flutter_unionad/flutter_unionad.dart';
import 'package:shuhang_mall_flutter/app/config/ad_config.dart';

/// 广告管理器 - 穿山甲SDK集成
/// 对应原 uni-ad 广告功能
class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  static AdManager get instance => _instance;

  bool _isInitialized = false;
  bool _isAdLoading = false;

  // 广告回调
  Function()? onAdClose;
  Function()? onAdReward;
  Function(String error)? onAdError;

  /// 初始化广告SDK
  Future<bool> init() async {
    if (_isInitialized) return true;

    try {
      debugPrint('开始初始化穿山甲广告SDK...');
      debugPrint('AppId: ${AdConfig.appId}');
      
      final result = await FlutterUnionad.register(
        androidAppId: AdConfig.appId,
        iosAppId: AdConfig.appId,
        useTextureView: true,
        appName: AdConfig.appName,
        allowShowNotify: true,
        debug: AdConfig.isTestMode,
        supportMultiProcess: false,
        useMediation: true,  // 启用GroMore聚合广告
        directDownloadNetworkType: [
          FlutterUnionadNetCode.NETWORK_STATE_WIFI,
          FlutterUnionadNetCode.NETWORK_STATE_4G,
        ],
      );
      
      debugPrint('穿山甲广告SDK register结果: $result');
      
      if (result == true) {
        _isInitialized = true;
        debugPrint('穿山甲广告SDK初始化成功');
        
        // iOS 请求ATT权限（延迟执行，避免影响初始化）
        Future.delayed(const Duration(milliseconds: 500), () {
          FlutterUnionad.requestPermissionIfNecessary();
        });
        
        return true;
      } else {
        debugPrint('穿山甲广告SDK初始化失败: register返回false');
        return false;
      }
    } catch (e) {
      debugPrint('穿山甲广告SDK初始化失败: $e');
      return false;
    }
  }

  /// 预加载激励视频广告
  Future<bool> preloadRewardedVideoAd() async {
    if (!_isInitialized) {
      await init();
    }

    if (_isAdLoading) return false;

    _isAdLoading = true;
    debugPrint('开始预加载激励视频广告...');

    try {
      final result = await FlutterUnionad.loadRewardVideoAd(
        androidCodeId: AdConfig.rewardVideoAdId,
        iosCodeId: AdConfig.rewardVideoAdId,
        rewardName: '积分',
        rewardAmount: 10,
        userID: 'user_${DateTime.now().millisecondsSinceEpoch}',
      );
      _isAdLoading = false;
      debugPrint('激励视频广告预加载${result ? "成功" : "失败"}');
      return result;
    } catch (e) {
      _isAdLoading = false;
      debugPrint('激励视频广告预加载失败: $e');
      return false;
    }
  }

  /// 显示激励视频广告
  Future<bool> showRewardedVideoAd({
    Function()? onClose,
    Function()? onReward,
    Function(String)? onError,
  }) async {
    if (!_isInitialized) {
      final success = await init();
      if (!success) {
        onError?.call('广告SDK未初始化');
        return false;
      }
    }

    onAdClose = onClose;
    onAdReward = onReward;
    onAdError = onError;

    try {
      debugPrint('准备显示激励视频广告');
      final result = await FlutterUnionad.showRewardVideoAd();
      return result;
    } catch (e) {
      debugPrint('显示激励视频广告失败: $e');
      onError?.call(e.toString());
      return false;
    }
  }

  /// 预加载插屏广告
  Future<bool> preloadInterstitialAd() async {
    if (!_isInitialized) {
      await init();
    }

    try {
      final result = await FlutterUnionad.loadFullScreenVideoAdInteraction(
        androidCodeId: AdConfig.interstitialAdId,
        iosCodeId: AdConfig.interstitialAdId,
      );
      debugPrint('插屏广告预加载${result ? "成功" : "失败"}');
      return result;
    } catch (e) {
      debugPrint('插屏广告预加载失败: $e');
      return false;
    }
  }

  /// 显示插屏广告
  Future<bool> showInterstitialAd({
    Function()? onClose,
    Function(String)? onError,
  }) async {
    if (!_isInitialized) {
      final success = await init();
      if (!success) {
        onError?.call('广告SDK未初始化');
        return false;
      }
    }

    try {
      debugPrint('准备显示插屏广告');
      final result = await FlutterUnionad.showFullScreenVideoAdInteraction();
      return result;
    } catch (e) {
      debugPrint('显示插屏广告失败: $e');
      onError?.call(e.toString());
      return false;
    }
  }

  /// 处理激励视频广告回调
  void handleRewardVideoCallback({
    required bool isReward,
    bool isClosed = false,
    String? error,
  }) {
    if (error != null) {
      onAdError?.call(error);
      return;
    }

    if (isReward) {
      onAdReward?.call();
    }

    if (isClosed) {
      onAdClose?.call();
    }
  }

  /// 检查SDK是否已初始化
  bool get isInitialized => _isInitialized;

  /// 检查是否正在加载
  bool get isAdLoading => _isAdLoading;
}
