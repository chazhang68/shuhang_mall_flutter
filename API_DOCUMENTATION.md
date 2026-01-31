# 数航商道 API 接口文档

本文档描述了从原始uni-app项目WIKI中提取的API接口，并提供了在Flutter项目中的实现方式。

## 目录

- [概述](#概述)
- [API接口列表](#api接口列表)
- [使用方法](#使用方法)
- [错误处理](#错误处理)

## 概述

此文档包含从原uni-app项目（位于`/api/`目录下）迁移过来的所有API接口，包括：

- `api.js` - 通用API接口
- `admin.js` - 管理员相关接口
- `order.js` - 订单相关接口
- `store.js` - 商品相关接口
- `public.js` - 公共接口
- `points_mall.js` - 积分商城接口
- `user.js` - 用户相关接口

## API接口列表

### 用户相关接口

| 方法 | 路径 | 描述 |
|------|------|------|
| POST | `/login/mobile` | 手机号+验证码登录 |
| POST | `/register` | 用户注册 |
| GET | `/user` | 获取用户信息 |
| GET | `/user/info` | 获取用户详细信息 |
| GET | `/logout` | 退出登录 |

### 商品相关接口

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/product/detail/:id` | 获取产品详情 |
| GET | `/products` | 获取产品列表 |
| GET | `/category` | 获取分类列表 |
| POST | `/cart/add` | 添加到购物车 |
| GET | `/cart/list` | 获取购物车列表 |
| POST | `/collect/add` | 添加收藏 |

### 订单相关接口

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/order/list` | 获取订单列表 |
| POST | `/order/pay` | 订单支付 |
| GET | `/order/detail/:uni` | 获取订单详情 |
| POST | `/order/cancel` | 取消订单 |
| POST | `/order/create/:key` | 创建订单 |

### 管理员相关接口

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/admin/order/statistics` | 获取统计数据 |
| GET | `/admin/order/list` | 获取管理员订单列表 |
| GET | `/admin/order/detail/:orderId` | 获取订单详情 |

### 文章相关接口

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/article/hot/list` | 获取热门文章列表 |
| GET | `/article/details/:id` | 获取文章详情 |

### 系统配置相关接口

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/site_config` | 获取站点配置 |
| GET | `/verify_code` | 获取验证码KEY |
| POST | `/register/verify` | 发送验证码 |

## 使用方法

### 1. 初始化API客户端

```dart
import 'package:shuhang_mall_flutter/app/data/providers/api_service.dart';

// 在应用启动时初始化
ApiClient.init('https://your-api-domain.com/api/');

// 如果有用户token，设置认证
if (userToken != null) {
  ApiClient.setToken(userToken);
}
```

### 2. 使用服务类

```dart
import 'package:shuhang_mall_flutter/app/data/providers/api_usage_example.dart';

final userService = UserService();

// 登录示例
Future<void> login() async {
  final response = await userService.login('13800138000', '123456');
  if (response.isSuccess) {
    print('登录成功');
  } else {
    print('登录失败: ${response.msg}');
  }
}
```

### 3. 调用具体接口

```dart
// 获取商品列表
final productService = ProductService();
final response = await productService.fetchProducts(page: 1, limit: 20);

if (response.isSuccess) {
  // 处理成功响应
  final data = response.data as Map<String, dynamic>;
  final products = data['list'] as List<dynamic>;
  print('获取到 ${products.length} 个商品');
} else {
  // 处理错误
  print('请求失败: ${response.msg}');
}
```

## 错误处理

所有API调用都会返回`ApiResponse`对象，包含以下字段：

- `status`: HTTP状态码或业务状态码
- `msg`: 响应消息
- `data`: 响应数据
- `isSuccess`: 是否成功（status == 200）

```dart
final response = await apiCall();
if (response.isSuccess) {
  // 处理成功情况
  final result = response.data;
} else {
  // 处理错误情况
  print('错误: ${response.msg}');
}
```

## 注意事项

1. 所有API接口都需要根据实际情况替换基础URL
2. 需要正确处理认证令牌
3. 根据业务需求调整请求参数
4. 适当处理网络错误和超时情况