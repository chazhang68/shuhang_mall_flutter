import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/theme/theme_colors.dart';

/// 购物车页面
/// 对应原 pages/order_addcart/order_addcart.vue
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with AutomaticKeepAliveClientMixin {
  bool _isEdit = false;
  bool _selectAll = false;

  // 示例购物车数据
  final List<Map<String, dynamic>> _cartItems = [
    {'id': 1, 'name': '商品1', 'price': 99.00, 'count': 1, 'selected': true},
    {'id': 2, 'name': '商品2', 'price': 199.00, 'count': 2, 'selected': false},
    {'id': 3, 'name': '商品3', 'price': 299.00, 'count': 1, 'selected': true},
  ];

  @override
  bool get wantKeepAlive => true;

  double get _totalPrice {
    return _cartItems
        .where((item) => item['selected'] == true)
        .fold(0.0, (sum, item) => sum + (item['price'] as double) * (item['count'] as int));
  }

  int get _selectedCount {
    return _cartItems.where((item) => item['selected'] == true).length;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GetBuilder<AppController>(
      builder: (controller) {
        final themeColor = controller.themeColor;

        return Scaffold(
          appBar: AppBar(
            title: const Text('购物车'),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _isEdit = !_isEdit;
                  });
                },
                child: Text(_isEdit ? '完成' : '编辑', style: TextStyle(color: themeColor.primary)),
              ),
            ],
          ),
          body: _cartItems.isEmpty
              ? _buildEmptyCart(themeColor)
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          return _buildCartItem(_cartItems[index], themeColor);
                        },
                      ),
                    ),
                    _buildBottomBar(themeColor),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildEmptyCart(ThemeColorData themeColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('购物车是空的', style: TextStyle(fontSize: 16, color: Color(0xFF999999))),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.offAllNamed(AppRoutes.main),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor.primary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: const Text('去逛逛'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, themeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          // 选择框
          Checkbox(
            value: item['selected'] as bool,
            onChanged: (value) {
              setState(() {
                item['selected'] = value;
              });
            },
            activeColor: themeColor.primary,
          ),

          // 商品图片
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Icon(Icons.shopping_bag, size: 40, color: Colors.grey[400])),
          ),

          const SizedBox(width: 12),

          // 商品信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '¥${(item['price'] as double).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: themeColor.price,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildQuantitySelector(item, themeColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(Map<String, dynamic> item, themeColor) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if ((item['count'] as int) > 1) {
                setState(() {
                  item['count'] = (item['count'] as int) - 1;
                });
              }
            },
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              child: const Icon(Icons.remove, size: 16),
            ),
          ),
          Container(
            width: 40,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border.symmetric(vertical: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Text('${item['count']}', style: const TextStyle(fontSize: 14)),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                item['count'] = (item['count'] as int) + 1;
              });
            },
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              child: const Icon(Icons.add, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeColorData themeColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 全选
            Checkbox(
              value: _selectAll,
              onChanged: (value) {
                setState(() {
                  _selectAll = value ?? false;
                  for (var item in _cartItems) {
                    item['selected'] = _selectAll;
                  }
                });
              },
              activeColor: themeColor.primary,
            ),
            const Text('全选'),

            const Spacer(),

            // 合计
            if (!_isEdit) ...[
              const Text('合计：'),
              Text(
                '¥${_totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  color: themeColor.price,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
            ],

            // 结算/删除按钮
            ElevatedButton(
              onPressed: () {
                if (_isEdit) {
                  // 删除选中商品
                  setState(() {
                    _cartItems.removeWhere((item) => item['selected'] == true);
                  });
                } else {
                  // 去结算
                  Get.toNamed(AppRoutes.orderConfirm);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isEdit ? Colors.red : themeColor.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              child: Text(_isEdit ? '删除($_selectedCount)' : '去结算($_selectedCount)'),
            ),
          ],
        ),
      ),
    );
  }
}
