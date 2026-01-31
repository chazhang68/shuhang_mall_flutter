import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地缓存工具类
/// 对应原 uni-app 项目的 utils/cache.js
class Cache {
  static SharedPreferences? _prefs;

  /// 初始化
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 获取 SharedPreferences 实例
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('Cache not initialized. Call Cache.init() first.');
    }
    return _prefs!;
  }

  /// 设置字符串
  static Future<bool> setString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  /// 获取字符串
  static String? getString(String key) {
    return prefs.getString(key);
  }

  /// 设置整数
  static Future<bool> setInt(String key, int value) async {
    return await prefs.setInt(key, value);
  }

  /// 获取整数
  static int? getInt(String key) {
    return prefs.getInt(key);
  }

  /// 设置布尔值
  static Future<bool> setBool(String key, bool value) async {
    return await prefs.setBool(key, value);
  }

  /// 获取布尔值
  static bool? getBool(String key) {
    return prefs.getBool(key);
  }

  /// 设置双精度浮点数
  static Future<bool> setDouble(String key, double value) async {
    return await prefs.setDouble(key, value);
  }

  /// 获取双精度浮点数
  static double? getDouble(String key) {
    return prefs.getDouble(key);
  }

  /// 设置字符串列表
  static Future<bool> setStringList(String key, List<String> value) async {
    return await prefs.setStringList(key, value);
  }

  /// 获取字符串列表
  static List<String>? getStringList(String key) {
    return prefs.getStringList(key);
  }

  /// 设置 JSON 对象
  static Future<bool> setJson(String key, Map<String, dynamic> value) async {
    return await prefs.setString(key, jsonEncode(value));
  }

  /// 获取 JSON 对象
  static Map<String, dynamic>? getJson(String key) {
    final String? value = prefs.getString(key);
    if (value == null) return null;
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// 设置带过期时间的缓存
  static Future<bool> setWithExpire(
    String key,
    dynamic value, {
    required Duration expire,
  }) async {
    final expireTime = DateTime.now().add(expire).millisecondsSinceEpoch;
    final data = {
      'value': value,
      'expire': expireTime,
    };
    return await prefs.setString(key, jsonEncode(data));
  }

  /// 获取带过期时间的缓存
  static dynamic getWithExpire(String key) {
    final String? dataStr = prefs.getString(key);
    if (dataStr == null) return null;

    try {
      final data = jsonDecode(dataStr) as Map<String, dynamic>;
      final expireTime = data['expire'] as int;
      
      if (DateTime.now().millisecondsSinceEpoch > expireTime) {
        // 已过期，删除缓存
        remove(key);
        return null;
      }
      
      return data['value'];
    } catch (e) {
      return null;
    }
  }

  /// 检查是否包含某个 key
  static bool has(String key) {
    return prefs.containsKey(key);
  }

  /// 删除指定 key
  static Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }

  /// 清空所有缓存
  static Future<bool> clear() async {
    return await prefs.clear();
  }

  /// 获取当前时间戳（秒）
  static int time() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }
}

/// 缓存 Key 常量
/// 对应原 config/cache.js
class CacheKey {
  // 用户相关
  static const String token = 'LOGIN_TOKEN';
  static const String userInfo = 'USER_INFO';
  static const String uid = 'USER_UID';
  static const String expires = 'EXPIRES_TIME';
  static const String spread = 'SPREAD';
  static const String loginType = 'LOGIN_TYPE';
  
  // 设置相关
  static const String viewColor = 'VIEW_COLOR';
  static const String colorStatus = 'COLOR_STATUS';
  static const String locale = 'LOCALE';
  static const String langVersion = 'LANG_VERSION';
  static const String localeJson = 'LOCALE_JSON';
  
  // 购物车
  static const String cartNum = 'CART_NUM';
  static const String footerAddCart = 'FOOTER_ADDCART';
  
  // 其他
  static const String copyRight = 'COPY_RIGHT';
  static const String mpVersionIsNew = 'MP_VERSION_ISNEW';
  static const String isDiy = 'IS_DIY';
  static const String storeInfo = 'STORE_INFO';
  static const String snsapiKey = 'SNSAPI_KEY';
  static const String backUrl = 'BACK_URL'; // 登录后返回的URL
}
