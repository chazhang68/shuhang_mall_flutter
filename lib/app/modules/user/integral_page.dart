import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/widgets/loading_widget.dart';

/// 积分页面
/// 对应 pages/users/user_integral/index.vue
class IntegralPage extends StatefulWidget {
  const IntegralPage({super.key});

  @override
  State<IntegralPage> createState() => _IntegralPageState();
}

class _IntegralPageState extends State<IntegralPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _type = 0; // 0=全部, 1=收入, 2=支出
  final List<Map<String, dynamic>> _integralList = [];
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
    // TODO: 调用API获取积分
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _totalIntegral = 5680;
      _usedIntegral = 1200;
    });
  }

  /// 切换类型
  void _changeType(int type) {
    setState(() {
      _type = type;
      _loadend = false;
      _page = 1;
      _integralList.clear();
    });
    _getIntegralList();
  }

  /// 获取积分列表
  Future<void> _getIntegralList() async {
    if (_loading || _loadend) return;

    setState(() {
      _loading = true;
    });

    // TODO: 调用API获取积分列表
    await Future.delayed(const Duration(seconds: 1));

    // 模拟数据
    final mockData = _generateMockData();

    setState(() {
      _integralList.addAll(mockData);
      _page++;
      _loadend = mockData.isEmpty || mockData.length < _limit;
      _loading = false;
    });
  }

  List<Map<String, dynamic>> _generateMockData() {
    if (_page > 3) return [];

    return [
      {
        'time': '2024-0$_page',
        'child': [
          {
            'title': _type == 1 ? '签到奖励' : (_type == 2 ? '积分兑换' : '签到奖励'),
            'add_time': '2024-0$_page-15 08:00:00',
            'pm': _type != 2,
            'number': '${_page * 10}',
          },
          {
            'title': _type == 1 ? '购物返积分' : (_type == 2 ? '商品兑换' : '购物返积分'),
            'add_time': '2024-0$_page-10 15:30:00',
            'pm': _type != 2,
            'number': '${_page * 50}',
          },
          {
            'title': _type == 1 ? '邀请好友' : (_type == 2 ? '优惠券兑换' : '抽奖消耗'),
            'add_time': '2024-0$_page-05 12:20:00',
            'pm': _type == 1,
            'number': '${_page * 20}',
          },
        ],
      },
    ];
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
          _buildHeader(theme),
          // Tab栏
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
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
          ),
          // 列表
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildIntegralList(), _buildIntegralList(), _buildIntegralList()],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.primaryColor, theme.primaryColor.withAlpha((0.8 * 255).round())],
        ),
      ),
      child: Column(
        children: [
          // AppBar
          Container(
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
          // 积分信息
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('当前积分', style: TextStyle(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 8),
                Text(
                  '$_totalIntegral',
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
                    _buildIntegralInfo('已使用', _usedIntegral),
                    Container(
                      width: 1,
                      height: 30,
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      color: Colors.white30,
                    ),
                    _buildIntegralInfo('累计获得', _totalIntegral + _usedIntegral),
                  ],
                ),
                const SizedBox(height: 15),
                // 积分商城按钮
                GestureDetector(
                  onTap: _goPointsMall,
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

  /// 构建积分信息项
  Widget _buildIntegralInfo(String label, int value) {
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

  /// 构建积分列表
  Widget _buildIntegralList() {
    if (_integralList.isEmpty && !_loading) {
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
      onRefresh: _onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            if (notification.metrics.extentAfter < 100) {
              _getIntegralList();
            }
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: _integralList.length + (_loading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _integralList.length) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: _loadend
                      ? const Text('没有更多数据了', style: TextStyle(color: Colors.grey, fontSize: 12))
                      : const LoadingWidget(),
                ),
              );
            }
            return _buildIntegralGroup(_integralList[index]);
          },
        ),
      ),
    );
  }

  /// 构建积分分组
  Widget _buildIntegralGroup(Map<String, dynamic> group) {
    final theme = Theme.of(context);
    final List<dynamic> children = group['child'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日期标题
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
          // 积分列表
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++)
                  _buildIntegralItem(children[i], i == children.length - 1, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建积分项
  Widget _buildIntegralItem(Map<String, dynamic> item, bool isLast, ThemeData theme) {
    final bool isIncome = item['pm'] == true;

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
          // 左侧信息
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
          // 积分数
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
