/// ZJSDK 广告配置
/// 统一管理广告位ID和配置参数
class AdConfig {
  // ==================== 应用配置 ====================

  /// ZJSDK 应用ID
  static const String appId = 'Z0062563231';

  /// 应用名称
  static const String appName = '数航商道';

  // ==================== 广告位ID ====================

  /// 开屏广告位ID
  static const String splashAdId = 'J8120762208';

  /// 激励视频广告位ID
  static const String rewardVideoAdId = 'J3449837410';

  /// 插全屏广告位ID
  static const String interstitialAdId = 'J6396345907';

  /// 信息流广告位ID
  static const String feedAdId = 'J2377787779';

  /// 横幅广告位ID
  static const String bannerAdId = 'J2377787779';

  // ==================== 配置参数 ====================

  /// 是否为测试模式（开发时设为true，生产环境设为false）
  static const bool isDebug = true;

  /// GDPR状态：-1为未知，0为用户未授权，1为用户授权
  static const int gdpr = -1;

  /// COPPA状态：-1为未知，0为成人，1为儿童
  static const int coppa = -1;

  /// CCPA状态：-1为未知，0为允许出售，1为不允许出售
  static const int ccpa = -1;

  /// 用户年龄，默认为0
  static const int age = 0;

  /// 测试用户ID
  static const String testUserId = 'test_user_001';

  /// 激励视频奖励名称
  static const String rewardName = '金币';

  /// 激励视频奖励数量
  static const int rewardAmount = 10;
}
