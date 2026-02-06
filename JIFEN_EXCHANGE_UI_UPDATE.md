# 积分兑换页面 UI 更新报告

## 🎨 UI 调整

### 调整前后对比

#### 调整前
- 使用白色卡片容器包裹各个部分
- 输入框有底部边框
- 手续费和损耗数量在同一行
- 布局较为紧凑

#### 调整后（与 uni-app 一致）
- 移除白色卡片容器，使用扁平化设计
- 输入框使用圆角边框（红色描边）
- 手续费和损耗数量分开显示
- 布局更加清晰简洁

### 具体修改

#### 1. 输入框样式
```dart
Container(
  height: 48,
  padding: const EdgeInsets.symmetric(horizontal: 16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: const Color(0xFFFF5A5A), width: 1),
  ),
  child: TextField(...)
)
```

**特点**:
- 高度: 48
- 圆角: 24（完全圆角）
- 红色边框: 1px
- 白色背景

#### 2. 信息显示布局
```dart
// 手续费和损耗数量（同一行）
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Row([手续费, 0.0%]),
    Row([损耗数量, 0.0个]),
  ],
)

// 实际到账数量（单独一行）
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text('实际到账数量'),
    Text('50.0个'),
  ],
)
```

#### 3. 按钮样式
```dart
Container(
  width: double.infinity,
  height: 48,
  decoration: BoxDecoration(
    color: const Color(0xFFFF5A5A),
    borderRadius: BorderRadius.circular(24),
  ),
  child: Text('兑换'),
)
```

**特点**:
- 高度: 48
- 圆角: 24（完全圆角）
- 红色背景

### 数字格式化

所有数字都使用 `toStringAsFixed(1)` 保留一位小数：
- 手续费率: `0.0%`
- 损耗数量: `0.0个`
- 实际到账: `50.0个`
- 可用积分: `5524.354个`（保留三位小数）

## 🐛 手续费显示问题

### 问题描述
手续费显示为 `0.0%`，说明 `_userInfo?.xfqSxf` 的值为 0。

### 可能原因

#### 1. 后端返回的数据中 `xfq_sxf` 确实是 0
检查后端接口返回的数据：
```json
{
  "xfq_sxf": 0  // 或者没有这个字段
}
```

#### 2. 使用了错误的接口
当前使用的是 `newUserInfo()` 接口：
```dart
final response = await _userProvider.newUserInfo();
```

可能需要使用 `getUserInfo()` 接口：
```dart
final response = await _userProvider.getUserInfo();
```

### 调试方法

已添加调试日志：
```dart
debugPrint('用户信息加载成功');
debugPrint('手续费率: ${_userInfo?.xfqSxf}');
debugPrint('可用积分: ${_userInfo?.fdKy}');
```

运行 App 后查看控制台输出，确认：
1. 用户信息是否加载成功
2. `xfqSxf` 的实际值是多少
3. 后端是否返回了这个字段

### 解决方案

#### 方案 1: 检查后端接口
确认后端 `/userinfo` 接口是否返回 `xfq_sxf` 字段。

#### 方案 2: 尝试其他接口
如果 `newUserInfo()` 不返回手续费率，尝试使用 `getUserInfo()`:
```dart
final response = await _userProvider.getUserInfo();
```

#### 方案 3: 从配置接口获取
如果手续费率不在用户信息中，可能需要单独的配置接口：
```dart
// 需要添加新的 API 方法
Future<ApiResponse> getExchangeConfig() async {
  return await _api.get('exchange/config');
}
```

## 📊 字段映射

### UserModel 中的字段
```dart
@JsonKey(fromJson: stringToDouble)
final double xfqSxf; // 消费券手续费率（百分比）
```

### JSON 映射
```dart
// user_model.g.dart
xfqSxf: json['xfq_sxf'] == null ? 0 : stringToDouble(json['xfq_sxf'])
```

### 后端字段名
- JSON 字段: `xfq_sxf`
- Dart 字段: `xfqSxf`
- 类型: `double`
- 默认值: `0`

## ✅ 完成的工作

1. ✅ 调整页面布局，与 uni-app 版本一致
2. ✅ 输入框使用圆角红色边框
3. ✅ 移除白色卡片容器
4. ✅ 调整信息显示布局
5. ✅ 统一数字格式化
6. ✅ 添加调试日志

## 🔍 待确认

1. ⏳ 后端接口是否返回 `xfq_sxf` 字段
2. ⏳ 手续费率的实际值是多少
3. ⏳ 是否需要从其他接口获取手续费率

## 📝 测试步骤

1. 运行 App
2. 进入积分兑换页面
3. 查看控制台输出：
   ```
   用户信息加载成功
   手续费率: 0.0  // 或其他值
   可用积分: 5524.354
   ```
4. 输入兑换数量（例如：50）
5. 检查显示：
   - 手续费: `0.0%` 或实际值
   - 损耗数量: 计算值
   - 实际到账: 计算值

## 🎯 下一步

根据调试日志的输出，确定：
1. 如果 `xfqSxf` 为 0，检查后端接口
2. 如果后端不返回该字段，需要添加新的 API
3. 如果字段名不匹配，更新 UserModel 的字段映射

---

**页面 UI 已完全按照 uni-app 版本调整！** 🎨
