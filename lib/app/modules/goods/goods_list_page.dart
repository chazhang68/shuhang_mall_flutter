import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/theme/theme_colors.dart';
import 'package:shuhang_mall_flutter/widgets/widgets.dart';

/// 商品列表页
/// 对应原 pages/goods/goods_list/index.vue
class GoodsListPage extends StatefulWidget {
  const GoodsListPage({super.key});

  @override
  State<GoodsListPage> createState() => _GoodsListPageState();
}

class _GoodsListPageState extends State<GoodsListPage> {
  final RefreshController _refreshController = RefreshController();
  final ScrollController _scrollController = ScrollController();

  String? _keyword;
  int _sortType = 0; // 0: 综合, 1: 销量, 2: 价格升, 3: 价格降
  bool _isGrid = true;
  int _page = 1;
  bool _hasMore = true;

  final List<Map<String, dynamic>> _goodsList = [];

  @override
  void initState() {
    super.initState();
    _keyword = Get.parameters['keyword'];
    _loadData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool isRefresh = false}) async {
    if (isRefresh) {
      _page = 1;
      _hasMore = true;
    }

    // 模拟API请求
    await Future.delayed(const Duration(milliseconds: 500));

    if (isRefresh) {
      _goodsList.clear();
    }

    // 添加示例数据
    final newItems = List.generate(10, (index) {
      return {
        'id': _page * 10 + index,
        'store_name': '示例商品 ${_page * 10 + index}',
        'image': '',
        'price': '${99 + index * 10}.00',
        'ot_price': '${199 + index * 10}.00',
        'sales': 100 + index * 50,
        'unit_name': '件',
      };
    });

    setState(() {
      _goodsList.addAll(newItems);
      _page++;
      _hasMore = newItems.length >= 10;
    });

    if (isRefresh) {
      _refreshController.refreshCompleted();
    } else {
      if (_hasMore) {
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        final themeColor = controller.themeColor;

        return Scaffold(
          appBar: _buildAppBar(themeColor),
          body: Column(
            children: [
              // 排序栏
              _buildSortBar(themeColor),
              // 商品列表
              Expanded(
                child: SmartRefresher(
                  controller: _refreshController,
                  enablePullDown: true,
                  enablePullUp: true,
                  onRefresh: () => _loadData(isRefresh: true),
                  onLoading: () => _loadData(),
                  child: _goodsList.isEmpty
                      ? EmptySearch(keyword: _keyword)
                      : _isGrid
                      ? _buildGridView()
                      : _buildListView(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeColorData themeColor) {
    return AppBar(
      title: GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.goodsSearch),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 20, color: Color(0xFF999999)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _keyword ?? '搜索商品',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortBar(ThemeColorData themeColor) {
    return Container(
      height: 44,
      color: Colors.white,
      child: Row(
        children: [
          _buildSortItem('综合', 0, themeColor),
          _buildSortItem('销量', 1, themeColor),
          _buildPriceSortItem(themeColor),
          const Spacer(),
          // 切换布局
          GestureDetector(
            onTap: () {
              setState(() {
                _isGrid = !_isGrid;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Icon(
                _isGrid ? Icons.view_list : Icons.grid_view,
                size: 22,
                color: const Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortItem(String label, int type, themeColor) {
    final isActive = _sortType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _sortType = type;
        });
        _loadData(isRefresh: true);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isActive ? themeColor.primary : const Color(0xFF333333),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSortItem(ThemeColorData themeColor) {
    final isAsc = _sortType == 2;
    final isDesc = _sortType == 3;
    final isActive = isAsc || isDesc;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_sortType == 2) {
            _sortType = 3;
          } else {
            _sortType = 2;
          }
        });
        _loadData(isRefresh: true);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        alignment: Alignment.center,
        child: Row(
          children: [
            Text(
              '价格',
              style: TextStyle(
                fontSize: 14,
                color: isActive ? themeColor.primary : const Color(0xFF333333),
              ),
            ),
            const SizedBox(width: 2),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_drop_up,
                  size: 14,
                  color: isAsc ? themeColor.primary : const Color(0xFFCCCCCC),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 14,
                  color: isDesc ? themeColor.primary : const Color(0xFFCCCCCC),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.65,
      ),
      itemCount: _goodsList.length,
      itemBuilder: (context, index) {
        return GoodsCard(
          goods: _goodsList[index],
          style: GoodsCardStyle.grid,
          onTap: () => _goToDetail(_goodsList[index]),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _goodsList.length,
      itemBuilder: (context, index) {
        return GoodsCard(
          goods: _goodsList[index],
          style: GoodsCardStyle.list,
          onTap: () => _goToDetail(_goodsList[index]),
        );
      },
    );
  }

  void _goToDetail(Map<String, dynamic> goods) {
    Get.toNamed(AppRoutes.goodsDetail, parameters: {'id': '${goods['id']}'});
  }
}
