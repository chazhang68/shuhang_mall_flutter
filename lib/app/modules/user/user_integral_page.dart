import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../data/providers/user_provider.dart';
import '../../theme/theme_colors.dart';
import '../../../widgets/empty_page.dart';

class UserIntegralPage extends StatefulWidget {
  const UserIntegralPage({super.key});

  @override
  State<UserIntegralPage> createState() => _UserIntegralPageState();
}

class _UserIntegralPageState extends State<UserIntegralPage> {
  final UserProvider _userProvider = UserProvider();
  final RefreshController _refreshController = RefreshController();

  double _integral = 0;
  List<Map<String, dynamic>> _integralList = [];
  int _page = 1;
  bool _loadEnd = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    _getIntegralList();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _getUserInfo() async {
    final response = await _userProvider.getUserInfo();
    if (response.isSuccess && response.data != null) {
      setState(() {
        _integral = response.data!.integral;
      });
    }
  }

  Future<void> _getIntegralList({bool reset = false}) async {
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

    final response = await _userProvider.getIntegralList({'page': _page, 'limit': 10});

    if (response.isSuccess && response.data != null) {
      List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(response.data);

      setState(() {
        if (reset) {
          _integralList = list;
        } else {
          _integralList.addAll(list);
        }

        if (list.length < 10) {
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
    _getUserInfo();
    _getIntegralList(reset: true);
  }

  void _onLoading() {
    _getIntegralList();
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ThemeColors.red.primary, ThemeColors.red.primary.withAlpha((0.8 * 255).round())],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Text(
            '当前消费券',
            style: TextStyle(fontSize: 14, color: Colors.white.withAlpha((0.8 * 255).round())),
          ),
          const SizedBox(height: 12),
          Text(
            _integral.toStringAsFixed(0),
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegralItem(Map<String, dynamic> item) {
    String title = item['title'] ?? '';
    String addTime = item['add_time'] ?? '';
    String number = (item['number'] ?? 0).toString();
    bool isPm = item['pm'] == 1 || item['pm'] == true;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.03 * 255).round()), blurRadius: 4)],
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
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(addTime, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          Text(
            '${isPm ? '+' : '-'}$number',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isPm ? ThemeColors.red.primary : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消费券中心'),
        centerTitle: true,
        backgroundColor: ThemeColors.red.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: _integralList.isEmpty && !_loading
                ? const EmptyPage(text: '暂无消费券记录哦～')
                : SmartRefresher(
                    controller: _refreshController,
                    enablePullDown: true,
                    enablePullUp: true,
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 16, bottom: 24),
                      itemCount: _integralList.length,
                      itemBuilder: (context, index) => _buildIntegralItem(_integralList[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
