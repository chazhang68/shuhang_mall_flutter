# 客服系统集成检查清单

## ✅ 已完成的文件

- [x] `lib/app/data/models/customer_model.dart` - 客服数据模型
- [x] `lib/app/data/providers/public_provider.dart` - 添加 getCustomerType API
- [x] `lib/app/services/customer_service.dart` - 客服服务核心逻辑
- [x] `lib/widgets/customer_float_button.dart` - 客服浮动按钮组件
- [x] `lib/widgets/widgets.dart` - 添加导出
- [x] `lib/app/routes/app_routes.dart` - 添加路由常量
- [x] `lib/app/services/customer_service_example.dart` - 使用示例
- [x] `lib/app/services/CUSTOMER_SERVICE_README.md` - 详细文档
- [x] `lib/app/modules/customer/customer_test_page.dart` - 测试页面
- [x] `CUSTOMER_INTEGRATION_GUIDE.md` - 集成指南
- [x] `CUSTOMER_CHECKLIST.md` - 本检查清单

## 📋 需要你完成的任务

### 1. 创建客服聊天页面 (必需)

**文件**: `lib/app/modules/customer/customer_chat_page.dart`

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
        child: Text('客服聊天页面 - 商品ID: $productId'),
      ),
    );
  }
}
```

### 2. 创建 WebView 页面 (必需)

**文件**: `lib/app/modules/webview/webview_page.dart`

**步骤**:
1. 在 `pubspec.yaml` 添加依赖:
```yaml
dependencies:
  webview_flutter: ^4.5.0
```

2. 运行: `flutter pub get`

3. 创建页面:
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

### 3. 配置路由 (必需)

**文件**: `lib/app/routes/app_pages.dart`

在 `pages` 列表中添加:

```dart
import 'package:shuhang_mall_flutter/app/modules/customer/customer_chat_page.dart';
import 'package:shuhang_mall_flutter/app/modules/webview/webview_page.dart';

GetPage(
  name: AppRoutes.customerChat,
  page: () => const CustomerChatPage(),
),
GetPage(
  name: AppRoutes.webView,
  page: () => const WebViewPage(),
),
```

### 4. iOS 配置 (必需 - 如果需要电话功能)

**文件**: `ios/Runner/Info.plist`

添加:
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>tel</string>
</array>
```

### 5. 在商品详情页集成 (推荐)

找到你的商品详情页面，添加客服浮动按钮:

```dart
import 'package:shuhang_mall_flutter/widgets/customer_float_button.dart';

// 在 Scaffold 的 body 中使用 Stack
body: Stack(
  children: [
    // 原有内容
    YourContent(),
    
    // 添加客服浮动按钮
    CustomerFloatButton(
      productId: productId, // 传入商品ID
      initialTop: 480.0,
      visible: true,
    ),
  ],
),
```

## 🧪 测试步骤

### 1. 添加测试路由

在 `lib/app/routes/app_pages.dart` 中添加:

```dart
GetPage(
  name: '/customer-test',
  page: () => const CustomerTestPage(),
),
```

### 2. 运行测试

```dart
// 在任意页面跳转到测试页面
Get.toNamed('/customer-test');
```

### 3. 测试项目

- [ ] 点击"打开客服（基础）"按钮
- [ ] 点击"打开客服（带商品ID）"按钮
- [ ] 点击"打开客服（自定义路径）"按钮
- [ ] 测试浮动按钮拖动功能
- [ ] 测试浮动按钮点击功能
- [ ] 测试不同客服类型（需要后端配置）

## 📱 平台测试

### iOS
- [ ] 电话拨打功能（真机）
- [ ] 企业微信客服打开
- [ ] WebView 页面显示
- [ ] 浮动按钮拖动

### Android
- [ ] 电话拨打功能
- [ ] 企业微信客服打开
- [ ] WebView 页面显示
- [ ] 浮动按钮拖动

## 🔧 后端配置测试

### 测试站内客服 (type = 0)

后端返回:
```json
{
  "status": 200,
  "msg": "success",
  "data": {
    "customer_type": "0"
  }
}
```

预期: 跳转到客服聊天页面

### 测试电话客服 (type = 1)

后端返回:
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

预期: 打开拨号界面

### 测试企业微信客服 (type = 2)

后端返回:
```json
{
  "status": 200,
  "msg": "success",
  "data": {
    "customer_type": "2",
    "customer_url": "https://work.weixin.qq.com/kfid/xxx",
    "customer_corpId": "wwxxx"
  }
}
```

预期: 打开企业微信客服

### 测试其他第三方客服 (type = 2)

后端返回:
```json
{
  "status": 200,
  "msg": "success",
  "data": {
    "customer_type": "2",
    "customer_url": "https://example.com/customer"
  }
}
```

预期: 在 WebView 中打开链接

## 📊 功能验证

- [ ] 客服类型自动识别
- [ ] 电话拨打功能正常
- [ ] 企业微信客服打开正常
- [ ] WebView 加载正常
- [ ] 浮动按钮显示正常
- [ ] 浮动按钮可拖动
- [ ] 浮动按钮位置限制正常
- [ ] 商品ID传递正常
- [ ] 错误提示正常显示
- [ ] 网络异常处理正常

## 🎯 快速开始命令

```bash
# 1. 添加 WebView 依赖
flutter pub add webview_flutter

# 2. 获取依赖
flutter pub get

# 3. 运行项目
flutter run

# 4. 测试客服功能
# 在应用中导航到测试页面: /customer-test
```

## 📝 注意事项

1. **电话功能**: 只能在真机上测试，模拟器不支持
2. **WebView**: iOS 需要在 Info.plist 中配置网络权限
3. **企业微信**: 需要企业微信环境才能完整测试
4. **路由配置**: 确保所有路由都已正确配置
5. **依赖版本**: 确保 `url_launcher` 和 `webview_flutter` 版本兼容

## ✨ 完成标志

当以下所有项都完成时，客服系统即可投入使用:

- [ ] 所有必需文件已创建
- [ ] 路由已正确配置
- [ ] iOS/Android 配置已完成
- [ ] 至少一种客服类型测试通过
- [ ] 浮动按钮功能正常
- [ ] 错误处理正常工作

## 🆘 遇到问题？

查看以下文档:
- `CUSTOMER_INTEGRATION_GUIDE.md` - 详细集成指南
- `lib/app/services/CUSTOMER_SERVICE_README.md` - API 文档
- `lib/app/services/customer_service_example.dart` - 代码示例

或者检查:
1. 路由是否正确配置
2. 依赖是否已安装
3. 平台配置是否完成
4. 后端 API 是否正常返回
