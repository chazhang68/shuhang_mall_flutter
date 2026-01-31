import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/providers/user_provider.dart';
import '../../controllers/app_controller.dart';
import '../../routes/app_routes.dart';

/// 注销账号页面
/// 对应 uni-app: pages/users/user_cancellation/index.vue
class UserCancellationPage extends StatefulWidget {
  const UserCancellationPage({super.key});

  @override
  State<UserCancellationPage> createState() => _UserCancellationPageState();
}

class _UserCancellationPageState extends State<UserCancellationPage> {
  final UserProvider _userProvider = UserProvider();
  bool _isLoading = true;
  Map<String, dynamic> _agreementData = {};

  @override
  void initState() {
    super.initState();
    _getAgreement();
  }

  /// 获取注销协议内容
  Future<void> _getAgreement() async {
    try {
      // type=5 为注销协议
      final response = await _userProvider.getUserAgreement('5');
      if (response.isSuccess && response.data != null) {
        setState(() {
          _agreementData = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('获取注销协议失败: $e');
      setState(() => _isLoading = false);
    }
  }

  /// 显示注销确认弹窗
  void _showCancellationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部图片区域
            Container(
              width: double.infinity,
              height: 135,
              decoration: const BoxDecoration(
                color: Color(0xFFE93323),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: const Center(
                child: Icon(Icons.warning_amber_rounded, size: 80, color: Colors.white),
              ),
            ),
            // 底部内容区域
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    '是否确认注销',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '注销后无法恢复，请谨慎操作',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _cancelUser();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5F5F5),
                            foregroundColor: const Color(0xFF333333),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(21),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('注销'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE93323),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(21),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('取消'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 执行账号注销
  Future<void> _cancelUser() async {
    try {
      // 清除登录状态
      final appController = Get.find<AppController>();
      await appController.logout();
      
      // 跳转到首页
      Get.offAllNamed(AppRoutes.main);
      
      Get.snackbar('提示', '账号已注销');
    } catch (e) {
      Get.snackbar('错误', '注销失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('注销账号'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 用户信息区域
                if (_agreementData['avatar'] != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: Row(
                      children: [
                        ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: _agreementData['avatar'] ?? '',
                            width: 38,
                            height: 38,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.person, size: 24),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.person, size: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _agreementData['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // 协议内容区域
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: SingleChildScrollView(
                      child: Html(
                        data: _agreementData['content'] ?? '<p>暂无内容</p>',
                      ),
                    ),
                  ),
                ),
                
                // 底部按钮区域
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    border: Border(
                      top: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        const Text(
                          '点击【立即注销】即代表您已经同意《用户注销协议》',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF999999),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: _showCancellationDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE93323),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(23),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              '立即注销',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
