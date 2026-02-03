# 记住账号功能说明

## 功能概述
在登录页面添加了"记住账号"功能，用户登录成功后，下次打开登录页面会自动填充上次登录的账号。

## 实现细节

### 1. 缓存键定义 (lib/app/utils/cache.dart)
添加了两个新的缓存键：
- `rememberedAccount`: 存储记住的账号
- `rememberAccount`: 存储是否记住账号的选项

### 2. 登录页面修改 (lib/app/modules/user/login_page.dart)

#### 新增状态变量
```dart
bool _rememberAccount = false; // 是否记住账号
```

#### 新增方法

**加载记住的账号**
```dart
void _loadRememberedAccount() {
  final rememberAccount = Cache.getBool(CacheKey.rememberAccount) ?? false;
  final rememberedAccount = Cache.getString(CacheKey.rememberedAccount) ?? '';
  
  setState(() {
    _rememberAccount = rememberAccount;
    if (rememberAccount && rememberedAccount.isNotEmpty) {
      _accountController.text = rememberedAccount;
    }
  });
}
```

**保存记住的账号**
```dart
Future<void> _saveRememberedAccount(String account) async {
  await Cache.setBool(CacheKey.rememberAccount, _rememberAccount);
  if (_rememberAccount) {
    await Cache.setString(CacheKey.rememberedAccount, account);
  } else {
    await Cache.remove(CacheKey.rememberedAccount);
  }
}
```

#### UI 修改
在表单中添加了"记住账号"复选框（仅在登录时显示，注册时不显示）：
```dart
if (_currentTab != 2)
  Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      children: [
        Checkbox(
          value: _rememberAccount,
          onChanged: (value) => setState(() => _rememberAccount = value ?? false),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const Text('记住账号', style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    ),
  ),
```

#### 登录逻辑修改
在密码登录和验证码登录成功后，都会调用 `_saveRememberedAccount()` 保存账号：
- 密码登录：`_loginWithPassword()`
- 验证码登录：`_loginWithCaptcha()`

## 使用流程

1. **首次登录**
   - 用户输入账号和密码
   - 勾选"记住账号"复选框
   - 点击登录
   - 登录成功后，账号会被保存到本地缓存

2. **再次登录**
   - 打开登录页面
   - 账号输入框会自动填充上次保存的账号
   - "记住账号"复选框会保持勾选状态
   - 用户只需输入密码即可登录

3. **取消记住**
   - 取消勾选"记住账号"复选框
   - 登录后，本地缓存的账号会被清除
   - 下次打开登录页面时，账号输入框为空

## 注意事项

1. 账号信息存储在本地 SharedPreferences 中
2. 只保存账号，不保存密码（安全考虑）
3. 退出登录不会清除记住的账号
4. 注册页面不显示"记住账号"选项
5. 支持密码登录和验证码登录两种方式
