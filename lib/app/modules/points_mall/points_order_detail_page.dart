import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import '../../data/providers/lottery_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme_colors.dart';

/// 积分订单详情页面
class PointsOrderDetailPage extends StatefulWidget {
  const PointsOrderDetailPage({super.key});

  @override
  State<PointsOrderDetailPage> createState() => _PointsOrderDetailPageState();
}

class _PointsOrderDetailPageState extends State<PointsOrderDetailPage> {
  final PointsMallProvider _provider = PointsMallProvider();

  Map<String, dynamic>? _orderInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getOrderDetail();
  }

  Future<void> _getOrderDetail() async {
    final orderId = Get.parameters['order_id'];
    if (orderId == null) {
      FlutterToastPro.showMessage('订单ID不能为空');
      Get.back();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _provider.getPointsOrderDetail(int.parse(orderId));
      if (response.isSuccess && response.data != null) {
        setState(() {
          _orderInfo = response.data;
        });
      } else {
        FlutterToastPro.showMessage(
          response.msg.isNotEmpty ? response.msg : '获取订单详情失败',
        );
        // 加载失败跳转到兑换记录页
        Get.offNamed(AppRoutes.pointsOrderList);
      }
    } catch (e) {
      FlutterToastPro.showMessage(e.toString());
      // 加载失败跳转到兑换记录页
      Get.offNamed(AppRoutes.pointsOrderList);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmOrder() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认收货'),
        content: const Text('为保障权益，请收到货确认无误后，再确认收货'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (result != true) return;

    try {
      final orderId = _orderInfo?['order_id']?.toString() ?? '';
      final response = await _provider.orderTake(orderId);
      if (response.isSuccess) {
        FlutterToastPro.showMessage('操作成功');
        _getOrderDetail(); // 刷新订单信息
      } else {
        FlutterToastPro.showMessage(
          response.msg.isNotEmpty ? response.msg : '操作失败',
        );
      }
    } catch (e) {
      FlutterToastPro.showMessage(e.toString());
    }
  }

  Future<void> _deleteOrder() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('删除订单'),
        content: const Text('确定要删除此订单吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('确定', style: TextStyle(color: ThemeColors.red.primary)),
          ),
        ],
      ),
    );

    if (result != true) return;

    try {
      final orderId = _orderInfo?['order_id']?.toString() ?? '';
      final response = await _provider.orderDel(orderId);
      if (response.isSuccess) {
        FlutterToastPro.showMessage('删除成功');
        // 删除成功跳转到兑换记录页
        Get.offNamed(AppRoutes.pointsOrderList);
      } else {
        FlutterToastPro.showMessage(
          response.msg.isNotEmpty ? response.msg : '删除失败',
        );
      }
    } catch (e) {
      FlutterToastPro.showMessage(e.toString());
    }
  }

  void _copyOrderId() {
    final orderId = _orderInfo?['order_id']?.toString() ?? '';
    Clipboard.setData(ClipboardData(text: orderId));
    FlutterToastPro.showMessage('已复制订单号');
  }

  void _goLogistics() {
    final orderId = _orderInfo?['order_id']?.toString() ?? '';
    Get.toNamed('/points-mall/logistics', parameters: {'order_id': orderId});
  }

  void _jumpToProduct() {
    final productId = _orderInfo?['product_id']?.toString() ?? '';
    if (productId.isNotEmpty) {
      Get.toNamed(AppRoutes.pointsGoodsDetail, parameters: {'id': productId});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('订单详情'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orderInfo == null
          ? const Center(child: Text('订单信息加载失败'))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final info = _orderInfo!;
    final int status = info['status'] ?? 0;
    final String deliveryType = info['delivery_type']?.toString() ?? '';

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            children: [
              // 收货地址
              _buildAddressSection(),

              const SizedBox(height: 8),

              // 商品信息
              _buildGoodsSection(),

              const SizedBox(height: 8),

              // 订单信息
              _buildOrderInfoSection(),
            ],
          ),
        ),

        // 底部按钮
        _buildBottomButtons(status, deliveryType),
      ],
    );
  }

  Widget _buildAddressSection() {
    final info = _orderInfo!;
    final String realName = info['real_name']?.toString() ?? '';
    final String userPhone = info['user_phone']?.toString() ?? '';
    final String userAddress = info['user_address']?.toString() ?? '';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                realName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                userPhone,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            userAddress,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildGoodsSection() {
    final info = _orderInfo!;
    final int totalNum = info['total_num'] ?? 0;
    final String image = info['image']?.toString() ?? '';
    final String storeName = info['store_name']?.toString() ?? '';
    final String suk = info['suk']?.toString() ?? '';
    final String price = info['price']?.toString() ?? '0';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '共$totalNum件商品',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _jumpToProduct,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => Container(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              storeName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          Text(
                            'x $totalNum',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        suk,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$price消费券',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoSection() {
    final info = _orderInfo!;
    final String orderId = info['order_id']?.toString() ?? '';
    final String statusName = info['status_name']?.toString() ?? '';
    final String addTime = info['add_time']?.toString() ?? '';
    final String totalPrice = info['total_price']?.toString() ?? '0';
    final String mark = info['mark']?.toString() ?? '';
    final String remark = info['remark']?.toString() ?? '';
    final String deliveryType = info['delivery_type']?.toString() ?? '';
    final String deliveryId = info['delivery_id']?.toString() ?? '';
    final String deliveryName = info['delivery_name']?.toString() ?? '';
    final String fictitiousContent =
        info['fictitious_content']?.toString() ?? '';
    final String verifyCode = info['verify_code']?.toString() ?? '';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoRow('订单编号', orderId, showCopy: true),
          _buildInfoRow('订单状态', statusName),
          _buildInfoRow('下单时间', addTime),
          _buildInfoRow('支付消费券', totalPrice),
          if (mark.isNotEmpty) _buildInfoRow('订单备注', mark),
          if (remark.isNotEmpty) _buildInfoRow('商家备注', remark),
          if (deliveryType == 'express' && deliveryId.isNotEmpty)
            _buildInfoRow('快递单号', deliveryId),
          if (deliveryType == 'express' && deliveryName.isNotEmpty)
            _buildInfoRow('快递公司', deliveryName),
          if (deliveryType == 'send' && deliveryId.isNotEmpty)
            _buildInfoRow('送货人电话', deliveryId),
          if (deliveryType == 'send' && deliveryName.isNotEmpty)
            _buildInfoRow('配送人姓名', deliveryName),
          if (deliveryType == 'fictitious') _buildInfoRow('虚拟发货', '已发货，请注意查收'),
          if (fictitiousContent.isNotEmpty)
            _buildInfoRow('虚拟备注', fictitiousContent),
          if (deliveryType == 'send' && verifyCode.isNotEmpty)
            _buildInfoRow('配送核销码', verifyCode),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool showCopy = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label：',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
                if (showCopy)
                  GestureDetector(
                    onTap: _copyOrderId,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: ThemeColors.red.primary),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '复制',
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeColors.red.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(int status, String deliveryType) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 删除订单按钮（status=3 已完成）
            if (status == 3) ...[
              _buildButton(text: '删除订单', onTap: _deleteOrder, isPrimary: true),
            ],

            // 查看物流按钮（有快递单号且是快递配送）
            if (deliveryType == 'express' &&
                (_orderInfo?['delivery_id']?.toString() ?? '').isNotEmpty) ...[
              _buildButton(text: '查看物流', onTap: _goLogistics, isPrimary: false),
              const SizedBox(width: 12),
            ],

            // 确认收货按钮（status=2 待收货）
            if (status == 2) ...[
              _buildButton(text: '确认收货', onTap: _confirmOrder, isPrimary: true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? ThemeColors.red.primary : Colors.white,
          border: isPrimary ? null : Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isPrimary ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
