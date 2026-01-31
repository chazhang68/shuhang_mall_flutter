import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/data/models/user_model.dart';
import 'package:shuhang_mall_flutter/app/utils/cache.dart';
import 'package:shuhang_mall_flutter/app/theme/theme_colors.dart';

/// 全局应用控制器
/// 对应原 store/modules/app.js
class AppController extends GetxController {
  static AppController get to => Get.find<AppController>();

  // ==================== 用户状态 ====================

  /// 用户 Token
  final _token = ''.obs;
  String get token => _token.value;
  set token(String value) => _token.value = value;

  /// 用户 ID
  final _uid = 0.obs;
  int get uid => _uid.value;
  set uid(int value) => _uid.value = value;

  /// 用户信息
  final _userInfo = Rxn<UserModel>();
  UserModel? get userInfo => _userInfo.value;
  set userInfo(UserModel? value) => _userInfo.value = value;

  /// 是否已登录
  bool get isLogin => userInfo != null && token.isNotEmpty;

  /// 购物车数量
  final _cartNum = 0.obs;
  int get cartNum => _cartNum.value;
  set cartNum(int value) => _cartNum.value = value;

  // ==================== 主题状态 ====================

  /// 当前主题色
  final _themeColor = ThemeColors.red.obs;
  ThemeColorData get themeColor => _themeColor.value;
  set themeColor(ThemeColorData value) => _themeColor.value = value;

  /// 主题状态码
  final _colorStatus = 3.obs;
  int get colorStatus => _colorStatus.value;

  /// 是否使用 DIY 页面
  final _isDiy = false.obs;
  bool get isDiy => _isDiy.value;
  set isDiy(bool value) => _isDiy.value = value;

  // ==================== 其他状态 ====================

  /// 是否需要绑定手机号
  final _phoneStatus = false.obs;
  bool get phoneStatus => _phoneStatus.value;
  set phoneStatus(bool value) => _phoneStatus.value = value;

  /// 推广人 ID
  final _spreadId = 0.obs;
  int get spreadId => _spreadId.value;
  set spreadId(int value) => _spreadId.value = value;

  /// 页面是否在 iframe 中
  final _isIframe = false.obs;
  bool get isIframe => _isIframe.value;
  set isIframe(bool value) => _isIframe.value = value;

  /// 底部导航栏是否显示
  final _tabbarShow = true.obs;
  bool get tabbarShow => _tabbarShow.value;
  set tabbarShow(bool value) => _tabbarShow.value = value;

  /// 当前语言
  final _locale = 'zh_CN'.obs;
  String get locale => _locale.value;
  set locale(String value) => _locale.value = value;

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
  }

  /// 从缓存加载数据
  void _loadFromCache() {
    // 加载 Token
    final cachedToken = Cache.getString(CacheKey.token);
    if (cachedToken != null) {
      _token.value = cachedToken;
    }

    // 加载用户 ID
    final cachedUid = Cache.getInt(CacheKey.uid);
    if (cachedUid != null) {
      _uid.value = cachedUid;
    }

    // 加载用户信息
    final cachedUserInfo = Cache.getJson(CacheKey.userInfo);
    if (cachedUserInfo != null) {
      _userInfo.value = UserModel.fromJson(cachedUserInfo);
    }

    // 加载主题色
    final cachedColorStatus = Cache.getInt(CacheKey.colorStatus);
    if (cachedColorStatus != null) {
      _colorStatus.value = cachedColorStatus;
      _themeColor.value = ThemeColors.getByStatus(cachedColorStatus);
    }

    // 加载语言
    final cachedLocale = Cache.getString(CacheKey.locale);
    if (cachedLocale != null) {
      _locale.value = cachedLocale;
    }

    // 加载购物车数量
    final cachedCartNum = Cache.getInt(CacheKey.cartNum);
    if (cachedCartNum != null) {
      _cartNum.value = cachedCartNum;
    }

    update();
  }

  /// 登录
  Future<void> login({
    required String token,
    required int uid,
    UserModel? userInfo,
    int? expiresTime,
  }) async {
    _token.value = token;
    _uid.value = uid;
    _userInfo.value = userInfo;

    // 保存到缓存
    await Cache.setString(CacheKey.token, token);
    await Cache.setInt(CacheKey.uid, uid);
    if (userInfo != null) {
      await Cache.setJson(CacheKey.userInfo, userInfo.toJson());
    }
    if (expiresTime != null) {
      await Cache.setInt(CacheKey.expires, expiresTime);
    }

    update();
  }

  /// 退出登录
  Future<void> logout() async {
    _token.value = '';
    _uid.value = 0;
    _userInfo.value = null;
    _cartNum.value = 0;

    // 清除缓存
    await Cache.remove(CacheKey.token);
    await Cache.remove(CacheKey.uid);
    await Cache.remove(CacheKey.userInfo);
    await Cache.remove(CacheKey.expires);
    await Cache.remove(CacheKey.cartNum);

    update();
  }

  /// 更新用户信息
  Future<void> updateUserInfo(UserModel info) async {
    _userInfo.value = info;
    await Cache.setJson(CacheKey.userInfo, info.toJson());
    update();
  }

  /// 更新购物车数量
  Future<void> updateCartNum(int num) async {
    _cartNum.value = num;
    await Cache.setInt(CacheKey.cartNum, num);
  }

  /// 设置主题色
  Future<void> setThemeColor(int status) async {
    _colorStatus.value = status;
    _themeColor.value = ThemeColors.getByStatus(status);
    await Cache.setInt(CacheKey.colorStatus, status);
  }

  /// 设置语言
  Future<void> setLocale(String locale) async {
    _locale.value = locale;
    await Cache.setString(CacheKey.locale, locale);
  }

  /// 设置推广人 ID
  Future<void> setSpreadId(int id) async {
    _spreadId.value = id;
    await Cache.setInt(CacheKey.spread, id);
  }
}
