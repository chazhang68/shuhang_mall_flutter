import 'dart:convert';
import 'dart:io';

/// 纯Dart API测试脚本
/// 用于测试登录和获取用户信息的API调用
void main() async {
  print('=== 开始API测试 ===');
  
  // 测试配置
  final baseUrl = 'https://test.shsd.top/api/';
  final tokenName = 'Authori-zation'; // 注意这个拼写
  
  try {
    // 1. 测试登录接口
    print('\n1. 测试登录接口...');
    final loginResponse = await testLogin(baseUrl);
    print('登录响应: $loginResponse');
    
    if (loginResponse.containsKey('token')) {
      final token = loginResponse['token'];
      print('获取到token: $token');
      
      // 2. 使用token测试获取用户信息
      print('\n2. 测试获取用户信息...');
      final userInfoResponse = await testGetUserInfo(baseUrl, tokenName, token);
      print('用户信息响应: $userInfoResponse');
    } else {
      print('登录失败，无法获取token');
    }
    
  } catch (e) {
    print('测试过程中发生错误: $e');
  }
  
  print('\n=== API测试完成 ===');
}

/// 测试登录接口
Future<Map<String, dynamic>> testLogin(String baseUrl) async {
  final url = Uri.parse('${baseUrl}login');
  
  final requestBody = {
    'account': '13800138000', // 测试账号
    'password': '123456'      // 测试密码
  };
  
  print('请求URL: $url');
  print('请求体: ${jsonEncode(requestBody)}');
  
  try {
    final response = await HttpClient().postUrl(url)
      ..headers.set('Content-Type', 'application/json')
      ..headers.set('Accept', 'application/json')
      ..headers.set('Form-type', 'app')
      ..write(jsonEncode(requestBody));
    
    final httpResponse = await response.close();
    final responseBody = await httpResponse.transform(utf8.decoder).join();
    
    print('响应状态码: ${httpResponse.statusCode}');
    print('响应头: ${httpResponse.headers}');
    print('响应体: $responseBody');
    
    return jsonDecode(responseBody);
    
  } catch (e) {
    print('登录请求失败: $e');
    rethrow;
  }
}

/// 测试获取用户信息接口
Future<Map<String, dynamic>> testGetUserInfo(
    String baseUrl, String tokenName, String token) async {
  final url = Uri.parse('${baseUrl}user');
  
  print('请求URL: $url');
  print('Token名称: $tokenName');
  print('Token值: $token');
  
  try {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;
    
    final response = await client.getUrl(url)
      ..headers.set('Content-Type', 'application/json')
      ..headers.set('Accept', 'application/json')
      ..headers.set('Form-type', 'app')
      ..headers.set(tokenName, 'Bearer $token'); // 注意Bearer前缀
    
    final httpResponse = await response.close();
    final responseBody = await httpResponse.transform(utf8.decoder).join();
    
    print('响应状态码: ${httpResponse.statusCode}');
    print('响应头: ${httpResponse.headers}');
    print('响应体: $responseBody');
    
    return jsonDecode(responseBody);
    
  } catch (e) {
    print('获取用户信息请求失败: $e');
    rethrow;
  }
}