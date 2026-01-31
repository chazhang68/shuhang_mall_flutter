# Task Module - 任务页面模块

## 概述

任务页面模块是从 uni-app 项目的 `pages/task/task.vue` 完整复刻到 Flutter 的实现。该模块包含主任务页面和3个二级页面，实现了完整的任务系统、种子商店、积分管理等功能。

## 目录结构

```
lib/pages/task/
├── task_page.dart              # 页面入口
├── controllers/
│   └── task_controller.dart    # 业务逻辑控制器
├── bindings/
│   └── task_binding.dart       # 依赖注入
├── models/                     # 数据模型
│   ├── models.dart            # 模型导出文件
│   ├── task_seed_model.dart   # 种子模型
│   ├── task_plant_model.dart  # 植物模型
│   ├── task_plot_model.dart   # 地块模型
│   └── task_record_model.dart # 交易记录模型
├── pages/                      # 二级页面
│   ├── ryz_page.dart          # 我的账户页面
│   ├── jifen_exchange_page.dart  # 积分兑换SWP页面
│   └── swp_exchange_page.dart    # SWP兑换积分页面
└── README.md                   # 本文档
```

## 功能模块

### 数据模型

#### 1. TaskSeedModel - 种子模型
```dart
class TaskSeedModel {
  final int id;
  final String name;
  final String image;
  final double dhNum;        // 兑换所需积分
  final double outputNum;    // 预计获得积分
  final int activity;        // 活跃度
  final int count;           // 已购买数量
  final int limit;           // 限购数量
  final int day;             // 生长天数
  final String? description; // 描述
}
```

#### 2. TaskPlantModel - 植物模型
```dart
class TaskPlantModel {
  final int type;           // 植物类型（对应图片编号）
  final double progress;    // 生长进度（0-100）
  final double score;       // 已领取积分
  final int dkDay;          // 当前天数
  final int day;            // 总天数
  final int? id;            // 植物ID
  final String? name;       // 植物名称
  
  // 辅助方法
  bool get isCompleted => progress >= 100;
  double get progressPercent => progress / 100;
}
```

#### 3. TaskPlotModel - 地块模型
```dart
class TaskPlotModel {
  final int fieldType;           // 田块类型（1-12）
  final int left;                // 左侧图标编号
  final int right;               // 右侧图标编号
  final List<TaskPlantModel> plants; // 植物列表
  final int? id;                 // 地块ID
  final String? name;            // 地块名称
  
  // 辅助方法
  int get plantCount => plants.length;
  bool get hasPlants => plants.isNotEmpty;
  int get completedPlantCount => plants.where((plant) => plant.isCompleted).length;
  double get totalProgress { ... }
}
```

#### 4. TaskRecordModel - 交易记录模型
```dart
class TaskRecordModel {
  final int id;
  final String title;        // 标题
  final double num;          // 数量（积分）
  final double? number;      // 数量（SWP）
  final int pm;              // 0=支出, 1=收入
  final String addTime;      // 添加时间
  final String? mark;        // 备注
  final int? status;         // 状态
  
  // 辅助方法
  bool get isIncome => pm == 1;
  bool get isExpense => pm == 0;
  double get displayAmount => number ?? num;
  String get signedAmount => '${isIncome ? '+' : '-'}${displayAmount.toStringAsFixed(2)}';
}
```

### 1. 主任务页面 (task_page.dart)

#### 核心功能
- **水壶进度系统**：8个水壶的糖葫芦效果进度条，显示任务完成进度
- **广告激励系统**：观看广告获得奖励，支持多广告位轮播
- **种子商店弹窗**：网格布局展示种子列表，购买需输入交易密码
- **地块管理系统**：显示多个地块，每个地块包含多个植物，显示生长进度
- **右侧快捷按钮**：
  - 浇水按钮：观看广告或领取奖励
  - 播种按钮：打开种子商店
  - 积分按钮：跳转到可用积分页面
  - SWP按钮：跳转到SWP页面

#### 技术实现
- 使用 GetX 状态管理
- MVC 架构分离
- 响应式数据绑定
- 自定义进度条组件
- 45度透视地块布局算法

#### 数据流
```dart
onInit() 
  → initAd()           // 初始化广告
  → loadData()         // 加载所有数据
    → getUserInfo()    // 获取用户信息
    → getTaskList()    // 获取种子列表
    → getMyTask()      // 获取地块列表
```

### 2. 我的账户页面 (ryz_page.dart)

#### 功能特性
- **3个Tab切换**：
  - 仓库积分 (index=0)
  - 可用积分 (index=1)
  - SWP (index=2)
- **交易记录列表**：
  - 上拉加载更多
  - 下拉刷新
  - 收入/支出标识
- **余额显示**：根据当前Tab显示对应余额
- **兑换按钮**：跳转到对应的兑换页面

#### 路由参数
```dart
Get.toNamed('/task/ryz', arguments: {'index': 1});
```

#### API调用
- `getUserInfo()` - 获取用户信息和余额
- `getCommissionInfo()` - 获取SWP交易记录
- `getFudouList()` - 获取积分交易记录

### 3. 积分兑换SWP页面 (jifen_exchange_page.dart)

#### 功能特性
- 输入兑换数量
- 自动计算手续费（从配置读取）
- 自动计算到账数量
- 全部兑换快捷按钮
- 余额验证
- 交易密码验证

#### 计算公式
```dart
手续费 = 兑换数量 × 手续费率
到账数量 = 兑换数量 - 手续费
```

#### API调用
```dart
await _userProvider.jifenExchangeSwp({
  'num': _amount.value,
  'pwd': _password.value,
});
```

### 4. SWP兑换积分页面 (swp_exchange_page.dart)

#### 功能特性
- 输入兑换数量
- 显示实际到账数量（无手续费）
- 全部兑换快捷按钮
- 余额验证
- 交易密码验证

#### 计算公式
```dart
到账数量 = 兑换数量 × 1 (无手续费)
```

#### API调用
```dart
await _userProvider.swpExchangeJifen({
  'num': _amount.value,
  'pwd': _password.value,
});
```

## 路由配置

### 路由常量 (app_routes.dart)
```dart
static const task = '/task';
static const taskRyz = '/task/ryz';
static const taskJifenExchange = '/task/jifen-exchange';
static const taskSwpExchange = '/task/swp-exchange';
```

### 路由注册 (app_pages.dart)
```dart
GetPage(
  name: AppRoutes.taskRyz,
  page: () => const RyzPage(),
  transition: Transition.rightToLeft,
),
GetPage(
  name: AppRoutes.taskJifenExchange,
  page: () => const JifenExchangePage(),
  transition: Transition.rightToLeft,
),
GetPage(
  name: AppRoutes.taskSwpExchange,
  page: () => const SwpExchangePage(),
  transition: Transition.rightToLeft,
),
```

## 页面跳转关系

```
TaskPage (主任务页面)
  ├─ 积分按钮 → RyzPage (index=1, 可用积分)
  │              └─ 兑换按钮 → JifenExchangePage
  │
  └─ SWP按钮 → RyzPage (index=2, SWP)
                 └─ 兑换按钮 → SwpExchangePage
```

## API接口

### UserProvider 方法
```dart
// 用户信息
Future<ApiResponse<UserModel>> getUserInfo()

// 任务相关
Future<ApiResponse> getUserTask()           // 获取种子列表
Future<ApiResponse> getNewMyTask()          // 获取地块列表
Future<ApiResponse> watchOver(dynamic data) // 广告观看完成
Future<ApiResponse> lingqu()                // 领取奖励
Future<ApiResponse> exchangeTask(Map data)  // 购买种子

// 交易记录
Future<ApiResponse> getCommissionInfo(Map? params, int type)  // SWP记录
Future<ApiResponse> getFudouList(Map? params)                 // 积分记录

// 兑换操作
Future<ApiResponse> jifenExchangeSwp(Map data)  // 积分兑换SWP
Future<ApiResponse> swpExchangeJifen(Map data)  // SWP兑换积分
```

## 状态管理

### TaskController 主要状态
```dart
// 加载状态
final RxBool _isLoading = true.obs;

// 水壶进度 (0-8)
final RxInt _taskDoneCount = 0.obs;

// 种子列表（使用模型）
final RxList<TaskSeedModel> _seedList = <TaskSeedModel>[].obs;

// 地块列表（使用模型）
final RxList<TaskPlotModel> _plotList = <TaskPlotModel>[].obs;

// 用户信息（使用UserModel）
final Rx<UserModel?> _userInfo = Rx<UserModel?>(null);

// 弹窗状态
final RxBool _showShopPopup = false.obs;

// 广告加载状态
final RxBool _adLoading = false.obs;
```

## 广告系统

### AdManager 集成
```dart
// 初始化广告
await _adManager.init();
_adManager.preloadRewardedVideoAd();

// 显示激励视频广告
final success = await _adManager.showRewardedVideoAd(
  onReward: () => onAdComplete(),
  onClose: () => _adLoading.value = false,
  onError: (error) => Get.snackbar('提示', '广告加载失败: $error'),
);
```

### 广告流程
1. 用户点击浇水按钮
2. 检查实名认证状态
3. 显示激励视频广告
4. 用户观看完成后调用 `watchOver` API
5. 更新用户信息和任务进度
6. 如果完成8个任务，自动领取奖励

## 地块布局算法

### 透视布局配置
```dart
// 田块类型中心位置配置 (考虑45度透视)
fieldCenters: {
  1: [[{x: '50%', y: '50%'}]],  // 1个地块
  2: [[{x: '33%', y: '33%'}, {x: '66%', y: '66%'}]],  // 2个地块
  // ... 更多配置
}
```

### 位置计算
```dart
String getPlantPosition(int fieldType, int plantIndex) {
  final layout = fieldLayouts[fieldType];
  final centers = fieldCenters[fieldType];
  
  // 遍历 layout 找到第 plantIndex 个有效地块的位置
  int count = 0;
  for (int rowIndex = 0; rowIndex < layout.length; rowIndex++) {
    for (int colIndex = 0; colIndex < layout[rowIndex].length; colIndex++) {
      if (layout[rowIndex][colIndex] == 1) {
        if (count == plantIndex) {
          final center = centers[rowIndex][colIndex];
          return 'left: ${center.x}; top: ${center.y}; transform: translate(-50%, -100%);';
        }
        count++;
      }
    }
  }
  return '';
}
```

## UI组件

### 水壶进度条
- 8个水壶图标
- 糖葫芦效果的进度槽
- 圆球串在进度槽上
- 动态计算进度条宽度

### 种子商店弹窗
- 网格布局（2列）
- 种子图标和信息
- 购买按钮
- 交易密码输入

### 地块组件
- 田块背景图
- 植物图标（45度透视布局）
- 生长进度条
- 已领取积分显示

## 样式规范

### 颜色
- 主色：`#FF5A5A` (红色)
- 进度条：`linear-gradient(90deg, #ff6b6b 0%, #ff4757 100%)`
- 成功色：`#7dd87d` (绿色)
- 文字：`#333333`, `#666666`, `#999999`

### 圆角
- 卡片：`17rpx`
- 按钮：`4rpx` - `17rpx`
- 进度条：`6rpx`

### 阴影
- 卡片：`0 4rpx 16rpx rgba(0, 0, 0, 0.08)`
- 按钮：`0 4rpx 8rpx rgba(68, 170, 68, 0.3)`

## 注意事项

### 1. 实名认证检查
所有涉及奖励的操作都需要先检查实名认证状态：
```dart
if (_userInfo.value?['is_sign'] != true) {
  Get.snackbar('提示', '请先实名认证哦');
  Get.toNamed('/real-name');
  return;
}
```

### 2. 交易密码验证
所有涉及资产变动的操作都需要输入交易密码：
```dart
if (_password.value.isEmpty) {
  Get.snackbar('提示', '请输入交易密码');
  return;
}
```

### 3. 余额验证
兑换操作前需要验证余额是否充足：
```dart
if (userBalance < requiredAmount) {
  Get.snackbar('提示', '余额不足');
  return;
}
```

### 4. 防重复提交
使用 loading 状态防止重复提交：
```dart
if (_loading.value) return;
_loading.value = true;
try {
  // 执行操作
} finally {
  _loading.value = false;
}
```

## 测试要点

### 功能测试
- [ ] 水壶进度显示正确
- [ ] 广告观看流程完整
- [ ] 种子购买流程正常
- [ ] 地块显示正确
- [ ] 植物进度更新正常
- [ ] 页面跳转正常
- [ ] 兑换功能正常

### 边界测试
- [ ] 未实名认证时的提示
- [ ] 余额不足时的提示
- [ ] 密码错误时的提示
- [ ] 网络异常时的处理
- [ ] 广告加载失败的处理

### 性能测试
- [ ] 列表滚动流畅
- [ ] 图片加载优化
- [ ] 内存占用合理
- [ ] 广告预加载正常

## 与原Vue项目的对应关系

| Vue文件 | Flutter文件 | 说明 |
|---------|------------|------|
| pages/task/task.vue | lib/pages/task/task_page.dart | 主任务页面 |
| pages/users/ryz/ryz.vue | lib/pages/task/pages/ryz_page.dart | 我的账户 |
| pages/users/jifendswp/jifendswp.vue | lib/pages/task/pages/jifen_exchange_page.dart | 积分兑换SWP |
| pages/users/swpdjifen/swpdjifen.vue | lib/pages/task/pages/swp_exchange_page.dart | SWP兑换积分 |

## 更新日志

### v1.0.0 (2026-01-30)
- ✅ 完成主任务页面实现
- ✅ 完成我的账户页面实现
- ✅ 完成积分兑换SWP页面实现
- ✅ 完成SWP兑换积分页面实现
- ✅ 完成路由配置
- ✅ 完成API接口对接
- ✅ 完成广告系统集成
- ✅ 完成地块布局算法
- ✅ 完成文档编写

## 待优化项

1. **性能优化**
   - 地块列表虚拟滚动
   - 图片懒加载
   - 广告预加载策略优化

2. **用户体验**
   - 添加骨架屏
   - 优化加载动画
   - 添加操作反馈动画

3. **代码优化**
   - 提取公共组件
   - 优化状态管理
   - 添加单元测试

## 参考资料

- [GetX 文档](https://pub.dev/packages/get)
- [Flutter 官方文档](https://flutter.dev/docs)
- [Dart 语言规范](https://dart.dev/guides)
