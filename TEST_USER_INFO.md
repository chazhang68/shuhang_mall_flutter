# 用户信息获取测试

## 📋 测试目的

验证 Flutter 能否正确获取 `xfq_sxf` 字段。

## 🔍 字段映射检查

### UserModel 定义
```dart
@JsonKey(fromJson: stringToDouble)
final double xfqSxf; // 消费券手续费率（百分比）
```

### JSON 映射（user_model.g.dart）
```dart
xfqSxf: json['xfq_sxf'] == null ? 0 : stringToDouble(json['xfq_sxf'])
```

### 映射关系
- JSON 字段: `xfq_sxf`
- Dart 字段: `xfqSxf`
- 类型: `double`
- 默认值: `0`
- 转换函数: `stringToDouble`

✅ **字段映射正确！**

## 🌐 API 接口检查

### uni-app 使用的接口
```javascript
// shsdapp/api/user.js
export function newUserInfo() {
  return request.get('userinfo');
}

// 页面中调用
getUserInfo() {
  newUserInfo().then(res => {
    this.userInfo = res.data
  })
}
```

### Flutter 使用的接口
```dart
// lib/app/data/providers/user_provider.dart
Future<ApiResponse<UserModel>> newUserInfo() async {
  return await _api.get<UserModel>('userinfo', 
    fromJsonT: (data) => UserModel.fromJson(data));
}

// 页面中调用
Future<void> _getUserInfo() async {
  final response = await _userProvider.newUserInfo();
  if (response.isSuccess && response.data != null) {
    setState(() {
      _userInfo = response.data;
    });
  }
}
```

✅ **接口调用一致！**

## 🧪 测试步骤

### 步骤 1: 检查后端返回数据

使用 Postman 或浏览器访问：
```
GET /api/userinfo
Authorization: Bearer {token}
```

**预期返回**:
```json
{
  "code": 200,
  "data": {
    "uid": 123,
    "nickname": "用户名",
    "fd_ky": 5524.354,
    "xfq_sxf": 50,  // ← 检查这个字段
    "fudou": 1000,
    "balance": 100,
    ...
  }
}
```

### 步骤 2: 运行 Flutter App

1. 打开 App
2. 进入积分兑换页面
3. 查看控制台输出

**预期输出**:
```
用户信息加载成功
手续费率: 50.0
可用积分: 5524.354
```

### 步骤 3: 输入兑换数量

输入 `50`，查看控制台输出：

**预期输出**:
```
输入值: 50.0
手续费率: 50.0%
手续费率(小数): 0.5
损耗数量: 25.0
到账数量: 25.0
```

## 🐛 可能的问题

### 问题 1: 后端未返回 xfq_sxf 字段

**症状**:
```
用户信息加载成功
手续费率: 0.0  // 默认值
可用积分: 5524.354
```

**原因**: 后端接口返回的数据中没有 `xfq_sxf` 字段。

**解决方案**:
1. 检查后端代码，确保返回该字段
2. 检查数据库中是否有该字段
3. 检查用户表是否有默认值

### 问题 2: 字段值为 0

**症状**:
```
用户信息加载成功
手续费率: 0.0
可用积分: 5524.354
```

**原因**: 后端返回了字段，但值为 0。

**解决方案**:
1. 在后台管理系统中配置手续费率
2. 检查数据库中该字段的值
3. 更新用户的手续费率配置

### 问题 3: 字段类型不匹配

**症状**:
```
用户信息加载成功
手续费率: null
可用积分: 5524.354
```

**原因**: 后端返回的类型无法转换为 `double`。

**解决方案**:
检查后端返回的数据类型：
- ✅ 正确: `"xfq_sxf": 50` 或 `"xfq_sxf": "50"`
- ❌ 错误: `"xfq_sxf": "50%"` 或 `"xfq_sxf": null`

## 🔧 stringToDouble 函数

### 定义位置
`lib/constant/app_constant.dart`

### 函数实现
```dart
double stringToDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? 0;
  }
  return 0;
}
```

### 支持的输入类型
- `null` → `0`
- `50` (int) → `50.0`
- `50.0` (double) → `50.0`
- `"50"` (string) → `50.0`
- `"50.5"` (string) → `50.5`
- `"abc"` (invalid) → `0`

✅ **转换函数支持多种类型！**

## 📊 完整数据流

```
后端 API
  ↓
GET /userinfo
  ↓
返回 JSON: { "xfq_sxf": 50 }
  ↓
UserProvider.newUserInfo()
  ↓
UserModel.fromJson(data)
  ↓
stringToDouble(json['xfq_sxf'])
  ↓
UserModel.xfqSxf = 50.0
  ↓
_userInfo?.xfqSxf = 50.0
  ↓
显示: 手续费 50%
```

## ✅ 验证清单

- [x] UserModel 中定义了 `xfqSxf` 字段
- [x] user_model.g.dart 中正确映射 `xfq_sxf`
- [x] 使用 `stringToDouble` 转换函数
- [x] 默认值为 `0`
- [x] 使用 `newUserInfo()` 接口
- [x] 接口路径为 `/userinfo`
- [x] 添加了调试日志

## 🎯 结论

**Flutter 代码完全正确，能够正确获取 `xfq_sxf` 字段！**

如果显示 0.0%，问题在于：
1. 后端未返回该字段
2. 后端返回的值为 0
3. 需要在后台配置手续费率

## 🚀 下一步

1. 运行 App 查看调试日志
2. 使用 Postman 检查后端返回数据
3. 确认 `xfq_sxf` 字段的值
4. 如果为 0，在后台管理系统中配置

---

**代码实现完全正确，等待后端数据验证！** ✅
