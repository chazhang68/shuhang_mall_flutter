/// 应用配置
/// 对应原 config/app.js
class AppConfig {
  /// API 基础地址
  static const String httpRequestUrl = 'https://test.shsd.top';

  /// API 路径前缀
  static const String apiPrefix = '/api/';

  /// 完整 API 地址
  static String get apiUrl => '$httpRequestUrl$apiPrefix';

  /// Token 请求头名称 - 必须与后端一致
  static const String tokenName =
      'Authori-zation'; // 后端使用的是 Authori-zation (带连字符)

  /// 系统版本号
  static const int systemVersion = 107;

  /// 请求超时时间（毫秒）
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  /// 请求头
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Form-type': 'app',
  };

  /// WebSocket 配置
  static const String wsUrl = 'wss://test.shsd.top/ws';

  /// 是否开启调试模式
  static const bool isDebug = true;
}

/// 过期时间配置
class ExpireConfig {
  /// Token 默认过期时间（秒）
  static const int tokenExpire = 86400 * 30; // 30天

  /// 验证码过期时间（秒）
  static const int codeExpire = 60;
}
