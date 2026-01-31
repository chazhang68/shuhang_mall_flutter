import 'package:get/get.dart';

/// 首页数据控制器
/// 对应原 store/modules/indexData.js
class IndexDataController extends GetxController {
  static IndexDataController get to => Get.find();

  /// 购物车数量
  final _cartNum = ''.obs;
  String get cartNum => _cartNum.value;
  set cartNum(String value) => _cartNum.value = value;

  /// 首页数据
  final _homeData = Rxn<Map<String, dynamic>>();
  Map<String, dynamic>? get homeData => _homeData.value;
  set homeData(Map<String, dynamic>? value) => _homeData.value = value;

  /// 轮播图
  final _bannerList = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get bannerList => _bannerList;
  set bannerList(List<Map<String, dynamic>> value) => _bannerList.value = value;

  /// 菜单列表
  final _menuList = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get menuList => _menuList;
  set menuList(List<Map<String, dynamic>> value) => _menuList.value = value;

  /// 公告列表
  final _newsList = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get newsList => _newsList;
  set newsList(List<Map<String, dynamic>> value) => _newsList.value = value;

  /// 推荐商品
  final _recommendGoods = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get recommendGoods => _recommendGoods;
  set recommendGoods(List<Map<String, dynamic>> value) => _recommendGoods.value = value;

  /// 是否已加载首页数据
  final _isLoaded = false.obs;
  bool get isLoaded => _isLoaded.value;
  set isLoaded(bool value) => _isLoaded.value = value;

  /// 设置购物车数量
  void setCartNum(String num) {
    _cartNum.value = num;
  }

  /// 设置首页数据
  void setHomeData(Map<String, dynamic> data) {
    _homeData.value = data;
    _isLoaded.value = true;

    // 解析数据
    if (data['banner'] != null) {
      _bannerList.value = List<Map<String, dynamic>>.from(data['banner']);
    }
    if (data['menus'] != null) {
      _menuList.value = List<Map<String, dynamic>>.from(data['menus']);
    }
    if (data['news'] != null) {
      _newsList.value = List<Map<String, dynamic>>.from(data['news']);
    }
    if (data['recommend'] != null) {
      _recommendGoods.value = List<Map<String, dynamic>>.from(data['recommend']);
    }
  }

  /// 清空数据
  void clear() {
    _cartNum.value = '';
    _homeData.value = null;
    _bannerList.clear();
    _menuList.clear();
    _newsList.clear();
    _recommendGoods.clear();
    _isLoaded.value = false;
  }
}
