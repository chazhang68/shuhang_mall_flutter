import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/app/data/models/user_model.dart';
import 'package:shuhang_mall_flutter/widgets/empty_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../models/task_record_model.dart';

/// 我的账户页面（积分/SWP详情）
/// 对应原 pages/users/ryz/ryz.vue
class RyzPage extends StatefulWidget {
  const RyzPage({super.key});

  @override
  State<RyzPage> createState() => _RyzPageState();
}

class _RyzPageState extends State<RyzPage> with SingleTickerProviderStateMixin {
  final UserProvider _userProvider = UserProvider();
  final RefreshController _refreshController = RefreshController();

  // 当前选中的 tab (0=仓库积分, 1=可用积分, 2=SWP)
  int _current = 0;

  // 用户信息
  UserModel? _userInfo;

  // 数据列表
  List<TaskRecordModel> _yueList = []; // SWP列表
  List<TaskRecordModel> _fuDouList = []; // 积分列表
  List<TaskRecordModel> _showDataList = []; // 当前显示的列表

  // 分页
  int _page = 1;
  final int _limit = 15;
  bool _loading = false;
  bool _loadend = false;

  @override
  void initState() {
    super.initState();
    // 获取传入的 index 参数
    final args = Get.arguments as Map<String, dynamic>?;
    _current = args?['index'] ?? 0;
    _loadData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _getUserInfo();
    await Future.wait([
      _getAllData(_getCommissionInfo, _yueList),
      _getAllData(_getFudouList, _fuDouList),
    ]);
    _changeShowData();
  }

  Future<void> _getUserInfo() async {
    try {
      final response = await _userProvider.getUserInfo();
      if (response.isSuccess && response.data != null) {
        setState(() {
          _userInfo = response.data;
        });
      }
    } catch (e) {
      debugPrint('获取用户信息失败: $e');
    }
  }

  Future<void> _getAllData(
    Future<dynamic> Function(Map<String, dynamic>?, int) callback,
    List<TaskRecordModel> dataList,
  ) async {
    try {
      final response = await callback({
        'page': _page,
        'limit': _limit,
        'pm': 0,
      }, 0);
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data as List? ?? [];
        dataList.addAll(
          list
              .map(
                (item) =>
                    TaskRecordModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
        );
      }
    } catch (e) {
      debugPrint('获取数据失败: $e');
    }
  }

  Future<dynamic> _getCommissionInfo(
    Map<String, dynamic>? params,
    int type,
  ) async {
    return await _userProvider.getCommissionInfo(params, type);
  }

  Future<dynamic> _getFudouList(Map<String, dynamic>? params, int type) async {
    return await _userProvider.getFudouList(params);
  }

  void _changeShowData() {
    setState(() {
      switch (_current) {
        case 0: // 仓库积分
          _showDataList = List.from(_fuDouList);
          break;
        case 1: // 可用积分
          _showDataList = List.from(_fuDouList);
          break;
        case 2: // SWP
          _showDataList = List.from(_yueList);
          break;
      }
    });
  }

  Future<void> _onRefresh() async {
    _yueList.clear();
    _fuDouList.clear();
    _page = 1;
    await _loadData();
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    if (_loading || _loadend) {
      _refreshController.loadComplete();
      return;
    }

    _loading = true;
    _page++;

    try {
      final callback = _current == 2 ? _getCommissionInfo : _getFudouList;
      final response = await callback({
        'page': _page,
        'limit': _limit,
        'pm': 0,
      }, 0);

      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data as List? ?? [];
        final newData = list
            .map(
              (item) => TaskRecordModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        _loadend = newData.length < _limit;

        setState(() {
          _showDataList.addAll(newData);
        });

        _refreshController.loadComplete();
      }
    } catch (e) {
      _refreshController.loadFailed();
    } finally {
      _loading = false;
    }
  }

  String _getTitle() {
    switch (_current) {
      case 0:
        return '仓库积分';
      case 1:
        return '可用积分';
      case 2:
        return 'SWP';
      default:
        return '';
    }
  }

  String _getNumber() {
    switch (_current) {
      case 0:
        return (_userInfo?.fudou ?? 0).toStringAsFixed(2);
      case 1:
        return (_userInfo?.fdKy ?? 0).toStringAsFixed(2);
      case 2:
        return (_userInfo?.balance ?? 0).toStringAsFixed(2);
      default:
        return '0.00';
    }
  }

  void _goExchange() {
    if (_current == 0 || _current == 1) {
      // 积分兑换SWP
      Get.toNamed('/task/jifen-exchange');
    } else if (_current == 2) {
      // SWP兑换积分
      Get.toNamed('/task/swp-exchange');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 顶部账户信息
          _buildHeader(),

          // Tab 切换
          _buildTabBar(),

          // 列表内容
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 232,
      decoration: const BoxDecoration(color: Color(0xFFFF5A5A)),
      child: SafeArea(
        child: Column(
          children: [
            // 导航栏
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  const Text(
                    '我的账户',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // 余额信息
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTitle(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          _getNumber(),
                          style: const TextStyle(
                            fontSize: 29,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'DIN Alternate',
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: _goExchange,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _current == 2 ? 'SWP兑换积分' : '积分兑换SWP',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
      ),
      margin: const EdgeInsets.only(top: -65),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTabItem('仓库积分', 0),
          const SizedBox(width: 15),
          _buildTabItem('可用积分', 1),
          const SizedBox(width: 15),
          _buildTabItem('SWP', 2),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final isActive = _current == index;
    return GestureDetector(
      onTap: () {
        if (_current != index) {
          setState(() {
            _current = index;
            _loadend = false;
            _loading = false;
            _showDataList.clear();
            _changeShowData();
          });
        }
      },
      child: Container(
        width: 90,
        height: 35,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFF5A5A) : const Color(0xFFF6F7F9),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              color: isActive ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_showDataList.isEmpty) {
      return const EmptyPage(title: '暂无数据~');
    }

    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: true,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _showDataList.length,
        itemBuilder: (context, index) {
          final item = _showDataList[index];
          return _buildListItem(item);
        },
      ),
    );
  }

  Widget _buildListItem(TaskRecordModel item) {
    final isAdd = item.isIncome;
    final number = _current == 1 || _current == 0
        ? item.num
        : item.displayAmount;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '时间：${item.addTime}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isAdd ? '+' : '-'}${number.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isAdd
                      ? const Color(0xFFFF5A5A)
                      : const Color(0xFF333333),
                  fontFamily: 'DIN Alternate',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
