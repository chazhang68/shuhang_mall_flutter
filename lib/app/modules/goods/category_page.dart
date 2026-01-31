import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/data/providers/store_provider.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/theme/theme_colors.dart';

/// 商品分类页
/// 对应原 pages/goods_cate/goods_cate2.vue
class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> with AutomaticKeepAliveClientMixin {
  final StoreProvider _storeProvider = StoreProvider();

  List<Map<String, dynamic>> _categoryList = [];
  int _navActive = 0;
  List<Map<String, dynamic>> _subCategoryList = [];
  int _tabClick = 0;
  final List<Map<String, dynamic>> _productList = [];

  bool _isLoading = true;
  bool _loadingProducts = false;
  bool _loadEnd = false;
  int _page = 1;
  final int _limit = 10;
  int _cid = 0;
  int _sid = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadCategoryList();
  }

  Future<void> _loadCategoryList() async {
    try {
      final response = await _storeProvider.getCategoryList();

      if (response.isSuccess && response.data != null) {
        final list = response.data as List<dynamic>? ?? [];

        setState(() {
          _categoryList = List<Map<String, dynamic>>.from(list);
          _isLoading = false;

          if (_categoryList.isNotEmpty) {
            _tapNav(0, _categoryList[0]);
          }
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('获取分类列表失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _tapNav(int index, Map<String, dynamic> item) {
    setState(() {
      _navActive = index;
      _tabClick = 0;
      _page = 1;
      _loadEnd = false;
      _productList.clear();

      // 获取子分类
      final children = item['children'] as List<dynamic>? ?? [];
      _subCategoryList = List<Map<String, dynamic>>.from(children);

      // 设置分类ID
      _cid = item['id'] ?? 0;
      _sid = 0;

      // 如果有子分类，选中第一个
      if (_subCategoryList.isNotEmpty) {
        _sid = _subCategoryList[0]['id'] ?? 0;
      }
    });

    _loadProducts();
  }

  void _tapSubCategory(int index) {
    setState(() {
      _tabClick = index;
      _page = 1;
      _loadEnd = false;
      _productList.clear();

      if (_subCategoryList.isNotEmpty) {
        _sid = _subCategoryList[index]['id'] ?? 0;
      }
    });

    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (_loadingProducts || _loadEnd) return;

    setState(() {
      _loadingProducts = true;
    });

    try {
      final response = await _storeProvider.getProductList({
        'sid': _sid > 0 ? _sid : _cid,
        'page': _page,
        'limit': _limit,
      });

      if (response.isSuccess && response.data != null) {
        final list = response.data as List<dynamic>? ?? [];

        setState(() {
          if (list.length < _limit) {
            _loadEnd = true;
          }
          _productList.addAll(List<Map<String, dynamic>>.from(list));
          _page++;
          _loadingProducts = false;
        });
      } else {
        setState(() {
          _loadingProducts = false;
        });
      }
    } catch (e) {
      debugPrint('获取商品列表失败: $e');
      setState(() {
        _loadingProducts = false;
      });
    }
  }

  void _goSearch() {
    Get.toNamed(AppRoutes.goodsSearch);
  }

  void _goGoodsDetail(int id) {
    Get.toNamed(AppRoutes.goodsDetail, arguments: {'id': id});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GetBuilder<AppController>(
      builder: (controller) {
        final themeColor = controller.themeColor;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // 头部搜索栏
                    _buildHeader(themeColor),
                    // 主体内容
                    Expanded(
                      child: Row(
                        children: [
                          // 左侧分类导航
                          _buildLeftNav(themeColor),
                          // 右侧内容区
                          Expanded(
                            child: Column(
                              children: [
                                // 二级分类
                                if (_subCategoryList.isNotEmpty) _buildSubCategory(themeColor),
                                // 商品列表
                                Expanded(child: _buildProductList()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeColorData themeColor) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 12,
        right: 12,
        bottom: 10,
      ),
      child: Row(
        children: [
          // 首页按钮
          GestureDetector(
            onTap: () => Get.offAllNamed(AppRoutes.main),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.home, color: themeColor.primary, size: 24),
            ),
          ),
          const SizedBox(width: 8),
          // 搜索栏
          Expanded(
            child: GestureDetector(
              onTap: _goSearch,
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[400], size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '搜索商品名称',
                        style: TextStyle(color: Color(0xFF999999), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftNav(ThemeColorData themeColor) {
    return Container(
      width: 85,
      color: const Color(0xFFF6F6F6),
      child: ListView.builder(
        itemCount: _categoryList.length,
        itemBuilder: (context, index) {
          final item = _categoryList[index];
          final isSelected = _navActive == index;
          final cateName = item['cate_name']?.toString() ?? '';

          return GestureDetector(
            onTap: () => _tapNav(index, item),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border(
                  left: BorderSide(
                    color: isSelected ? themeColor.primary : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                cateName,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? themeColor.primary : const Color(0xFF333333),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubCategory(ThemeColorData themeColor) {
    return Container(
      color: Colors.white,
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _subCategoryList.length,
        itemBuilder: (context, index) {
          final item = _subCategoryList[index];
          final isSelected = _tabClick == index;
          final cateName = item['cate_name']?.toString() ?? '';

          return GestureDetector(
            onTap: () => _tapSubCategory(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              child: Text(
                cateName,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? themeColor.primary : const Color(0xFF666666),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductList() {
    if (_productList.isEmpty && !_loadingProducts) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('暂无商品', style: TextStyle(color: Color(0xFF999999))),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >= notification.metrics.maxScrollExtent - 100) {
          _loadProducts();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _productList.length + 1,
        itemBuilder: (context, index) {
          if (index == _productList.length) {
            return Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Text(
                _loadEnd ? '我也是有底线的' : (_loadingProducts ? '加载中...' : ''),
                style: const TextStyle(color: Color(0xFF999999), fontSize: 12),
              ),
            );
          }

          return _buildProductItem(_productList[index]);
        },
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> item) {
    final id = item['id'] ?? 0;
    final image = item['image']?.toString() ?? '';
    final storeName = item['store_name']?.toString() ?? '';
    final price = item['price']?.toString() ?? '0';
    final otPrice = item['ot_price']?.toString() ?? '';

    return GestureDetector(
      onTap: () => _goGoodsDetail(id is int ? id : int.tryParse(id.toString()) ?? 0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            // 商品图片
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[100],
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[100],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
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
                    storeName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '¥$price',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE93323),
                        ),
                      ),
                      if (otPrice.isNotEmpty && otPrice != price) ...[
                        const SizedBox(width: 8),
                        Text(
                          '¥$otPrice',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF999999),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
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
