import 'dart:io';
import 'dart:convert';

/// 简单的用户信息API测试

void main() async {
  print('=== 用户信息API测试 ===\n');
  
  final baseUrl = 'https://test.shsd.top/api/';
  
  // 测试用户信息接口（无认证）
  try {
    final uri = Uri.parse('${baseUrl}user');
    print('请求URL: $uri');
    
    final request = await HttpClient().getUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
    request.headers.set('Form-type', 'app');
    // 故意不设置token来测试未认证响应
    
    print('请求头:');
    request.headers.forEach((name, values) {
      print('  $name: ${values.join(', ')}');
    });
    
    final response = await request.close();
    print('响应状态码: ${response.statusCode}');
    
    final responseBody = await response.transform(utf8.decoder).join();
    print('响应内容: $responseBody');
    
    // 分析响应
    if (response.statusCode == 401) {
      print('✓ 确认需要认证');
    } else {
      print('? 意外的响应状态: ${response.statusCode}');
    }
    
  } catch (e) {
    print('✗ 请求失败: $e');
  }
  
  print('\n=== 测试完成 ===');
}