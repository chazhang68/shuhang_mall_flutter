import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';

/// 账户与安全页面
/// 对应原 pages/users/user_account_safe/index.vue
class AccountSafePage extends StatefulWidget {
  const AccountSafePage({super.key});

  @override
  State<AccountSafePage> createState() => _AccountSafePageState();
}

class _AccountSafePageState extends State<AccountSafePage> {
  final UserProvider _userProvider = Get.find<UserProvider>();
  
  String _phone = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final response = await _userProvider.getUserInfo();
    if (response.isSuccess && response.data != null) {
      String phone = response.data?.phone ?? '';
      // 手机号脱敏
      if (phone.length >= 11) {
        phone = '${phone.substring(0, 3)}****${phone.substring(7)}';
      }
      setState(() {
        _phone = phone;
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // 背景
                Container(
                  height: 280,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
                // 内容
                SafeArea(
                  child: Column(
                    children: [
                      // 返回按钮
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => Get.back(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // 手机号
                      Text(
                        _phone,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone_android, color: Colors.white.withValues(alpha: 0.8), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '手机号码',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      // 设置列表
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            _buildSettingItem(
                              title: '登录密码',
                              onTap: () => Get.toNamed('/user/update-login-pwd'),
                            ),
                            const SizedBox(height: 12),
                            _buildSettingItem(
                              title: '支付密码',
                              onTap: () => Get.toNamed('/user/update-payment-pwd'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
}
