import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../data/providers/user_provider.dart';
import '../../theme/theme_colors.dart';
import '../../../widgets/empty_page.dart';

class UserBillPage extends StatefulWidget {
  const UserBillPage({super.key});

  @override
  State<UserBillPage> createState() => _UserBillPageState();
}

class _UserBillPageState extends State<UserBillPage> {
  final UserProvider _userProvider = UserProvider();
  final RefreshController _refreshController = RefreshController();

  List<Map<String, dynamic>> _billList = [];
  List<String> _times = [];
  int _page = 1;
  bool _loadEnd = false;
  bool _loading = false;
  int _currentType = 0;

  final List<Map<String, dynamic>> _navList = [
    {'type': 0, 'name': '全部'},
    {'type': 1, 'name': '消费'},
    {'type': 2, 'name': '充值'},
  ];

  @override
  void initState() {
    super.initState();
    String? typeParam = Get.parameters['type'];
    if (typeParam != null) {
      _currentType = int.tryParse(typeParam) ?? 0;
    }
    _getUserBillList();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _changeType(int type) {
    if (_currentType == type) return;
    setState(() {
      _currentType = type;
      _billList = [];
      _times = [];
      _page = 1;
      _loadEnd = false;
    });
    _getUserBillList();
  }

  Future<void> _getUserBillList({bool reset = false}) async {
    if (reset) {
      _page = 1;
      _loadEnd = false;
      _times = [];
    }

    if (_loadEnd) {
      _refreshController.loadNoData();
      return;
    }

    if (_loading) return;

    setState(() {
      _loading = true;
    });

    final response = await _userProvider.getCommissionInfo({
      'page': _page,
      'limit': 15,
    }, _currentType);

    if (response.isSuccess && response.data != null) {
      List<dynamic> list = response.data['list'] ?? [];
      List<dynamic> timeList = response.data['time'] ?? [];

      // 处理时间分组
      for (var time in timeList) {
        String timeStr = time.toString();
        if (!_times.contains(timeStr)) {
          _times.add(timeStr);
          if (reset) {
            _billList.add({'time': timeStr, 'child': []});
          } else {
            setState(() {
              _billList.add({'time': timeStr, 'child': []});
            });
          }
        }
      }

      // 将账单按时间分组
      for (var bill in list) {
        String timeKey = bill['time_key'] ?? '';
        int timeIndex = _times.indexOf(timeKey);
        if (timeIndex >= 0 && timeIndex < _billList.length) {
          (_billList[timeIndex]['child'] as List).add(bill);
        }
      }

      setState(() {
        if (list.length < 15) {
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

    if (reset) {
      _refreshController.refreshCompleted();
    } else {
      if (_loadEnd) {
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
    }
  }

  void _onRefresh() {
    _billList = [];
    _times = [];
    _getUserBillList(reset: true);
  }

  void _onLoading() {
    _getUserBillList();
  }

  Widget _buildNav() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: _navList.map((nav) {
          bool isActive = _currentType == nav['type'];
          return Expanded(
            child: GestureDetector(
              onTap: () => _changeType(nav['type']),
              child: Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      nav['name'],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? ThemeColors.red.primary : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 24,
                      height: 3,
                      decoration: BoxDecoration(
                        color: isActive ? ThemeColors.red.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthSection(Map<String, dynamic> item) {
    String time = item['time'] ?? '';
    List<dynamic> childList = item['child'] ?? [];

    if (childList.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 月份标题
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 14,
                color: ThemeColors.red.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Divider(height: 1),

          // 账单列表
          ...childList.map((bill) {
            String title = bill['title'] ?? '';
            String addTime = bill['add_time'] ?? '';
            String number = (bill['number'] ?? 0).toString();
            bool isPm = bill['pm'] == 1 || bill['pm'] == true;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(addTime, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                  Text(
                    '${isPm ? '+' : '-'}$number',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isPm ? ThemeColors.red.primary : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEmpty = _billList.isEmpty || _billList.every((item) => (item['child'] as List).isEmpty);

    return Scaffold(
      appBar: AppBar(title: const Text('账单记录'), centerTitle: true),
      body: Column(
        children: [
          _buildNav(),

          Expanded(
            child: isEmpty && !_loading
                ? const EmptyPage(text: '暂无账单的记录哦～')
                : SmartRefresher(
                    controller: _refreshController,
                    enablePullDown: true,
                    enablePullUp: true,
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: _billList.length,
                      itemBuilder: (context, index) => _buildMonthSection(_billList[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
