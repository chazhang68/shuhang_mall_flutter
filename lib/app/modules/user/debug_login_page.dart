import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/app/data/providers/api_provider.dart';
import 'package:shuhang_mall_flutter/app/services/log_service.dart';
import 'package:shuhang_mall_flutter/app/utils/cache.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';

/// 调试登录页面 - 用于定位"获取用户信息失败"问题
class DebugLoginPage extends StatefulWidget {
  const DebugLoginPage({super.key});

  @override
  State<DebugLoginPage> createState() => _DebugLoginPageState();
}

class _DebugLoginPageState extends State<DebugLoginPage> {
  final UserProvider _userProvider = Get.find<UserProvider>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController.text = '13800138000'; // 测试账号
    _passwordController.text = '123456';   // 测试密码
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('调试登录')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: '手机号',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: '密码',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _debugLogin,
                child: _isLoading 
                  ? const CircularProgressIndicator()
                  : const Text('调试登录'),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testTokenHeader,
              child: const Text('测试Token Header'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _clearCache,
              child: const Text('清空缓存'),
            ),
          ],
        ),
      ),
    );
  }

  /// 调试登录流程
  Future<void> _debugLogin() async {
    setState(() => _isLoading = true);
    
    try {
      LogService.i('开始调试登录流程');
      
      // 1. 先清空现有登录状态
      await _clearLoginState();
      
      // 2. 执行登录
      LogService.i('执行密码登录');
      final loginResponse = await _userProvider.loginH5(
        account: _phoneController.text.trim(),
        password: _passwordController.text,
      );
      
      LogService.apiResponse('login', loginResponse);
      
      if (!loginResponse.isSuccess) {
        _showError('登录失败: ${loginResponse.msg}');
        return;
      }
      
      // 3. 提取登录数据
      final loginData = loginResponse.data as Map<String, dynamic>? ?? {};
      final token = loginData['token']?.toString() ?? '';
      final expiresTime = loginData['expires_time'] ?? 0;
      
      LogService.i('登录成功，token: $token');
      
      if (token.isEmpty) {
        _showError('Token为空');
        return;
      }
      
      // 4. 保存token到缓存
      await Cache.setString(CacheKey.token, token);
      await Cache.setInt(CacheKey.expires, expiresTime);
      
      LogService.i('Token已保存到缓存');
      
      // 5. 验证缓存中的token
      final cachedToken = Cache.getString(CacheKey.token);
      LogService.i('缓存中的token: $cachedToken');
      
      // 6. 短暂延迟确保token生效
      await Future.delayed(const Duration(milliseconds: 200));
      
      // 7. 测试API请求头
      await _testApiHeaders();
      
      // 8. 获取用户信息
      LogService.i('开始获取用户信息');
      final userResponse = await _userProvider.getUserInfo();
      
      LogService.apiResponse('getUserInfo', userResponse);
      
      if (userResponse.isSuccess) {
        LogService.i('用户信息获取成功: ${userResponse.data}');
        _showSuccess('登录成功！用户ID: ${userResponse.data?.uid}');
        
        // 完整登录流程
        final appController = Get.find<AppController>();
        await appController.login(
          token: token,
          uid: userResponse.data?.uid ?? 0,
          userInfo: userResponse.data,
          expiresTime: expiresTime,
        );
        
        debugPrint('准备跳转到主页');
        
        // 跳转到主页（使用 WidgetsBinding 延迟导航）
        WidgetsBinding.instance.addPostFrameCallback((_) {
          debugPrint('开始执行跳转到主页');
          Get.offAllNamed('/main');
        });
      } else {
        _showError('获取用户信息失败: ${userResponse.msg}, status: ${userResponse.status}');
      }
      
    } catch (e, stack) {
      LogService.e('调试登录异常', e, stackTrace: stack);
      _showError('登录异常: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 测试Token Header配置
  Future<void> _testTokenHeader() async {
    LogService.i('=== 开始测试Token Header配置 ===');
    
    // 检查当前配置
    LogService.i('当前token header名称: ${AppConfig.tokenName}');
    
    // 测试标准Authorization header
    final standardHeader = 'Authorization';
    final currentHeader = AppConfig.tokenName;
    
    if (currentHeader != standardHeader) {
      LogService.w('警告: Token header名称可能不正确');
      LogService.w('当前: $currentHeader');
      LogService.w('标准: $standardHeader');
      _showError('Token header名称可能不正确: $currentHeader');
    } else {
      LogService.i('Token header名称配置正确');
      _showSuccess('Token header名称配置正确');
    }
  }

  /// 测试API请求头
  Future<void> _testApiHeaders() async {
    LogService.i('=== 测试API请求头 ===');
    
    try {
      // 直接测试一个简单的API调用来查看请求头
      final response = await ApiProvider.instance.get('test', noAuth: true);
      LogService.i('测试API响应: ${response.status} - ${response.msg}');
    } catch (e) {
      LogService.e('测试API调用失败', e);
    }
  }

  /// 清空登录状态
  Future<void> _clearLoginState() async {
    LogService.i('清空登录状态');
    await Cache.remove(CacheKey.token);
    await Cache.remove(CacheKey.userInfo);
    await Cache.remove(CacheKey.uid);
    await Cache.remove(CacheKey.expires);
    
    final appController = Get.find<AppController>();
    await appController.logout();
  }

  /// 清空缓存
  Future<void> _clearCache() async {
    LogService.i('清空所有缓存');
    await Cache.clear();
    _showSuccess('缓存已清空');
  }

  void _showSuccess(String message) {
    FlutterToastPro.showMessage(message, type: 'success');
    LogService.i('成功: $message');
  }

  void _showError(String message) {
    FlutterToastPro.showMessage(message, type: 'error');
    LogService.e('错误: $message');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}