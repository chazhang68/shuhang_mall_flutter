import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import '../../data/providers/public_provider.dart';
import '../../theme/theme_colors.dart';
import '../../../widgets/empty_page.dart';

class CouponCenterPage extends StatefulWidget {
  const CouponCenterPage({super.key});

  @override
  State<CouponCenterPage> createState() => _CouponCenterPageState();
}

class _CouponCenterPageState extends State<CouponCenterPage> with SingleTickerProviderStateMixin {
  final PublicProvider _publicProvider = PublicProvider();

  List<Map<String, dynamic>> _couponsList = [];
  int _page = 1;
  bool _loadEnd = false;
  bool _loading = false;
  int _currentType = 0;
  bool _receiveLoading = false;

  final List<Map<String, dynamic>> _navList = [
    {'type': 0, 'name': '通用券', 'count': 0},
    {'type': 1, 'name': '品类券', 'count': 0},
    {'type': 2, 'name': '商品券', 'count': 0},
  ];

  @override
  void initState() {
    super.initState();
    _getCoupons();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setType(int type) {
    if (_currentType == type) return;
    setState(() {
      _currentType = type;
      _couponsList = [];
      _page = 1;
      _loadEnd = false;
    });
    _getCoupons();
  }

  Future<void> _getCoupons({bool reset = false}) async {
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

    final response = await _publicProvider.getCoupons({
      'type': _currentType,
      'page': _page,
      'limit': 20,
    });

    if (response.isSuccess && response.data != null) {
      List<dynamic> list = response.data['list'] ?? [];
      List<dynamic> count = response.data['count'] ?? [];

      setState(() {
        if (reset) {
          _couponsList = List<Map<String, dynamic>>.from(list);
        } else {
          _couponsList.addAll(List<Map<String, dynamic>>.from(list));
        }

        // 更新分类数量
        for (int i = 0; i < count.length && i < _navList.length; i++) {
          _navList[i]['count'] = count[i];
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

  Future<void> _receiveCoupon(int id, Map<String, dynamic> item) async {
    if (_receiveLoading) return;

    _receiveLoading = true;

    final response = await _publicProvider.receiveCoupon(id);

    if (response.isSuccess) {
      setState(() {
        item['is_use'] = (item['is_use'] ?? 0) + 1;
      });
      FlutterToastPro.showMessage('领取成功');
    } else {
      FlutterToastPro.showMessage(response.msg);
    }

    await Future.delayed(const Duration(milliseconds: 500));
    _receiveLoading = false;
  }

  int get _totalCount {
    int total = 0;
    for (var nav in _navList) {
      total += (nav['count'] as int?) ?? 0;
    }
    return total;
  }

  String _getCouponTypeName(int type) {
    switch (type) {
      case 0:
        return '通用劵';
      case 1:
        return '品类券';
      case 2:
        return '商品券';
      default:
        return '通用劵';
    }
  }

  Widget _buildNavBar() {
    if (_totalCount <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _navList.where((nav) => (nav['count'] ?? 0) > 0).map((nav) {
          bool isActive = _currentType == nav['type'];
          return GestureDetector(
            onTap: () => _setType(nav['type']),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? ThemeColors.red.primary : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                nav['name'],
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black87,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCouponCard(Map<String, dynamic> item) {
    int isUse = item['is_use'] ?? 0;
    int receiveLimit = item['receive_limit'] ?? 1;
    bool isReceived = isUse >= receiveLimit;
    bool isEmpty = (item['is_permanent'] == 0) && (item['remain_count'] ?? 0) == 0;
    bool isDisabled = isReceived || isEmpty;
    int type = item['type'] ?? 0;
    String couponPrice = (item['coupon_price'] ?? 0).toString();
    double useMinPrice = double.tryParse((item['use_min_price'] ?? 0).toString()) ?? 0;
    String title = item['title'] ?? '';
    int couponTime = item['coupon_time'] ?? 0;
    String startUseTime = item['start_use_time'] ?? '';
    String endUseTime = item['end_use_time'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 4)],
      ),
      child: Row(
        children: [
          // 左侧金额区域
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: isDisabled ? Colors.grey[300] : ThemeColors.red.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¥',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDisabled ? Colors.grey[600] : Colors.white,
                      ),
                    ),
                    Text(
                      couponPrice,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDisabled ? Colors.grey[600] : Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  useMinPrice > 0 ? '满${useMinPrice.toInt()}元可用' : '无门槛券',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDisabled ? Colors.grey[500] : Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // 右侧信息区域
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDisabled
                              ? Colors.grey[300]
                              : ThemeColors.red.primary.withAlpha((0.1 * 255).round()),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getCouponTypeName(type),
                          style: TextStyle(
                            fontSize: 10,
                            color: isDisabled ? Colors.grey[600] : ThemeColors.red.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          couponTime > 0
                              ? '领取后$couponTime天内可用'
                              : (startUseTime.isNotEmpty || endUseTime.isNotEmpty)
                              ? '${startUseTime.isNotEmpty ? '$startUseTime-' : ''}$endUseTime'
                              : '',
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                      ),
                      GestureDetector(
                        onTap: isDisabled ? null : () => _receiveCoupon(item['id'], item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDisabled ? Colors.grey[300] : ThemeColors.red.primary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            isReceived ? '已领取' : (isEmpty ? '已领完' : '立即领取'),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDisabled ? Colors.grey[600] : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('领券中心'), centerTitle: true),
      body: Column(
        children: [
          _buildNavBar(),
          if (_totalCount > 1) const SizedBox(height: 8),

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
              onRefresh: () => _getCoupons(reset: true),
              onLoad: _loadEnd ? null : () => _getCoupons(),
              child: _couponsList.isEmpty && !_loading
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [EmptyPage(text: '暂无优惠券')],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: _couponsList.length,
                      itemBuilder: (context, index) => _buildCouponCard(_couponsList[index]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
