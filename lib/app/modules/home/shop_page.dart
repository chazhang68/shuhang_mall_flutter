import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/data/models/home_index_model.dart';
import 'package:shuhang_mall_flutter/app/data/providers/public_provider.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/widgets/banner_swiper.dart';
import 'package:shuhang_mall_flutter/widgets/home_product_card.dart';

/// 商城页面
/// 对应原 pages/active/active.vue
class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> with AutomaticKeepAliveClientMixin {
  final PublicProvider _publicProvider = PublicProvider();

  List<HomeBannerItem> _banners = [];
  final List<HomeHotProduct> _productList = [];
  int _page = 1;
  final int _limit = 10;
  bool _loading = false;
  bool _loadEnd = false;

  @override
  void initState() {
    super.initState();
    _loadIndexData();
    _loadProductList();
  }

  Future<void> _loadIndexData() async {
    try {
      final response = await _publicProvider.getHomeIndexDataByType(2);
      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        setState(() {
          _banners = data.banners;
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
    });

    try {
      final response = await _publicProvider.getHomeProductsByType(2, {
        'page': _page,
        'limit': _limit,
      });
      if (response.isSuccess && response.data != null) {
        final data = response.data ?? <HomeHotProduct>[];
        setState(() {
          _loadEnd = data.length < _limit;
          _productList.addAll(data);
          _page++;
        });
      }
    } catch (e) {
      debugPrint('加载商品列表失败: $e');
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
    super.build(context);
    final bannerList = _banners
        .map(
          (banner) => {
            'id': banner.id,
            'image': banner.imgUrl,
            'pic': banner.imgUrl,
            'url': banner.url,
            'type': banner.type,
          },
        )
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logos.png',
          width: 120,
          height: 48,
          fit: BoxFit.contain,
        ),
        toolbarHeight: 54,
        centerTitle: false,
      ),
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
          noMoreText: '我也是有底线的',
          failedText: '加载失败',
        ),
        onRefresh: _onRefresh,
        onLoad: _loadEnd ? null : _loadProductList,
        child: CustomScrollView(
          slivers: [
            // Banner轮播
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(12),
                height: 188,
                child: bannerList.isNotEmpty
                    ? BannerSwiper(banners: bannerList, height: 188)
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(child: Text('暂无轮播图')),
                      ),
              ),
            ),

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
                  return HomeProductCard(product: item, onTap: () => _goDetail(item.id));
                }, childCount: _productList.length),
              ),
            ),

            // 底部间距
            const SliverToBoxAdapter(child: SizedBox(height: 98)),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
