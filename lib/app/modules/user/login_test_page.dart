import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/app/data/providers/api_provider.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/utils/cache.dart';
import 'package:shuhang_mall_flutter/app/services/log_service.dart';

/// 简单的登录测试页面
/// 用于验证修复后的登录功能
class LoginTestPage extends StatefulWidget {
  const LoginTestPage({super.key});

  @override
  State<LoginTestPage> createState() => _LoginTestPageState();
}

class _LoginTestPageState extends State<LoginTestPage> {
  final UserProvider _userProvider = UserProvider();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String _logOutput = '';

  @override
  void initState() {
    super.initState();
    _phoneController.text = '13800138000'; // 测试账号
    _passwordController.text = '123456';   // 测试密码
    _appendToLog('测试页面初始化完成');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _appendToLog(String message) {
    setState(() {
      _logOutput = '[$DateTime.now()] $message\n$_logOutput';
    });
    LogService.i('LoginTest: $message');
  }

  Future<void> _testLogin() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    _appendToLog('开始登录测试...');
    
    try {
      // 1. 执行登录
      _appendToLog('步骤1: 执行账号密码登录');
      final loginResponse = await _userProvider.loginH5(
        account: _phoneController.text.trim(),
        password: _passwordController.text,
      );
      
      _appendToLog('登录响应状态: ${loginResponse.status}');
      _appendToLog('登录响应消息: ${loginResponse.msg}');
      
      if (!loginResponse.isSuccess) {
        _appendToLog('✗ 登录失败: ${loginResponse.msg}');
        setState(() => _isLoading = false);
        return;
      }
      
      // 2. 提取token和用户信息
      _appendToLog('步骤2: 提取认证信息');
      final loginData = loginResponse.data as Map<String, dynamic>? ?? {};
      final token = loginData['token']?.toString() ?? '';
      final expiresTime = loginData['expires_time'] ?? 0;
      
      if (token.isEmpty) {
        _appendToLog('✗ Token为空，登录失败');
        setState(() => _isLoading = false);
        return;
      }
      
      _appendToLog('✓ 登录成功，获取到token: ${token.substring(0, 20)}...');
      
      // 3. 保存到AppController
      _appendToLog('步骤3: 保存登录状态');
      final appController = Get.find<AppController>();
      await appController.login(token: token, uid: 0, expiresTime: expiresTime);
      
      // 4. 等待token生效
      _appendToLog('步骤4: 等待token生效(100ms)');
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 5. 获取用户信息
      _appendToLog('步骤5: 获取用户信息');
      final userResponse = await _userProvider.getUserInfo();
      
      _appendToLog('用户信息响应状态: ${userResponse.status}');
      _appendToLog('用户信息响应消息: ${userResponse.msg}');
      
      if (userResponse.isSuccess && userResponse.data != null) {
        final userInfo = userResponse.data;
        final uid = userInfo?.uid ?? 0;
        
        _appendToLog('✓ 用户信息获取成功');
        _appendToLog('用户ID: $uid');
        _appendToLog('用户名: ${userInfo?.nickname ?? "未知"}');
        
        // 6. 完整保存用户信息
        await appController.login(
          token: token,
          uid: uid,
          userInfo: userInfo,
          expiresTime: expiresTime,
        );
        
        _appendToLog('✓ 登录流程完成');
        _showSuccessDialog();
      } else {
        _appendToLog('✗ 用户信息获取失败: ${userResponse.msg}');
        await appController.logout();
      }
      
    } catch (e) {
      _appendToLog('✗ 登录过程异常: $e');
      LogService.e('LoginTest Error', e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    Get.defaultDialog(
      title: '🎉 登录成功',
      middleText: '恭喜！登录功能修复成功\n可以正常获取用户信息了',
      textConfirm: '知道了',
      onConfirm: () => Get.back(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录功能测试'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 测试输入框
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: '手机号',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: '密码',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _testLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('开始测试登录', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 日志输出区域
            const Text(
              '测试日志:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _logOutput,
                    style: const TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}