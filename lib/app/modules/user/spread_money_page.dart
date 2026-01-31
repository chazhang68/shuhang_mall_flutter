import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/user_provider.dart';
import '../../theme/theme_colors.dart';
import '../../../widgets/empty_page.dart';

/// 佣金明细页面 - 对应 pages/users/user_spread_money/index.vue
class SpreadMoneyPage extends StatefulWidget {
  const SpreadMoneyPage({super.key});

  @override
  State<SpreadMoneyPage> createState() => _SpreadMoneyPageState();
}

class _SpreadMoneyPageState extends State<SpreadMoneyPage> {
  final UserProvider _userProvider = UserProvider();
  final ScrollController _scrollController = ScrollController();

  String name = '';
  int type = 0;
  int page = 1;
  int limit = 15;
  bool loading = false;
  bool loadend = false;
  String loadTitle = '加载更多';
  List<Map<String, dynamic>> recordList = [];
  int recordType = 0;
  double recordCount = 0;
  double extractCount = 0;
  List<String> times = [];

  Color get _primaryColor => ThemeColors.red.primary;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initData() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    type = args['type'] ?? 0;

    if (type == 1) {
      name = '提现总额';
      recordType = 4;
      _getRecordList();
      _getRecordListCount();
    } else if (type == 2) {
      name = '佣金明细';
      recordType = 3;
      _getRecordList();
      _getRecordListCount();
    } else {
      Get.snackbar('错误', '参数错误');
      Future.delayed(const Duration(seconds: 1), () {
        Get.back();
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      _getRecordList();
    }
  }

  /// 获取记录列表
  Future<void> _getRecordList() async {
    if (loading || loadend) return;

    setState(() {
      loading = true;
      loadTitle = '';
    });

    try {
      final response = await _userProvider.getCommissionInfo({
        'page': page,
        'limit': limit,
      }, recordType);

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final timeList = (data['time'] as List?)?.cast<String>() ?? [];
        final list = (data['list'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        for (var time in timeList) {
          if (!times.contains(time)) {
            times.add(time);
            recordList.add({'time': time, 'child': []});
          }
        }

        for (var i = 0; i < times.length; i++) {
          for (var item in list) {
            if (times[i] == item['time_key']) {
              (recordList[i]['child'] as List).add(item);
            }
          }
        }

        final isLoadend = list.length < limit;
        setState(() {
          loadend = isLoadend;
          loadTitle = isLoadend ? '我也是有底线的' : '加载更多';
          page += 1;
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        loadTitle = '加载更多';
      });
    }
  }

  /// 获取统计数据
  Future<void> _getRecordListCount() async {
    try {
      final response = await _userProvider.getSpreadInfo();
      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        setState(() {
          recordCount = double.tryParse(data['commissionCount']?.toString() ?? '0') ?? 0;
          extractCount = double.tryParse(data['extractCount']?.toString() ?? '0') ?? 0;
        });
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(type == 1 ? '提现记录' : '佣金记录'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: recordList.isEmpty && page > 1
                ? const EmptyPage(text: '暂无数据~')
                : _buildRecordList(),
          ),
        ],
      ),
    );
  }

  /// 头部信息
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _primaryColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 14, color: Colors.white70)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text('￥', style: TextStyle(fontSize: 18, color: Colors.white)),
                  Text(
                    recordType == 4
                        ? extractCount.toStringAsFixed(2)
                        : recordCount.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Icon(Icons.monetization_on, size: 60, color: Colors.white30),
        ],
      ),
    );
  }

  /// 记录列表
  Widget _buildRecordList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      itemCount: recordList.length + 1,
      itemBuilder: (context, index) {
        if (index == recordList.length) {
          return _buildLoadMore();
        }
        return _buildDateGroup(recordList[index]);
      },
    );
  }

  /// 日期分组
  Widget _buildDateGroup(Map<String, dynamic> group) {
    final children = (group['child'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    if (children.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              group['time'] ?? '',
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Column(children: children.map((item) => _buildRecordItem(item)).toList()),
          ),
        ],
      ),
    );
  }

  /// 记录项
  Widget _buildRecordItem(Map<String, dynamic> item) {
    final pm = item['pm'] ?? 0;
    final number = item['number']?.toString() ?? '0';

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  item['add_time'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                ),
                if (item['fail_msg'] != null && item['fail_msg'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      '原因：${item['fail_msg']}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFFFF5722)),
                    ),
                  )
                else if (item['extract_type'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      '提现方式：${item['extract_type']}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            pm == 1 ? '+$number' : '-$number',
            style: TextStyle(
              fontSize: 16,
              color: pm == 1 ? _primaryColor : const Color(0xFF333333),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 加载更多
  Widget _buildLoadMore() {
    if (recordList.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: _primaryColor),
            ),
          if (loading) const SizedBox(width: 8),
          Text(
            loading ? '' : loadTitle,
            style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }
}
