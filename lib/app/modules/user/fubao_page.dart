import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../data/providers/user_provider.dart';
import '../../theme/theme_colors.dart';
import '../../../widgets/empty_page.dart';

/// 福宝页面
/// 对应原 pages/users/fubao/fubao.vue
class FubaoPage extends StatefulWidget {
  const FubaoPage({super.key});

  @override
  State<FubaoPage> createState() => _FubaoPageState();
}

class _FubaoPageState extends State<FubaoPage> {
  final UserProvider _userProvider = UserProvider();
  final RefreshController _refreshController = RefreshController();

  // 数据
  String _fubaoBalance = '0';
  List<Map<String, dynamic>> _recordList = [];

  // 分页
  int _page = 1;
  final int _limit = 15;
  bool _isLoading = false;
  bool _hasMore = true;

  Color get _primaryColor => ThemeColors.red.primary;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadRecordList();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      final response = await _userProvider.getUserInfo();
      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        setState(() {
          _fubaoBalance = (data['fubao'] ?? 0).toString();
        });
      }
    } catch (e) {
      debugPrint('获取用户信息失败: $e');
    }
  }

  Future<void> _loadRecordList({bool isRefresh = false}) async {
    if (_isLoading) return;
    if (!isRefresh && !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    if (isRefresh) {
      _page = 1;
      _hasMore = true;
    }

    try {
      final response = await _userProvider.getFubaoList({'page': _page, 'limit': _limit});

      if (response.isSuccess && response.data != null) {
        final list = (response.data as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList();

        setState(() {
          if (isRefresh) {
            _recordList = list;
          } else {
            _recordList.addAll(list);
          }
          _hasMore = list.length >= _limit;
          _page++;
        });
      }
    } catch (e) {
      debugPrint('获取记录列表失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      if (isRefresh) {
        _refreshController.refreshCompleted();
      } else {
        if (_hasMore) {
          _refreshController.loadComplete();
        } else {
          _refreshController.loadNoData();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          '我的福宝',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // 头部余额区域
          _buildHeader(),
          // 记录列表
          Expanded(child: _buildRecordList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _primaryColor.withAlpha((0.85 * 255).round())],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('我的福宝', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              Text(
                _fubaoBalance,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.2 * 255).round()),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(Icons.card_giftcard, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordList() {
    if (_recordList.isEmpty && !_isLoading) {
      return const EmptyPage(text: '暂无数据~');
    }

    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: true,
      onRefresh: () => _loadRecordList(isRefresh: true),
      onLoading: () => _loadRecordList(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _recordList.length,
        itemBuilder: (context, index) {
          return _buildRecordItem(_recordList[index]);
        },
      ),
    );
  }

  Widget _buildRecordItem(Map<String, dynamic> item) {
    final isPM = item['pm'] == 1;
    final num = item['num'] ?? item['number'] ?? '0';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  item['add_time'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${isPM ? '+' : '-'}$num',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isPM ? _primaryColor : const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}
