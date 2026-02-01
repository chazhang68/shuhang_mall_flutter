import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:get/get.dart';
import '../../data/providers/order_provider.dart';
import '../../theme/theme_colors.dart';
import '../../../widgets/empty_page.dart';

class UserReturnListPage extends StatefulWidget {
  const UserReturnListPage({super.key});

  @override
  State<UserReturnListPage> createState() => _UserReturnListPageState();
}

class _UserReturnListPageState extends State<UserReturnListPage> {
  final OrderProvider _orderProvider = OrderProvider();

  int _type = 0;
  int _page = 1;
  bool _loadEnd = false;
  bool _loading = false;
  List<Map<String, dynamic>> _orderList = [];

  final List<Map<String, dynamic>> _tabsList = [
    {'key': 0, 'name': '全部'},
    {'key': 1, 'name': '申请中'},
    {'key': 2, 'name': '已退款'},
  ];

  @override
  void initState() {
    super.initState();
    String isT = Get.parameters['isT'] ?? '';
    if (isT == '1') {
      _type = 1; // 申请中
    }
    _getOrderList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getOrderList({bool reset = false}) async {
    if (reset) {
      _page = 1;
      _loadEnd = false;
    }

    if (_loadEnd) {
      return;
    }

    if (_loading) return;

    setState(() {
      _loading = true;
    });

    final response = await _orderProvider.getRefundList({
      'page': _page,
      'limit': 20,
      'refund_status': _type,
    });

    if (response.isSuccess && response.data != null) {
      List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
        response.data['list'] ?? response.data,
      );

      setState(() {
        if (reset) {
          _orderList = list;
        } else {
          _orderList.addAll(list);
        }

        if (list.length < 20) {
          _loadEnd = true;
        }
        _page++;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  void _changeTabs(int index) {
    setState(() {
      _type = index;
      _orderList = [];
    });
    _getOrderList(reset: true);
  }

  void _goOrderDetails(String orderId) {
    if (orderId.isEmpty) {
      FlutterToastPro.showMessage('缺少订单号无法查看订单详情');
      return;
    }
    Get.toNamed('/order/detail', parameters: {'id': orderId, 'isReturn': '1'});
  }

  Widget _buildRefundStatusIcon(int refundType) {
    IconData icon;
    Color color;

    switch (refundType) {
      case 1:
      case 2:
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        break;
      case 3:
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case 4:
        icon = Icons.local_shipping;
        color = Colors.orange;
        break;
      case 5:
        icon = Icons.sync;
        color = Colors.orange;
        break;
      case 6:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
    }

    return Icon(icon, size: 48, color: color.withAlpha((0.5 * 255).round()));
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    List<dynamic> cartInfo = item['cart_info'] ?? [];
    int refundType = item['refund_type'] ?? 0;

    return GestureDetector(
      onTap: () => _goOrderDetails(item['order_id'] ?? ''),
      child: Container(
        margin: const EdgeInsets.only(top: 12, left: 12, right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '订单号：${item['order_id'] ?? ''}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                ...cartInfo.map((cartItem) => _buildCartItem(cartItem)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '共 ${item['refund_num'] ?? 0} 件商品，总金额 ',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      '¥${item['refund_price'] ?? 0}',
                      style: TextStyle(
                        fontSize: 16,
                        color: ThemeColors.red.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(top: 0, right: 0, child: _buildRefundStatusIcon(refundType)),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(dynamic cartItem) {
    Map<String, dynamic> productInfo = cartItem['productInfo'] ?? {};
    Map<String, dynamic>? attrInfo = productInfo['attrInfo'];
    String image = attrInfo?['image'] ?? productInfo['image'] ?? '';
    String price = (attrInfo?['price'] ?? productInfo['price'] ?? 0).toString();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: image,
              width: 64,
              height: 64,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        productInfo['store_name'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      'x ${cartItem['cart_num'] ?? 1}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  attrInfo?['suk'] ?? productInfo['store_name'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 4),
                Text('¥$price', style: TextStyle(fontSize: 14, color: ThemeColors.red.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('退款订单'), centerTitle: true),
      body: Column(
        children: [
          // 顶部Tab
          Container(
            color: Colors.white,
            child: Row(
              children: _tabsList.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> tab = entry.value;
                bool isActive = _type == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _changeTabs(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isActive ? ThemeColors.red.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        tab['name'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: isActive ? ThemeColors.red.primary : Colors.black,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 订单列表
          Expanded(
            child: EasyRefresh(
              header: const ClassicHeader(
                dragText: '下拉刷新',
                armedText: '松手刷新',
                processingText: '刷新中...',
                processedText: '刷新完成',
                failedText: '刷新失败',
              ),
              footer: const ClassicFooter(
                dragText: '上拉加载',
                armedText: '松手加载',
                processingText: '加载中...',
                processedText: '加载完成',
                failedText: '加载失败',
                noMoreText: '我也是有底线的',
              ),
              onRefresh: () => _getOrderList(reset: true),
              onLoad: _loadEnd ? null : () => _getOrderList(),
              child: _orderList.isEmpty && !_loading
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [EmptyPage(text: '暂无退款订单~')],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _orderList.length,
                      itemBuilder: (context, index) => _buildOrderItem(_orderList[index]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
