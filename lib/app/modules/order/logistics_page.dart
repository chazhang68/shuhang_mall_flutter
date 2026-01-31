import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/providers/order_provider.dart';
import '../../theme/theme_colors.dart';

/// 物流详情页面
/// 对应原 pages/goods/goods_logistics/index.vue
class LogisticsPage extends StatefulWidget {
  const LogisticsPage({super.key});

  @override
  State<LogisticsPage> createState() => _LogisticsPageState();
}

class _LogisticsPageState extends State<LogisticsPage> {
  final OrderProvider _orderProvider = OrderProvider();

  String _orderId = '';
  Map<String, dynamic> _orderInfo = {};
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _expressList = [];
  bool _isLoading = true;

  Color get _primaryColor => ThemeColors.red.primary;

  @override
  void initState() {
    super.initState();
    _orderId = Get.arguments?['orderId']?.toString() ?? '';
    if (_orderId.isEmpty) {
      FlutterToastPro.showMessage( '缺少订单号');
      return;
    }
    _loadExpress();
  }

  Future<void> _loadExpress() async {
    try {
      final response = await _orderProvider.getExpress(_orderId);
      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final order = data['order'] as Map<String, dynamic>? ?? {};
        final express = data['express'] as Map<String, dynamic>? ?? {};
        final result = express['result'] as Map<String, dynamic>? ?? {};

        setState(() {
          _orderInfo = order;
          _products =
              (order['cartInfo'] as List<dynamic>?)
                  ?.map((e) => e as Map<String, dynamic>)
                  .toList() ??
              [];
          _expressList =
              (result['list'] as List<dynamic>?)?.map((e) => e as Map<String, dynamic>).toList() ??
              [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        FlutterToastPro.showMessage( response.msg);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      FlutterToastPro.showMessage( '获取物流信息失败');
    }
  }

  void _copyExpressId() {
    final deliveryId = _orderInfo['delivery_id']?.toString() ?? '';
    if (deliveryId.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: deliveryId));
      FlutterToastPro.showMessage( '复制成功');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          '物流详情',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
          ? const Center(child: Text('暂无物流信息'))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // 商品列表
                  ..._products.map((product) => _buildProductItem(product)),
                  const SizedBox(height: 12),
                  // 物流信息
                  _buildLogisticsInfo(),
                ],
              ),
            ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    final productInfo = product['productInfo'] as Map<String, dynamic>? ?? {};
    final truePrice = double.tryParse(product['truePrice']?.toString() ?? '0') ?? 0;
    final postagePrice = double.tryParse(product['postage_price']?.toString() ?? '0') ?? 0;
    final cartNum = int.tryParse(product['cart_num']?.toString() ?? '1') ?? 1;
    final totalPrice = (truePrice + postagePrice / cartNum).toStringAsFixed(2);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品图片
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: productInfo['image'] ?? '',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: const Color(0xFFF5F5F5)),
              errorWidget: (context, url, error) => Container(color: const Color(0xFFF5F5F5)),
            ),
          ),
          const SizedBox(width: 12),
          // 商品信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productInfo['store_name'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF282828)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 价格和数量
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('¥$totalPrice', style: const TextStyle(fontSize: 14, color: Color(0xFF999999))),
              const SizedBox(height: 4),
              Text('x$cartNum', style: const TextStyle(fontSize: 14, color: Color(0xFF999999))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogisticsInfo() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // 快递公司信息
          Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
            ),
            child: Row(
              children: [
                // 图标
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: const Color(0xFF666666),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.local_shipping, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 12),
                // 快递信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '快递公司：',
                            style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
                          ),
                          Expanded(
                            child: Text(
                              _orderInfo['delivery_name'] ?? '',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF282828)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text(
                            '快递单号：',
                            style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
                          ),
                          Expanded(
                            child: Text(
                              _orderInfo['delivery_id']?.toString() ?? '',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF282828)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 复制按钮
                GestureDetector(
                  onTap: _copyExpressId,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF999999)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Text(
                      '复制',
                      style: TextStyle(fontSize: 10, color: Color(0xFF666666)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 物流轨迹
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: List.generate(_expressList.length, (index) {
                final item = _expressList[index];
                final isFirst = index == 0;
                final isLast = index == _expressList.length - 1;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 时间轴
                    Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: isFirst ? _primaryColor : const Color(0xFFDDDDDD),
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 1,
                            height: 50,
                            color: isFirst
                                ? _primaryColor.withAlpha((0.3 * 255).round())
                                : const Color(0xFFE6E6E6),
                          ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    // 物流信息
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['status'] ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: isFirst ? _primaryColor : const Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item['time'] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: isFirst ? _primaryColor : const Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}


