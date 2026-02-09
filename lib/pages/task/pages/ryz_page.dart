import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/app/data/models/user_model.dart';
import 'package:shuhang_mall_flutter/widgets/empty_page.dart';
import 'package:easy_refresh/easy_refresh.dart';
import '../models/task_record_model.dart';

/// 我的账户页面（积分/消费券详情）
/// 对应原 pages/users/ryz/ryz.vue
class RyzPage extends StatefulWidget {
  const RyzPage({super.key});

  @override
  State<RyzPage> createState() => _RyzPageState();
}

class _RyzPageState extends State<RyzPage> with SingleTickerProviderStateMixin {
  final UserProvider _userProvider = UserProvider();

  // 当前选中的 tab (0=仓库积分, 1=可用积分, 2=消费券)
  int _current = 0;

  // 用户信息
  UserModel? _userInfo;

  // 数据列表
  final List<TaskRecordModel> _yueList = []; // 消费券列表
  final List<TaskRecordModel> _fuDouList = []; // 积分列表
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
      final response = await callback({'page': _page, 'limit': _limit, 'pm': 0}, 0);
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data as List? ?? [];
        dataList.addAll(
          list.map((item) => TaskRecordModel.fromJson(item as Map<String, dynamic>)).toList(),
        );
      }
    } catch (e) {
      debugPrint('获取数据失败: $e');
    }
  }

  Future<dynamic> _getCommissionInfo(Map<String, dynamic>? params, int type) async {
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
        case 2: // 消费券
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
  }

  Future<void> _onLoading() async {
    if (_loading || _loadend) {
      return;
    }

    _loading = true;
    _page++;

    try {
      final callback = _current == 2 ? _getCommissionInfo : _getFudouList;
      final response = await callback({'page': _page, 'limit': _limit, 'pm': 0}, 0);

      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data as List? ?? [];
        final newData = list
            .map((item) => TaskRecordModel.fromJson(item as Map<String, dynamic>))
            .toList();
        _loadend = newData.length < _limit;

        setState(() {
          _showDataList.addAll(newData);
        });
      }
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
        return '消费券';
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
      // 积分兑换消费券
      Get.toNamed('/task/jifen-exchange');
    } else if (_current == 2) {
      // 消费券兑换积分
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
      decoration: const BoxDecoration(color: Color(0xFFFF5A5A)),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 导航栏
            SizedBox(
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    '我的账户',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                      onPressed: () => Get.back(),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),

            // 余额信息区域
            Container(
              padding: const EdgeInsets.fromLTRB(32, 20, 32, 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 左侧：标题和余额
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getTitle(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getNumber(),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'DIN Alternate',
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 右侧：兑换按钮
                  GestureDetector(
                    onTap: _goExchange,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _current == 2 ? '消费券兑换积分' : '积分兑换消费券',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF333333),
                          fontWeight: FontWeight.w500,
                        ),
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
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        spacing: 12.w,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: _buildTabItem('仓库积分', 0)),
          Expanded(child: _buildTabItem('可用积分', 1)),
          Expanded(child: _buildTabItem('消费券', 2)),
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
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFF5A5A) : const Color(0xFFF6F7F9),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: .center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            color: isActive ? Colors.white : const Color(0xFF000000),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_showDataList.isEmpty) {
      return const EmptyPage(title: '暂无数据~');
    }

    return EasyRefresh(
      header: const ClassicHeader(
        dragText: '下拉刷新',
        armedText: '松手刷新',
        readyText: '正在刷新',
        processingText: '刷新中...',
        processedText: '刷新完成',
        failedText: '刷新失败',
        noMoreText: '我也是有底线的',
      ),
      footer: const ClassicFooter(
        dragText: '上拉加载',
        armedText: '松手加载',
        readyText: '正在加载',
        processingText: '加载中...',
        processedText: '加载完成',
        failedText: '加载失败',
        noMoreText: '我也是有底线的',
      ),
      onRefresh: _onRefresh,
      onLoad: _loadend ? null : _onLoading,
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
    final number = _current == 1 || _current == 0 ? item.num : item.displayAmount;

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
                  style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
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
                  color: isAdd ? const Color(0xFFFF5A5A) : const Color(0xFF333333),
                  fontFamily: 'DIN Alternate',
                ),
              ),
              const SizedBox(height: 10),
              Text(item.title, style: const TextStyle(fontSize: 12, color: Color(0xFF333333))),
            ],
          ),
        ],
      ),
    );
  }
}
