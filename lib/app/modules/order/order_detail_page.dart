import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:shuhang_mall_flutter/app/data/models/cart_model.dart';
import 'package:shuhang_mall_flutter/app/data/models/order_detail_model.dart';
import 'package:shuhang_mall_flutter/app/data/providers/order_provider.dart';
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
  final OrderProvider _orderProvider = OrderProvider();

  String orderId = '';
  bool isLoading = true;
  OrderDetailModel? orderInfo;
  List<CartItem> cartInfo = [];
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
    try {
      final response = await _orderProvider.getOrderDetail(orderId);
      if (!response.isSuccess) {
        FlutterToastPro.showMessage(response.msg);
        setState(() => isLoading = false);
        return;
      }

      final detail = response.data;
      if (detail == null) {
        FlutterToastPro.showMessage('订单详情为空');
        setState(() => isLoading = false);
        return;
      }

      setState(() {
        orderInfo = detail;
        cartInfo = detail.cartInfo;
        statusType = detail.statusInfo.type == 0 ? detail.status : detail.statusInfo.type;
        isGoodsReturn = detail.refundStatus != 0;
        isLoading = false;
      });
    } catch (e) {
      FlutterToastPro.showMessage('订单详情加载失败');
      setState(() => isLoading = false);
    }
  }

  void _copyOrderId() {
    Clipboard.setData(ClipboardData(text: orderId));
    FlutterToastPro.showMessage('订单号已复制');
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
              _submitCancel();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitCancel() async {
    try {
      final response = await _orderProvider.cancelOrder(orderId);
      FlutterToastPro.showMessage(response.msg);
      if (response.isSuccess) {
        _loadOrderDetail();
      }
    } catch (e) {
      FlutterToastPro.showMessage('取消失败');
    }
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
              _submitTakeOrder();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTakeOrder() async {
    try {
      final response = await _orderProvider.takeOrder(orderId);
      FlutterToastPro.showMessage(response.msg);
      if (response.isSuccess) {
        _loadOrderDetail();
      }
    } catch (e) {
      FlutterToastPro.showMessage('确认收货失败');
    }
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
    final status = orderInfo?.statusInfo;

    return Container(
      color: theme.primaryColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            status?.title ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(status?.message ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
                      orderInfo?.realName ?? '',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      orderInfo?.userPhone ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  orderInfo?.userAddress ?? '',
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
          final product = item.productInfo;
          final attrInfo = product?.attrInfo;
          final imageUrl = product?.image ?? '';
          final price =
              attrInfo?.price ?? (item.truePrice > 0 ? item.truePrice : product?.price ?? 0);
          final sku = attrInfo?.suk ?? '';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
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
                        product?.storeName ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (sku.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(sku, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '¥${_formatMoney(price)}',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text('x${item.cartNum}', style: const TextStyle(color: Colors.grey)),
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
    final totalPrice = _formatMoney(orderInfo?.totalPrice ?? 0);
    final couponPrice = _formatMoney(orderInfo?.couponPrice ?? 0);
    final payPostage = _formatMoney(orderInfo?.payPostage ?? 0);
    final payPrice = _formatMoney(orderInfo?.payPrice ?? 0);
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildPriceRow('商品总价', '¥$totalPrice'),
          _buildPriceRow('优惠券', '-¥$couponPrice'),
          _buildPriceRow('运费', payPostage == '0.00' ? '免运费' : '¥$payPostage'),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('实付款', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                '¥$payPrice',
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
    final payType = orderInfo?.statusInfo.payType ?? '';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('订单信息', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _buildInfoRow('订单号', orderInfo?.orderId ?? '', showCopy: true),
          _buildInfoRow('下单时间', _buildOrderTime()),
          _buildInfoRow('支付状态', orderInfo?.paid == 1 ? '已支付' : '未支付'),
          if (orderInfo?.paid == 1) _buildInfoRow('支付方式', payType),
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
            if (statusType == 4) ...[
              OutlinedButton(
                onPressed: () {
                  // TODO: 删除订单逻辑
                  FlutterToastPro.showMessage('删除订单待实现');
                },
                child: const Text('删除订单'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _submitAgainOrder,
                style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
                child: const Text('再次购买', style: TextStyle(color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submitAgainOrder() async {
    try {
      final response = await _orderProvider.againOrder(orderId);
      FlutterToastPro.showMessage(response.msg);
    } catch (e) {
      FlutterToastPro.showMessage('再次购买失败');
    }
  }

  String _formatMoney(double value) => value.toStringAsFixed(2);

  String _buildOrderTime() {
    final date = orderInfo?.addTimeY ?? '';
    final time = orderInfo?.addTimeH ?? '';
    final combined = '$date $time'.trim();
    return combined.isEmpty ? '-' : combined;
  }
}
