import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/user_set_controller.dart';

/// 设置页面
/// 对应原 pages/users/user_set/index.vue
class UserSetView extends GetView<UserSetController> {
  const UserSetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置'), centerTitle: true, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // 个人信息卡片
            _buildUserInfoCard(),
            const SizedBox(height: 10),
            // 设置选项列表
            _buildSettingsList(),
            const SizedBox(height: 20),
            // 退出登录按钮
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  /// 个人信息卡片
  Widget _buildUserInfoCard() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => controller.goToUserInfo(),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          child: Row(
            children: [
              Obx(
                () => ClipOval(
                  child:
                      controller.userInfo?.avatar != null && controller.userInfo!.avatar.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: controller.userInfo!.avatar,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 36,
                            height: 36,
                            color: Colors.grey[300],
                            child: const Icon(Icons.person, size: 30),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 36,
                            height: 36,
                            color: Colors.grey[300],
                            child: const Icon(Icons.person, size: 30),
                          ),
                        )
                      : Container(
                          width: 36,
                          height: 36,
                          color: Colors.grey[300],
                          child: const Icon(Icons.person, size: 30),
                        ),
                ),
              ),
              const Spacer(),
              const Text(
                '个人信息',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  /// 设置选项列表
  Widget _buildSettingsList() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          // 账户与安全
          _buildSettingItem(title: '账户与安全', onTap: () => controller.goToAccountSafe()),
          _buildDivider(),
          // 清除缓存
          _buildSettingItem(title: '清除缓存', onTap: () => _showClearCacheDialog()),
          _buildDivider(),
          // 检查版本
          _buildSettingItem(title: '检查版本', onTap: () => controller.checkVersionUpdate()),
          _buildDivider(),
          // 关于
          _buildSettingItem(title: '关于', onTap: () => controller.goToAboutUs()),
          _buildDivider(),
          // 注销账号
          _buildSettingItem(title: '注销账号', onTap: () => controller.goToUserCancellation()),
        ],
      ),
    );
  }

  /// 设置项
  Widget _buildSettingItem({required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// 分隔线
  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      height: 0.5,
      color: const Color(0xFFE6E6E6),
    );
  }

  /// 退出登录按钮
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () => controller.showLogoutConfirmation(),
      child: Container(
        width: double.infinity,
        height: 49, // 98rpx
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        child: const Text(
          '退出登陆',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
        ),
      ),
    );
  }

  /// 显示清除缓存确认对话框
  /// 对应 uni-app 的 uni.showModal
  void _showClearCacheDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text(
          '清除缓存',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          '确定清除本地缓存数据吗',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              // 显示取消提示
              FlutterToastPro.showMessage('取消');
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearCache();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
