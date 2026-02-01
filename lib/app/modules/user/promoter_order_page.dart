import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/widgets/empty_page.dart';

/// 推广人订单页面
/// 对应原 pages/users/promoter-order/index.vue
class PromoterOrderPage extends StatefulWidget {
  final int? type; // 0: 推广订单, 1: 分销订单

  const PromoterOrderPage({super.key, this.type = 0});

  @override
  State<PromoterOrderPage> createState() => _PromoterOrderPageState();
}

class _PromoterOrderPageState extends State<PromoterOrderPage> {
  final UserProvider _userProvider = Get.find<UserProvider>();

  final List<Map<String, dynamic>> _recordList = [];
  final List<String> _times = [];
  int _page = 1;
  int _count = 0;
  bool _isLoading = true;
  bool _loadEnd = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData({bool isRefresh = false}) async {
    if (isRefresh) {
      _page = 1;
      _recordList.clear();
      _times.clear();
      _loadEnd = false;
    }

    if (_loadEnd) {
      return;
    }

    final response = widget.type == 1
        ? await _userProvider.divisionOrder({'page': _page, 'limit': 8})
        : await _userProvider.spreadOrder({'page': _page, 'limit': 8});

    if (response.isSuccess && response.data != null) {
      final data = response.data;
      List<dynamic> timeList = data['time'] ?? [];
      List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(data['list'] ?? []);

      // 处理时间分组
      for (var timeItem in timeList) {
        String time = timeItem['time'] ?? '';
        if (!_times.contains(time)) {
          _times.add(time);
          _recordList.add({
            'time': time,
            'count': timeItem['count'] ?? 0,
            'child': <Map<String, dynamic>>[],
          });
        }
      }

      // 将订单分配到对应时间组
      for (int x = 0; x < _times.length; x++) {
        for (var orderItem in list) {
          if (_times[x] == orderItem['time_key']) {
            orderItem['open'] = false; // 控制展开收起状态
            _recordList[x]['child'].add(orderItem);
          }
        }
      }

      setState(() {
        _count = data['count'] ?? 0;
        _page++;
        _loadEnd = list.length < 8;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type == 1 ? '推广订单列表' : '推广订单'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 头部统计
          _buildHeader(),
          // 订单列表
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  /// 头部统计
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('累计推广订单', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$_count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text: ' 单',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Icon(Icons.receipt_long, color: Colors.white30, size: 60),
        ],
      ),
    );
  }

  /// 订单列表
  Widget _buildList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recordList.isEmpty) {
      return EasyRefresh(
        header: const ClassicHeader(
          dragText: '下拉刷新',
          armedText: '松手刷新',
          processingText: '刷新中...',
          processedText: '刷新完成',
          failedText: '刷新失败',
        ),
        onRefresh: () => _loadData(isRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [EmptyPage(text: '暂无推广订单～')],
        ),
      );
    }

    return EasyRefresh(
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
      onRefresh: () => _loadData(isRefresh: true),
      onLoad: _loadEnd ? null : _loadData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _recordList.length,
        itemBuilder: (context, index) => _buildDateSection(_recordList[index]),
      ),
    );
  }

  /// 日期分组
  Widget _buildDateSection(Map<String, dynamic> dateItem) {
    return Container(
      margin: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日期标题
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateItem['time'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '本月累计推广订单：${dateItem['count'] ?? 0} 单',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // 订单列表
          ...List.generate(
            dateItem['child'].length,
            (index) => _buildOrderItem(dateItem['child'][index]),
          ),
        ],
      ),
    );
  }

  /// 订单项
  Widget _buildOrderItem(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 订单头部
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              children: [
                // 用户头像
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: order['avatar'] ?? '',
                    width: 33, // 66rpx / 2
                    height: 33,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.person, color: Colors.grey, size: 16),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.person, color: Colors.grey, size: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 用户昵称
                Expanded(
                  child: Text(
                    order['nickname'] ?? '',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 佣金信息
                Text(
                  order['type'] == 'brokerage'
                      ? '返佣：¥${order['number'] ?? '0'}'
                      : '暂未返佣：¥${order['number'] ?? '0'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: order['type'] == 'brokerage'
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // 订单底部信息
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '订单编号：${order['order_id'] ?? ''}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  '下单时间：${order['time'] ?? ''}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                // 更多按钮
                if ((order['children'] as List?)?.isNotEmpty == true)
                  Container(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => _toggleExpand(order),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              order['open'] == true ? '收起' : '更多',
                              style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              order['open'] == true ? Icons.expand_less : Icons.expand_more,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 子订单列表
          if (order['open'] == true && (order['children'] as List?)?.isNotEmpty == true)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF2F2F2))),
              ),
              child: Column(
                children: List.generate(
                  order['children'].length,
                  (index) => _buildSubOrderItem(order['children'][index]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 子订单项
  Widget _buildSubOrderItem(Map<String, dynamic> subOrder) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '单号：${subOrder['order_id'] ?? ''}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Text(
            subOrder['type'] == 'brokerage'
                ? '返佣：¥${subOrder['number'] ?? '0'}'
                : '暂未返佣：¥${subOrder['number'] ?? '0'}',
            style: TextStyle(
              fontSize: 12,
              color: subOrder['type'] == 'brokerage' ? Theme.of(context).primaryColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// 切换展开收起状态
  void _toggleExpand(Map<String, dynamic> order) {
    setState(() {
      order['open'] = !(order['open'] ?? false);
    });
  }
}
