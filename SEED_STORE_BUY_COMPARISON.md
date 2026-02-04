# 种子商店购买接口对比

## uni-app 实现

### API调用
```javascript
exchangeTask({
    task_id: this.info.id,
    num: num,
    pwd: that.pwd
}, true)  // 注意：第二个参数 true
```

### 完整流程
1. 点击购买按钮 → `buySeed(seed)`
2. 打开密码输入弹窗
3. 输入密码后点击确认 → `qurenBuy()`
4. 验证密码不为空
5. 调用 `OkDH()` 方法
6. 验证：
   - num >= 1
   - 用户积分 >= 种子价格 * 数量
7. 调用 `exchangeTask` API
8. 成功后：
   - 关闭弹窗
   - 清空密码
   - 重置 num = 1
   - 刷新数据（种子列表、用户信息、我的任务）

### 关键参数
```javascript
data() {
    return {
        num: 1,        // 购买数量，默认1
        pwd: '',       // 交易密码
        info: [],      // 当前选中的种子信息
        click: false   // 防重复点击标志
    }
}
```

## Flutter 实现

### API调用
```dart
await _userProvider.exchangeTask({
    'task_id': _selectedSeed!['id'],
    'num': _buyNum,
    'pwd': _pwd,
});
```

### 完整流程
1. 点击购买按钮 → 设置 `_selectedSeed`
2. 调用 `_showBuyDialog()` 显示密码输入对话框
3. 输入密码后点击确认 → 调用 `_buySeed()`
4. 验证：
   - 密码不为空
   - 用户积分 >= 种子价格 * 数量
5. 显示加载对话框
6. 调用 `exchangeTask` API
7. 成功后：
   - 关闭加载对话框
   - 关闭种子商店弹窗
   - 清空密码和选中的种子
   - 重置 _buyNum = 1
   - 刷新数据

### 关键参数
```dart
int _buyNum = 1;                        // 购买数量
String _pwd = '';                       // 交易密码
Map<String, dynamic>? _selectedSeed;    // 选中的种子
```

## 主要差异

### 1. API调用方式
- **uni-app**: `exchangeTask(data, true)` - 有第二个参数
- **Flutter**: `exchangeTask(data)` - 只有一个参数

### 2. 防重复点击
- **uni-app**: 使用 `click` 标志位防止重复点击
- **Flutter**: 使用 `Get.dialog` 显示加载对话框，间接防止重复点击

### 3. 数量验证
- **uni-app**: 验证 `num == 0` 时提示"最少兑换一个包"
- **Flutter**: 默认 `_buyNum = 1`，未做0值验证（因为对话框中没有数量输入）

## 可能的问题

### 1. 缺少数量输入
uni-app的弹窗中应该有数量输入控件，但在当前代码中没有看到。Flutter实现中也没有数量输入。

### 2. API第二个参数
uni-app调用 `exchangeTask(data, true)` 时传递了第二个参数 `true`，这可能是某种标志（如是否显示loading）。需要检查Flutter的API封装是否需要类似参数。

### 3. 错误处理
- **uni-app**: catch中关闭弹窗并清空密码
- **Flutter**: catch中只显示错误提示，未关闭弹窗

## 建议修复

### 1. 改进错误处理
```dart
} catch (e) {
  Get.back(); // 关闭加载对话框
  setState(() {
    _pwd = '';  // 清空密码
  });
  FlutterToastPro.showMessage(e.toString());
}
```

### 2. 添加防重复点击
```dart
bool _isExchanging = false;

Future<void> _buySeed() async {
  if (_isExchanging) return;
  _isExchanging = true;
  
  try {
    // ... 原有逻辑
  } finally {
    _isExchanging = false;
  }
}
```

### 3. 添加数量验证
```dart
if (_buyNum <= 0) {
  FlutterToastPro.showMessage('最少兑换一个');
  return;
}
```

## 测试要点
1. ✅ 密码为空时的提示
2. ✅ 积分不足时的提示
3. ✅ 购买成功后的数据刷新
4. ✅ 购买失败时的错误处理
5. ⚠️ 防止重复点击
6. ⚠️ 数量为0时的验证
7. ⚠️ 网络错误时的处理
