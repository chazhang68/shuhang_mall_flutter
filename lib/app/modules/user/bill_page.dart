import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/widgets/loading_widget.dart';

/// 账单页面
/// 对应 pages/users/user_bill/index.vue
class BillPage extends StatefulWidget {
  const BillPage({super.key});

  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> with SingleTickerProviderStateMixin {
  final UserProvider _userProvider = UserProvider();
  late TabController _tabController;
  int _type = 0; // 0=全部, 1=消费, 2=充值
  final List<Map<String, dynamic>> _userBillList = [];
  final List<String> _times = [];
  bool _loading = false;
  bool _loadend = false;
  int _page = 1;
  final int _limit = 15;

  @override
  void initState() {
    super.initState();
    _type = int.tryParse(Get.parameters['type'] ?? '0') ?? 0;
    _tabController = TabController(length: 3, vsync: this, initialIndex: _type);
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
      _times.clear();
    });
    _getUserBillList();
  }

  /// 获取账单列表
  Future<void> _getUserBillList() async {
    if (_loading || _loadend) return;

    setState(() {
      _loading = true;
    });

    final response = await _userProvider.getCommissionInfo({'page': _page, 'limit': _limit}, _type);

    if (response.isSuccess && response.data != null) {
      final list = response.data['list'] ?? [];
      final timeList = response.data['time'] ?? [];

      for (var time in timeList) {
        final timeStr = time.toString();
        if (!_times.contains(timeStr)) {
          _times.add(timeStr);
          _userBillList.add({'time': timeStr, 'child': []});
        }
      }

      for (var bill in list) {
        final timeKey = bill['time_key'] ?? '';
        final timeIndex = _times.indexOf(timeKey);
        if (timeIndex >= 0 && timeIndex < _userBillList.length) {
          (_userBillList[timeIndex]['child'] as List).add(bill);
        }
      }

      setState(() {
        if (list.length < _limit) {
          _loadend = true;
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

  /// 下拉刷新
  Future<void> _onRefresh() async {
    setState(() {
      _userBillList.clear();
      _times.clear();
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
          _BillListView(
            userBillList: _userBillList,
            loading: _loading,
            loadEnd: _loadend,
            onRefresh: _onRefresh,
            onLoad: _getUserBillList,
          ),
          _BillListView(
            userBillList: _userBillList,
            loading: _loading,
            loadEnd: _loadend,
            onRefresh: _onRefresh,
            onLoad: _getUserBillList,
          ),
          _BillListView(
            userBillList: _userBillList,
            loading: _loading,
            loadEnd: _loadend,
            onRefresh: _onRefresh,
            onLoad: _getUserBillList,
          ),
        ],
      ),
    );
  }
}

class _BillListView extends StatelessWidget {
  final List<Map<String, dynamic>> userBillList;
  final bool loading;
  final bool loadEnd;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoad;

  const _BillListView({
    required this.userBillList,
    required this.loading,
    required this.loadEnd,
    required this.onRefresh,
    required this.onLoad,
  });

  @override
  Widget build(BuildContext context) {
    if (userBillList.isEmpty && !loading) {
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
          itemCount: userBillList.length + (loading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == userBillList.length) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: loadEnd
                      ? const Text('没有更多数据了', style: TextStyle(color: Colors.grey, fontSize: 12))
                      : const LoadingWidget(),
                ),
              );
            }
            return _BillGroup(group: userBillList[index]);
          },
        ),
      ),
    );
  }
}

class _BillGroup extends StatelessWidget {
  final Map<String, dynamic> group;

  const _BillGroup({required this.group});

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
                  _BillItem(item: children[i], isLast: i == children.length - 1, theme: theme),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BillItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isLast;
  final ThemeData theme;

  const _BillItem({required this.item, required this.isLast, required this.theme});

  @override
  Widget build(BuildContext context) {
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
