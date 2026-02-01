import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/data/providers/activity_provider.dart';
import 'package:shuhang_mall_flutter/widgets/cached_image.dart';
import 'package:shuhang_mall_flutter/widgets/loading_widget.dart';

/// 砍价列表页
/// 对应 pages/activity/goods_bargain/index.vue
class BargainListPage extends StatefulWidget {
  const BargainListPage({super.key});

  @override
  State<BargainListPage> createState() => _BargainListPageState();
}

class _BargainListPageState extends State<BargainListPage> {
  final ActivityProvider _activityProvider = ActivityProvider();
  final List<Map<String, dynamic>> _bargainList = [];
  bool _loading = false;
  bool _loadend = false;
  int _page = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _getBargainList();
  }

  /// 获取砍价列表
  Future<void> _getBargainList() async {
    if (_loading || _loadend) return;

    setState(() {
      _loading = true;
    });

    final response = await _activityProvider.getBargainList({'page': _page, 'limit': _limit});
    if (response.isSuccess && response.data != null) {
      final list = List<Map<String, dynamic>>.from(response.data);
      setState(() {
        _bargainList.addAll(list);
        _page++;
        _loadend = list.length < _limit;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  /// 跳转到砍价详情
  void _goDetail(Map<String, dynamic> item) {
    Get.toNamed('/activity/bargain/detail', arguments: {'id': item['id']});
  }

  /// 下拉刷新
  Future<void> _onRefresh() async {
    setState(() {
      _bargainList.clear();
      _page = 1;
      _loadend = false;
    });
    await _getBargainList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('砍价列表'), centerTitle: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.primaryColor, theme.primaryColor.withAlpha((0.8 * 255).round())],
          ),
        ),
        child: Column(
          children: [
            _BargainHeader(theme: theme),
            Expanded(
              child: Container(
                color: const Color(0xFFF5F5F5),
                child: _BargainListView(
                  theme: theme,
                  list: _bargainList,
                  loading: _loading,
                  loadEnd: _loadend,
                  onRefresh: _onRefresh,
                  onLoad: _getBargainList,
                  onItemTap: _goDetail,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BargainHeader extends StatelessWidget {
  final ThemeData theme;

  const _BargainHeader({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.primaryColor, theme.primaryColor.withAlpha((0.7 * 255).round())],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.content_cut, size: 50, color: Colors.white.withAlpha((0.9 * 255).round())),
            const SizedBox(height: 8),
            Text(
              '参与砍价 · 超低价购',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white.withAlpha((0.95 * 255).round()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BargainListView extends StatelessWidget {
  final ThemeData theme;
  final List<Map<String, dynamic>> list;
  final bool loading;
  final bool loadEnd;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoad;
  final ValueChanged<Map<String, dynamic>> onItemTap;

  const _BargainListView({
    required this.theme,
    required this.list,
    required this.loading,
    required this.loadEnd,
    required this.onRefresh,
    required this.onLoad,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty && !loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无砍价活动', style: TextStyle(color: Colors.grey)),
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
          padding: const EdgeInsets.all(15),
          itemCount: list.length + (loading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == list.length) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: loadEnd
                      ? const Text('没有更多数据了', style: TextStyle(color: Colors.grey, fontSize: 12))
                      : const LoadingWidget(),
                ),
              );
            }
            final item = list[index];
            return _BargainItem(theme: theme, item: item, onTap: () => onItemTap(item));
          },
        ),
      ),
    );
  }
}

class _BargainItem extends StatelessWidget {
  final ThemeData theme;
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _BargainItem({required this.theme, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedImage(
                imageUrl: item['image'],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? '',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people_outline, size: 14, color: theme.primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        '${item['people'] ?? 0}人正在参与',
                        style: TextStyle(fontSize: 12, color: theme.primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '最低: ¥${item['min_price'] ?? ''}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.error,
                            ),
                          ),
                          Text(
                            '¥${item['price'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.primaryColor,
                              theme.primaryColor.withAlpha((0.8 * 255).round()),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '参与砍价',
                          style: TextStyle(fontSize: 12, color: Colors.white),
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
