import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/data/providers/store_provider.dart';
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
  final ScrollController _scrollController = ScrollController();
  final StoreProvider _storeProvider = StoreProvider();

  String? _keyword;
  int? _cateId;
  int _page = 1;
  final int _limit = 10;
  bool _hasMore = true;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _goodsList = [];

  @override
  void initState() {
    super.initState();
    _keyword = Get.parameters['keyword'];
    _cateId = int.tryParse(Get.parameters['cid'] ?? '');
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool isRefresh = false}) async {
    if (_isLoading) return;
    
    if (isRefresh) {
      _page = 1;
      _hasMore = true;
      _goodsList.clear();
    }

    if (!_hasMore) return;

    setState(() => _isLoading = true);

    try {
      // 构建请求参数
      final params = <String, dynamic>{
        'page': _page,
        'limit': _limit,
      };
      
      if (_keyword != null && _keyword!.isNotEmpty) {
        params['keyword'] = _keyword;
      }
      if (_cateId != null) {
        params['cid'] = _cateId;
      }

      // 调用API
      final response = await _storeProvider.getProductList(params);

      if (response.isSuccess && response.data != null) {
        // 处理返回数据 - API可能返回List或包含list字段的Map
        List<Map<String, dynamic>> newItems = [];
        
        if (response.data is List) {
          // 直接是List的情况
          for (var item in response.data) {
            if (item is Map) {
              newItems.add(Map<String, dynamic>.from(item));
            }
          }
        } else if (response.data is Map) {
          // Map情况，尝试获取list/data字段
          final dataMap = Map<String, dynamic>.from(response.data as Map);
          final listData = dataMap['list'] ?? dataMap['data'];
          if (listData is List) {
            for (var item in listData) {
              if (item is Map) {
                newItems.add(Map<String, dynamic>.from(item));
              }
            }
          }
        }

        setState(() {
          _goodsList.addAll(newItems);
          _page++;
          _hasMore = newItems.length >= _limit;
        });
      }
    } catch (e) {
      debugPrint('加载商品列表失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        final themeColor = controller.themeColor;

        return Scaffold(
          appBar: _buildAppBar(themeColor),
          body: EasyRefresh(
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
              noMoreText: '没有更多内容啦~',
            ),
            onRefresh: () => _loadData(isRefresh: true),
            onLoad: _hasMore ? () => _loadData() : null,
            child: _goodsList.isEmpty && !_isLoading
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [EmptySearch(keyword: _keyword)],
                  )
                : _goodsList.isEmpty && _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildListView(),
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
    final id = goods['id'] ?? goods['product_id'] ?? 0;
    Get.toNamed(AppRoutes.goodsDetail, arguments: {'id': id});
  }
}
