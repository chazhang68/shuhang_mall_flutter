import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';

/// 支付状态页
/// 对应原 pages/goods/order_pay_status/index.vue
class PayStatusPage extends StatefulWidget {
  const PayStatusPage({super.key});

  @override
  State<PayStatusPage> createState() => _PayStatusPageState();
}

class _PayStatusPageState extends State<PayStatusPage> {
  String orderId = '';
  int status = 0;
  bool isLoading = true;
  Map<String, dynamic> orderPayInfo = {};
  List<Map<String, dynamic>> couponList = [];

  @override
  void initState() {
    super.initState();
    orderId = Get.parameters['order_id'] ?? '';
    status = int.tryParse(Get.parameters['status'] ?? '0') ?? 0;
    _loadOrderPayInfo();
  }

  Future<void> _loadOrderPayInfo() async {
    setState(() => isLoading = true);

    // TODO: 调用API获取订单支付信息
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      orderPayInfo = {
        'paid': 1,
        'order_id': orderId,
        'pay_price': '299.00',
        '_add_time': '2024-01-15 14:30:00',
        '_status': {'_payType': '微信支付'},
      };

      couponList = [
        {
          'coupon_title': '新人优惠券',
          'coupon_price': 10,
          'use_min_price': 100,
          'end_time': '2024-02-15',
        },
      ];

      isLoading = false;
    });
  }

  void _goOrderDetails() {
    Get.offNamed(AppRoutes.orderDetail, parameters: {'order_id': orderId});
  }

  void _goHome() {
    Get.offAllNamed(AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPaid = orderPayInfo['paid'] == 1;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(isPaid ? '支付成功' : '支付失败'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // 状态图标
                  _buildStatusIcon(theme, isPaid),

                  // 状态文字
                  const SizedBox(height: 20),
                  Text(
                    isPaid ? '订单支付成功' : '订单支付失败',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  // 订单信息卡片
                  const SizedBox(height: 30),
                  _buildOrderInfoCard(theme),

                  // 按钮
                  const SizedBox(height: 30),
                  _buildButtons(theme),

                  // 赠送优惠券
                  if (couponList.isNotEmpty && isPaid) ...[
                    const SizedBox(height: 30),
                    _buildCouponSection(theme),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildStatusIcon(ThemeData theme, bool isPaid) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isPaid ? theme.primaryColor : Colors.grey,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!, width: 3),
      ),
      child: Icon(isPaid ? Icons.check : Icons.close, color: Colors.white, size: 40),
    );
  }

  Widget _buildOrderInfoCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildInfoRow('订单号', orderId),
          const SizedBox(height: 12),
          _buildInfoRow('下单时间', orderPayInfo['_add_time'] ?? ''),
          const SizedBox(height: 12),
          _buildInfoRow('支付方式', orderPayInfo['_status']?['_payType'] ?? '暂未支付'),
          const SizedBox(height: 12),
          _buildInfoRow('支付金额', '¥${orderPayInfo['pay_price']}'),
          if (orderPayInfo['paid'] != 1) ...[
            const SizedBox(height: 12),
            _buildInfoRow('失败原因', '未支付', isError: true),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isError = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        Text(value, style: TextStyle(fontSize: 14, color: isError ? Colors.red : Colors.grey[600])),
      ],
    );
  }

  Widget _buildButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _goOrderDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: Text(
                orderPayInfo['paid'] == 1 ? '查看订单' : '重新支付',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _goHome,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.primaryColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: Text('返回首页', style: TextStyle(color: theme.primaryColor, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection(ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 60, height: 1, color: Colors.grey[300]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('赠送优惠券', style: TextStyle(fontSize: 14, color: Colors.grey)),
            ),
            Container(width: 60, height: 1, color: Colors.grey[300]),
          ],
        ),
        const SizedBox(height: 16),
        ...couponList.map((coupon) => _buildCouponItem(theme, coupon)),
      ],
    );
  }

  Widget _buildCouponItem(ThemeData theme, Map<String, dynamic> coupon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 80,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            ),
            child: Center(
              child: Text(
                '¥${coupon['coupon_price']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coupon['coupon_title'] ?? '',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '满${coupon['use_min_price']}元可用',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '有效期至: ${coupon['end_time']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
