import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/theme_colors.dart';
import '../../routes/app_routes.dart';

/// 关于我们页面
/// 对应原 pages/users/about_us/index.vue
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Color get _primaryColor => ThemeColors.red.primary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          '关于我们',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 用户协议
            _buildItem(
              title: '用户协议',
              onTap: () => Get.toNamed(AppRoutes.userPrivacy, arguments: {'type': '4'}),
            ),
            const SizedBox(height: 12),
            // 隐私政策
            _buildItem(
              title: '隐私政策',
              onTap: () => Get.toNamed(AppRoutes.userPrivacy, arguments: {'type': '3'}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 15, color: Color(0xFF333333))),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF999999)),
          ],
        ),
      ),
    );
  }
}
