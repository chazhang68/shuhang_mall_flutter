import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/data/providers/activity_provider.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';

/// 秒杀列表页
/// 对应原 pages/activity/goods_seckill/index.vue
class SeckillListPage extends StatefulWidget {
  const SeckillListPage({super.key});

  @override
  State<SeckillListPage> createState() => _SeckillListPageState();
}

class _SeckillListPageState extends State<SeckillListPage> {
  final ActivityProvider _activityProvider = ActivityProvider();
  List<Map<String, dynamic>> timeList = [];
  List<Map<String, dynamic>> seckillList = [];
  int activeIndex = 0;
  int status = 1; // 1:抢购中 2:未开始 3:已结束
  bool isLoading = true;
  bool isLoadingMore = false;
  int page = 1;
  final int limit = 8;
  bool loadEnd = false;
  String topImage = '';
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

    final response = await _activityProvider.getSeckillIndex();
    if (response.isSuccess && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final List<dynamic> timeData = data['seckillTime'] ?? [];
      setState(() {
        topImage = data['lovely'] ?? '';
        timeList = timeData.cast<Map<String, dynamic>>();
        activeIndex = (data['seckillTimeIndex'] ?? 0) as int;
        if (activeIndex < 0 || activeIndex >= timeList.length) {
          activeIndex = 0;
        }
        status = timeList.isNotEmpty ? (timeList[activeIndex]['status'] ?? 1) : 1;
      });

      if (timeList.isNotEmpty) {
        await _loadSeckillList();
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActiveTime();
      });
    }

    setState(() => isLoading = false);
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

    final timeId = timeList.isNotEmpty ? timeList[activeIndex]['id'] : 0;
    final response = await _activityProvider.getSeckillList(int.tryParse('$timeId') ?? 0, {
      'page': page,
      'limit': limit,
    });

    if (response.isSuccess && response.data != null) {
      final List<dynamic> newList = response.data;
      setState(() {
        if (page == 1) {
          seckillList = newList.cast<Map<String, dynamic>>();
        } else {
          seckillList.addAll(newList.cast<Map<String, dynamic>>());
        }
        loadEnd = newList.length < limit;
        page++;
      });
    }
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
                    ),
                    child: topImage.isEmpty
                        ? const SizedBox.shrink()
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              topImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                            ),
                          ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // 时间段选择
          _SeckillTimeList(
            theme: theme,
            timeList: timeList,
            activeIndex: activeIndex,
            controller: _timeScrollController,
            onSelect: _selectTime,
          ),

          // 商品列表
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : (seckillList.isEmpty && (page != 1 || activeIndex == 0))
                ? const _SeckillEmptyView()
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
                      return _SeckillItem(
                        theme: theme,
                        item: seckillList[index],
                        status: status,
                        onTap: () => _goDetail(seckillList[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SeckillTimeList extends StatelessWidget {
  final ThemeData theme;
  final List<Map<String, dynamic>> timeList;
  final int activeIndex;
  final ScrollController controller;
  final ValueChanged<int> onSelect;

  const _SeckillTimeList({
    required this.theme,
    required this.timeList,
    required this.activeIndex,
    required this.controller,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(left: 12),
            child: Icon(Icons.local_offer, color: theme.primaryColor),
          ),
          Expanded(
            child: SizedBox(
              height: 60,
              child: ListView.builder(
                controller: controller,
                scrollDirection: Axis.horizontal,
                itemCount: timeList.length,
                itemBuilder: (context, index) {
                  final item = timeList[index];
                  final isActive = index == activeIndex;

                  return GestureDetector(
                    onTap: () => onSelect(index),
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
}

class _SeckillItem extends StatelessWidget {
  final ThemeData theme;
  final Map<String, dynamic> item;
  final int status;
  final VoidCallback onTap;

  const _SeckillItem({
    required this.theme,
    required this.item,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percent = item['percent'] ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
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
}

class _SeckillEmptyView extends StatelessWidget {
  const _SeckillEmptyView();

  @override
  Widget build(BuildContext context) {
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
