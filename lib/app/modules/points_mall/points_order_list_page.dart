import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import '../../data/providers/lottery_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme_colors.dart';
import '../../../widgets/empty_page.dart';

/// 积分兑换记录页面
class PointsOrderListPage extends StatefulWidget {
  const PointsOrderListPage({super.key});

  @override
  State<PointsOrderListPage> createState() => _PointsOrderListPageState();
}

class _PointsOrderListPageState extends State<PointsOrderListPage> {
  final PointsMallProvider _provider = PointsMallProvider();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _orderList = [];
  int _page = 1;
  final int _limit = 20;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _getOrderList();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _getOrderList() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final response = await _provider.getIntegralOrderList(
        page: _page,
        limit: _limit,
      );
      if (response.isSuccess && response.data != null) {
        final List<dynamic> data = response.data;
        setState(() {
          _orderList.addAll(data.cast<Map<String, dynamic>>());
          _hasMore = data.length >= _limit;
          _page++;
        });
      }
    } catch (e) {
      FlutterToastPro.showMessage(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoading) return;
    await _getOrderList();
  }

  Future<void> _refresh() async {
    setState(() {
      _orderList.clear();
      _page = 1;
      _hasMore = true;
    });
    await _getOrderList();
  }

  void _goDetail(String orderId) {
    Get.toNamed(AppRoutes.pointsOrderDetail, parameters: {'order_id': orderId});
  }

  void _goLogistics(String orderId) {
    // 跳转到物流详情页
    Get.toNamed('/points-mall/logistics', parameters: {'order_id': orderId});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('兑换记录'), centerTitle: true),
      body: _orderList.isEmpty && !_isLoading
          ? const EmptyPage(text: '暂无兑换记录～')
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _orderList.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _orderList.length) {
                    return _buildLoadingIndicator();
                  }
                  return _buildOrderItem(_orderList[index]);
                },
              ),
            ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    final String orderId = order['order_id']?.toString() ?? '';
    final String addTime = order['add_time']?.toString() ?? '';
    final String statusName = order['status_name']?.toString() ?? '';
    final int status = order['status'] ?? 0;
    final String deliveryType = order['delivery_type']?.toString() ?? '';
    final String image = order['image']?.toString() ?? '';
    final String storeName = order['store_name']?.toString() ?? '';
    final String suk = order['suk']?.toString() ?? '';
    final String totalPrice = order['total_price']?.toString() ?? '0';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 顶部：兑换时间和状态
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '兑换时间：$addTime',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                Text(
                  statusName,
                  style: TextStyle(
                    fontSize: 13,
                    color: ThemeColors.red.primary,
                  ),
                ),
              ],
            ),
          ),

          // 中间：商品信息
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
            ),
            child: Row(
              children: [
                // 商品图片
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

                // 商品信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        storeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
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
                        '消费券：$totalPrice',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 底部：操作按钮
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 查看物流按钮（status=2 且 delivery_type=express）
                if (status == 2 && deliveryType == 'express') ...[
                  _buildButton(
                    text: '查看物流',
                    onTap: () => _goLogistics(orderId),
                    isPrimary: false,
                  ),
                  const SizedBox(width: 12),
                ],

                // 查看详情按钮
                _buildButton(
                  text: '查看详情',
                  onTap: () => _goDetail(orderId),
                  isPrimary: true,
                ),
              ],
            ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? ThemeColors.red.primary : Colors.white,
          border: isPrimary ? null : Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isPrimary ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              '没有更多了',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
    );
  }
}
