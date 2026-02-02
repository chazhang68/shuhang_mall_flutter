import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/app/data/providers/api_provider.dart';
import 'package:shuhang_mall_flutter/app/utils/config.dart';
import 'package:shuhang_mall_flutter/app/services/log_service.dart';

void main() {
  runApp(const DebugApp());
}

class DebugApp extends StatelessWidget {
  const DebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'API Debug Tool',
      home: const DebugPage(),
    );
  }
}

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  final UserProvider _userProvider = UserProvider();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String _logOutput = '';
  bool _isLoading = false;

  void _log(String message) {
    setState(() {
      _logOutput = '[$DateTime.now()] $message\n$_logOutput';
    });
    LogService.i(message);
  }

  Future<void> _testApiConnection() async {
    setState(() => _isLoading = true);
    _log('开始测试API连接...');
    
    try {
      // 测试基础API连接
      _log('API基础地址: ${AppConfig.apiUrl}');
      _log('Token Header名称: ${AppConfig.tokenName}');
      
      final response = await ApiProvider.instance.get('wechat/get_logo', noAuth: true);
      _log('Logo API响应: ${response.status} - ${response.msg}');
      _log('响应数据: ${response.data}');
      
    } catch (e) {
      _log('API连接测试失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testLogin() async {
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    
    if (phone.isEmpty || password.isEmpty) {
      _log('请填写手机号和密码');
      return;
    }
    
    setState(() => _isLoading = true);
    _log('开始测试登录...');
    
    try {
      final response = await _userProvider.loginH5(account: phone, password: password);
      _log('登录响应: ${response.status} - ${response.msg}');
      _log('登录数据: ${response.data}');
      
      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token']?.toString() ?? '';
        _tokenController.text = token;
        _log('登录成功，获取到Token: $token');
        
        // 短暂延迟后测试用户信息
        await Future.delayed(const Duration(milliseconds: 100));
        _log('延迟100ms后测试用户信息...');
        _testUserInfo();
      }
    } catch (e) {
      _log('登录失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testUserInfo() async {
    String token = _tokenController.text.trim();
    if (token.isEmpty) {
      _log('请先登录获取Token');
      return;
    }
    
    setState(() => _isLoading = true);
    _log('开始测试获取用户信息...');
    
    try {
      // 直接使用API Provider测试
      final apiProvider = ApiProvider.instance;
      final response = await apiProvider.get('user', noAuth: false);
      _log('用户信息API响应: ${response.status} - ${response.msg}');
      _log('用户信息数据: ${response.data}');
      
      if (response.isSuccess) {
        _log('✅ 用户信息获取成功!');
      } else {
        _log('❌ 用户信息获取失败');
      }
    } catch (e) {
      _log('用户信息请求异常: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API调试工具')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: '手机号',
                hintText: '输入测试手机号'
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: '密码',
                hintText: '输入测试密码'
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Token (自动填充)',
                hintText: '登录成功后自动填充'
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testApiConnection,
                  child: const Text('测试API连接'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testLogin,
                  child: const Text('测试登录'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testUserInfo,
                  child: const Text('测试用户信息'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('调试日志:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(8),
                child: SingleChildScrollView(
                  child: Text(
                    _logOutput,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
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