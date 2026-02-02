import 'dart:io';
import 'dart:convert';

/// 详细API测试脚本
/// 用于调试登录和用户信息获取流程

void main() async {
  print('=== 开始API调试测试 ===\n');
  
  // 测试配置
  final baseUrl = 'https://test.shsd.top';
  final apiPrefix = '/api/';
  final fullUrl = '$baseUrl$apiPrefix';
  
  print('基础配置检查:');
  print('  Base URL: $baseUrl');
  print('  API Prefix: $apiPrefix');
  print('  Full URL: $fullUrl');
  print('');
  
  // 测试1: 检查API基础连接
  await testApiConnection(fullUrl);
  
  // 测试2: 模拟登录流程
  await testLoginFlow(fullUrl);
  
  print('\n=== API调试测试完成 ===');
}

Future<void> testApiConnection(String baseUrl) async {
  print('测试1: API基础连接测试');
  print('------------------------');
  
  try {
    final uri = Uri.parse('${baseUrl}user');
    print('请求URL: $uri');
    
    final request = await HttpClient().getUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
    request.headers.set('Form-type', 'app');
    
    print('请求头:');
    request.headers.forEach((name, values) {
      print('  $name: ${values.join(', ')}');
    });
    
    final response = await request.close();
    print('响应状态码: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('✓ API连接正常');
    } else {
      print('✗ API连接异常，状态码: ${response.statusCode}');
      
      // 读取响应内容
      final responseBody = await response.transform(utf8.decoder).join();
      print('响应内容: $responseBody');
    }
    
  } catch (e) {
    print('✗ API连接失败: $e');
  }
  print('');
}

Future<void> testLoginFlow(String baseUrl) async {
  print('测试2: 模拟登录流程测试');
  print('------------------------');
  
  // 模拟登录请求
  final loginData = {
    'account': '13800138000', // 测试手机号
    'password': '123456'      // 测试密码
  };
  
  try {
    final uri = Uri.parse('${baseUrl}login');
    print('登录请求URL: $uri');
    print('登录数据: ${jsonEncode(loginData)}');
    
    final request = await HttpClient().postUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
    request.headers.set('Form-type', 'app');
    
    request.write(jsonEncode(loginData));
    final response = await request.close();
    
    print('登录响应状态码: ${response.statusCode}');
    
    final responseBody = await response.transform(utf8.decoder).join();
    print('登录响应内容: $responseBody');
    
    if (response.statusCode == 200) {
      // 尝试解析响应
      try {
        final responseData = jsonDecode(responseBody);
        print('响应数据结构: ${responseData.keys.toList()}');
        
        if (responseData.containsKey('status') && responseData['status'] == 200) {
          print('✓ 登录请求成功');
          
          // 如果有token，测试获取用户信息
          if (responseData.containsKey('data') && 
              responseData['data'] is Map && 
              (responseData['data'] as Map).containsKey('token')) {
            final token = (responseData['data'] as Map)['token'];
            print('获取到token: $token');
            await testUserInfo(baseUrl, token.toString());
          }
        } else {
          print('✗ 登录失败: ${responseData['msg'] ?? '未知错误'}');
        }
      } catch (e) {
        print('✗ 响应解析失败: $e');
      }
    }
    
  } catch (e) {
    print('✗ 登录请求失败: $e');
  }
  print('');
}

Future<void> testUserInfo(String baseUrl, String token) async {
  print('测试3: 用户信息获取测试');
  print('------------------------');
  
  try {
    final uri = Uri.parse('${baseUrl}user');
    print('用户信息请求URL: $uri');
    print('使用token: $token');
    
    final request = await HttpClient().getUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
    request.headers.set('Form-type', 'app');
    request.headers.set('Authori-zation', 'Bearer $token'); // 注意这里的拼写
    
    print('请求头:');
    request.headers.forEach((name, values) {
      print('  $name: ${values.join(', ')}');
    });
    
    final response = await request.close();
    print('用户信息响应状态码: ${response.statusCode}');
    
    final responseBody = await response.transform(utf8.decoder).join();
    print('用户信息响应内容: $responseBody');
    
    if (response.statusCode == 200) {
      print('✓ 用户信息获取成功');
    } else if (response.statusCode == 401) {
      print('✗ 认证失败 - Token无效或过期');
    } else {
      print('✗ 用户信息获取失败，状态码: ${response.statusCode}');
    }
    
  } catch (e) {
    print('✗ 用户信息请求失败: $e');
  }
}