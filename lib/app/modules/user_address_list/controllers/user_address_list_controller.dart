import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/providers/user_provider.dart';

class UserAddressListController extends GetxController {
  final UserProvider _userProvider = UserProvider();

  // 地址列表
  final RxList<dynamic> _addressList = <dynamic>[].obs;
  List<dynamic> get addressList => _addressList;

  // 加载状态
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // 是否加载结束
  final RxBool _loadEnd = false.obs;
  bool get loadEnd => _loadEnd.value;

  // 当前页码
  final RxInt _page = 1.obs;
  int get page => _page.value;

  // 每页数量
  final int _limit = 20;

  // 购物车ID等参数
  String? cartId;
  int pinkId = 0;
  int couponId = 0;
  String news = '';
  int noCoupon = 0;

  @override
  void onInit() {
    super.onInit();
    // 初始化时获取地址列表
    getAddressList(isRefresh: true);
  }

  // 获取地址列表
  Future<void> getAddressList({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        _page.value = 1;
        _loadEnd.value = false;
        _addressList.clear();
      }

      if (_isLoading.value || _loadEnd.value) return;

      _isLoading.value = true;

      final params = {'page': _page.value, 'limit': _limit};

      final response = await _userProvider.getAddressList(params);
      if (response.isSuccess && response.data != null) {
        final newList = response.data as List<dynamic>;

        if (isRefresh) {
          _addressList.assignAll(newList);
        } else {
          _addressList.addAll(newList);
        }

        // 判断是否还有更多数据
        _loadEnd.value = newList.length < _limit;
        if (!_loadEnd.value) {
          _page.value++;
        }
      }
    } catch (e) {
      debugPrint('获取地址列表失败: $e');
      Get.snackbar('错误', '获取地址列表失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // 设置默认地址
  Future<void> setDefaultAddress(int addressId, int index) async {
    try {
      _isLoading.value = true;

      final response = await _userProvider.setAddressDefault(addressId);
      if (response.isSuccess) {
        // 更新本地列表状态
        for (int i = 0; i < _addressList.length; i++) {
          _addressList[i]['is_default'] = (i == index) ? 1 : 0;
        }

        Get.snackbar('成功', '设置成功');
      } else {
        Get.snackbar('错误', response.msg);
      }
    } catch (e) {
      debugPrint('设置默认地址失败: $e');
      Get.snackbar('错误', '设置失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // 删除地址
  Future<void> deleteAddress(int addressId, int index) async {
    try {
      _isLoading.value = true;

      final response = await _userProvider.delAddress(addressId);
      if (response.isSuccess) {
        // 从本地列表中移除
        _addressList.removeAt(index);
        Get.snackbar('成功', '删除成功');
      } else {
        Get.snackbar('错误', response.msg);
      }
    } catch (e) {
      debugPrint('删除地址失败: $e');
      Get.snackbar('错误', '删除失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // 编辑地址
  void editAddress(int addressId) {
    // 传递参数到编辑页面
    Get.toNamed('/user/address', arguments: {'id': addressId.toString()});
  }

  // 添加新地址
  void addNewAddress() {
    Get.toNamed('/user/address');
  }

  // 选择地址并返回（用于订单确认页面）
  void selectAddress(int addressId) {
    // 如果是从订单页面跳转过来的，需要返回订单页面
    // 否则只是普通的查看列表
    Get.back(result: addressId);
  }

  // 上拉加载更多
  void loadMore() {
    if (!_loadEnd.value && !_isLoading.value) {
      getAddressList();
    }
  }
}
