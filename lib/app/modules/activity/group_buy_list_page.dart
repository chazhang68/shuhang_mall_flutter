import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    // TODO: 调用API
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _pinkPeople.addAll([
        'https://via.placeholder.com/46',
        'https://via.placeholder.com/46',
        'https://via.placeholder.com/46',
        'https://via.placeholder.com/46',
        'https://via.placeholder.com/46',
        'https://via.placeholder.com/46',
      ]);
      _pinkCount = 1234;
    });
  }

  /// 获取拼团列表
  Future<void> _getCombinationList() async {
    if (_loading || _loadend) return;

    setState(() {
      _loading = true;
    });

    // TODO: 调用API获取拼团列表
    await Future.delayed(const Duration(seconds: 1));

    // 模拟数据
    final mockData = List.generate(
      10,
      (index) => {
        'id': _page * 10 + index,
        'image': 'https://via.placeholder.com/186',
        'title': '拼团商品${_page * 10 + index}超值优惠限时抢购',
        'people': 2 + index % 5,
        'price': '${(index + 1) * 50}.00',
        'product_price': '${(index + 1) * 100}.00',
        'stock': index % 3 == 0 ? 0 : 100,
        'quota': index % 3 == 0 ? 0 : 50,
      },
    );

    setState(() {
      _combinationList.addAll(mockData);
      _page++;
      _loadend = mockData.length < _limit;
      _loading = false;
    });
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
              _buildAppBar(theme),
              // 参与人员展示
              _buildGroupMembers(theme),
              // 列表
              Expanded(child: _buildList(theme)),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建AppBar
  Widget _buildAppBar(ThemeData theme) {
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

  /// 构建参与人员展示
  Widget _buildGroupMembers(ThemeData theme) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 左侧线条
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
          // 头像列表
          SizedBox(
            height: 30,
            child: Stack(
              children: [
                for (int i = 0; i < _pinkPeople.length && i < 6; i++)
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
                          imageUrl: _pinkPeople[i],
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
          Text('$_pinkCount人参与', style: const TextStyle(fontSize: 12, color: Colors.white)),
          const SizedBox(width: 15),
          // 右侧线条
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

  /// 构建列表
  Widget _buildList(ThemeData theme) {
    if (_combinationList.isEmpty && !_loading) {
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
      onRefresh: _onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            if (notification.metrics.extentAfter < 100) {
              _getCombinationList();
            }
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          itemCount: _combinationList.length + (_loading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _combinationList.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: LoadingWidget()),
              );
            }
            return _buildCombinationItem(_combinationList[index], theme);
          },
        ),
      ),
    );
  }

  /// 构建拼团商品项
  Widget _buildCombinationItem(Map<String, dynamic> item, ThemeData theme) {
    final bool soldOut = item['stock'] == 0 || item['quota'] == 0;

    return GestureDetector(
      onTap: () => _goDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            // 商品图片
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedImage(imageUrl: item['image'], width: 93, height: 93, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            // 商品信息
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
                      // 价格信息
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
                      // 拼团按钮
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
                              // 人数
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
                              // 去拼团
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
