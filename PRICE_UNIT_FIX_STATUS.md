# 价格单位显示修复状态

## 背景说明

在 uni-app 原版中，价格单位使用多语言系统 `$t('swp')`，在中文环境下会被翻译成"消费券"。
Flutter 版本需要将所有显示"swp"或"SWP"的地方改为显示"消费券"。

## ✅ 已完成修改的文件

### 1. 首页商品卡片
**文件**: `lib/widgets/home_product_card.dart`
**修改内容**: 
- 价格前显示红色边框的"消费券"文字标签
- 样式：红色边框 + 红色文字 + 10号字体

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
  decoration: BoxDecoration(
    border: Border.all(color: const Color(0xFFFA281D), width: 1),
    borderRadius: BorderRadius.circular(3),
  ),
  child: const Text(
    '消费券',
    style: TextStyle(
      fontSize: 10,
      color: Color(0xFFFA281D),
      fontWeight: FontWeight.bold,
      height: 1.0,
    ),
  ),
),
```

### 2. 商品详情页
**文件**: `lib/app/modules/goods/goods_detail_page.dart`
**修改内容**:
- ✅ 主价格区域：使用 `xiaofeiquan.png` 图片
- ✅ VIP价格标签：使用 `xiaofeiquan.png` 图片
- ✅ 优惠券弹窗：使用 `xiaofeiquan.png` 图片
- ✅ 海报预览：使用 `xiaofeiquan.png` 图片

所有地方都添加了 errorBuilder 回退方案，如果图片加载失败则显示"消费券"文字。

## ❌ 还需要修改的文件

以下文件仍在显示"SWP"，需要根据实际需求决定是否修改：

### 1. 用户资产页面
- `lib/pages/task/pages/ryz_page.dart` - Tab标签显示"SWP"
- `lib/app/modules/user/ryz_page.dart` - Tab标签显示"SWP"
- `lib/app/modules/user/user_page.dart` - 账户信息显示"SWP"

### 2. 订单支付页面
- `lib/app/modules/order/cashier_page.dart` - 支付金额单位显示"SWP"

### 3. 任务页面
- `lib/app/modules/home/task_page.dart` - 任务类型显示"SWP"
- `lib/pages/task/controllers/task_controller.dart` - 任务类型判断使用"SWP"

## 建议

根据 uni-app 的实现，建议：

1. **商品相关页面**（首页、商品详情、购物车、订单）应该显示"消费券"
2. **用户资产页面**（余额、积分）可以考虑显示"SWP"或"消费券"，取决于产品定位
3. **支付页面**应该显示"消费券"以保持一致性

## 下一步行动

如果需要修改其他页面，请明确指出具体需要修改哪些页面，我会立即进行修改。

## 参考

uni-app 中的多语言配置示例：
```javascript
// 中文环境下
$t('swp') => '消费券'
$t('SWP') => 'SWP' 或 '消费券'（取决于配置）
```

Flutter 中的实现方式：
1. 使用图片：`Image.asset('assets/images/xiaofeiquan.png')`
2. 使用文字：`Text('消费券')`
3. 使用带边框的文字标签（首页商品卡片的方式）
