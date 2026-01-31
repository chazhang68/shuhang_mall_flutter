import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/app/core/constants/app_images.dart';

/// 我的银行卡页面
/// 对应原 pages/users/mybank/index.vue
class MyBankPage extends StatefulWidget {
  const MyBankPage({super.key});

  @override
  State<MyBankPage> createState() => _MyBankPageState();
}

class _MyBankPageState extends State<MyBankPage> {
  final UserProvider _userProvider = Get.find<UserProvider>();
  
  Map<String, dynamic> _userInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final response = await _userProvider.getUserInfo();
    if (response.isSuccess && response.data != null) {
      setState(() {
        _userInfo = response.data?.toJson() ?? {};
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
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text('我的银行卡'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 提示文字
                  Text(
                    '您所使用的收款账户的姓名需与平台认证姓名一致，否则由此造成的损失自行承担',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 银行卡信息
                  _buildBankCard(),
                ],
              ),
            ),
    );
  }

  /// 银行卡信息
  Widget _buildBankCard() {
    String bankCard = _userInfo['qy_bank'] ?? '';
    
    if (bankCard.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFF5A5A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              AppImages.bank,
              width: 30,
              height: 30,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.account_balance,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '银行卡号：',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bankCard,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _showUnbindDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFF1F1F), Color(0xFFDF1443)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      '解绑',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // 未绑定银行卡
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: GestureDetector(
          onTap: () => Get.toNamed('/user/set-bank'),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFF1F1F), Color(0xFFDF1443)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '立即设置',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  /// 显示解绑确认弹窗
  void _showUnbindDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('提示'),
        content: const Text('解绑后将不能进行快捷支付哦'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: _unbindBank,
            child: const Text('确认', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 解绑银行卡
  Future<void> _unbindBank() async {
    Get.back();
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    // TODO: 调用解绑API
    await Future.delayed(const Duration(seconds: 1));
    
    Get.back();
    FlutterToastPro.showMessage( '解绑成功');
    _loadUserInfo();
  }
}


