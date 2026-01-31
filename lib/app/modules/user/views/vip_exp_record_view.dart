import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/app/core/constants/app_images.dart';

class VipExpRecordView extends StatefulWidget {
  const VipExpRecordView({super.key});

  @override
  State<VipExpRecordView> createState() => _VipExpRecordViewState();
}

class _VipExpRecordViewState extends State<VipExpRecordView> {
  final UserProvider _userProvider = UserProvider();

  List<dynamic> expList = [];
  bool loading = false;
  bool loadend = false;
  String loadTitle = "加载更多";
  int page = 1;
  int limit = 20;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _getExpList();
  }

  /// 获取成长值记录列表
  Future<void> _getExpList() async {
    if (loadend) return;
    if (loading) return;

    try {
      setState(() {
        loading = true;
      });

      final response = await _userProvider.getlevelExpList({'page': page, 'limit': limit});

      if (response.isSuccess && response.data != null) {
        final List<dynamic> newList = response.data as List<dynamic>;
        final bool isLoadEnd = newList.length < limit;

        setState(() {
          expList = page == 1 ? newList : [...expList, ...newList];
          loadend = isLoadEnd;
          loadTitle = isLoadEnd ? '我也是有底线的' : '加载更多';
          page = page + 1;
          loading = false;
        });

        if (mounted) {
          if (page == 2) {
            _refreshController.refreshCompleted();
          } else {
            _refreshController.loadComplete();
          }
        }
      } else {
        setState(() {
          loading = false;
          loadTitle = '加载更多';
        });

        if (mounted) {
          if (page == 1) {
            _refreshController.refreshFailed();
          } else {
            _refreshController.loadFailed();
          }
        }
      }
    } catch (e) {
      setState(() {
        loading = false;
        loadTitle = '加载更多';
      });

      if (mounted) {
        if (page == 1) {
          _refreshController.refreshFailed();
        } else {
          _refreshController.loadFailed();
        }
      }
    }
  }

  /// 刷新
  void _onRefresh() async {
    page = 1;
    loadend = false;
    _getExpList();
  }

  /// 加载更多
  void _onLoading() async {
    if (!loadend) {
      _getExpList();
    } else {
      _refreshController.loadNoData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('成长值明细'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        enablePullUp: expList.isNotEmpty,
        child: expList.isEmpty && !loading ? _buildEmptyWidget() : _buildContentWidget(),
      ),
    );
  }

  /// 构建空状态组件
  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppImages.emptyBox, width: 207, height: 107, fit: BoxFit.cover),
          const SizedBox(height: 20),
          const Text('暂无成长值记录', style: TextStyle(fontSize: 15, color: Color(0xFF999999))),
        ],
      ),
    );
  }

  /// 构建内容组件
  Widget _buildContentWidget() {
    return ListView.builder(
      itemCount: expList.length,
      itemBuilder: (context, index) {
        final item = expList[index];
        final String title = item['title'] ?? '';
        final String addTime = item['add_time'] ?? '';
        final int number = item['number'] ?? 0;
        final bool pm = item['pm'] ?? false; // true表示增加，false表示减少

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: const Color(0xFFEEEEEE), width: 0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF282828))),
                    const SizedBox(height: 5),
                    Text(addTime, style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  pm ? '+$number' : '-$number',
                  style: TextStyle(
                    fontSize: 16,
                    color: pm ? const Color(0xFF16AC57) : const Color(0xFFE93323),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
