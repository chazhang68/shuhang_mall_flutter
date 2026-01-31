import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../data/providers/user_provider.dart';
import '../../theme/theme_colors.dart';
import '../../../widgets/empty_page.dart';

class UserSignListPage extends StatefulWidget {
  const UserSignListPage({super.key});

  @override
  State<UserSignListPage> createState() => _UserSignListPageState();
}

class _UserSignListPageState extends State<UserSignListPage> {
  final UserProvider _userProvider = UserProvider();
  final RefreshController _refreshController = RefreshController();

  List<Map<String, dynamic>> _signList = [];
  int _page = 1;
  bool _loadEnd = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _getSignMonthList();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _getSignMonthList({bool reset = false}) async {
    if (reset) {
      _page = 1;
      _loadEnd = false;
    }

    if (_loadEnd) {
      _refreshController.loadNoData();
      return;
    }

    if (_loading) return;

    setState(() {
      _loading = true;
    });

    final response = await _userProvider.getSignMonthList({'page': _page, 'limit': 8});

    if (response.isSuccess && response.data != null) {
      List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(response.data);

      setState(() {
        if (reset) {
          _signList = list;
        } else {
          _signList.addAll(list);
        }

        if (list.length < 8) {
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
    _getSignMonthList(reset: true);
  }

  void _onLoading() {
    _getSignMonthList();
  }

  Widget _buildMonthSection(Map<String, dynamic> item) {
    String month = item['month'] ?? '';
    List<dynamic> list = item['list'] ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 月份标题
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Text(
              month,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ThemeColors.red.primary,
              ),
            ),
          ),

          // 签到记录列表
          ...list.map((record) {
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
                          record['title'] ?? '',
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          record['add_time'] ?? '',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '+${record['number'] ?? 0}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.red.primary,
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
    return Scaffold(
      appBar: AppBar(title: const Text('签到记录'), centerTitle: true),
      body: _signList.isEmpty && !_loading
          ? const EmptyPage(text: '暂无签到记录~')
          : SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              enablePullUp: true,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                itemCount: _signList.length,
                itemBuilder: (context, index) => _buildMonthSection(_signList[index]),
              ),
            ),
    );
  }
}
