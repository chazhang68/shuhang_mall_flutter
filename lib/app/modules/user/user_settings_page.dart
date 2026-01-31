import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/app/data/models/user_model.dart';
import 'package:shuhang_mall_flutter/app/core/constants/app_images.dart';

/// 用户设置页面
/// 对应原 pages/users/user_set/index.vue
class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  final UserProvider _userProvider = Get.find<UserProvider>();
  UserModel? _userInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final response = await _userProvider.getUserInfo();
    if (response.isSuccess) {
      setState(() {
        _userInfo = response.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // 个人信息入口
                  _buildUserInfoCard(),
                  const SizedBox(height: 12),
                  // 设置列表
                  _buildSettingsList(),
                  const SizedBox(height: 40),
                  // 退出登录按钮
                  _buildLogoutButton(),
                ],
              ),
            ),
    );
  }

  /// 用户信息卡片
  Widget _buildUserInfoCard() {
    String avatar = _userInfo?.avatar ?? '';
    return GestureDetector(
      onTap: () => Get.toNamed('/user/info'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 头像
            ClipOval(
              child: avatar.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: avatar,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        AppImages.defaultAvatar,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      AppImages.defaultAvatar,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
            ),
            const Spacer(),
            const Text(
              '个人信息',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// 设置列表
  Widget _buildSettingsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            title: '账户与安全',
            onTap: () => Get.toNamed('/user/account-safe'),
          ),
          _buildDivider(),
          _buildSettingItem(
            title: '清除缓存',
            onTap: _clearCache,
          ),
          _buildDivider(),
          _buildSettingItem(
            title: '检查版本',
            onTap: _checkUpdate,
          ),
          _buildDivider(),
          _buildSettingItem(
            title: '关于',
            onTap: () => Get.toNamed('/user/about'),
          ),
          _buildDivider(),
          _buildSettingItem(
            title: '注销账号',
            onTap: () => Get.toNamed('/user/cancellation'),
          ),
        ],
      ),
    );
  }

  /// 设置项
  Widget _buildSettingItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// 分隔线
  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 0.5,
      color: const Color(0xFFE6E6E6),
    );
  }

  /// 退出登录按钮
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _logout,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Text(
          '退出登录',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 清除缓存
  Future<void> _clearCache() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定清除本地缓存数据吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // 清除图片缓存
      await CachedNetworkImage.evictFromCache('');
      Get.snackbar('提示', '缓存清理完成');
    }
  }

  /// 检查更新
  void _checkUpdate() {
    Get.snackbar('提示', '当前为最新版本');
  }

  /// 退出登录
  Future<void> _logout() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('提示'),
        content: const Text('确认退出登录？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await _userProvider.getLogout();
      if (response.isSuccess) {
        // 清除登录状态
        Get.offAllNamed('/');
      }
    }
  }
}
