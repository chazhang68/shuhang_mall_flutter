/// 客服服务使用示例
/// 
/// 本文件展示如何在 Flutter 项目中使用客服功能
/// 对应 uni-app 中的客服实现

import 'package:flutter/material.dart';
import 'package:shuhang_mall_flutter/app/services/customer_service.dart';
import 'package:shuhang_mall_flutter/widgets/customer_float_button.dart';

/// ============================================
/// 示例 1: 在商品详情页中使用客服浮动按钮
/// ============================================
class ProductDetailPageExample extends StatelessWidget {
  final int productId;

  const ProductDetailPageExample({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('商品详情')),
      body: Stack(
        children: [
          // 商品详情内容
          SingleChildScrollView(
            child: Column(
              children: [
                // 商品图片、价格、描述等
                const Text('商品详情内容...'),
              ],
            ),
          ),
          
          // 客服浮动按钮
          CustomerFloatButton(
            productId: productId,
            initialTop: 480.0, // 初始位置
            visible: true, // 是否显示
          ),
        ],
      ),
    );
  }
}

/// ============================================
/// 示例 2: 在底部导航栏中添加客服按钮
/// ============================================
class BottomBarWithCustomerExample extends StatelessWidget {
  final CustomerService _customerService = CustomerService();

  BottomBarWithCustomerExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 首页按钮
          _buildBottomItem(
            icon: Icons.home,
            label: '首页',
            onTap: () {
              // 跳转首页
            },
          ),
          
          // 收藏按钮
          _buildBottomItem(
            icon: Icons.favorite_border,
            label: '收藏',
            onTap: () {
              // 收藏操作
            },
          ),
          
          // 客服按钮
          _buildBottomItem(
            icon: Icons.headset_mic,
            label: '客服',
            onTap: () {
              // 打开客服
              _customerService.openCustomer();
            },
          ),
          
          // 购物车按钮
          _buildBottomItem(
            icon: Icons.shopping_cart,
            label: '购物车',
            onTap: () {
              // 跳转购物车
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

/// ============================================
/// 示例 3: 直接调用客服服务
/// ============================================
class DirectCallExample {
  final CustomerService _customerService = CustomerService();

  /// 打开客服（不带商品信息）
  void openCustomer() {
    _customerService.openCustomer();
  }

  /// 打开客服（带商品信息）
  void openCustomerWithProduct(int productId) {
    _customerService.openCustomerWithProduct(productId);
  }

  /// 自定义路径打开客服
  void openCustomerWithCustomUrl(String url) {
    _customerService.openCustomer(url: url);
  }
}

/// ============================================
/// 示例 4: 在列表页中使用（如订单列表）
/// ============================================
class OrderListWithCustomerExample extends StatelessWidget {
  final CustomerService _customerService = CustomerService();

  OrderListWithCustomerExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的订单')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('订单号: 202401010001$index'),
                  const SizedBox(height: 8),
                  const Text('商品信息...'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 联系客服按钮
                      OutlinedButton.icon(
                        onPressed: () {
                          _customerService.openCustomer();
                        },
                        icon: const Icon(Icons.headset_mic, size: 16),
                        label: const Text('联系客服'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ============================================
/// 客服类型说明
/// ============================================
/// 
/// 后端返回的客服配置 (get_customer_type API):
/// 
/// 类型 0 - 站内客服:
/// {
///   "customer_type": "0"
/// }
/// 
/// 类型 1 - 电话客服:
/// {
///   "customer_type": "1",
///   "customer_phone": "400-123-4567"
/// }
/// 
/// 类型 2 - 企业微信客服:
/// {
///   "customer_type": "2",
///   "customer_url": "https://work.weixin.qq.com/...",
///   "customer_corpId": "ww1234567890abcdef"
/// }
/// 
/// 类型 2 - 其他第三方客服:
/// {
///   "customer_type": "2",
///   "customer_url": "https://example.com/customer"
/// }
