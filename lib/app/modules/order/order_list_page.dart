import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/widgets/widgets.dart';

/// 订单列表页
/// 对应原 pages/goods/order_list/index.vue
class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<RefreshController> _refreshControllers = [];
  
  // Tab状态: 0-全部, 1-待付款, 2-待发货, 3-待收货, 4-待评价
  final List<String> _tabTitles = ['全部', '待付款', '待发货', '待收货', '待评价'];
  final List<int> _tabStatus = [-1, 0, 1, 2, 3];
  
  final Map<int, List<Map<String, dynamic>>> _orderData = {};
  final Map<int, int> _pageData = {};
  final Map<int, bool> _hasMoreData = {};

  @override
  void initState() {
    super.initState();
    final initialIndex = int.tryParse(Get.parameters['status'] ?? '0') ?? 0;
    _tabController = TabController(
      length: _tabTitles.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    
    for (int i = 0; i < _tabTitles.length; i++) {
      _refreshControllers.add(RefreshController());
      _orderData[i] = [];
      _pageData[i] = 1;
      _hasMoreData[i] = true;
    }
    
    _loadData(initialIndex, isRefresh: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _refreshControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData(int tabIndex, {bool isRefresh = false}) async {
    if (isRefresh) {
      _pageData[tabIndex] = 1;
      _hasMoreData[tabIndex] = true;
    }

    // 模拟API请求
    await Future.delayed(const Duration(milliseconds: 500));

    if (isRefresh) {
      _orderData[tabIndex]?.clear();
    }

    // 添加示例数据
    final newItems = List.generate(5, (index) {
      final orderIndex = (_pageData[tabIndex]! - 1) * 5 + index;
      return {
        'order_id': 'ORDER${DateTime.now().millisecondsSinceEpoch}$orderIndex',
        'status': _tabStatus[tabIndex] == -1 ? index % 4 : _tabStatus[tabIndex],
        'status_name': _getStatusName(_tabStatus[tabIndex] == -1 ? index % 4 : _tabStatus[tabIndex]),
        'total_price': 199.00 + orderIndex * 100,
        'total_num': 1 + index,
        'create_time': '2024-01-01 12:00:00',
        'goods': [
          {
            'name': '示例商品 $orderIndex',
            'image': '',
            'spec': '规格: 默认',
            'price': 199.00,
            'count': 1,
          },
        ],
      };
    });

    setState(() {
      _orderData[tabIndex]?.addAll(newItems);
      _pageData[tabIndex] = _pageData[tabIndex]! + 1;
      _hasMoreData[tabIndex] = newItems.length >= 5;
    });

    final controller = _refreshControllers[tabIndex];
    if (isRefresh) {
      controller.refreshCompleted();
    } else {
      if (_hasMoreData[tabIndex]!) {
        controller.loadComplete();
      } else {
        controller.loadNoData();
      }
    }
  }

  String _getStatusName(int status) {
    switch (status) {
      case 0:
        return '待付款';
      case 1:
        return '待发货';
      case 2:
        return '待收货';
      case 3:
        return '待评价';
      case 4:
        return '已完成';
      default:
        return '未知';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        final themeColor = controller.themeColor;

        return Scaffold(
          appBar: AppBar(
            title: const Text('我的订单'),
            bottom: TabBar(
              controller: _tabController,
              labelColor: themeColor.primary,
              unselectedLabelColor: const Color(0xFF666666),
              indicatorColor: themeColor.primary,
              indicatorSize: TabBarIndicatorSize.label,
              onTap: (index) {
                if (_orderData[index]?.isEmpty ?? true) {
                  _loadData(index, isRefresh: true);
                }
              },
              tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: List.generate(_tabTitles.length, (index) {
              return _buildOrderList(index, themeColor);
            }),
          ),
        );
      },
    );
  }

  Widget _buildOrderList(int tabIndex, themeColor) {
    final orders = _orderData[tabIndex] ?? [];
    final controller = _refreshControllers[tabIndex];

    return SmartRefresher(
      controller: controller,
      enablePullDown: true,
      enablePullUp: true,
      onRefresh: () => _loadData(tabIndex, isRefresh: true),
      onLoading: () => _loadData(tabIndex),
      child: orders.isEmpty
          ? const EmptyOrder()
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(orders[index], themeColor);
              },
            ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, themeColor) {
    final goods = order['goods'] as List<dynamic>? ?? [];

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.orderDetail,
          parameters: {'order_id': order['order_id']},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // 订单头部
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF5F5F5)),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '订单号: ${order['order_id']}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    order['status_name'] ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: themeColor.primary,
                    ),
                  ),
                ],
              ),
            ),
            // 商品列表
            ...goods.map((item) => _buildGoodsItem(item as Map<String, dynamic>)),
            // 订单底部
            Container(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '共${order['total_num']}件商品',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        '合计: ',
                        style: TextStyle(fontSize: 13),
                      ),
                      Text(
                        '¥${(order['total_price'] as double).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeColor.price,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 操作按钮
            _buildOrderActions(order, themeColor),
          ],
        ),
      ),
    );
  }

  Widget _buildGoodsItem(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: item['image'] != null && item['image'].toString().isNotEmpty
                ? CachedImage(
                    imageUrl: item['image'],
                    width: 70,
                    height: 70,
                    borderRadius: 6,
                  )
                : const Icon(Icons.shopping_bag, size: 30, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  item['spec'] ?? '',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF999999),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '¥${(item['price'] as double).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'x${item['count']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderActions(Map<String, dynamic> order, themeColor) {
    final status = order['status'] as int? ?? 0;
    final actions = <Widget>[];

    switch (status) {
      case 0: // 待付款
        actions.add(_buildActionButton('取消订单', () {}, isOutline: true));
        actions.add(_buildActionButton('去支付', () {
          // 支付
        }, themeColor: themeColor));
        break;
      case 1: // 待发货
        actions.add(_buildActionButton('催发货', () {}));
        break;
      case 2: // 待收货
        actions.add(_buildActionButton('查看物流', () {}));
        actions.add(_buildActionButton('确认收货', () {}, themeColor: themeColor));
        break;
      case 3: // 待评价
        actions.add(_buildActionButton('去评价', () {}, themeColor: themeColor));
        break;
    }

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: actions,
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    VoidCallback onTap, {
    bool isOutline = false,
    dynamic themeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isOutline ? Colors.white : themeColor?.primary ?? const Color(0xFFF5F5F5),
          border: Border.all(
            color: isOutline
                ? const Color(0xFFCCCCCC)
                : themeColor?.primary ?? const Color(0xFFF5F5F5),
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isOutline
                ? const Color(0xFF666666)
                : themeColor != null
                    ? Colors.white
                    : const Color(0xFF333333),
          ),
        ),
      ),
    );
  }
}
