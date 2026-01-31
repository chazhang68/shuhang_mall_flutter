import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';

/// 秒杀列表页
/// 对应原 pages/activity/goods_seckill/index.vue
class SeckillListPage extends StatefulWidget {
  const SeckillListPage({super.key});

  @override
  State<SeckillListPage> createState() => _SeckillListPageState();
}

class _SeckillListPageState extends State<SeckillListPage> {
  List<Map<String, dynamic>> timeList = [];
  List<Map<String, dynamic>> seckillList = [];
  int activeIndex = 0;
  int status = 1; // 1:抢购中 2:未开始 3:已结束
  bool isLoading = true;
  bool isLoadingMore = false;
  int page = 1;
  final int limit = 8;
  bool loadEnd = false;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _timeScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSeckillConfig();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _timeScrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      _loadMoreSeckillList();
    }
  }

  Future<void> _loadSeckillConfig() async {
    setState(() => isLoading = true);

    // TODO: 调用API获取秒杀时间段配置
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      timeList = [
        {'id': 1, 'time': '00:00', 'state': '已结束', 'status': 3, 'slide': ''},
        {'id': 2, 'time': '08:00', 'state': '已结束', 'status': 3, 'slide': ''},
        {'id': 3, 'time': '10:00', 'state': '已结束', 'status': 3, 'slide': ''},
        {'id': 4, 'time': '12:00', 'state': '抢购中', 'status': 1, 'slide': ''},
        {'id': 5, 'time': '14:00', 'state': '未开始', 'status': 2, 'slide': ''},
        {'id': 6, 'time': '16:00', 'state': '未开始', 'status': 2, 'slide': ''},
        {'id': 7, 'time': '18:00', 'state': '未开始', 'status': 2, 'slide': ''},
        {'id': 8, 'time': '20:00', 'state': '未开始', 'status': 2, 'slide': ''},
      ];

      // 默认选中正在抢购中的时间段
      activeIndex = timeList.indexWhere((item) => item['status'] == 1);
      if (activeIndex < 0) activeIndex = 0;
      status = timeList[activeIndex]['status'] ?? 1;
    });

    await _loadSeckillList();

    setState(() => isLoading = false);

    // 滚动到选中的时间段
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveTime();
    });
  }

  void _scrollToActiveTime() {
    if (_timeScrollController.hasClients) {
      double offset = (activeIndex - 1) * 80.0;
      if (offset < 0) offset = 0;
      _timeScrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _loadSeckillList() async {
    if (loadEnd || isLoadingMore) return;

    // TODO: 调用API获取秒杀商品列表
    await Future.delayed(const Duration(milliseconds: 300));

    final newList = List.generate(
      page == 1 ? 5 : 3,
      (index) => {
        'id': (page - 1) * limit + index + 1,
        'image': 'https://via.placeholder.com/200',
        'title': '秒杀商品${(page - 1) * limit + index + 1}',
        'price': '99.00',
        'ot_price': '199.00',
        'quota_show': 100,
        'unit_name': '件',
        'percent': 30 + (index * 10),
      },
    );

    setState(() {
      if (page == 1) {
        seckillList = newList;
      } else {
        seckillList.addAll(newList);
      }
      loadEnd = newList.length < limit;
      page++;
    });
  }

  Future<void> _loadMoreSeckillList() async {
    if (loadEnd || isLoadingMore) return;

    setState(() => isLoadingMore = true);
    await _loadSeckillList();
    setState(() => isLoadingMore = false);
  }

  void _selectTime(int index) {
    if (activeIndex == index) return;

    setState(() {
      activeIndex = index;
      status = timeList[index]['status'] ?? 1;
      seckillList = [];
      page = 1;
      loadEnd = false;
    });

    _loadSeckillList();
  }

  void _goDetail(Map<String, dynamic> item) {
    Get.toNamed(AppRoutes.seckillDetail, parameters: {'id': item['id'].toString()});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // 顶部背景
          Container(
            color: theme.primaryColor,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // AppBar
                  SizedBox(
                    height: 56,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        const Expanded(
                          child: Text(
                            '限时秒杀',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // 秒杀Banner
                  Container(
                    height: 120,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: NetworkImage('https://via.placeholder.com/400x150'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // 时间段选择
          _buildTimeList(theme),

          // 商品列表
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : seckillList.isEmpty
                ? _buildEmptyView()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: seckillList.length + (isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == seckillList.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return _buildSeckillItem(theme, seckillList[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeList(ThemeData theme) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // 价格标签图标
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(left: 12),
            child: Icon(Icons.local_offer, color: theme.primaryColor),
          ),

          // 时间段横向滚动列表
          Expanded(
            child: SizedBox(
              height: 60,
              child: ListView.builder(
                controller: _timeScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: timeList.length,
                itemBuilder: (context, index) {
                  final item = timeList[index];
                  final isActive = index == activeIndex;

                  return GestureDetector(
                    onTap: () => _selectTime(index),
                    child: Container(
                      width: 80,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['time'] ?? '',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isActive ? theme.primaryColor : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isActive ? theme.primaryColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              item['state'] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: isActive ? Colors.white : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeckillItem(ThemeData theme, Map<String, dynamic> item) {
    final percent = item['percent'] ?? 0;

    return GestureDetector(
      onTap: () => _goDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            // 商品图片
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['image'] ?? '',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // 商品信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('¥', style: TextStyle(fontSize: 12, color: theme.primaryColor)),
                      Text(
                        item['price'] ?? '',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '¥${item['ot_price']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '限量 ${item['quota_show']}${item['unit_name'] ?? ''}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),

                  // 进度条
                  Stack(
                    children: [
                      Container(
                        width: 130,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEFEF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Container(
                        width: 130 * percent / 100,
                        height: 16,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE93323), Color(0xFFFF8933)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(
                        width: 130,
                        height: 16,
                        child: Center(
                          child: Text(
                            '已抢$percent%',
                            style: TextStyle(
                              fontSize: 10,
                              color: percent > 30 ? Colors.white : const Color(0xFFFFB9B9),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 抢购按钮
            Container(
              width: 70,
              height: 32,
              decoration: BoxDecoration(
                color: status == 1
                    ? theme.primaryColor
                    : status == 2
                    ? theme.primaryColor
                    : Colors.grey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  status == 1
                      ? '抢购中'
                      : status == 2
                      ? '未开始'
                      : '已结束',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://via.placeholder.com/200',
            width: 200,
            height: 150,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
          ),
          const SizedBox(height: 16),
          Text('暂无商品，去看点别的吧', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
        ],
      ),
    );
  }
}
