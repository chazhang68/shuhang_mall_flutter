import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/widgets/empty_page.dart';

/// 推广人列表页面
/// 对应原 pages/users/promoter-list/index.vue
class PromoterListPage extends StatefulWidget {
  const PromoterListPage({super.key});

  @override
  State<PromoterListPage> createState() => _PromoterListPageState();
}

class _PromoterListPageState extends State<PromoterListPage> {
  final UserProvider _userProvider = Get.find<UserProvider>();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _recordList = [];
  int _page = 1;
  int _total = 0;
  int _totalLevel = 0;
  int _teamCount = 0;
  int _grade = 0; // 0: 一级, 1: 二级
  int _brokerageLevel = 0;
  bool _isLoading = true;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool isRefresh = false}) async {
    if (isRefresh) {
      _page = 1;
      _hasMore = true;
      _recordList.clear();
    }

    final response = await _userProvider.spreadPeople({
      'page': _page,
      'limit': 20,
      'keyword': _searchController.text.trim(),
      'grade': _grade,
    });

    if (response.isSuccess && response.data != null) {
      final data = response.data;
      List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(data['list'] ?? []);

      setState(() {
        if (isRefresh) {
          _recordList = list;
        } else {
          _recordList.addAll(list);
        }
        _total = data['total'] ?? 0;
        _totalLevel = data['totalLevel'] ?? 0;
        _teamCount = data['count'] ?? 0;
        _brokerageLevel = data['brokerage_level'] ?? 0;
        _page++;
        _hasMore = list.length >= 20;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('推广人统计'), centerTitle: true, elevation: 0),
      body: Column(
        children: [
          // 头部统计
          _buildHeader(),
          // 等级切换
          if (_brokerageLevel == 2) _buildGradeTabs(),
          // 搜索框
          _buildSearchBar(),
          // 列表
          Expanded(child: _buildList()),
        ],
      ),
      // 底部邀请码按钮
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// 头部统计
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('推广人数', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$_teamCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text: ' 人',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Icon(Icons.people, color: Colors.white30, size: 60),
        ],
      ),
    );
  }

  /// 等级切换
  Widget _buildGradeTabs() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _switchGrade(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _grade == 0 ? Theme.of(context).primaryColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  '一级($_total)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _grade == 0 ? Theme.of(context).primaryColor : Colors.grey[600],
                    fontWeight: _grade == 0 ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _switchGrade(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _grade == 1 ? Theme.of(context).primaryColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  '二级($_totalLevel)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _grade == 1 ? Theme.of(context).primaryColor : Colors.grey[600],
                    fontWeight: _grade == 1 ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 搜索框
  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '点击搜索名称',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onSubmitted: (_) => _onSearch(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(icon: const Icon(Icons.search), onPressed: _onSearch),
        ],
      ),
    );
  }

  /// 列表
  Widget _buildList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recordList.isEmpty) {
      return EasyRefresh(
        header: const ClassicHeader(
          dragText: '下拉刷新',
          armedText: '松手刷新',
          processingText: '刷新中...',
          processedText: '刷新完成',
          failedText: '刷新失败',
        ),
        onRefresh: () => _loadData(isRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [EmptyPage(text: '暂无数据')],
        ),
      );
    }

    return EasyRefresh(
      header: const ClassicHeader(
        dragText: '下拉刷新',
        armedText: '松手刷新',
        processingText: '刷新中...',
        processedText: '刷新完成',
        failedText: '刷新失败',
      ),
      footer: const ClassicFooter(
        dragText: '上拉加载',
        armedText: '松手加载',
        processingText: '加载中...',
        processedText: '加载完成',
        failedText: '加载失败',
        noMoreText: '我也是有底线的',
      ),
      onRefresh: () => _loadData(isRefresh: true),
      onLoad: _hasMore ? _loadData : null,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _recordList.length,
        itemBuilder: (context, index) => _buildItem(_recordList[index]),
      ),
    );
  }

  /// 列表项
  Widget _buildItem(Map<String, dynamic> item) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 1),
      child: Row(
        children: [
          // 头像
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: item['avatar'] ?? '',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.person, color: Colors.grey),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.person, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nickname'] ?? '',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '加入时间: ${item['time'] ?? ''}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // 统计
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${item['childCount'] ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' 人'),
                  ],
                ),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${item['orderCount'] ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' 单'),
                  ],
                ),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${item['numberCount'] ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' 元'),
                  ],
                ),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 底部邀请码按钮
  Widget _buildBottomBar() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE6E6E6))),
      ),
      child: GestureDetector(
        onTap: () => Get.toNamed('/user/spread-code'),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.qr_code, size: 24), SizedBox(width: 8), Text('邀请码')],
        ),
      ),
    );
  }

  void _switchGrade(int grade) {
    if (_grade != grade) {
      setState(() {
        _grade = grade;
        _isLoading = true;
      });
      _searchController.clear();
      _loadData(isRefresh: true);
    }
  }

  void _onSearch() {
    setState(() => _isLoading = true);
    _loadData(isRefresh: true);
  }
}
