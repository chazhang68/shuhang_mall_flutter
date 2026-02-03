# 农场页面修复总结

## 修复时间
2026年2月3日

## 问题1: 同一账号在 uni-app 能显示田地，Flutter 不行

### 根本原因
**Token 请求头名称不一致**

- **uni-app 使用**: `Authori-zation` (中间有连字符)
- **Flutter 原来使用**: `Authorization` (标准 HTTP 头)

后端期望的是 `Authori-zation`，但 Flutter 发送的是 `Authorization`，导致后端认为用户未登录，返回空数据。

### 修复方案
修改 `lib/app/utils/config.dart`:

```dart
// 修改前
static const String tokenName = 'Authorization';

// 修改后
static const String tokenName = 'Authori-zation'; // 必须与后端一致
```

### 影响文件
- `lib/app/utils/config.dart` - Token 配置
- `lib/app/data/providers/api_provider.dart` - 使用此配置发送请求

### 参考文件
- `shuhang_mall_uniapp/config/app.js` - uni-app 的 Token 配置
- `shuhang_mall_uniapp/utils/request.js` - uni-app 的请求实现

---

## 问题2: 头部应该是水壶图标，不是水滴

### 问题描述
Flutter 使用的是 Material Icons 的水滴图标 (`Icons.water_drop`)，但 uni-app 使用的是自定义的水壶图片。

### uni-app 实现
```vue
<image class="pot-icon" :src="
  index < task_done_count 
    ? '/static/pot_progress_active.png' 
    : '/static/pot_progress_default.png'
"></image>
```

### Flutter 修复
修改 `lib/app/modules/home/task_page.dart`:

```dart
// 修改前
return Icon(
  Icons.water_drop,
  size: 30,
  color: isActive ? themeColor.primary : Colors.grey[300],
);

// 修改后
return Image.asset(
  isActive
      ? 'assets/images/pot_progress_active.png'
      : 'assets/images/pot_progress_default.png',
  width: 30,
  height: 30,
  fit: BoxFit.contain,
);
```

### 使用的图片资源
- `assets/images/pot_progress_active.png` - 已完成的水壶（彩色）
- `assets/images/pot_progress_default.png` - 未完成的水壶（灰色）

---

## 测试步骤

### 1. 完全重启应用
由于修改了 Token 配置，需要完全重启应用（不是热重载）：

```bash
# 停止应用
flutter run --release  # 或重新运行
```

### 2. 重新登录
- 退出当前账号
- 重新登录（确保新的 Token 头被使用）

### 3. 验证农场数据
- 进入农场页面
- 检查是否显示田地数据
- 查看日志输出：
  ```
  🌱 开始获取种植任务...
  📦 API 响应:
    - isSuccess: true
    - data: [...]
  ✅ 获取到 X 个地块
  ```

### 4. 验证水壶图标
- 查看顶部进度条
- 确认显示的是水壶图片，不是水滴图标
- 已完成的水壶应该是彩色的
- 未完成的水壶应该是灰色的

---

## 技术细节

### Token 发送流程

1. **登录时保存 Token**
   ```dart
   Cache.setString(CacheKey.token, token);
   ```

2. **API 请求拦截器添加 Token**
   ```dart
   // lib/app/data/providers/api_provider.dart
   void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
     final token = Cache.getString(CacheKey.token);
     if (token != null && token.isNotEmpty) {
       options.headers[AppConfig.tokenName] = 'Bearer $token';
     }
     handler.next(options);
   }
   ```

3. **后端验证 Token**
   - 后端查找 `Authori-zation` 请求头
   - 如果找不到，认为用户未登录
   - 返回空数据或错误

### 为什么需要完全重启

- Token 配置是静态常量，在应用启动时加载
- 热重载不会重新加载静态常量
- 必须完全重启应用才能使用新的配置

---

## 相关文档
- `FARM_API_TOKEN_FIX.md` - Token 问题详细分析
- `FARM_3D_IMPLEMENTATION_COMPLETE.md` - 3D 农场实现
- `FARM_GAME_AD_INTEGRATION.md` - 广告集成
- `FARM_EMPTY_STATE_DEBUG.md` - 空数据调试指南

---

## 注意事项

1. **非标准请求头**: `Authori-zation` 不是标准的 HTTP 头名称（标准是 `Authorization`），但必须与后端保持一致。

2. **图片资源**: 确保 `pubspec.yaml` 中已经包含图片资源：
   ```yaml
   flutter:
     assets:
       - assets/images/
   ```

3. **日志监控**: 使用 `adb logcat` 或 IDE 控制台查看详细的 API 请求日志，确认 Token 是否正确发送。
