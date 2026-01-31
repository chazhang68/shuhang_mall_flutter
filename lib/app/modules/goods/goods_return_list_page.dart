import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/providers/order_provider.dart';
import '../../theme/theme_colors.dart';

class GoodsReturnListPage extends StatefulWidget {
  const GoodsReturnListPage({super.key});

  @override
  State<GoodsReturnListPage> createState() => _GoodsReturnListPageState();
}

class _GoodsReturnListPageState extends State<GoodsReturnListPage> {
  final OrderProvider _orderProvider = OrderProvider();

  int _id = 0;
  String _orderId = '';
  List<Map<String, dynamic>> _returnGoodsList = [];
  List<Map<String, dynamic>> _cartList = [];

  @override
  void initState() {
    super.initState();
    _id = int.tryParse(Get.parameters['id'] ?? '0') ?? 0;
    _orderId = Get.parameters['orderId'] ?? '';

    if (_id > 0) {
      _getGoodsList();
    }
  }

  Future<void> _getGoodsList() async {
    final response = await _orderProvider.getRefundGoodsList(_id);
    if (response.isSuccess && response.data != null) {
      setState(() {
        List<dynamic> list = response.data;
        _returnGoodsList = list.map((item) {
          Map<String, dynamic> mapItem = Map<String, dynamic>.from(item);
          mapItem['checked'] = false;
          mapItem['numShow'] = item['surplus_num'] ?? 1;
          return mapItem;
        }).toList();
      });
    }
  }

  void _toggleItem(int index) {
    setState(() {
      _returnGoodsList[index]['checked'] = !_returnGoodsList[index]['checked'];
      _updateCartList();
    });
  }

  void _updateCartList() {
    _cartList = [];
    for (var item in _returnGoodsList) {
      if (item['checked'] == true) {
        _cartList.add({'cart_id': item['cart_id'], 'cart_num': item['surplus_num']});
      }
    }
  }

  void _goToRefund() {
    if (_cartList.isEmpty) {
      FlutterToastPro.showMessage( '请先选择退货商品');
      return;
    }

    String cartIdsStr = _cartList.map((e) => e['cart_id'].toString()).join(',');
    Get.toNamed(
      '/goods/return',
      parameters: {'id': _id.toString(), 'orderId': _orderId, 'cartIds': cartIdsStr},
    );
  }

  Widget _buildGoodsItem(int index) {
    Map<String, dynamic> item = _returnGoodsList[index];
    Map<String, dynamic> productInfo = item['productInfo'] ?? {};
    Map<String, dynamic>? attrInfo = productInfo['attrInfo'];
    String image = attrInfo?['image'] ?? productInfo['image'] ?? '';
    bool checked = item['checked'] ?? false;
    int surplusNum = item['surplus_num'] ?? 1;
    double price = double.tryParse((item['truePrice'] ?? 0).toString()) ?? 0;

    return GestureDetector(
      onTap: () => _toggleItem(index),
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 1),
        child: Row(
          children: [
            // 选择框
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: checked ? ThemeColors.red.primary : Colors.transparent,
                border: Border.all(
                  color: checked ? ThemeColors.red.primary : Colors.grey[300]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: checked ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),

            // 商品图片
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) =>
                    Container(color: Colors.grey[200], child: const Icon(Icons.image)),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '¥${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: ThemeColors.red.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '可退数量：$surplusNum',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('选择退货商品'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _returnGoodsList.length,
              itemBuilder: (context, index) => _buildGoodsItem(index),
            ),
          ),

          // 底部按钮
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 12 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.05 * 255).round()),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _goToRefund,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.red.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
                child: const Text(
                  '申请退款',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


