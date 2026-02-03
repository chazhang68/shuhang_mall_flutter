# 农场 API 测试指南

## 问题
登录成功，但农场页面没有显示田地。

## 可能的原因

### 1. API 没有被调用
检查日志中是否有：
```
🌱 开始获取种植任务...
```

如果没有，说明：
- 页面可能没有正确初始化
- `_loadData()` 没有被调用
- 或者有异常被捕获了

### 2. API 返回空数据
检查日志中的 API 响应：
```
📦 API 响应:
  - isSuccess: true
  - data: []  // 空数组
```

如果是空数组，说明：
- 用户确实没有田地数据
- 需要先种植

### 3. API 调用失败
检查日志中是否有：
```
❌ 获取失败: ...
💥 获取我的任务失败: ...
```

---

## 调试步骤

### 步骤1：检查页面是否加载
在农场页面，查看日志是否有：
```
🌱 开始获取种植任务...
```

**如果没有**：
- 页面可能没有正确初始化
- 检查是否有其他错误

**如果有**：
- 继续下一步

### 步骤2：检查 API 响应
查看日志中的完整 API 响应：
```
📦 API 响应:
  - isSuccess: true/false
  - msg: ...
  - data type: ...
  - data: ...
```

### 步骤3：检查 API 请求
查看日志中是否有：
```
[API Request] GET https://test.shsd.top/api/task/new_my_tasks
[API Headers] {...}
```

确认：
- URL 是否正确
- Token 是否发送
- Headers 是否包含 `Authori-zation`

---

## 手动测试 API

### 使用 curl 测试
```bash
curl -X GET "https://test.shsd.top/api/task/new_my_tasks" \
  -H "Content-Type: application/json" \
  -H "Authori-zation: Bearer YOUR_TOKEN_HERE"
```

替换 `YOUR_TOKEN_HERE` 为你的实际 token。

### 预期响应

#### 情况1：有田地数据
```json
{
  "status": 200,
  "msg": "success",
  "data": [
    {
      "fieldType": 0,
      "right": {...},
      "plants": [...]
    }
  ]
}
```

#### 情况2：没有田地数据
```json
{
  "status": 200,
  "msg": "success",
  "data": []
}
```

#### 情况3：认证失败
```json
{
  "status": 110002,
  "msg": "请先登录"
}
```

---

## 对比 uni-app

### 在 uni-app 中测试
1. 用同一账号登录 uni-app
2. 进入农场页面
3. 查看是否有田地

### 如果 uni-app 有田地，Flutter 没有
说明：
- API 调用可能有问题
- Token 可能没有正确发送
- 或者 API 端点不同

### 如果 uni-app 也没有田地
说明：
- 这个账号确实没有种植
- 需要先购买种子并播种

---

## 临时解决方案

### 方案1：在 uni-app 中种植
1. 在 uni-app 中登录同一账号
2. 购买种子
3. 播种到田地
4. 回到 Flutter 查看

### 方案2：使用测试数据
临时添加测试数据到 Flutter：

```dart
Future<void> _getMyTask() async {
  try {
    debugPrint('🌱 开始获取种植任务...');
    final response = await _userProvider.getNewMyTask();

    debugPrint('📦 API 响应:');
    debugPrint('  - isSuccess: ${response.isSuccess}');
    debugPrint('  - msg: ${response.msg}');
    debugPrint('  - data: ${response.data}');

    // 临时测试数据
    if (response.data == null || (response.data as List).isEmpty) {
      debugPrint('⚠️ API 返回空数据，使用测试数据');
      setState(() {
        _plotList = [
          {
            'fieldType': 0,
            'right': {'id': 1, 'name': '测试种子'},
            'plants': [
              {'type': 1, 'progress': 50}
            ]
          }
        ];
      });
      return;
    }

    // 正常处理
    if (response.isSuccess && response.data != null) {
      final dataList = response.data as List? ?? [];
      setState(() {
        _plotList = List<Map<String, dynamic>>.from(dataList);
      });
    }
  } catch (e, stackTrace) {
    debugPrint('💥 获取我的任务失败: $e');
    debugPrint('堆栈: $stackTrace');
  }
}
```

---

## 需要的信息

请提供以下日志信息：

1. **进入农场页面后的完整日志**
   ```
   从 "🌱 开始获取种植任务..." 开始
   到 "✅ 获取到 X 个地块" 或错误信息
   ```

2. **API 请求日志**
   ```
   [API Request] GET https://test.shsd.top/api/task/new_my_tasks
   [API Headers] {...}
   ```

3. **API 响应日志**
   ```
   [API Response] 200
   [API Response Data] {...}
   ```

4. **在 uni-app 中的情况**
   - 同一账号在 uni-app 中是否有田地？
   - 如果有，有多少块田地？
   - 田地上有植物吗？

---

## 快速检查命令

```bash
# 查看农场相关日志
adb logcat | grep -E "🌱|📦|API.*task|new_my_tasks"

# 查看所有 API 请求
adb logcat | grep -E "API Request|API Response"

# 查看错误
adb logcat | grep -E "ERROR|Exception|失败"
```

请把这些日志发给我，我来帮你分析！
