import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/core/constants/app_icons.dart';
import 'user_account_safe_controller.dart';

class UserAccountSafeView extends GetView<UserAccountSafeController> {
  const UserAccountSafeView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('账户与安全'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 背景区域，显示手机号
              Container(
                width: double.infinity,
                height: screenHeight * 0.35, // 使用屏幕高度的35%，更灵活
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/account_safe_bac.png'),
                    fit: BoxFit.cover, // 改为cover以更好适配
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => Text(
                        controller.formattedPhone,
                        style: TextStyle(
                          fontSize: screenWidth * 0.12, // 使用屏幕宽度的12%
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DIN Alternate',
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03), // 使用屏幕高度的3%
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppIcons.phone,
                          size: screenWidth * 0.06, // 使用屏幕宽度的6%
                          color: Colors.black,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          '手机号码',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04, // 使用屏幕宽度的4%
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 设置选项列表
              Container(
                margin: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 登录密码设置
                    _buildSettingItem(
                      title: '登录密码',
                      onTap: () => controller.goToUpdateLoginPwd(),
                    ),

                    const SizedBox(height: 16),

                    // 支付密码设置
                    _buildSettingItem(
                      title: '支付密码',
                      onTap: () => controller.goToUpdatePaymentPwd(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建设置项
  Widget _buildSettingItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.1 * 255).round()),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
