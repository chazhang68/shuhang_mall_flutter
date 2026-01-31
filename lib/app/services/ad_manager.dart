import 'package:flutter/foundation.dart';

/// 广告管理器（模拟实现）
/// 对应原 uni-ad 广告功能
/// 注意：穿山甲SDK暂时禁用，待兼容性问题解决后再启用
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

  /// 初始化广告SDK（模拟）
  Future<bool> init() async {
    if (_isInitialized) return true;

    try {
      // 模拟初始化延迟
      await Future.delayed(const Duration(milliseconds: 100));

      _isInitialized = true;
      debugPrint('广告SDK初始化成功（模拟模式）');
      return true;
    } catch (e) {
      debugPrint('广告SDK初始化失败: $e');
      return false;
    }
  }

  /// 预加载激励视频广告（模拟）
  Future<void> preloadRewardedVideoAd() async {
    if (!_isInitialized) {
      await init();
    }

    if (_isAdLoading) return;

    _isAdLoading = true;
    debugPrint('开始预加载激励视频广告...（模拟模式）');

    try {
      // 模拟加载延迟
      await Future.delayed(const Duration(milliseconds: 500));

      _isAdLoading = false;
      debugPrint('激励视频广告预加载成功（模拟模式）');
    } catch (e) {
      _isAdLoading = false;
      debugPrint('激励视频广告预加载失败: $e');
    }
  }

  /// 显示激励视频广告（模拟）
  /// 在模拟模式下，直接触发奖励回调
  Future<bool> showRewardedVideoAd({
    Function()? onClose,
    Function()? onReward,
    Function(String)? onError,
  }) async {
    if (!_isInitialized) {
      final success = await init();
      if (!success) {
        onError?.call('广告SDK初始化失败');
        return false;
      }
    }

    onAdClose = onClose;
    onAdReward = onReward;
    onAdError = onError;

    try {
      debugPrint('显示激励视频广告（模拟模式）');

      // 模拟广告播放
      await Future.delayed(const Duration(seconds: 2));

      // 模拟奖励回调
      onAdReward?.call();
      onAdClose?.call();

      return true;
    } catch (e) {
      debugPrint('显示激励视频广告失败: $e');
      onError?.call(e.toString());
      return false;
    }
  }

  /// 检查SDK是否已初始化
  bool get isInitialized => _isInitialized;

  /// 检查是否正在加载
  bool get isAdLoading => _isAdLoading;
}
