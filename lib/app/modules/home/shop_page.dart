import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/data/providers/public_provider.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/widgets/banner_swiper.dart';

/// 商城页面
/// 对应原 pages/active/active.vue
class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final AppController _appController = Get.find<AppController>();
  final PublicProvider _publicProvider = PublicProvider();

  List<Map<String, dynamic>> _bannerList = [];
  final List<Map<String, dynamic>> _productList = [];
  int _page = 1;
  final int _limit = 10;
  bool _loading = false;
  bool _loadEnd = false;
  String _loadTitle = '加载更多';

  @override
  void initState() {
    super.initState();
    _loadIndexData();
    _loadProductList();
  }

  Future<void> _loadIndexData() async {
    try {
      final response = await _publicProvider.getIndexDataByType(2);
      if (response.isSuccess && response.data != null) {
        setState(() {
          _bannerList = List<Map<String, dynamic>>.from(response.data['banner'] ?? []);
        });
      }
    } catch (e) {
      debugPrint('加载首页数据失败: $e');
    }
  }

  Future<void> _loadProductList() async {
    if (_loading || _loadEnd) return;

    setState(() {
      _loading = true;
      _loadTitle = '';
    });

    try {
      final response = await _publicProvider.getProducts(2, {'page': _page, 'limit': _limit});
      if (response.isSuccess && response.data != null) {
        final List<dynamic> data = response.data is List ? response.data : [];
        setState(() {
          _loadEnd = data.length < _limit;
          _productList.addAll(List<Map<String, dynamic>>.from(data));
          _loadTitle = _loadEnd ? '我也是有底线的' : '加载更多';
          _page++;
        });
      }
    } catch (e) {
      debugPrint('加载商品列表失败: $e');
      setState(() {
        _loadTitle = '加载更多';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _page = 1;
      _loadEnd = false;
      _productList.clear();
    });
    await _loadIndexData();
    await _loadProductList();
  }

  void _goDetail(int id) {
    Get.toNamed(AppRoutes.goodsDetail, arguments: {'id': id});
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _appController.themeColor;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            // 顶部Logo
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.only(top: statusBarHeight + 8, left: 16, right: 16, bottom: 8),
                child: Image.asset(
                  'assets/images/logos.png',
                  width: 120,
                  height: 48,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      '商城',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
            ),

            // Banner轮播
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                height: 188,
                child: _bannerList.isNotEmpty
                    ? BannerSwiper(banners: _bannerList, height: 188)
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(child: Text('暂无轮播图')),
                      ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 商品列表
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.68,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = _productList[index];
                  return _buildProductItem(item, themeColor);
                }, childCount: _productList.length),
              ),
            ),

            // 加载更多
            SliverToBoxAdapter(
              child: _productList.isNotEmpty
                  ? GestureDetector(
                      onTap: _loadEnd ? null : _loadProductList,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_loading)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            if (_loading) const SizedBox(width: 8),
                            Text(
                              _loadTitle,
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // 底部间距
            const SliverToBoxAdapter(child: SizedBox(height: 98)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> item, dynamic themeColor) {
    return GestureDetector(
      onTap: () => _goDetail(item['id'] ?? 0),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图片
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                item['image'] ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 40, color: Colors.grey),
                  );
                },
              ),
            ),
            // 商品信息
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['store_name'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'SWP',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFFFA281D),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${item['price'] ?? '0'}',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFFFA281D),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Image.asset(
                          'assets/images/shop-card.png',
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.shopping_cart_outlined,
                              size: 20,
                              color: themeColor.primary,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
