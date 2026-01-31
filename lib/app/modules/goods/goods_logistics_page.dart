import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/providers/order_provider.dart';
import '../../data/providers/store_provider.dart';
import '../../theme/theme_colors.dart';

class GoodsLogisticsPage extends StatefulWidget {
  const GoodsLogisticsPage({super.key});

  @override
  State<GoodsLogisticsPage> createState() => _GoodsLogisticsPageState();
}

class _GoodsLogisticsPageState extends State<GoodsLogisticsPage> {
  final OrderProvider _orderProvider = OrderProvider();
  final StoreProvider _storeProvider = StoreProvider();
  final RefreshController _refreshController = RefreshController();

  String _orderId = '';
  List<Map<String, dynamic>> _product = [];
  Map<String, dynamic> _orderInfo = {};
  List<Map<String, dynamic>> _expressList = [];
  List<Map<String, dynamic>> _hostProduct = [];

  @override
  void initState() {
    super.initState();
    _orderId = Get.parameters['orderId'] ?? '';

    if (_orderId.isNotEmpty) {
      _getExpress();
      _getHostProduct();
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _getExpress() async {
    final response = await _orderProvider.getExpress(_orderId);
    if (response.isSuccess && response.data != null) {
      setState(() {
        Map<String, dynamic> order = response.data['order'] ?? {};
        Map<String, dynamic> express = response.data['express'] ?? {};
        Map<String, dynamic> result = express['result'] ?? {};

        _product = List<Map<String, dynamic>>.from(order['cartInfo'] ?? []);
        _orderInfo = order;
        _expressList = List<Map<String, dynamic>>.from(result['list'] ?? []);
      });
    }
    _refreshController.refreshCompleted();
  }

  Future<void> _getHostProduct() async {
    final response = await _storeProvider.getHotProducts(null);
    if (response.isSuccess && response.data != null) {
      setState(() {
        _hostProduct = List<Map<String, dynamic>>.from(response.data);
      });
    }
  }

  void _copyOrderId() {
    String deliveryId = _orderInfo['delivery_id'] ?? '';
    if (deliveryId.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: deliveryId));
      Get.snackbar('提示', '复制成功', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Widget _buildProductItem(Map<String, dynamic> item) {
    Map<String, dynamic> productInfo = item['productInfo'] ?? {};
    double truePrice = double.tryParse((item['truePrice'] ?? 0).toString()) ?? 0;
    double postagePrice = double.tryParse((item['postage_price'] ?? 0).toString()) ?? 0;
    int cartNum = item['cart_num'] ?? 1;
    double totalPrice = truePrice + (postagePrice / cartNum);

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: productInfo['image'] ?? '',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[200]),
              errorWidget: (context, url, error) =>
                  Container(color: Colors.grey[200], child: const Icon(Icons.image)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productInfo['store_name'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '¥${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('x$cartNum', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpressInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      color: Colors.white,
      child: Column(
        children: [
          // 快递公司信息
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ThemeColors.red.primary.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.local_shipping, color: ThemeColors.red.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '快递公司：${_orderInfo['delivery_name'] ?? ''}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '快递单号：${_orderInfo['delivery_id'] ?? ''}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _copyOrderId,
                  style: TextButton.styleFrom(
                    foregroundColor: ThemeColors.red.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('复制'),
                ),
              ],
            ),
          ),

          // 物流轨迹
          ..._expressList.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> item = entry.value;
            bool isFirst = index == 0;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isFirst ? ThemeColors.red.primary : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (index < _expressList.length - 1)
                        Container(width: 1, height: 50, color: Colors.grey[300]),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['status'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: isFirst ? Colors.black : Colors.grey[600],
                            fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['time'] ?? '',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecommend() {
    if (_hostProduct.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('为你推荐', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _hostProduct.length > 4 ? 4 : _hostProduct.length,
            itemBuilder: (context, index) {
              final item = _hostProduct[index];
              return GestureDetector(
                onTap: () {
                  Get.toNamed('/goods/detail', parameters: {'id': (item['id'] ?? 0).toString()});
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 4),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        child: CachedNetworkImage(
                          imageUrl: item['image'] ?? '',
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[200]),
                          errorWidget: (context, url, error) =>
                              Container(color: Colors.grey[200], child: const Icon(Icons.image)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['store_name'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '¥${item['price'] ?? 0}',
                              style: TextStyle(
                                fontSize: 14,
                                color: ThemeColors.red.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('物流详情'), centerTitle: true),
      body: _product.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              onRefresh: _getExpress,
              child: ListView(
                children: [
                  // 商品列表
                  ..._product.map((item) => _buildProductItem(item)),

                  // 物流信息
                  _buildExpressInfo(),

                  // 推荐商品
                  _buildRecommend(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
