# 客服系统使用文档

## 概述

本客服系统完全复刻了 uni-app 版本的客服功能，支持三种客服类型：
- **站内客服**：跳转到自建聊天页面
- **电话客服**：直接拨打客服电话
- **第三方客服**：支持企业微信客服和其他第三方客服链接

## 文件结构

```
lib/
├── app/
│   ├── data/
│   │   ├── models/
│   │   │   └── customer_model.dart          # 客服数据模型
│   │   └── providers/
│   │       └── public_provider.dart         # 添加了 getCustomerType API
│   └── services/
│       ├── customer_service.dart            # 客服服务核心逻辑
│       ├── customer_service_example.dart    # 使用示例
│       └── CUSTOMER_SERVICE_README.md       # 本文档
└── widgets/
    └── customer_float_button.dart           # 客服浮动按钮组件
```

## 快速开始

### 1. 基础使用

```dart
import 'package:shuhang_mall_flutter/app/services/customer_service.dart';

// 创建客服服务实例
final customerService = CustomerService();

// 打开客服
customerService.openCustomer();
```

### 2. 在商品详情页使用浮动按钮

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
          YourPageContent(),
          
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

### 3. 在底部按钮中使用

```dart
ElevatedButton.icon(
  onPressed: () {
    CustomerService().openCustomer();
  },
  icon: Icon(Icons.headset_mic),
  label: Text('联系客服'),
)
```

## API 说明

### CustomerService 类

#### 方法

##### `openCustomer({String? url, int? productId})`
打开客服

**参数：**
- `url` (可选): 自定义跳转路径，用于站内客服
- `productId` (可选): 商品ID，传递给客服

**示例：**
```dart
// 基础调用
customerService.openCustomer();

// 带商品ID
customerService.openCustomer(productId: 123);

// 自定义路径
customerService.openCustomer(url: '/pages/custom/chat');
```

##### `openCustomerWithProduct(int productId)`
快速打开客服并传递商品ID

**参数：**
- `productId`: 商品ID

**示例：**
```dart
customerService.openCustomerWithProduct(123);
```

### CustomerFloatButton 组件

#### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| productId | int? | null | 商品ID（可选） |
| initialTop | double? | 480.0 | 初始位置（距离顶部的距离） |
| visible | bool | true | 是否显示 |

#### 特性

- ✅ 可拖动调整位置
- ✅ 自动限制在安全区域内
- ✅ 半透明背景，带阴影效果
- ✅ 点击打开客服

## 客服类型处理

### 类型 0：站内客服

后端返回：
```json
{
  "customer_type": "0"
}
```

行为：跳转到聊天页面 `/pages/extension/customer_list/chat`

### 类型 1：电话客服

后端返回：
```json
{
  "customer_type": "1",
  "customer_phone": "400-123-4567"
}
```

行为：调用系统拨号功能

### 类型 2：第三方客服

#### 企业微信客服

后端返回：
```json
{
  "customer_type": "2",
  "customer_url": "https://work.weixin.qq.com/...",
  "customer_corpId": "ww1234567890abcdef"
}
```

行为：使用外部浏览器打开企业微信客服链接

#### 其他第三方客服

后端返回：
```json
{
  "customer_type": "2",
  "customer_url": "https://example.com/customer"
}
```

行为：使用 WebView 打开客服链接

## 需要配置的路由

在 `lib/app/routes/app_routes.dart` 中添加以下路由：

```dart
class AppRoutes {
  // ... 其他路由
  
  /// 客服聊天页面
  static const customerChat = '/customer/chat';
  
  /// WebView 页面
  static const webView = '/webview';
}
```

在 `lib/app/routes/app_pages.dart` 中添加对应的页面：

```dart
GetPage(
  name: AppRoutes.customerChat,
  page: () => CustomerChatPage(),
),
GetPage(
  name: AppRoutes.webView,
  page: () => WebViewPage(),
),
```

## 错误处理

系统会自动处理以下错误情况：

1. **API 请求失败**：显示"获取客服信息失败"提示
2. **电话号码未配置**：显示"客服电话未配置"提示
3. **客服链接未配置**：显示"客服链接未配置"提示
4. **无法拨打电话**：显示"无法拨打电话"提示
5. **无法打开链接**：显示"无法打开企业微信客服"提示

所有错误都会通过 `Get.snackbar` 显示给用户。

## 与 uni-app 版本的对应关系

| uni-app | Flutter |
|---------|---------|
| `components/kefuIcon/index.vue` | `widgets/customer_float_button.dart` |
| `utils/index.js` 中的 `getCustomer` | `services/customer_service.dart` 中的 `openCustomer` |
| `api/api.js` 中的 `getCustomerType` | `providers/public_provider.dart` 中的 `getCustomerType` |
| `open-type="contact"` (小程序) | 不适用（Flutter 无小程序环境） |
| `uni.navigateTo` | `Get.toNamed` |
| `uni.makePhoneCall` | `launchUrl(Uri(scheme: 'tel'))` |
| `plus.runtime.openURL` (App) | `launchUrl(mode: LaunchMode.externalApplication)` |

## 依赖说明

本功能依赖以下 Flutter 包（已在 pubspec.yaml 中配置）：

- `get`: 路由管理和状态管理
- `url_launcher`: 打开电话和外部链接
- `dio`: 网络请求

## 注意事项

1. **iOS 配置**：在 `ios/Runner/Info.plist` 中添加电话权限：
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>tel</string>
</array>
```

2. **Android 配置**：在 `android/app/src/main/AndroidManifest.xml` 中添加网络权限（通常已有）：
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

3. **路由配置**：确保已创建客服聊天页面和 WebView 页面

4. **测试建议**：
   - 在真机上测试电话拨打功能
   - 测试不同客服类型的切换
   - 测试浮动按钮的拖动功能

## 完整示例

查看 `customer_service_example.dart` 文件获取更多使用示例。

## 常见问题

### Q: 如何自定义浮动按钮样式？

A: 修改 `CustomerFloatButton` 组件中的 `Container` 样式：

```dart
Container(
  width: 48.0,
  height: 48.0,
  decoration: BoxDecoration(
    color: Colors.red, // 修改背景色
    borderRadius: BorderRadius.circular(24.0),
    // ... 其他样式
  ),
  child: Icon(
    Icons.support_agent, // 修改图标
    size: 24.0,
    color: Colors.white, // 修改图标颜色
  ),
)
```

### Q: 如何禁用浮动按钮的拖动功能？

A: 移除 `GestureDetector` 的 `onPanUpdate` 回调：

```dart
GestureDetector(
  onTap: _handleTap,
  // 移除 onPanUpdate
  child: Container(...),
)
```

### Q: 如何在多个页面共享浮动按钮位置？

A: 使用 GetX 状态管理保存位置：

```dart
class CustomerButtonController extends GetxController {
  final top = 480.0.obs;
}

// 在组件中使用
final controller = Get.find<CustomerButtonController>();
```

## 更新日志

- **v1.0.0** (2024-02-01)
  - 初始版本
  - 支持三种客服类型
  - 实现浮动按钮组件
  - 完全复刻 uni-app 功能
