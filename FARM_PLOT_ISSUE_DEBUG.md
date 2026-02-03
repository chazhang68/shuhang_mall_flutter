# 农场种植任务显示问题调试

## 问题描述
Flutter 版本的农场页面中，种植任务（地块列表）没有显示，显示"暂无种植任务"。

## Uni-app 实现分析

### 数据获取
```javascript
getMyTask() {
  let that = this;
  getNewMyTask().then(res => {
    that.plotList = that.SplitArray(res.data, that.myTaskList);
  }).catch(e => {
    uni.showToast({
      title: e,
      icon: "none"
    })
  })
}
```

### 数据结构
每个地块（plot）包含：
```javascript
{
  right: 0,           // 右侧指示牌图标编号
  fieldType: 1,       // 田块类型（1-12）
  plants: [           // 植物数组
    {
      type: 0,        // 植物类型（0-7）
      progress: 50,   // 进度百分比
      dk_day: 5,      // 当前天数
      day: 10,        // 总天数
      score: 100      // 已领取积分
    }
  ]
}
```

### 渲染逻辑
```vue
<view v-for="(plot, plotIndex) in plotList">
  <!-- 右侧指示牌 -->
  <image :src="'/static/right_icon' + plot.right + '.png'"></image>
  
  <!-- 田块背景 -->
  <image :src="'/static/' + plot.fieldType + '.png'"></image>
  
  <!-- 植物层 -->
  <view v-for="(plant, plantIndex) in plot.plants">
    <image :src="'/static/plant' + plant.type + '.png'"></image>
    <view class="plant-progress">
      <view :style="{ width: plant.progress + '%' }"></view>
      <text>{{plant.dk_day}}/{{plant.day}}天</text>
      <text>已领取{{ plant.score }}</text>
    </view>
  </view>
</view>
```

## Flutter 实现分析

### 数据获取
```dart
Future<void> _getMyTask() async {
  try {
    final response = await _userProvider.getNewMyTask();
    if (response.isSuccess && response.data != null) {
      setState(() {
        _plotList = List<Map<String, dynamic>>.from(
          response.data as List? ?? [],
        );
      });
    }
  } catch (e) {
    debugPrint('获取我的任务失败: $e');
  }
}
```

### 渲染逻辑（简化版）
```dart
Widget _buildPlotItem(Map<String, dynamic> plot, ThemeColorData themeColor) {
  final progress = double.tryParse(plot['progress']?.toString() ?? '0') ?? 0;
  final dkDay = plot['dk_day'] ?? 0;
  final totalDay = plot['day'] ?? 1;
  final score = plot['score'] ?? 0;

  return Container(
    child: Column(
      children: [
        Text(plot['name']?.toString() ?? '种植任务'),
        LinearProgressIndicator(value: progress / 100),
        Text('$dkDay/$totalDay天'),
        Text('已领取 $score 积分'),
      ],
    ),
  );
}
```

## 问题分析

### 可能的原因

#### 1. API 返回空数据
**检查方法：**
```dart
Future<void> _getMyTask() async {
  try {
    final response = await _userProvider.getNewMyTask();
    
    // 添加调试日志
    debugPrint('=== getNewMyTask 响应 ===');
    debugPrint('isSuccess: ${response.isSuccess}');
    debugPrint('data: ${response.data}');
    debugPrint('data type: ${response.data.runtimeType}');
    
    if (response.isSuccess && response.data != null) {
      final dataList = response.data as List? ?? [];
      debugPrint('plotList length: ${dataList.length}');
      debugPrint('plotList content: $dataList');
      
      setState(() {
        _plotList = List<Map<String, dynamic>>.from(dataList);
      });
    }
  } catch (e) {
    debugPrint('获取我的任务失败: $e');
  }
}
```

#### 2. 数据结构不匹配
**Flutter 期望的结构：**
```dart
// 直接使用 plot 的字段
plot['progress']  // 进度
plot['dk_day']    // 当前天数
plot['day']       // 总天数
plot['score']     // 积分
```

**Uni-app 的结构：**
```javascript
// plot 包含 plants 数组
plot.plants[0].progress  // 进度
plot.plants[0].dk_day    // 当前天数
plot.plants[0].day       // 总天数
plot.plants[0].score     // 积分
```

**问题：** Flutter 版本没有处理 `plants` 数组！

#### 3. 用户没有种植任务
如果用户还没有购买种子或种植任务，API 返回空数组是正常的。

## 解决方案

### 方案1: 修复数据结构处理（推荐）

修改 `_buildPlotItem` 方法，正确处理 `plants` 数组：

```dart
Widget _buildPlotItem(Map<String, dynamic> plot, ThemeColorData themeColor) {
  // 获取 plants 数组
  final plants = plot['plants'] as List? ?? [];
  
  if (plants.isEmpty) {
    return const SizedBox.shrink();
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withAlpha((0.9 * 255).round()),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 显示地块信息
        Text(
          '田块 ${plot['fieldType'] ?? ''}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        
        // 遍历每个植物
        ...plants.map((plant) => _buildPlantItem(plant, themeColor)).toList(),
      ],
    ),
  );
}

Widget _buildPlantItem(Map<String, dynamic> plant, ThemeColorData themeColor) {
  final progress = double.tryParse(plant['progress']?.toString() ?? '0') ?? 0;
  final dkDay = plant['dk_day'] ?? 0;
  final totalDay = plant['day'] ?? 1;
  final score = plant['score'] ?? 0;

  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 进度条
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    themeColor.primary,
                  ),
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$dkDay/$totalDay天',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '已领取 $score 积分',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    ),
  );
}
```

### 方案2: 添加详细日志

在 `_getMyTask` 中添加详细日志：

```dart
Future<void> _getMyTask() async {
  try {
    debugPrint('🌱 开始获取种植任务...');
    final response = await _userProvider.getNewMyTask();
    
    debugPrint('📦 API 响应:');
    debugPrint('  - isSuccess: ${response.isSuccess}');
    debugPrint('  - msg: ${response.msg}');
    debugPrint('  - data: ${response.data}');
    
    if (response.isSuccess && response.data != null) {
      final dataList = response.data as List? ?? [];
      debugPrint('✅ 获取到 ${dataList.length} 个地块');
      
      for (var i = 0; i < dataList.length; i++) {
        final plot = dataList[i];
        debugPrint('  地块 $i:');
        debugPrint('    - fieldType: ${plot['fieldType']}');
        debugPrint('    - right: ${plot['right']}');
        debugPrint('    - plants: ${plot['plants']}');
      }
      
      setState(() {
        _plotList = List<Map<String, dynamic>>.from(dataList);
      });
      
      debugPrint('🎉 地块列表更新完成');
    } else {
      debugPrint('❌ 获取失败: ${response.msg}');
    }
  } catch (e, stackTrace) {
    debugPrint('💥 获取我的任务异常: $e');
    debugPrint('堆栈: $stackTrace');
  }
}
```

### 方案3: 检查用户是否有种植任务

添加提示信息：

```dart
Widget _buildFarmArea(ThemeColorData themeColor) {
  if (_plotList.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.agriculture,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无种植任务',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            '点击右侧"播种"按钮购买种子开始种植',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
        ],
      ),
    );
  }

  return ListView.builder(
    padding: const EdgeInsets.all(20),
    itemCount: _plotList.length,
    itemBuilder: (context, index) {
      final plot = _plotList[index];
      return _buildPlotItem(plot, themeColor);
    },
  );
}
```

## 调试步骤

### 1. 添加日志
在 `_getMyTask` 方法中添加详细日志，查看 API 返回的数据结构。

### 2. 检查 API 响应
运行应用，查看控制台输出：
```
🌱 开始获取种植任务...
📦 API 响应:
  - isSuccess: true
  - msg: success
  - data: [...]
✅ 获取到 X 个地块
```

### 3. 验证数据结构
确认 API 返回的数据是否包含 `plants` 数组。

### 4. 修复代码
根据实际数据结构，修改 `_buildPlotItem` 方法。

## 预期结果

修复后，农场页面应该显示：
- ✅ 地块列表（如果有数据）
- ✅ 每个地块的植物信息
- ✅ 植物的进度条
- ✅ 当前天数/总天数
- ✅ 已领取积分

如果没有数据：
- ✅ 显示友好的空状态提示
- ✅ 引导用户购买种子

## 总结

问题的根本原因很可能是：
1. **数据结构不匹配** - Flutter 版本没有正确处理 `plants` 数组
2. **用户没有种植任务** - 这是正常情况，需要友好提示

建议先添加日志查看实际数据结构，然后根据实际情况修复代码。
