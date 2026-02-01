import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/data/providers/activity_provider.dart';
import 'package:shuhang_mall_flutter/widgets/cached_image.dart';
import 'package:shuhang_mall_flutter/widgets/loading_widget.dart';

/// 预售列表页
/// 对应 pages/activity/presell/index.vue
class PresellListPage extends StatefulWidget {
  const PresellListPage({super.key});

  @override
  State<PresellListPage> createState() => _PresellListPageState();
}

class _PresellListPageState extends State<PresellListPage> with SingleTickerProviderStateMixin {
  final ActivityProvider _activityProvider = ActivityProvider();
  late TabController _tabController;
  int _type = 1; // 1=全款, 2=定金
  final List<Map<String, dynamic>> _presellList = [];
  bool _loading = false;
  bool _loadend = false;
  int _page = 1;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _getPresellList();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _changeType(_tabController.index + 1);
  }

  /// 切换类型
  void _changeType(int type) {
    setState(() {
      _type = type;
      _loadend = false;
      _page = 1;
      _presellList.clear();
    });
    _getPresellList();
  }

  /// 获取预售列表
  Future<void> _getPresellList() async {
    if (_loading || _loadend) return;

    setState(() {
      _loading = true;
    });

    final response = await _activityProvider.getPresellList({
      'page': _page,
      'limit': _limit,
      'type': _type,
    });

    if (response.isSuccess && response.data != null) {
      final list = List<Map<String, dynamic>>.from(response.data);
      setState(() {
        _presellList.addAll(list);
        _page++;
        _loadend = list.length < _limit;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  /// 下拉刷新
  Future<void> _onRefresh() async {
    setState(() {
      _presellList.clear();
      _page = 1;
      _loadend = false;
    });
    await _getPresellList();
  }

  /// 跳转详情
  void _goDetail(Map<String, dynamic> item) {
    Get.toNamed('/activity/presell/detail', arguments: {'id': item['id']});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.primaryColor, theme.primaryColor.withAlpha((0.7 * 255).round())],
            stops: const [0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 自定义AppBar
              _PresellAppBar(theme: theme),
              // 头部Banner
              _PresellHeader(theme: theme),
              // Tab栏
              _PresellTabBar(theme: theme, controller: _tabController),
              // 列表
              Expanded(
                child: Container(
                  color: const Color(0xFFF5F5F5),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _PresellListView(
                        list: _presellList,
                        loading: _loading,
                        loadEnd: _loadend,
                        onRefresh: _onRefresh,
                        onLoad: _getPresellList,
                        onItemTap: _goDetail,
                      ),
                      _PresellListView(
                        list: _presellList,
                        loading: _loading,
                        loadEnd: _loadend,
                        onRefresh: _onRefresh,
                        onLoad: _getPresellList,
                        onItemTap: _goDetail,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresellAppBar extends StatelessWidget {
  final ThemeData theme;

  const _PresellAppBar({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          ),
          const Expanded(
            child: Center(
              child: Text(
                '预售专区',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

class _PresellHeader extends StatelessWidget {
  final ThemeData theme;

  const _PresellHeader({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time_filled,
                color: Colors.white.withAlpha((0.9 * 255).round()),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '新品预售 · 抢先预定',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withAlpha((0.95 * 255).round()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '预付定金享优惠价格，尽享新品先机',
            style: TextStyle(fontSize: 12, color: Colors.white.withAlpha((0.8 * 255).round())),
          ),
        ],
      ),
    );
  }
}

class _PresellTabBar extends StatelessWidget {
  final ThemeData theme;
  final TabController controller;

  const _PresellTabBar({required this.theme, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: controller,
        labelColor: theme.primaryColor,
        unselectedLabelColor: Colors.white,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: '全款预售'),
          Tab(text: '定金预售'),
        ],
      ),
    );
  }
}

class _PresellListView extends StatelessWidget {
  final List<Map<String, dynamic>> list;
  final bool loading;
  final bool loadEnd;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoad;
  final ValueChanged<Map<String, dynamic>> onItemTap;

  const _PresellListView({
    required this.list,
    required this.loading,
    required this.loadEnd,
    required this.onRefresh,
    required this.onLoad,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty && !loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无预售活动', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            if (notification.metrics.extentAfter < 100) {
              onLoad();
            }
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: list.length + (loading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == list.length) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: loadEnd
                      ? const Text('没有更多数据了', style: TextStyle(color: Colors.grey, fontSize: 12))
                      : const LoadingWidget(),
                ),
              );
            }
            final item = list[index];
            return _PresellItem(item: item, onTap: () => onItemTap(item));
          },
        ),
      ),
    );
  }
}

class _PresellItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _PresellItem({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool soldOut = item['stock'] == 0;
    final bool isDeposit = item['presell_type'] == 2;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.primaryColor.withAlpha((0.1 * 255).round()),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: theme.primaryColor),
                      const SizedBox(width: 4),
                      Text('距结束', style: TextStyle(fontSize: 12, color: theme.primaryColor)),
                    ],
                  ),
                  _CountdownText(endTime: item['end_time'], theme: theme),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedImage(
                      imageUrl: item['image'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF333333),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.people_outline, size: 14, color: theme.primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              '${item['people']}人已预定',
                              style: TextStyle(fontSize: 12, color: theme.primaryColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isDeposit)
                                  Text(
                                    '定金: ¥${item['deposit_price']}',
                                    style: TextStyle(fontSize: 12, color: theme.primaryColor),
                                  ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '¥',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                    Text(
                                      item['price'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '¥${item['ot_price']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF999999),
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: soldOut ? const Color(0xFFCCCCCC) : theme.primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                soldOut ? '已售罄' : (isDeposit ? '付定金' : '立即预定'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownText extends StatelessWidget {
  final dynamic endTime;
  final ThemeData theme;

  const _CountdownText({required this.endTime, required this.theme});

  @override
  Widget build(BuildContext context) {
    final int end = int.tryParse('$endTime') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = end - now;
    if (diff <= 0) {
      return Text(
        '已结束',
        style: TextStyle(fontSize: 12, color: theme.primaryColor, fontWeight: FontWeight.bold),
      );
    }
    final duration = Duration(milliseconds: diff);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    String text;
    if (days > 0) {
      text = '$days天$hours时$minutes分';
    } else {
      text = '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return Text(
      text,
      style: TextStyle(fontSize: 12, color: theme.primaryColor, fontWeight: FontWeight.bold),
    );
  }
}
