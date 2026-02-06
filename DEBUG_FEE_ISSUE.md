# 手续费显示问题排查指南

## 🐛 问题描述

积分兑换页面显示：
- 手续费: `0.0%`
- 损耗数量: `0.0个`
- 实际到账: `50.0个`（等于输入数量）

## 🔍 排查步骤

### 步骤 1: 检查后端返回数据

运行 App 并查看控制台输出：

```
用户信息加载成功
手续费率: 0.0  // 或其他值
可用积分: 5524.354
```

**如果显示 0.0**，说明后端返回的 `xfq_sxf` 字段值为 0。

### 步骤 2: 检查后端接口

#### 当前使用的接口
```dart
final response = await _userProvider.newUserInfo();
```

对应后端接口: `GET /userinfo`

#### 检查返回数据
使用 Postman 或浏览器查看接口返回：
```json
{
  "uid": 123,
  "nickname": "用户名",
  "fd_ky": 5524.354,
  "xfq_sxf": 0,  // ← 检查这个字段
  ...
}
```

### 步骤 3: 确认字段名

#### uni-app 使用的字段
```javascript
{{userInfo.xfq_sxf}}%
```

#### Flutter 使用的字段
```dart
${_userInfo?.xfqSxf}%
```

#### 字段映射
- JSON 字段: `xfq_sxf`
- Dart 字段: `xfqSxf`
- 自动转换: `user_model.g.dart`

### 步骤 4: 测试计算逻辑

输入 50 积分，查看控制台输出：

```
输入值: 50.0
手续费率: 0.0%
手续费率(小数): 0.0
损耗数量: 0.0
到账数量: 50.0
```

**如果手续费率不是 0**，应该看到：
```
输入值: 50.0
手续费率: 50.0%
手续费率(小数): 0.5
损耗数量: 25.0
到账数量: 25.0
```

## 🔧 可能的解决方案

### 方案 1: 后端配置手续费率

如果后端 `xfq_sxf` 确实是 0，需要在后台管理系统中配置手续费率。

**配置位置**（可能）:
- 系统设置 → 兑换配置 → 消费券手续费率
- 用户管理 → 用户设置 → 手续费率

### 方案 2: 使用其他接口

如果 `newUserInfo()` 不返回手续费率，尝试使用 `getUserInfo()`:

```dart
// 修改 _getUserInfo 方法
Future<void> _getUserInfo() async {
  try {
    final response = await _userProvider.getUserInfo(); // 改用这个
    if (response.isSuccess && response.data != null) {
      setState(() {
        _userInfo = response.data;
      });
      debugPrint('用户信息加载成功');
      debugPrint('手续费率: ${_userInfo?.xfqSxf}');
    }
  } catch (e) {
    debugPrint('获取用户信息失败: $e');
  }
}
```

### 方案 3: 从配置接口获取

如果手续费率不在用户信息中，可能需要单独的配置接口：

```dart
// 1. 在 UserProvider 中添加方法
Future<ApiResponse> getExchangeConfig() async {
  return await _api.get('exchange/config');
}

// 2. 在页面中调用
Future<void> _getExchangeConfig() async {
  try {
    final response = await _userProvider.getExchangeConfig();
    if (response.isSuccess && response.data != null) {
      final config = response.data as Map<String, dynamic>;
      setState(() {
        _xfqSxfRate = config['xfq_sxf'] ?? 0;
      });
    }
  } catch (e) {
    debugPrint('获取配置失败: $e');
  }
}
```

### 方案 4: 硬编码测试

临时测试，硬编码手续费率为 50%：

```dart
void _onInputChanged() {
  final text = _controller.text;
  if (text.isEmpty) {
    setState(() {
      _jfnum = 0;
      _xfqsxfnum = 0;
      _dznum = 0;
    });
    return;
  }

  final value = double.tryParse(text) ?? 0;
  // 临时硬编码为 50%
  final sxfRate = 50 / 100; // 或使用: (_userInfo?.xfqSxf ?? 50) / 100

  setState(() {
    _jfnum = value;
    _xfqsxfnum = double.parse((value * sxfRate).toStringAsFixed(2));
    _dznum = double.parse((value - _xfqsxfnum).toStringAsFixed(2));
  });
}
```

## 📊 对比 uni-app 实现

### uni-app 代码
```javascript
watch: {
  jfnum: {
    handler: function(newV, old) {
      if (newV == '') {
        this.xfqsxfnum = 0
      } else {
        // 计算损耗
        this.xfqsxfnum = (newV * this.userInfo.xfq_sxf / 100).toFixed(2)
      }
      // 计算到账
      this.dznum = (newV - this.xfqsxfnum).toFixed(2)
    }
  }
}
```

### Flutter 代码
```dart
void _onInputChanged() {
  final value = double.tryParse(text) ?? 0;
  final sxfRate = (_userInfo?.xfqSxf ?? 0) / 100;
  
  _xfqsxfnum = double.parse((value * sxfRate).toStringAsFixed(2));
  _dznum = double.parse((value - _xfqsxfnum).toStringAsFixed(2));
}
```

**逻辑完全一致！**

## ✅ 检查清单

- [ ] 运行 App 并查看控制台输出
- [ ] 确认 `手续费率` 的值
- [ ] 使用 Postman 检查后端接口返回
- [ ] 确认 `xfq_sxf` 字段是否存在
- [ ] 确认 `xfq_sxf` 字段的值
- [ ] 尝试使用 `getUserInfo()` 接口
- [ ] 检查后台管理系统的配置
- [ ] 临时硬编码测试计算逻辑

## 🎯 预期结果

当手续费率为 50% 时：

| 输入 | 手续费 | 损耗 | 到账 |
|------|--------|------|------|
| 50 | 50% | 25.0 | 25.0 |
| 100 | 50% | 50.0 | 50.0 |
| 1000 | 50% | 500.0 | 500.0 |

## 📝 调试日志示例

### 正常情况（手续费率 50%）
```
用户信息加载成功
手续费率: 50.0
可用积分: 5524.354
输入值: 50.0
手续费率: 50.0%
手续费率(小数): 0.5
损耗数量: 25.0
到账数量: 25.0
```

### 异常情况（手续费率 0%）
```
用户信息加载成功
手续费率: 0.0
可用积分: 5524.354
输入值: 50.0
手续费率: 0.0%
手续费率(小数): 0.0
损耗数量: 0.0
到账数量: 50.0
```

## 🚀 下一步

1. 运行 App 并查看调试日志
2. 根据日志输出确定问题原因
3. 选择合适的解决方案
4. 测试验证

---

**关键是确认后端返回的 `xfq_sxf` 字段值！** 🔑
