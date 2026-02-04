import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/core/constants/app_icons.dart';
import 'user_account_safe_controller.dart';

class UserAccountSafeView extends GetView<UserAccountSafeController> {
  const UserAccountSafeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账户与安全'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 背景区域，显示手机号
            Container(
              width: double.infinity,
              height: 335, // 大约等于536rpx转换后的高度
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/account_safe_bac.png'), // 需要添加背景图片
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(
                    () => Text(
                      controller.formattedPhone,
                      style: const TextStyle(
                        fontSize: 60, // 对应原60rpx
                        fontWeight: FontWeight.bold,
                        fontFamily: 'DIN Alternate',
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 49), // 49rpx
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppIcons.phone, // 使用手机图标
                        size: 24,
                        color: Colors.black,
                      ),
                      SizedBox(width: 14),
                      Text('手机号码', style: TextStyle(fontSize: 16, color: Colors.black)),
                    ],
                  ),
                ],
              ),
            ),

            // 设置选项列表
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 登录密码设置
                    _buildSettingItem(title: '登录密码', onTap: () => controller.goToUpdateLoginPwd()),

                    const SizedBox(height: 16),

                    // 支付密码设置
                    _buildSettingItem(
                      title: '支付密码',
                      onTap: () => controller.goToUpdatePaymentPwd(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建设置项
  Widget _buildSettingItem({required String title, required VoidCallback onTap}) {
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
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
