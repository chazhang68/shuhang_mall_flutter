import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shuhang_mall_flutter/app/data/providers/api_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../../widgets/empty_page.dart';

/// 我的账户页面 (仓库积分/可用积分/SWP)
/// 对应原 pages/users/ryz/ryz.vue
class RyzPage extends StatefulWidget {
  const RyzPage({super.key});

  @override
  State<RyzPage> createState() => _RyzPageState();
}

class _RyzPageState extends State<RyzPage> {
  final UserProvider _userProvider = UserProvider();
  final RefreshController _refreshController = RefreshController();

  // 选项卡: 0-仓库积分, 1-可用积分, 2-SWP
  int _currentIndex = 0;
  final List<String> _tabNames = ['仓库积分', '可用积分', 'SWP'];

  // 用户数据
  Map<String, dynamic> _userInfo = {};
  List<Map<String, dynamic>> _recordList = [];

  // 分页
  int _page = 1;
  final int _limit = 5;
  bool _isLoading = false;
  bool _hasMore = true;

  Color get _primaryColor => const Color(0xFFFF5A5A);

  // 获取当前标题
  String get _currentTitle => _tabNames[_currentIndex];

  // 获取当前余额
  String get _currentBalance {
    switch (_currentIndex) {
      case 0:
        return (_userInfo['fudou'] ?? 0).toString();
      case 1:
        return (_userInfo['fd_ky'] ?? 0).toString();
      case 2:
        return (_userInfo['now_money'] ?? 0).toString();
      default:
        return '0';
    }
  }

  @override
  void initState() {
    super.initState();
    // 获取路由参数
    final index = Get.arguments?['index'] ?? 0;
    _currentIndex = index is int ? index : int.tryParse(index.toString()) ?? 0;

    _loadUserInfo();
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
        setState(() {
          _userInfo = response.data as Map<String, dynamic>;
        });
        _loadRecordList(isRefresh: true);
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
      _recordList = [];
    }

    try {
      late final ApiResponse<dynamic> response;

      if (_currentIndex == 2) {
        // SWP - 使用佣金接口
        response = await _userProvider.getCommissionInfo({
          'page': _page,
          'limit': _limit,
          'pm': 0,
        }, 0);
      } else {
        // 仓库积分/可用积分 - 使用福豆接口
        response = await _userProvider.getFudouList({'page': _page, 'limit': _limit, 'pm': 0});
      }

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

  void _onTabChanged(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
        _recordList = [];
        _page = 1;
        _hasMore = true;
      });
      _loadRecordList(isRefresh: true);
    }
  }

  void _goExchange() {
    if (_currentIndex == 0 || _currentIndex == 1) {
      // 积分兑换SWP
      Get.toNamed('/asset/jifen-exchange');
    } else {
      // SWP兑换积分
      Get.toNamed('/asset/swp-exchange');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 顶部区域（状态栏 + 导航栏 + 余额）
          _buildHeader(),
          // Tab选项卡
          _buildTabBar(),
          // 记录列表
          Expanded(child: _buildRecordList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: _primaryColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 导航栏
            SizedBox(
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 标题
                  const Text(
                    '我的账户',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // 返回按钮
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ],
              ),
            ),
            // 余额区域
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _currentBalance,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DIN Alternate',
                        ),
                      ),
                    ],
                  ),
                  // 兑换按钮
                  GestureDetector(
                    onTap: _goExchange,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _currentIndex == 2 ? 'SWP兑换积分' : '积分兑换SWP',
                        style: TextStyle(color: _primaryColor, fontSize: 12),
                      ),
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

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      transform: Matrix4.translationValues(0, -16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_tabNames.length, (index) {
          final isSelected = _currentIndex == index;
          return GestureDetector(
            onTap: () => _onTabChanged(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? _primaryColor : const Color(0xFFF6F7F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _tabNames[index],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: isSelected ? Colors.white : const Color(0xFF000000),
                ),
              ),
            ),
          );
        }),
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _recordList.length,
        itemBuilder: (context, index) {
          return _buildRecordItem(_recordList[index]);
        },
      ),
    );
  }

  Widget _buildRecordItem(Map<String, dynamic> item) {
    final isPM = item['pm'] == 1;
    final num = _currentIndex == 2
        ? (item['number'] ?? item['num'] ?? '0')
        : (item['num'] ?? item['number'] ?? '0');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.03 * 255).round()),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  '时间：${item['add_time'] ?? ''}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPM ? '+' : '-'}$num',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DIN Alternate',
                  color: isPM ? _primaryColor : const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item['title'] ?? '',
                style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
