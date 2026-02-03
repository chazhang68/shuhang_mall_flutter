import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/data/providers/order_provider.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';

/// 支付状态页
/// 对应原 pages/goods/order_pay_status/index.vue
class PayStatusPage extends StatefulWidget {
  const PayStatusPage({super.key});

  @override
  State<PayStatusPage> createState() => _PayStatusPageState();
}

class _PayStatusPageState extends State<PayStatusPage> {
  final OrderProvider _orderProvider = OrderProvider();
  String orderId = '';
  int status = 0;
  String msg = '';
  bool isLoading = true;
  Map<String, dynamic> orderPayInfo = {};
  List<Map<String, dynamic>> couponList = [];
  bool couponsHidden = true;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map) {
      orderId = args['order_id']?.toString() ?? '';
      status = int.tryParse(args['status']?.toString() ?? '0') ?? 0;
      msg = args['msg']?.toString() ?? '';
    }
    orderId = orderId.isNotEmpty ? orderId : (Get.parameters['order_id'] ?? '');
    status = status != 0 ? status : (int.tryParse(Get.parameters['status'] ?? '0') ?? 0);
    msg = msg.isNotEmpty ? msg : (Get.parameters['msg'] ?? '');
    _loadOrderPayInfo();
  }

  Future<void> _loadOrderPayInfo() async {
    setState(() => isLoading = true);

    if (orderId.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await _orderProvider.getOrderPayInfo(orderId);
      if (response.isSuccess && response.data != null) {
        final couponResponse = await _orderProvider.orderCoupon(orderId);
        setState(() {
          orderPayInfo = response.data!;
          couponList = couponResponse.data ?? <Map<String, dynamic>>[];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
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
    final isOffline = orderPayInfo['pay_type']?.toString() == 'offline';
    final payTypeText = orderPayInfo['_status']?['_payType'] ?? '暂未支付';
    final statusText = isOffline
        ? '订单创建成功'
        : (status == 1 ? '订单支付中' : (status == 2 ? '订单支付失败' : (isPaid ? '订单支付成功' : '订单支付失败')));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(isPaid ? '支付成功' : '未支付'),
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
                  _StatusIcon(isPaid: isPaid),

                  // 状态文字
                  const SizedBox(height: 20),
                  Text(
                    statusText,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  // 订单信息卡片
                  const SizedBox(height: 30),
                  _OrderInfoCard(
                    orderId: orderId,
                    orderPayInfo: orderPayInfo,
                    payTypeText: payTypeText,
                    isOffline: isOffline,
                    msg: msg,
                  ),

                  // 按钮
                  const SizedBox(height: 30),
                  _ActionButtons(
                    theme: theme,
                    status: status,
                    isPaid: isPaid,
                    orderPayInfo: orderPayInfo,
                    onOrderDetails: _goOrderDetails,
                    onRefresh: _loadOrderPayInfo,
                    onPink: _goPink,
                    onHome: _goHome,
                  ),

                  // 赠送优惠券
                  if (couponList.isNotEmpty && isPaid) ...[
                    const SizedBox(height: 30),
                    _CouponSection(
                      couponList: couponList,
                      couponsHidden: couponsHidden,
                      onToggle: _toggleCoupons,
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  void _goPink() {
    final pinkId = int.tryParse('${orderPayInfo['pink_id'] ?? ''}') ?? 0;
    if (pinkId > 0) {
      Get.toNamed(AppRoutes.groupBuyStatus, parameters: {'id': '$pinkId'});
    }
  }

  void _toggleCoupons() {
    setState(() {
      couponsHidden = !couponsHidden;
    });
  }
}

class _StatusIcon extends StatelessWidget {
  final bool isPaid;

  const _StatusIcon({required this.isPaid});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
}

class _OrderInfoCard extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderPayInfo;
  final String payTypeText;
  final bool isOffline;
  final String msg;

  const _OrderInfoCard({
    required this.orderId,
    required this.orderPayInfo,
    required this.payTypeText,
    required this.isOffline,
    required this.msg,
  });

  @override
  Widget build(BuildContext context) {
    final reason = msg.isNotEmpty ? msg : '未支付';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _InfoRow(label: '订单号', value: orderId),
          const SizedBox(height: 12),
          _InfoRow(label: '下单时间', value: orderPayInfo['_add_time'] ?? ''),
          const SizedBox(height: 12),
          _InfoRow(label: '支付方式', value: payTypeText),
          const SizedBox(height: 12),
          _InfoRow(label: '支付金额', value: '¥${orderPayInfo['pay_price']}'),
          if (orderPayInfo['paid'] != 1 && !isOffline) ...[
            const SizedBox(height: 12),
            _InfoRow(label: '失败原因', value: reason, isError: true),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isError;

  const _InfoRow({required this.label, required this.value, this.isError = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        Text(value, style: TextStyle(fontSize: 14, color: isError ? Colors.red : Colors.grey[600])),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final ThemeData theme;
  final int status;
  final bool isPaid;
  final Map<String, dynamic> orderPayInfo;
  final VoidCallback onOrderDetails;
  final VoidCallback onRefresh;
  final VoidCallback onPink;
  final VoidCallback onHome;

  const _ActionButtons({
    required this.theme,
    required this.status,
    required this.isPaid,
    required this.orderPayInfo,
    required this.onOrderDetails,
    required this.onRefresh,
    required this.onPink,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final pinkId = int.tryParse('${orderPayInfo['pink_id'] ?? ''}') ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (status == 0)
            _PrimaryButton(theme: theme, text: '查看订单', onPressed: onOrderDetails)
          else if (!isPaid && status == 1)
            _PrimaryButton(theme: theme, text: '重新购买', onPressed: onOrderDetails)
          else if (!isPaid && status == 2)
            _PrimaryButton(theme: theme, text: '重新支付', onPressed: onOrderDetails)
          else
            _PrimaryButton(theme: theme, text: '查看订单', onPressed: onOrderDetails),
          if (kIsWeb && !isPaid) ...[
            const SizedBox(height: 12),
            _PrimaryButton(theme: theme, text: '刷新支付状态', onPressed: onRefresh),
          ],
          const SizedBox(height: 12),
          if (pinkId > 0 && isPaid && status != 1 && status != 2)
            _SecondaryButton(theme: theme, text: '邀请好友参团', onPressed: onPink)
          else
            _SecondaryButton(theme: theme, text: '返回首页', onPressed: onHome),
        ],
      ),
    );
  }
}

class _CouponSection extends StatelessWidget {
  final List<Map<String, dynamic>> couponList;
  final bool couponsHidden;
  final VoidCallback onToggle;

  const _CouponSection({
    required this.couponList,
    required this.couponsHidden,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
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
        ...couponList
            .asMap()
            .entries
            .where((entry) => entry.key < 2 || !couponsHidden)
            .map((entry) => _CouponItem(coupon: entry.value)),
        if (couponList.length > 2)
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(couponsHidden ? '更多' : '关闭'),
                  Icon(couponsHidden ? Icons.expand_more : Icons.expand_less),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _CouponItem extends StatelessWidget {
  final Map<String, dynamic> coupon;

  const _CouponItem({required this.coupon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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

class _PrimaryButton extends StatelessWidget {
  final ThemeData theme;
  final String text;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.theme, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final ThemeData theme;
  final String text;
  final VoidCallback onPressed;

  const _SecondaryButton({required this.theme, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.primaryColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Text(text, style: TextStyle(color: theme.primaryColor, fontSize: 16)),
      ),
    );
  }
}
