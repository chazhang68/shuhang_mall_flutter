import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import '../../data/providers/user_provider.dart';
import '../../data/models/user_model.dart';

class UserAccountSafeController extends GetxController {
  final UserProvider _userProvider = UserProvider();

  // 用户信息
  final Rx<UserModel?> _userInfo = Rx<UserModel?>(null);
  UserModel? get userInfo => _userInfo.value;

  // 格式化的手机号码
  final RxString _formattedPhone = ''.obs;
  String get formattedPhone => _formattedPhone.value;

  // 加载状态
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    getUserInfo();
  }

  // 获取用户信息
  Future<void> getUserInfo() async {
    try {
      _isLoading.value = true;
      final response = await _userProvider.getUserInfo();
      if (response.isSuccess && response.data != null) {
        _userInfo.value = response.data!;
        // 格式化手机号码，中间四位用星号代替
        String phone = response.data!.phone;
        if (phone.length >= 11) {
          String formatted = '${phone.substring(0, 3)}****${phone.substring(7)}';
          _formattedPhone.value = formatted;
        } else {
          _formattedPhone.value = phone;
        }
      }
    } catch (e) {
      debugPrint('获取用户信息失败: $e');
      FlutterToastPro.showMessage('获取用户信息失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // 跳转到修改登录密码页面
  void goToUpdateLoginPwd() {
    Get.toNamed('/update-login-pwd');
  }

  // 跳转到修改支付密码页面
  void goToUpdatePaymentPwd() {
    Get.toNamed('/update-payment-pwd');
  }
}
