/// 穿山甲广告配置
/// 统一管理广告位ID和配置参数
class AdConfig {
  // ==================== 应用配置 ====================
  
  /// 穿山甲应用ID
  static const String appId = 'Z0062563231';
  
  /// 应用名称
  static const String appName = '数航商道';

  // ==================== 广告位ID ====================
  
  /// 开屏广告位ID
  static const String splashAdId = 'J8120762208';
  
  /// 激励视频广告位ID
  static const String rewardVideoAdId = 'J3449837410';
  
  /// 插屏广告位ID
  static const String interstitialAdId = 'J6396345907';
  
  /// 信息流广告位ID（左右图文-静音）
  static const String feedAdId = 'J2377787779';

  // ==================== 配置参数 ====================
  
  /// 开屏广告超时时间（毫秒）
  static const int splashTimeout = 3500;
  
  /// 信息流广告宽度
  static const double feedAdExpressWidth = 350;
  
  /// 信息流广告高度（0表示自适应）
  static const double feedAdExpressHeight = 0;
  
  /// 是否为测试模式（开发时设为true）
  static const bool isTestMode = false;
  
  /// 是否允许个性化推荐广告
  static const bool allowPersonalizedAd = true;
}
