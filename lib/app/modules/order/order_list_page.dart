import 'package:flutter/material.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/data/models/cart_model.dart';
import 'package:shuhang_mall_flutter/app/data/models/order_list_model.dart';
import 'package:shuhang_mall_flutter/app/data/models/order_status_summary_model.dart';
import 'package:shuhang_mall_flutter/app/data/providers/order_provider.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/widgets/widgets.dart';

/// 订单列表页
/// 对应原 pages/goods/order_list/index.vue
class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> with SingleTickerProviderStateMixin {
  final OrderProvider _orderProvider = OrderProvider();
  late TabController _tabController;
  final List<RefreshController> _refreshControllers = [];
  static const int _pageLimit = 20;

  // Tab状态: 对齐 uniapp（9-全部, 0-待付款, 1-待发货, 2-待收货, 3-已完成）
  final List<String> _tabTitles = ['全部', '待付款', '待发货', '待收货', '已完成'];
  final List<int> _tabStatus = [9, 0, 1, 2, 3];

  final Map<int, List<OrderListItem>> _orderData = {};
  final Map<int, int> _pageData = {};
  final Map<int, bool> _hasMoreData = {};
  OrderStatusSummary? _orderStatusData;

  @override
  void initState() {
    super.initState();
    final statusParam = int.tryParse(Get.parameters['status'] ?? '') ?? 9;
    final initialIndex = _tabStatus.indexOf(statusParam) < 0 ? 0 : _tabStatus.indexOf(statusParam);
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
    _fetchOrderStatusData();
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

    if (!(_hasMoreData[tabIndex] ?? true) && !isRefresh) {
      _refreshControllers[tabIndex].loadNoData();
      return;
    }

    final page = _pageData[tabIndex] ?? 1;
    final params = <String, dynamic>{
      'type': _tabStatus[tabIndex],
      'page': page,
      'limit': _pageLimit,
    };

    try {
      final response = await _orderProvider.getOrderList(params);
      if (!response.isSuccess) {
        FlutterToastPro.showMessage(response.msg);
        _finishLoad(tabIndex, isRefresh, isError: true);
        return;
      }

      final newItems = response.data ?? <OrderListItem>[];

      if (isRefresh) {
        _orderData[tabIndex]?.clear();
      }

      setState(() {
        _orderData[tabIndex]?.addAll(newItems);
        _pageData[tabIndex] = page + 1;
        _hasMoreData[tabIndex] = newItems.length >= _pageLimit;
      });

      _finishLoad(tabIndex, isRefresh);
    } catch (e) {
      FlutterToastPro.showMessage('加载失败');
      _finishLoad(tabIndex, isRefresh, isError: true);
    }
  }

  Future<void> _fetchOrderStatusData() async {
    try {
      final response = await _orderProvider.getOrderStatusNum();
      if (response.isSuccess && response.data != null) {
        setState(() {
          _orderStatusData = response.data;
        });
      }
    } catch (_) {}
  }

  void _finishLoad(int tabIndex, bool isRefresh, {bool isError = false}) {
    final controller = _refreshControllers[tabIndex];
    if (isRefresh) {
      isError ? controller.refreshFailed() : controller.refreshCompleted();
      return;
    }

    if (isError) {
      controller.loadFailed();
      return;
    }

    if (_hasMoreData[tabIndex] ?? false) {
      controller.loadComplete();
    } else {
      controller.loadNoData();
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
                  _fetchOrderStatusData();
                }
              },
              tabs: List.generate(_tabTitles.length, (index) => Tab(text: _buildTabTitle(index))),
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

  Widget _buildOrderCard(OrderListItem order, themeColor) {
    final goods = order.cartInfo;
    final statusTitle = order.statusInfo.title;

    return GestureDetector(
      onTap: () {
        _goOrderDetailItem(order);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            // 订单头部
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
              ),
              child: Row(
                children: [
                  Text(
                    '订单号: ${order.orderId}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                  ),
                  const Spacer(),
                  Text(statusTitle, style: TextStyle(fontSize: 13, color: themeColor.primary)),
                ],
              ),
            ),
            // 商品列表
            ...goods.map(_buildGoodsItem),
            // 订单底部
            Container(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '共${order.totalNum}件商品',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                  ),
                  Row(
                    children: [
                      const Text('合计: ', style: TextStyle(fontSize: 13)),
                      Text(
                        '¥${_formatMoney(order.payPrice)}',
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

  Widget _buildGoodsItem(CartItem item) {
    final productInfo = item.productInfo;
    final attrInfo = productInfo?.attrInfo;
    final imageUrl = productInfo?.image ?? '';
    final productName = productInfo?.storeName ?? '';
    final sku = attrInfo?.suk ?? '';
    final price =
        attrInfo?.price ?? (item.truePrice > 0 ? item.truePrice : productInfo?.price ?? 0);
    final count = item.cartNum;

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
            child: imageUrl.isNotEmpty
                ? CachedImage(imageUrl: imageUrl, width: 70, height: 70, borderRadius: 6)
                : const Icon(Icons.shopping_bag, size: 30, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(sku, style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '¥${_formatMoney(price)}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Text('x$count', style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderActions(OrderListItem order, themeColor) {
    final statusType = order.statusInfo.type == 0 ? order.status : order.statusInfo.type;
    final deliveryType = order.deliveryType;
    final actions = <Widget>[];

    switch (statusType) {
      case 0: // 待付款
      case 9: // 线下付款未支付
        actions.add(
          _buildActionButton('取消订单', () {
            _handleCancel(order);
          }, isOutline: true),
        );
        actions.add(
          _buildActionButton('去支付', () {
            // 支付
          }, themeColor: themeColor),
        );
        break;
      case 1: // 待发货
        actions.add(
          _buildActionButton('查看详情', () {
            _goOrderDetailItem(order);
          }, themeColor: themeColor),
        );
        break;
      case 2: // 待收货
        if (deliveryType == 'express') {
          actions.add(
            _buildActionButton('查看物流', () {
              // TODO: 跳转物流页面
            }),
          );
        }
        actions.add(
          _buildActionButton('查看详情', () {
            _goOrderDetailItem(order);
          }, themeColor: themeColor),
        );
        break;
      case 4: // 已完成
        actions.add(
          _buildActionButton('删除订单', () {
            // TODO: 删除订单逻辑（按你的要求先标记）
            FlutterToastPro.showMessage('删除订单待实现');
          }, isOutline: true),
        );
        actions.add(
          _buildActionButton('查看详情', () {
            _goOrderDetailItem(order);
          }, themeColor: themeColor),
        );
        break;
      default:
        actions.add(
          _buildActionButton('查看详情', () {
            _goOrderDetailItem(order);
          }, themeColor: themeColor),
        );
    }

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: actions),
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

  void _goOrderDetailItem(OrderListItem order) {
    Get.toNamed(AppRoutes.orderDetail, parameters: {'order_id': order.orderId});
  }

  Future<void> _handleCancel(OrderListItem order) async {
    final orderId = order.orderId;
    if (orderId.isEmpty) {
      FlutterToastPro.showMessage('订单号缺失');
      return;
    }

    try {
      final response = await _orderProvider.cancelOrder(orderId);
      FlutterToastPro.showMessage(response.msg);
      if (response.isSuccess) {
        final index = _tabController.index;
        _loadData(index, isRefresh: true);
        _fetchOrderStatusData();
      }
    } catch (e) {
      FlutterToastPro.showMessage('取消失败');
    }
  }

  String _buildTabTitle(int index) {
    final summary = _orderStatusData;
    if (summary == null) {
      return _tabTitles[index];
    }

    int count = 0;
    switch (index) {
      case 0:
        count = summary.orderCount;
        break;
      case 1:
        count = summary.unpaidCount;
        break;
      case 2:
        count = summary.unshippedCount;
        break;
      case 3:
        count = summary.receivedCount;
        break;
      case 4:
        count = summary.completeCount;
        break;
    }

    return count > 0 ? '${_tabTitles[index]}($count)' : _tabTitles[index];
  }

  String _formatMoney(double value) => value.toStringAsFixed(2);
}
