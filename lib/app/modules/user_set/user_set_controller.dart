import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/public_provider.dart';
import '../../data/providers/api_provider.dart';
import '../../data/models/user_model.dart';
import '../../routes/app_routes.dart';
import '../../controllers/app_controller.dart';
import '../../../widgets/app_update_dialog.dart';

class UserSetController extends GetxController {
  final UserProvider _userProvider = UserProvider();
  final PublicProvider _publicProvider = PublicProvider();

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
  // 对应 uni-app 的 app-update.vue 组件
  Future<void> checkVersionUpdate() async {
    try {
      EasyLoading.show(status: '检查更新中...');

      // 获取当前版本号
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // 调用API获取最新版本信息 (1=Android, 2=iOS)
      final type = Platform.isIOS ? 2 : 1;
      final response = await _publicProvider.getUpdateInfo(type);

      EasyLoading.dismiss();

      if (!response.isSuccess || response.data == null) {
        EasyLoading.showToast('当前为最新版本');
        return;
      }

      // 如果返回的是数组，说明没有更新
      if (response.data is List) {
        EasyLoading.showToast('当前为最新版本');
        return;
      }

      final data = response.data as Map<String, dynamic>;
      final newVersion = data['version']?.toString() ?? '';
      final info = data['info']?.toString() ?? '';
      final url = data['url']?.toString() ?? '';
      final isForce = data['is_force'] == 1 || data['is_force'] == true;
      final platform = data['platform']?.toString() ?? '';

      // 没有配置当前平台的升级数据
      if (platform.isEmpty) {
        EasyLoading.showToast('当前为最新版本');
        return;
      }

      // 对比版本号
      if (_compareVersion(currentVersion, newVersion)) {
        // 获取 App Logo
        String logoUrl = '';
        try {
          final logoResponse = await ApiProvider.instance.get('wechat/get_logo', noAuth: true);
          if (logoResponse.isSuccess && logoResponse.data != null) {
            final logoData = logoResponse.data as Map<String, dynamic>;
            logoUrl = logoData['logo_url']?.toString() ?? '';
          }
        } catch (_) {}

        // 需要更新，显示更新弹窗
        Get.dialog(
          AppUpdateDialog(
            version: newVersion,
            info: info,
            url: url,
            isForce: isForce,
            logoUrl: logoUrl,
          ),
          barrierDismissible: !isForce,
          barrierColor: Colors.black.withAlpha(153),
        );
      } else {
        EasyLoading.showToast('当前为最新版本');
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('检查更新失败: $e');
      EasyLoading.showToast('检查更新失败');
    }
  }

  /// 对比版本号，判断是否需要更新
  /// 对应 uni-app 的 compareVersion 方法
  bool _compareVersion(String oldVersion, String newVersion) {
    if (oldVersion.isEmpty || newVersion.isEmpty) return false;

    final ov = oldVersion.split('.');
    final nv = newVersion.split('.');

    for (int i = 0; i < ov.length && i < nv.length; i++) {
      final no = int.tryParse(ov[i]) ?? 0;
      final nn = int.tryParse(nv[i]) ?? 0;
      if (nn > no) return true;
      if (nn < no) return false;
    }

    // 新版本号段数更多且前缀相同，说明有更新
    if (nv.length > ov.length && newVersion.startsWith(oldVersion)) {
      return true;
    }
    return false;
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
        content: const Text('确认退出登录', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
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
