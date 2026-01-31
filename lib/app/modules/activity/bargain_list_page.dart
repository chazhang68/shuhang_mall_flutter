import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    // TODO: 调用API获取砍价列表
    await Future.delayed(const Duration(seconds: 1));

    // 模拟数据
    final mockData = List.generate(
      10,
      (index) => {
        'id': _page * 10 + index,
        'image': 'https://via.placeholder.com/200',
        'title': '砍价商品${_page * 10 + index}',
        'people': 100 + index * 10,
        'min_price': '${(index + 1) * 10}.00',
        'price': '${(index + 1) * 100}.00',
      },
    );

    setState(() {
      _bargainList.addAll(mockData);
      _page++;
      _loadend = mockData.length < _limit;
      _loading = false;
    });
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
            // 头部背景图
            _buildHeader(theme),
            // 列表
            Expanded(child: _buildList(theme)),
          ],
        ),
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader(ThemeData theme) {
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

  /// 构建列表
  Widget _buildList(ThemeData theme) {
    if (_bargainList.isEmpty && !_loading) {
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
      onRefresh: _onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            if (notification.metrics.extentAfter < 100) {
              _getBargainList();
            }
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: _bargainList.length + (_loading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _bargainList.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: LoadingWidget()),
              );
            }
            return _buildBargainItem(_bargainList[index], theme);
          },
        ),
      ),
    );
  }

  /// 构建砍价商品项
  Widget _buildBargainItem(Map<String, dynamic> item, ThemeData theme) {
    return GestureDetector(
      onTap: () => _goDetail(item),
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
            // 商品图片
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
            // 商品信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
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
                        '${item['people']}人正在参与',
                        style: TextStyle(fontSize: 12, color: theme.primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 价格
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '最低: ¥${item['min_price']}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.error,
                            ),
                          ),
                          Text(
                            '¥${item['price']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      // 参与砍价按钮
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.content_cut,
                              size: 14,
                              color: Colors.white.withAlpha((0.9 * 255).round()),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '参与砍价',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
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
