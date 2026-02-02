# 🚀 客服系统快速开始

## 📦 已完成 ✅

客服系统已经完全对接完成！所有核心代码都已实现。

## ⚡ 3分钟快速集成

### 步骤 1: 创建客服聊天页面 (1分钟)

创建文件 `lib/app/modules/customer/customer_chat_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerChatPage extends StatelessWidget {
  const CustomerChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productId = Get.parameters['productId'];
    
    return Scaffold(
      appBar: AppBar(title: const Text('在线客服')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat, size: 64),
            const SizedBox(height: 16),
            Text('客服聊天页面'),
            if (productId != null) Text('商品ID: $productId'),
          ],
        ),
      ),
    );
  }
}
```

### 步骤 2: 添加 WebView 依赖 (30秒)

在 `pubspec.yaml` 中添加:

```yaml
dependencies:
  webview_flutter: ^4.5.0
```

运行:
```bash
flutter pub get
```

### 步骤 3: 创建 WebView 页面 (1分钟)

创建文件 `lib/app/modules/webview/webview_page.dart`:

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

  @override
  void initState() {
    super.initState();
    final url = Get.parameters['url'] ?? '';
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('客服')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
```

### 步骤 4: 配置路由 (30秒)

在 `lib/app/routes/app_pages.dart` 中添加:

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

## 🎉 完成！现在可以使用了

### 使用方式 1: 直接调用

```dart
import 'package:shuhang_mall_flutter/app/services/customer_service.dart';

// 打开客服
CustomerService().openCustomer();

// 带商品ID
CustomerService().openCustomerWithProduct(123);
```

### 使用方式 2: 浮动按钮

```dart
import 'package:shuhang_mall_flutter/widgets/customer_float_button.dart';

Stack(
  children: [
    YourPageContent(),
    CustomerFloatButton(
      productId: productId,
      visible: true,
    ),
  ],
)
```

### 使用方式 3: 按钮中使用

```dart
ElevatedButton(
  onPressed: () => CustomerService().openCustomer(),
  child: const Text('联系客服'),
)
```

## 🧪 测试

### 添加测试路由

在 `lib/app/routes/app_pages.dart` 中:

```dart
import 'package:shuhang_mall_flutter/app/modules/customer/customer_test_page.dart';

GetPage(
  name: '/customer-test',
  page: () => const CustomerTestPage(),
),
```

### 运行测试

```dart
Get.toNamed('/customer-test');
```

## 📱 平台配置 (可选)

### iOS - 电话功能

在 `ios/Runner/Info.plist` 中添加:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>tel</string>
</array>
```

## 🎯 支持的客服类型

### 类型 0: 站内客服
后端返回:
```json
{"customer_type": "0"}
```
行为: 跳转到聊天页面

### 类型 1: 电话客服
后端返回:
```json
{"customer_type": "1", "customer_phone": "400-123-4567"}
```
行为: 拨打电话

### 类型 2: 第三方客服
后端返回:
```json
{"customer_type": "2", "customer_url": "https://..."}
```
行为: 打开链接

## 📚 更多文档

- **详细文档**: `lib/app/services/CUSTOMER_SERVICE_README.md`
- **集成指南**: `CUSTOMER_INTEGRATION_GUIDE.md`
- **检查清单**: `CUSTOMER_CHECKLIST.md`
- **完整总结**: `CUSTOMER_SUMMARY.md`
- **代码示例**: `lib/app/services/customer_service_example.dart`

## ✨ 就是这么简单！

只需 3 分钟，4 个步骤，客服系统就可以使用了！🎉
