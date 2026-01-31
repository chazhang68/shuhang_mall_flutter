import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/theme/theme_colors.dart';

/// 设置页面
/// 对应原 pages/users/user_set/index.vue
class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        final themeColor = controller.themeColor;

        return Scaffold(
          appBar: AppBar(title: const Text('设置')),
          body: ListView(
            children: [
              const SizedBox(height: 10),
              // 账号设置
              _buildSection([
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: '个人资料',
                  onTap: () => Get.toNamed(AppRoutes.userInfo),
                ),
                _buildMenuItem(
                  icon: Icons.location_on_outlined,
                  title: '收货地址',
                  onTap: () => Get.toNamed(AppRoutes.addressList),
                ),
                _buildMenuItem(icon: Icons.lock_outline, title: '账户安全', onTap: () {}),
              ]),
              const SizedBox(height: 10),
              // 通用设置
              _buildSection([
                _buildMenuItem(
                  icon: Icons.palette_outlined,
                  title: '主题色',
                  trailing: _buildThemeColorDot(themeColor),
                  onTap: () => _showThemeColorPicker(context),
                ),
                _buildMenuItem(icon: Icons.notifications_none, title: '消息通知', onTap: () {}),
                _buildMenuItem(
                  icon: Icons.language,
                  title: '语言设置',
                  trailing: const Text(
                    '简体中文',
                    style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
                  ),
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 10),
              // 其他
              _buildSection([
                _buildMenuItem(icon: Icons.help_outline, title: '帮助中心', onTap: () {}),
                _buildMenuItem(icon: Icons.description_outlined, title: '关于我们', onTap: () {}),
                _buildMenuItem(icon: Icons.privacy_tip_outlined, title: '隐私政策', onTap: () {}),
              ]),
              const SizedBox(height: 10),
              // 缓存
              _buildSection([
                _buildMenuItem(
                  icon: Icons.cleaning_services_outlined,
                  title: '清除缓存',
                  trailing: const Text(
                    '12.5MB',
                    style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
                  ),
                  onTap: () {
                    FlutterToastPro.showMessage( '缓存已清除');
                  },
                ),
              ]),
              const SizedBox(height: 30),
              // 退出登录按钮
              _buildLogoutButton(context, themeColor),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      color: Colors.white,
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF666666)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF333333))),
            ),
            if (trailing != null) ...[trailing, const SizedBox(width: 8)],
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFF999999)),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeColorDot(ThemeColorData themeColor) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(color: themeColor.primary, borderRadius: BorderRadius.circular(10)),
    );
  }

  void _showThemeColorPicker(BuildContext context) {
    final controller = Get.find<AppController>();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('选择主题色', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildThemeColorItem('红色', const Color(0xFFE93323), 3, controller),
                _buildThemeColorItem('蓝色', const Color(0xFF1E90FF), 1, controller),
                _buildThemeColorItem('绿色', const Color(0xFF4CAF50), 2, controller),
                _buildThemeColorItem('粉色', const Color(0xFFE91E63), 4, controller),
                _buildThemeColorItem('橙色', const Color(0xFFFF9800), 5, controller),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeColorItem(String name, Color color, int status, AppController controller) {
    return GestureDetector(
      onTap: () {
        controller.setThemeColor(status);
        Get.back();
      },
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(22)),
            child: controller.themeColor.primary == color
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, themeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GestureDetector(
        onTap: () => _showLogoutDialog(context),
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            border: Border.all(color: themeColor.primary),
            borderRadius: BorderRadius.circular(23),
          ),
          alignment: Alignment.center,
          child: Text('退出登录', style: TextStyle(fontSize: 15, color: themeColor.primary)),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('提示'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Get.back();
              final controller = Get.find<AppController>();
              controller.logout();
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}


