# 客服系统集成指南

## 📋 概述

本文档说明如何将客服系统集成到 Flutter 项目中。客服系统完全复刻了 uni-app 版本的功能，支持三种客服类型。

## ✅ 已完成的工作

### 1. 数据模型
- ✅ `lib/app/data/models/customer_model.dart` - 客服配置数据模型

### 2. API 接口
- ✅ `lib/app/data/providers/public_provider.dart` - 添加了 `getCustomerType()` 方法

### 3. 核心服务
- ✅ `lib/app/services/customer_service.dart` - 客服服务核心逻辑

### 4. UI 组件
- ✅ `lib/widgets/customer_float_button.dart` - 可拖动的客服浮动按钮

### 5. 文档和示例
- ✅ `lib/app/services/customer_service_example.dart` - 使用示例
- ✅ `lib/app/services/CUSTOMER_SERVICE_README.md` - 详细文档
- ✅ `lib/app/modules/customer/customer_test_page.dart` - 测试页面

### 6. 路由配置
- ✅ `lib/app/routes/app_routes.dart` - 添加了 `customerChat` 路由常量

## 🔧 需要完成的配置

### 1. 创建客服聊天页面

创建 `lib/app/modules/customer/customer_chat_page.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerChatPage extends StatelessWidget {
  const CustomerChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 获取传递的参数
    final productId = Get.parameters['productId'];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('在线客服'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('客服聊天页面'),
            if (productId != null) ...[
              const SizedBox(height: 8),
              Text('商品ID: $productId'),
            ],
            const SizedBox(height: 16),
            const Text(
              '这里需要实现你的聊天界面',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. 创建 WebView 页面

创建 `lib/app/modules/webview/webview_page.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key}) : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final url = Get.parameters['url'] ?? '';
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('客服'),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
```

**注意**：需要在 `pubspec.yaml` 中添加 `webview_flutter` 依赖：

```yaml
dependencies:
  webview_flutter: ^4.5.0
```

### 3. 配置路由

在 `lib/app/routes/app_pages.dart` 中添加路由：

```dart
import 'package:shuhang_mall_flutter/app/modules/customer/customer_chat_page.dart';
import 'package:shuhang_mall_flutter/app/modules/webview/webview_page.dart';

// 在 pages 列表中添加
GetPage(
  name: AppRoutes.customerChat,
  page: () => const CustomerChatPage(),
),
GetPage(
  name: AppRoutes.webView,
  page: () => const WebViewPage(),
),
```

### 4. iOS 配置

在 `ios/Runner/Info.plist` 中添加：

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>tel</string>
</array>
```

### 5. Android 配置

确保 `android/app/src/main/AndroidManifest.xml` 中有网络权限（通常已有）：

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## 📱 使用方法

### 方法 1：在商品详情页使用浮动按钮

```dart
import 'package:shuhang_mall_flutter/widgets/customer_float_button.dart';

class ProductDetailPage extends StatelessWidget {
  final int productId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 页面内容
          YourContent(),
          
          // 客服浮动按钮
          CustomerFloatButton(
            productId: productId,
            initialTop: 480.0,
            visible: true,
          ),
        ],
      ),
    );
  }
}
```

### 方法 2：在按钮中直接调用

```dart
import 'package:shuhang_mall_flutter/app/services/customer_service.dart';

ElevatedButton(
  onPressed: () {
    CustomerService().openCustomer();
  },
  child: const Text('联系客服'),
)
```

### 方法 3：在底部导航栏中使用

```dart
BottomNavigationBarItem(
  icon: const Icon(Icons.headset_mic),
  label: '客服',
  onTap: () {
    CustomerService().openCustomer();
  },
)
```

## 🧪 测试

### 运行测试页面

1. 在路由中添加测试页面：

```dart
GetPage(
  name: '/customer-test',
  page: () => const CustomerTestPage(),
),
```

2. 跳转到测试页面：

```dart
Get.toNamed('/customer-test');
```

### 测试不同客服类型

后端需要返回不同的配置来测试：

**站内客服：**
```json
{
  "status": 200,
  "msg": "success",
  "data": {
    "customer_type": "0"
  }
}
```

**电话客服：**
```json
{
  "status": 200,
  "msg": "success",
  "data": {
    "customer_type": "1",
    "customer_phone": "400-123-4567"
  }
}
```

**企业微信客服：**
```json
{
  "status": 200,
  "msg": "success",
  "data": {
    "customer_type": "2",
    "customer_url": "https://work.weixin.qq.com/...",
    "customer_corpId": "ww1234567890abcdef"
  }
}
```

## 📊 功能对比

| 功能 | uni-app | Flutter | 状态 |
|------|---------|---------|------|
| 站内客服 | ✅ | ✅ | 完成 |
| 电话客服 | ✅ | ✅ | 完成 |
| 企业微信客服 | ✅ | ✅ | 完成 |
| 第三方客服链接 | ✅ | ✅ | 完成 |
| 浮动按钮 | ✅ | ✅ | 完成 |
| 可拖动位置 | ✅ | ✅ | 完成 |
| 传递商品ID | ✅ | ✅ | 完成 |
| 小程序原生客服 | ✅ | ❌ | 不适用 |

## 🔍 常见问题

### Q1: 如何修改浮动按钮样式？

修改 `lib/widgets/customer_float_button.dart` 中的样式代码。

### Q2: 如何禁用浮动按钮拖动？

移除 `GestureDetector` 的 `onPanUpdate` 回调。

### Q3: 电话拨打功能在模拟器上不工作？

这是正常的，需要在真机上测试。

### Q4: 如何自定义客服聊天页面？

实现 `CustomerChatPage`，可以集成任何聊天 SDK（如环信、融云等）。

### Q5: 如何处理客服离线状态？

在 `CustomerChatPage` 中实现离线检测和提示逻辑。

## 📝 后续优化建议

1. **聊天功能**：集成第三方聊天 SDK（环信、融云、腾讯云 IM 等）
2. **消息推送**：实现客服消息推送通知
3. **历史记录**：保存聊天历史记录
4. **快捷回复**：添加常用问题快捷回复
5. **图片发送**：支持发送图片和文件
6. **满意度评价**：聊天结束后的满意度评价
7. **排队系统**：客服繁忙时的排队功能
8. **智能客服**：接入 AI 客服机器人

## 📚 相关文档

- [详细使用文档](lib/app/services/CUSTOMER_SERVICE_README.md)
- [使用示例](lib/app/services/customer_service_example.dart)
- [测试页面](lib/app/modules/customer/customer_test_page.dart)

## ✨ 总结

客服系统已经完全复刻了 uni-app 的功能，包括：

✅ 三种客服类型支持
✅ 可拖动浮动按钮
✅ 商品信息传递
✅ 完整的错误处理
✅ 详细的文档和示例

只需要完成聊天页面和 WebView 页面的实现，即可投入使用！
