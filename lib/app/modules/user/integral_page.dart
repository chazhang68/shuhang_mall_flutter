import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/widgets/loading_widget.dart';

/// 积分页面
/// 对应 pages/users/user_integral/index.vue
class IntegralPage extends StatefulWidget {
  const IntegralPage({super.key});

  @override
  State<IntegralPage> createState() => _IntegralPageState();
}

class _IntegralPageState extends State<IntegralPage> with SingleTickerProviderStateMixin {
  final UserProvider _userProvider = UserProvider();
  late TabController _tabController;
  int _type = 0; // 0=全部, 1=收入, 2=支出
  final List<Map<String, dynamic>> _integralList = [];
  final Map<String, List<Map<String, dynamic>>> _groupedItems = {};
  bool _loading = false;
  bool _loadend = false;
  int _page = 1;
  final int _limit = 15;

  // 积分信息
  int _totalIntegral = 0;
  int _usedIntegral = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _getUserIntegral();
    _getIntegralList();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _changeType(_tabController.index);
  }

  /// 获取用户积分
  Future<void> _getUserIntegral() async {
    final response = await _userProvider.getUserInfo();
    if (response.isSuccess && response.data != null) {
      final extra = response.data!.extra ?? {};
      final used = _readInt(extra['integral_use'] ?? extra['integralUse'] ?? 0);
      final total = response.data!.integral.toInt();
      setState(() {
        _totalIntegral = total;
        _usedIntegral = used;
      });
    }
  }

  /// 切换类型
  void _changeType(int type) {
    setState(() {
      _type = type;
      _loadend = false;
      _page = 1;
      _integralList.clear();
      _groupedItems.clear();
    });
    _getIntegralList();
  }

  /// 获取积分列表
  Future<void> _getIntegralList() async {
    if (_loading || _loadend) return;

    setState(() {
      _loading = true;
    });

    final response = await _userProvider.getIntegralList({'page': _page, 'limit': _limit});

    if (response.isSuccess && response.data != null) {
      final list = List<Map<String, dynamic>>.from(response.data);
      final filtered = _filterByType(list);
      _mergeIntegralList(filtered);
      setState(() {
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

  int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  List<Map<String, dynamic>> _filterByType(List<Map<String, dynamic>> list) {
    if (_type == 0) return list;
    return list.where((item) {
      final isIncome = item['pm'] == true || item['pm'] == 1;
      if (_type == 1) return isIncome;
      if (_type == 2) return !isIncome;
      return true;
    }).toList();
  }

  void _mergeIntegralList(List<Map<String, dynamic>> list) {
    for (final item in list) {
      final key = _groupKey(item['add_time']);
      _groupedItems.putIfAbsent(key, () => []);
      _groupedItems[key]!.add(item);
    }

    setState(() {
      _integralList
        ..clear()
        ..addAll(
          _groupedItems.entries.map((entry) => {'time': entry.key, 'child': entry.value}).toList(),
        );
    });
  }

  String _groupKey(dynamic value) {
    final text = '${value ?? ''}';
    if (text.length >= 10) return text.substring(0, 10);
    if (text.length >= 7) return text.substring(0, 7);
    return text.isEmpty ? '未知' : text;
  }

  /// 下拉刷新
  Future<void> _onRefresh() async {
    setState(() {
      _integralList.clear();
      _page = 1;
      _loadend = false;
    });
    await _getUserIntegral();
    await _getIntegralList();
  }

  /// 跳转到积分商城
  void _goPointsMall() {
    Get.toNamed('/points-mall');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // 顶部积分展示
          _IntegralHeader(
            theme: theme,
            totalIntegral: _totalIntegral,
            usedIntegral: _usedIntegral,
            topPadding: MediaQuery.of(context).padding.top,
            onBack: () => Get.back(),
            onPointsMall: _goPointsMall,
          ),
          // Tab栏
          _IntegralTabBar(theme: theme, controller: _tabController),
          // 列表
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _IntegralListView(
                  list: _integralList,
                  loading: _loading,
                  loadEnd: _loadend,
                  onRefresh: _onRefresh,
                  onLoad: _getIntegralList,
                ),
                _IntegralListView(
                  list: _integralList,
                  loading: _loading,
                  loadEnd: _loadend,
                  onRefresh: _onRefresh,
                  onLoad: _getIntegralList,
                ),
                _IntegralListView(
                  list: _integralList,
                  loading: _loading,
                  loadEnd: _loadend,
                  onRefresh: _onRefresh,
                  onLoad: _getIntegralList,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IntegralHeader extends StatelessWidget {
  final ThemeData theme;
  final int totalIntegral;
  final int usedIntegral;
  final double topPadding;
  final VoidCallback onBack;
  final VoidCallback onPointsMall;

  const _IntegralHeader({
    required this.theme,
    required this.totalIntegral,
    required this.usedIntegral,
    required this.topPadding,
    required this.onBack,
    required this.onPointsMall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: topPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.primaryColor, theme.primaryColor.withAlpha((0.8 * 255).round())],
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      '我的积分',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('当前积分', style: TextStyle(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 8),
                Text(
                  '$totalIntegral',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _IntegralInfo(label: '已使用', value: usedIntegral),
                    Container(
                      width: 1,
                      height: 30,
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      color: Colors.white30,
                    ),
                    _IntegralInfo(label: '累计获得', value: totalIntegral + usedIntegral),
                  ],
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: onPointsMall,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.2 * 255).round()),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white54),
                    ),
                    child: const Text('积分商城', style: TextStyle(fontSize: 14, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IntegralInfo extends StatelessWidget {
  final String label;
  final int value;

  const _IntegralInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}

class _IntegralTabBar extends StatelessWidget {
  final ThemeData theme;
  final TabController controller;

  const _IntegralTabBar({required this.theme, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: controller,
        labelColor: theme.primaryColor,
        unselectedLabelColor: const Color(0xFF282828),
        indicatorColor: theme.primaryColor,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: const [
          Tab(text: '全部'),
          Tab(text: '收入'),
          Tab(text: '支出'),
        ],
      ),
    );
  }
}

class _IntegralListView extends StatelessWidget {
  final List<Map<String, dynamic>> list;
  final bool loading;
  final bool loadEnd;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoad;

  const _IntegralListView({
    required this.list,
    required this.loading,
    required this.loadEnd,
    required this.onRefresh,
    required this.onLoad,
  });

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty && !loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stars_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无积分记录', style: TextStyle(color: Colors.grey)),
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
            return _IntegralGroup(group: list[index]);
          },
        ),
      ),
    );
  }
}

class _IntegralGroup extends StatelessWidget {
  final Map<String, dynamic> group;

  const _IntegralGroup({required this.group});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<dynamic> children = group['child'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              group['time'] ?? '',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++)
                  _IntegralItem(item: children[i], isLast: i == children.length - 1, theme: theme),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IntegralItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isLast;
  final ThemeData theme;

  const _IntegralItem({required this.item, required this.isLast, required this.theme});

  @override
  Widget build(BuildContext context) {
    final bool isIncome = item['pm'] == true || item['pm'] == 1;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF5F5F5), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item['add_time'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                '${isIncome ? '+' : '-'}${item['number']}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isIncome ? theme.primaryColor : const Color(0xFF333333),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.stars, size: 16, color: isIncome ? theme.primaryColor : Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}
