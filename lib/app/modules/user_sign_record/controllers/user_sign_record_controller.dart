import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';

class UserSignRecordController extends GetxController {
  final UserProvider _userProvider = UserProvider();

  // 签到记录列表
  final RxList<dynamic> _signRecords = <dynamic>[].obs;
  List<dynamic> get signRecords => _signRecords;

  // 是否正在加载
  final RxBool _isLoading = true.obs;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadSignRecords();
  }

  // 加载签到记录
  Future<void> loadSignRecords() async {
    _isLoading.value = true;
    try {
      final response = await _userProvider.getSignList({
        'page': 1,
        'limit': 20, // 获取更多记录
      });
      if (response.isSuccess && response.data != null) {
        _signRecords.assignAll(response.data!);
      }
    } catch (e) {
      debugPrint('获取签到记录失败: $e');
      FlutterToastPro.showMessage( '获取签到记录失败');
    } finally {
      _isLoading.value = false;
    }
  }

  // 下拉刷新
  @override
  Future<void> refresh() async {
    await loadSignRecords();
  }
}


