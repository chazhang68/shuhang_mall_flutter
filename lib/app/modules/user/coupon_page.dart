import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/widgets/widgets.dart';

/// 我的优惠券页面
/// 对应原 pages/users/user_coupon/index.vue
class CouponPage extends StatefulWidget {
  const CouponPage({super.key});

  @override
  State<CouponPage> createState() => _CouponPageState();
}

class _CouponPageState extends State<CouponPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab状态: 0-可使用, 1-已使用, 2-已过期
  final List<String> _tabTitles = ['可使用', '已使用', '已过期'];
  final Map<int, List<Map<String, dynamic>>> _couponData = {};
  final Map<int, int> _pageData = {};
  final Map<int, bool> _hasMoreData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);

    for (int i = 0; i < _tabTitles.length; i++) {
      _couponData[i] = [];
      _pageData[i] = 1;
      _hasMoreData[i] = true;
    }

    _loadData(0, isRefresh: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData(int tabIndex, {bool isRefresh = false}) async {
    if (isRefresh) {
      _pageData[tabIndex] = 1;
      _hasMoreData[tabIndex] = true;
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (isRefresh) {
      _couponData[tabIndex]?.clear();
    }

    // 添加示例数据
    final newItems = tabIndex == 0
        ? List.generate(5, (index) {
            return {
              'id': (_pageData[tabIndex]! - 1) * 5 + index + 1,
              'coupon_title': '满100减10优惠券',
              'coupon_type': 1,
              'coupon_price': 10,
              'use_min_price': 100,
              'start_time': '2024-01-01',
              'end_time': '2024-12-31',
              'status': 0,
              'is_fail': 0,
            };
          })
        : <Map<String, dynamic>>[];

    setState(() {
      _couponData[tabIndex]?.addAll(newItems);
      _pageData[tabIndex] = _pageData[tabIndex]! + 1;
      _hasMoreData[tabIndex] = newItems.length >= 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        final themeColor = controller.themeColor;

        return Scaffold(
          appBar: AppBar(
            title: const Text('我的优惠券'),
            bottom: TabBar(
              controller: _tabController,
              labelColor: themeColor.primary,
              unselectedLabelColor: const Color(0xFF666666),
              indicatorColor: themeColor.primary,
              indicatorSize: TabBarIndicatorSize.label,
              onTap: (index) {
                if (_couponData[index]?.isEmpty ?? true) {
                  _loadData(index, isRefresh: true);
                }
              },
              tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: List.generate(_tabTitles.length, (index) {
              return _buildCouponList(index, themeColor);
            }),
          ),
        );
      },
    );
  }

  Widget _buildCouponList(int tabIndex, themeColor) {
    final coupons = _couponData[tabIndex] ?? [];
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
      onRefresh: () => _loadData(tabIndex, isRefresh: true),
      onLoad: (_hasMoreData[tabIndex] ?? false) ? () => _loadData(tabIndex) : null,
      child: coupons.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [EmptyCoupon()],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(15),
              itemCount: coupons.length,
              itemBuilder: (context, index) {
                return CouponCard(
                  coupon: coupons[index],
                  isReceived: true,
                  onUse: tabIndex == 0
                      ? () {
                          Get.back();
                        }
                      : null,
                );
              },
            ),
    );
  }
}
