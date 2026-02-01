import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/data/providers/activity_provider.dart';
import 'package:shuhang_mall_flutter/widgets/cached_image.dart';
import 'package:shuhang_mall_flutter/widgets/loading_widget.dart';

/// 拼团列表页
/// 对应 pages/activity/goods_combination/index.vue
class GroupBuyListPage extends StatefulWidget {
  const GroupBuyListPage({super.key});

  @override
  State<GroupBuyListPage> createState() => _GroupBuyListPageState();
}

class _GroupBuyListPageState extends State<GroupBuyListPage> {
  final ActivityProvider _activityProvider = ActivityProvider();
  final List<Map<String, dynamic>> _combinationList = [];
  final List<String> _pinkPeople = [];
  int _pinkCount = 0;
  bool _loading = false;
  bool _loadend = false;
  int _page = 1;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _getCombinationList();
    _getPink();
  }

  /// 获取正在拼团的人
  Future<void> _getPink() async {
    final response = await _activityProvider.getPink(null);
    if (response.isSuccess && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      setState(() {
        _pinkPeople
          ..clear()
          ..addAll(List<String>.from(data['avatars'] ?? []));
        _pinkCount = int.tryParse('${data['pink_count'] ?? 0}') ?? 0;
      });
    }
  }

  /// 获取拼团列表
  Future<void> _getCombinationList() async {
    if (_loading || _loadend) return;

    setState(() {
      _loading = true;
    });

    final response = await _activityProvider.getCombinationList({'page': _page, 'limit': _limit});

    if (response.isSuccess && response.data != null) {
      final List<dynamic> data = response.data;
      setState(() {
        _combinationList.addAll(data.cast<Map<String, dynamic>>());
        _page++;
        _loadend = data.length < _limit;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  /// 跳转到详情
  void _goDetail(Map<String, dynamic> item) {
    Get.toNamed('/activity/group-buy/detail', arguments: {'id': item['id']});
  }

  /// 下拉刷新
  Future<void> _onRefresh() async {
    setState(() {
      _combinationList.clear();
      _page = 1;
      _loadend = false;
    });
    await _getCombinationList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: theme.primaryColor),
        child: SafeArea(
          child: Column(
            children: [
              // 自定义AppBar
              _GroupBuyAppBar(theme: theme),
              // 参与人员展示
              _GroupBuyMembers(theme: theme, pinkPeople: _pinkPeople, pinkCount: _pinkCount),
              // 列表
              Expanded(
                child: _GroupBuyListView(
                  theme: theme,
                  combinationList: _combinationList,
                  loading: _loading,
                  loadEnd: _loadend,
                  onRefresh: _onRefresh,
                  onLoad: _getCombinationList,
                  onItemTap: _goDetail,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupBuyAppBar extends StatelessWidget {
  final ThemeData theme;

  const _GroupBuyAppBar({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          ),
          const Expanded(
            child: Center(
              child: Text(
                '拼团列表',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

class _GroupBuyMembers extends StatelessWidget {
  final ThemeData theme;
  final List<String> pinkPeople;
  final int pinkCount;

  const _GroupBuyMembers({
    required this.theme,
    required this.pinkPeople,
    required this.pinkCount,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.white.withAlpha((0.5 * 255).round())],
              ),
            ),
          ),
          const SizedBox(width: 15),
          SizedBox(
            height: 30,
            child: Stack(
              children: [
                for (int i = 0; i < pinkPeople.length && i < 6; i++)
                  Positioned(
                    left: i * 20.0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: ClipOval(
                        child: CachedImage(
                          imageUrl: pinkPeople[i],
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('$pinkCount人参与', style: const TextStyle(fontSize: 12, color: Colors.white)),
          const SizedBox(width: 15),
          Container(
            width: 50,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white.withAlpha((0.5 * 255).round()), Colors.transparent],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupBuyListView extends StatelessWidget {
  final ThemeData theme;
  final List<Map<String, dynamic>> combinationList;
  final bool loading;
  final bool loadEnd;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoad;
  final ValueChanged<Map<String, dynamic>> onItemTap;

  const _GroupBuyListView({
    required this.theme,
    required this.combinationList,
    required this.loading,
    required this.loadEnd,
    required this.onRefresh,
    required this.onLoad,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (combinationList.isEmpty && !loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: Colors.white54),
            SizedBox(height: 16),
            Text('暂无拼团活动', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            if (notification.metrics.extentAfter < 100) {
              onLoad();
            }
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          itemCount: combinationList.length + (loading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == combinationList.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: LoadingWidget()),
              );
            }
            final item = combinationList[index];
            return _CombinationItem(item: item, theme: theme, onTap: () => onItemTap(item));
          },
        ),
      ),
    );
  }
}

class _CombinationItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final ThemeData theme;
  final VoidCallback onTap;

  const _CombinationItem({required this.item, required this.theme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool soldOut = item['stock'] == 0 || item['quota'] == 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedImage(imageUrl: item['image'], width: 93, height: 93, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¥${item['product_price']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF999999),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              const Text(
                                '¥',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE93323),
                                ),
                              ),
                              Text(
                                item['price'],
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE93323),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (soldOut)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCCCCC),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '已售罄',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        )
                      else
                        Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha((0.85 * 255).round()),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${item['people']}人团',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                alignment: Alignment.center,
                                child: const Text(
                                  '去拼团',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
