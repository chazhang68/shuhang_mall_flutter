import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../../../controllers/app_controller.dart';

class UserSetController extends GetxController {
  final UserProvider _userProvider = UserProvider();

  // 用户信息
  final Rx<UserModel?> _userInfo = Rx<UserModel?>(null);
  UserModel? get userInfo => _userInfo.value;

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
      }
    } catch (e) {
      debugPrint('获取用户信息失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // 清除缓存
  // 对应 uni-app 的 clearCache 方法
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      // 显示 Toast "缓存清理完成"
      EasyLoading.showToast('缓存清理完成');
    } catch (e) {
      debugPrint('清除缓存失败: $e');
      EasyLoading.showToast('清除缓存失败');
    }
  }

  // 检查版本更新
  // 对应 uni-app 的 isNew 回调
  void checkVersionUpdate() {
    // 显示 Toast "当前为最新版本"
    EasyLoading.showToast('当前为最新版本');
  }

  // 跳转到个人信息页面
  void goToUserInfo() {
    Get.toNamed(AppRoutes.userInfo);
  }

  // 跳转到账户安全页面
  void goToAccountSafe() {
    Get.toNamed(AppRoutes.accountSafe);
  }

  // 跳转到关于页面
  void goToAboutUs() {
    Get.toNamed(AppRoutes.userAbout);
  }

  // 跳转到注销账号页面
  void goToUserCancellation() {
    Get.toNamed(AppRoutes.userCancellation);
  }

  // 退出登录确认弹框
  // 对应 uni-app 的 outLogin 方法中的 uni.showModal
  Future<void> showLogoutConfirmation() async {
    Get.dialog(
      AlertDialog(
        title: const Text(
          '提示',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          '确认退出登录',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await performLogout();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 执行登出操作
  // 对应 uni-app 的 getLogout 调用
  Future<void> performLogout() async {
    try {
      final response = await _userProvider.getLogout();
      if (response.isSuccess) {
        // 清除AppController中的用户状态
        final appController = Get.find<AppController>();
        await appController.logout();

        // 返回首页 - 对应 uni.reLaunch({ url: '/pages/index/index' })
        Get.offAllNamed(AppRoutes.main);
      } else {
        EasyLoading.showToast(response.msg);
      }
    } catch (e) {
      EasyLoading.showToast('退出登录失败');
    }
  }
}
