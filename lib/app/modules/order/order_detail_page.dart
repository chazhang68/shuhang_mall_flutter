import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';

/// 订单详情页
/// 对应原 pages/goods/order_details/index.vue
class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final AppController appController = Get.find<AppController>();

  String orderId = '';
  bool isLoading = true;
  Map<String, dynamic> orderInfo = {};
  List<Map<String, dynamic>> cartInfo = [];
  int statusType = 0;
  bool isGoodsReturn = false;

  @override
  void initState() {
    super.initState();
    orderId = Get.parameters['order_id'] ?? '';
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    setState(() => isLoading = true);

    // TODO: 调用API获取订单详情
    await Future.delayed(const Duration(milliseconds: 500));

    // 模拟订单数据
    setState(() {
      orderInfo = {
        'order_id': orderId,
        'paid': 1,
        'status': 1,
        'pay_price': '299.00',
        'total_price': '319.00',
        'coupon_price': '20.00',
        'pay_postage': '0.00',
        'add_time_y': '2024-01-15',
        'add_time_h': '14:30:00',
        'real_name': '张三',
        'user_phone': '13800138000',
        'user_address': '广东省深圳市南山区科技园',
        '_status': {'_title': '待发货', '_msg': '商家正在处理您的订单', '_payType': '微信支付', '_type': 1},
      };

      cartInfo = [
        {
          'productInfo': {
            'image': 'https://via.placeholder.com/200',
            'store_name': '测试商品',
            'price': '99.00',
          },
          'cart_num': 3,
        },
      ];

      statusType = orderInfo['_status']?['_type'] ?? 0;
      isLoading = false;
    });
  }

  void _copyOrderId() {
    Clipboard.setData(ClipboardData(text: orderId));
    Get.snackbar('提示', '订单号已复制');
  }

  void _goPayment() {
    Get.toNamed(AppRoutes.cashier, parameters: {'order_id': orderId, 'from_type': 'order'});
  }

  void _cancelOrder() {
    Get.dialog(
      AlertDialog(
        title: const Text('取消订单'),
        content: const Text('确定要取消此订单吗？'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Get.back();
              // TODO: 调用取消订单API
              Get.snackbar('提示', '订单已取消');
              Get.back();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _confirmReceipt() {
    Get.dialog(
      AlertDialog(
        title: const Text('确认收货'),
        content: const Text('确定已收到商品吗？'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Get.back();
              // TODO: 调用确认收货API
              Get.snackbar('提示', '已确认收货');
              _loadOrderDetail();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // 自定义AppBar
          Container(
            color: theme.primaryColor,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 56,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        '订单详情',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        // 订单状态卡片
                        _buildStatusCard(theme),

                        // 收货地址
                        _buildAddressCard(theme),

                        // 商品列表
                        _buildGoodsCard(theme),

                        // 价格信息
                        _buildPriceCard(theme),

                        // 订单信息
                        _buildOrderInfoCard(theme),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
          ),

          // 底部按钮
          if (!isLoading) _buildBottomButtons(theme),
        ],
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    final status = orderInfo['_status'] ?? {};

    return Container(
      color: theme.primaryColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            status['_title'] ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(status['_msg'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildAddressCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.location_on, color: theme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      orderInfo['real_name'] ?? '',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      orderInfo['user_phone'] ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  orderInfo['user_address'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoodsCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: cartInfo.map((item) {
          final product = item['productInfo'] ?? {};
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product['image'] ?? '',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['store_name'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '¥${product['price']}',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text('x${item['cart_num']}', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildPriceRow('商品总价', '¥${orderInfo['total_price']}'),
          _buildPriceRow('优惠券', '-¥${orderInfo['coupon_price']}'),
          _buildPriceRow(
            '运费',
            orderInfo['pay_postage'] == '0.00' ? '免运费' : '¥${orderInfo['pay_postage']}',
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('实付款', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                '¥${orderInfo['pay_price']}',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('订单信息', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _buildInfoRow('订单号', orderInfo['order_id'] ?? '', showCopy: true),
          _buildInfoRow('下单时间', '${orderInfo['add_time_y']} ${orderInfo['add_time_h']}'),
          _buildInfoRow('支付状态', orderInfo['paid'] == 1 ? '已支付' : '未支付'),
          if (orderInfo['paid'] == 1)
            _buildInfoRow('支付方式', orderInfo['_status']?['_payType'] ?? ''),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool showCopy = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Row(
            children: [
              Text(value, style: const TextStyle(fontSize: 14)),
              if (showCopy) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _copyOrderId,
                  child: const Text('复制', style: TextStyle(color: Colors.blue, fontSize: 12)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 待付款状态
            if (statusType == 0) ...[
              OutlinedButton(onPressed: _cancelOrder, child: const Text('取消订单')),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _goPayment,
                style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
                child: const Text('立即付款', style: TextStyle(color: Colors.white)),
              ),
            ],

            // 待收货状态
            if (statusType == 2) ...[
              OutlinedButton(
                onPressed: () {
                  Get.toNamed(AppRoutes.orderLogistics, parameters: {'orderId': orderId});
                },
                child: const Text('查看物流'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _confirmReceipt,
                style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
                child: const Text('确认收货', style: TextStyle(color: Colors.white)),
              ),
            ],

            // 已完成状态
            if (statusType == 4)
              ElevatedButton(
                onPressed: () {
                  // 再次购买
                },
                style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
                child: const Text('再次购买', style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }
}
