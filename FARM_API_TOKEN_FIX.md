# 农场 API Token 问题修复

## 问题描述
Flutter 应用登录后，农场页面无法获取田地数据（返回空），但同一账号在 uni-app 中可以正常显示田地。

## 问题原因
经过对比 uni-app 和 Flutter 的 API 请求实现，发现 Token 请求头名称不一致：

### uni-app 配置 (config/app.js)
```javascript
TOKENNAME: 'Authori-zation',  // 注意：中间有连字符
```

### Flutter 原配置 (lib/app/utils/config.dart)
```dart
static const String tokenName = 'Authorization';  // 标准 HTTP 头名称
```

**后端期望的请求头名称是 `Authori-zation`（带连字符），而不是标准的 `Authorization`。**

当 Flutter 发送 `Authorization` 请求头时，后端无法识别 Token，认为用户未登录，因此返回空数据。

## 修复方案
修改 `lib/app/utils/config.dart`，将 tokenName 改为与 uni-app 一致：

```dart
/// Token 请求头名称 - 必须与后端一致
static const String tokenName = 'Authori-zation'; // 后端使用的是 Authori-zation (带连字符)
```

## 影响范围
此修复会影响所有需要认证的 API 请求，包括：
- 用户信息获取
- 农场任务数据
- 订单数据
- 个人中心数据
- 等所有需要登录的接口

## 测试步骤
1. 重新启动 Flutter 应用
2. 登录账号
3. 进入农场页面
4. 检查是否能正常显示田地数据

## 相关文件
- `lib/app/utils/config.dart` - Token 配置
- `lib/app/data/providers/api_provider.dart` - API 请求拦截器
- `shuhang_mall_uniapp/config/app.js` - uni-app Token 配置参考

## 注意事项
这个非标准的请求头名称 `Authori-zation` 是后端特定的要求，虽然不符合 HTTP 标准（标准是 `Authorization`），但必须保持一致才能正常工作。
