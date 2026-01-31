import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/widgets/loading_widget.dart';

/// 账单页面
/// 对应 pages/users/user_bill/index.vue
class BillPage extends StatefulWidget {
  const BillPage({super.key});

  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _type = 0; // 0=全部, 1=消费, 2=充值
  final List<Map<String, dynamic>> _userBillList = [];
  bool _loading = false;
  bool _loadend = false;
  int _page = 1;
  final int _limit = 15;

  @override
  void initState() {
    super.initState();
    _type = int.tryParse(Get.parameters['type'] ?? '0') ?? 0;
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _type,
    );
    _tabController.addListener(_onTabChanged);
    _getUserBillList();
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

  /// 切换类型
  void _changeType(int type) {
    setState(() {
      _type = type;
      _loadend = false;
      _page = 1;
      _userBillList.clear();
    });
    _getUserBillList();
  }

  /// 获取账单列表
  Future<void> _getUserBillList() async {
    if (_loading || _loadend) return;
    
    setState(() {
      _loading = true;
    });

    // TODO: 调用API获取账单列表
    await Future.delayed(const Duration(seconds: 1));

    // 模拟数据
    final mockData = _generateMockData();

    setState(() {
      _userBillList.addAll(mockData);
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
            'title': _type == 1 ? '购买商品' : (_type == 2 ? '余额充值' : '购买商品'),
            'add_time': '2024-0$_page-15 12:30:00',
            'pm': _type == 2 ? true : false,
            'number': '${_page * 100}.00',
          },
          {
            'title': _type == 1 ? '订单支付' : (_type == 2 ? '充值返现' : '积分兑换'),
            'add_time': '2024-0$_page-10 09:20:00',
            'pm': _type == 2 ? true : (_page % 2 == 0),
            'number': '${_page * 50}.00',
          },
          {
            'title': _type == 1 ? '服务费' : (_type == 2 ? '活动奖励' : '退款'),
            'add_time': '2024-0$_page-05 18:45:00',
            'pm': _type != 1,
            'number': '${_page * 30}.00',
          },
        ],
      },
    ];
  }

  /// 下拉刷新
  Future<void> _onRefresh() async {
    setState(() {
      _userBillList.clear();
      _page = 1;
      _loadend = false;
    });
    await _getUserBillList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('账单明细'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.primaryColor,
          unselectedLabelColor: const Color(0xFF282828),
          indicatorColor: theme.primaryColor,
          indicatorWeight: 2,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: '全部'),
            Tab(text: '消费'),
            Tab(text: '充值'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBillList(),
          _buildBillList(),
          _buildBillList(),
        ],
      ),
    );
  }

  /// 构建账单列表
  Widget _buildBillList() {
    if (_userBillList.isEmpty && !_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无账单记录', style: TextStyle(color: Colors.grey)),
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
              _getUserBillList();
            }
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: _userBillList.length + (_loading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _userBillList.length) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: _loadend
                      ? const Text(
                          '没有更多数据了',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        )
                      : const LoadingWidget(),
                ),
              );
            }
            return _buildBillGroup(_userBillList[index]);
          },
        ),
      ),
    );
  }

  /// 构建账单分组
  Widget _buildBillGroup(Map<String, dynamic> group) {
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
          // 账单列表
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++)
                  _buildBillItem(children[i], i == children.length - 1, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建账单项
  Widget _buildBillItem(Map<String, dynamic> item, bool isLast, ThemeData theme) {
    final bool isIncome = item['pm'] == true;
    
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                  color: Color(0xFFF5F5F5),
                  width: 1,
                ),
              ),
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
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item['add_time'] ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
          // 金额
          Text(
            '${isIncome ? '+' : '-'}${item['number']}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isIncome ? theme.primaryColor : const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}
