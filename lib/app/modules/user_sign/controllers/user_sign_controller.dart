import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';

class UserSignController extends GetxController {
  final UserProvider _userProvider = UserProvider();

  // 用户信息
  final Rx<Map<String, dynamic>?> _userInfo = Rx<Map<String, dynamic>?>(null);
  Map<String, dynamic>? get userInfo => _userInfo.value;

  // 签到配置列表
  final RxList<dynamic> _signSystemList = <dynamic>[].obs;
  List<dynamic> get signSystemList => _signSystemList;

  // 签到记录列表
  final RxList<dynamic> _signList = <dynamic>[].obs;
  List<dynamic> get signList => _signList;

  // 累计签到天数
  final RxList<int> _signCount = <int>[].obs;
  List<int> get signCount => _signCount;

  // 当前签到索引
  final RxInt _signIndex = 0.obs;
  int get signIndex => _signIndex.value;

  // 是否已签到
  final RxBool _isSignedToday = false.obs;
  bool get isSignedToday => _isSignedToday.value;

  // 获得的积分
  final RxInt _receivedIntegral = 0.obs;
  int get receivedIntegral => _receivedIntegral.value;

  // 是否显示签到成功弹窗
  final RxBool _showSignSuccessDialog = false.obs;
  bool get showSignSuccessDialog => _showSignSuccessDialog.value;

  @override
  void onInit() {
    super.onInit();
    loadSignData();
  }

  // 加载签到数据
  Future<void> loadSignData() async {
    await getUserInfo();
    await getSignSystem();
    await getSignList();
  }

  // 获取用户信息
  Future<void> getUserInfo() async {
    try {
      final response = await _userProvider.postSignUser({'sign': 1});
      if (response.isSuccess && response.data != null) {
        final userData = response.data!;
        // 确保积分是整数
        userData.integral = (userData.integral ?? 0).round();
        _userInfo.value = userData;

        // 格式化累计签到天数
        final sumSginDay = (userData['sum_sgin_day'] ?? 0) as int;
        _signCount.assignAll(_prefixInteger(sumSginDay, 4));
        _signIndex.value = (userData['sign_num'] ?? 0) as int;
        _isSignedToday.value = (userData['is_day_sgin'] ?? false) as bool;
      }
    } catch (e) {
      debugPrint('获取用户签到信息失败: $e');
    }
  }

  // 获取签到配置
  Future<void> getSignSystem() async {
    try {
      final response = await _userProvider.getSignConfig();
      if (response.isSuccess && response.data != null) {
        _signSystemList.assignAll(response.data!);
      }
    } catch (e) {
      debugPrint('获取签到配置失败: $e');
    }
  }

  // 获取签到记录
  Future<void> getSignList() async {
    try {
      final response = await _userProvider.getSignList({'page': 1, 'limit': 3});
      if (response.isSuccess && response.data != null) {
        _signList.assignAll(response.data!);
      }
    } catch (e) {
      debugPrint('获取签到记录失败: $e');
    }
  }

  // 用户签到
  Future<void> sign() async {
    if (_isSignedToday.value) {
      Get.snackbar('提示', '您今日已签到!');
      return;
    }

    try {
      final response = await _userProvider.setSignIntegral();
      if (response.isSuccess && response.data != null) {
        _showSignSuccessDialog.value = true;
        _receivedIntegral.value = response.data!['integral'] ?? 0;

        // 更新签到状态
        _signIndex.value = (_signIndex.value + 1) > _signSystemList.length
            ? 1
            : _signIndex.value + 1;

        final sumSginDay = ((_userInfo.value?['sum_sgin_day'] ?? 0) as int) + 1;
        _signCount.assignAll(_prefixInteger(sumSginDay, 4));
        _isSignedToday.value = true;

        // 更新用户积分
        if (_userInfo.value != null) {
          final currentIntegral = (_userInfo.value!['integral'] ?? 0) as double;
          _userInfo.value!['integral'] = currentIntegral + _receivedIntegral.value.toDouble();
        }

        // 重新获取最新签到记录
        await getSignList();
      }
    } catch (e) {
      Get.snackbar('签到失败', e.toString());
    }
  }

  // 跳转到签到记录页面
  void goToSignRecord() {
    Get.toNamed('/user/sign-list');
  }

  // 关闭签到成功弹窗
  void closeSignSuccessDialog() {
    _showSignSuccessDialog.value = false;
  }

  // 数字分割为数组
  List<int> _prefixInteger(int num, int length) {
    final str = num.toString();
    final paddedStr = str.padLeft(length, '0');
    return paddedStr.split('').map((e) => int.parse(e)).toList();
  }

  // 数字转中文
  String rp(int n) {
    const cnum = ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九'];
    var s = '';
    final str = n.toString();
    for (int i = 0; i < str.length; i++) {
      s += cnum[int.parse(str[i])];
    }
    return s;
  }
}
