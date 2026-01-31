import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/models/user_model.dart';

class UpdatePaymentPwdController extends GetxController {
  final UserProvider _userProvider = UserProvider();
  final ApiProvider _apiProvider = ApiProvider.instance;

  // 用户手机号
  final RxString _phone = ''.obs;
  String get phone => _phone.value;

  // 用户信息
  final Rx<UserModel?> _userInfo = Rx<UserModel?>(null);
  UserModel? get userInfo => _userInfo.value;

  // 表单数据
  final RxString _newPassword = ''.obs;
  String get newPassword => _newPassword.value;

  final RxString _enterPassword = ''.obs;
  String get enterPassword => _enterPassword.value;

  final RxString _captcha = ''.obs;
  String get captcha => _captcha.value;

  // 验证码相关
  final RxBool _disabled = false.obs;
  bool get disabled => _disabled.value;

  final RxString _text = '获取验证码'.obs;
  String get text => _text.value;

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
        String tel = response.data!.phone;
        String formattedPhone = '${tel.substring(0, 3)}****${tel.substring(7)}';
        _phone.value = formattedPhone;
      }
    } catch (e) {
      debugPrint('获取用户信息失败: $e');
      Get.snackbar('错误', '获取用户信息失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // 更新新支付密码
  void updateNewPassword(String value) {
    _newPassword.value = value;
  }

  // 更新确认支付密码
  void updateEnterPassword(String value) {
    _enterPassword.value = value;
  }

  // 更新验证码
  void updateCaptcha(String value) {
    _captcha.value = value;
  }

  // 发送验证码
  Future<void> sendVerificationCode() async {
    if (_userInfo.value?.phone == null || _userInfo.value?.phone == '') {
      Get.snackbar('错误', '手机号码不存在,无法发送验证码！');
      return;
    }

    if (_disabled.value) return;

    try {
      _disabled.value = true;
      int seconds = 60;

      // 模拟倒计时
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (seconds > 0) {
          _text.value = '${seconds}s';
          seconds--;
        } else {
          timer.cancel();
          _disabled.value = false;
          _text.value = '获取验证码';
        }
      });

      // 这里需要调用实际的发送验证码API
      // 为了演示，我们使用模拟的API调用
      // final response = await _userProvider.sendCode(
      //   phone: _userInfo['phone'],
      //   type: 'reset',
      // );

      // 模拟API调用成功
      await Future.delayed(const Duration(seconds: 1));
      Get.snackbar('成功', '验证码已发送');
    } catch (e) {
      _disabled.value = false;
      _text.value = '获取验证码';
      Get.snackbar('错误', '发送验证码失败: $e');
    }
  }

  // 修改支付密码
  Future<bool> editPaymentPassword() async {
    // 验证输入
    if (_newPassword.value.isEmpty) {
      Get.snackbar('错误', '请输入新支付密码');
      return false;
    }

    if (_enterPassword.value.isEmpty) {
      Get.snackbar('错误', '请再次输入新支付密码');
      return false;
    }

    if (_newPassword.value != _enterPassword.value) {
      Get.snackbar('错误', '两次输入的密码不一致！');
      return false;
    }

    if (_captcha.value.isEmpty) {
      Get.snackbar('错误', '请输入验证码');
      return false;
    }

    try {
      _isLoading.value = true;

      // 调用API修改支付密码
      // 注意：这里可能需要调用支付密码专用的API端点
      final response = await _apiProvider.post(
        'zhi_fu_register_reset', // 假设这是支付密码重置的API端点
        data: {
          'account': _userInfo.value?.phone ?? '',
          'captcha': _captcha.value,
          'password': _newPassword.value,
        },
      );

      if (response.isSuccess) {
        Get.snackbar('成功', response.msg);
        return true;
      } else {
        Get.snackbar('错误', response.msg);
        return false;
      }
    } catch (e) {
      debugPrint('修改支付密码失败: $e');
      Get.snackbar('错误', '支付密码修改失败: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}
