import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/data/models/home_index_model.dart';
import 'package:shuhang_mall_flutter/app/data/providers/public_provider.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/theme/theme_colors.dart';

/// 首页
/// 对应原 pages/index/index.vue
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final PublicProvider _publicProvider = PublicProvider();

  // 数据
  List<HomeBannerItem> _banners = [];
  String _notes = '';
  int _notesId = 0;
  List<HomeHotProduct> _hotList = [];

  bool _isLoading = true;
  int _page = 1;
  final int _limit = 10;
  bool _loadEnd = false;
  bool _loadingMore = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadIndexData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadIndexData() async {
    try {
      final response = await _publicProvider.getHomeIndexDataByType(1);

      if (response.isSuccess && response.data != null) {
        final data = response.data!;

        setState(() {
          _banners = data.banners;
          _notes = data.notes;
          _notesId = data.notesId;
          _hotList = data.hotList;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        debugPrint('获取首页数据失败: ${response.msg}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('获取首页数据异常: $e');
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_loadingMore || _loadEnd) return;

    setState(() {
      _loadingMore = true;
    });

    try {
      final response = await _publicProvider.getHomeProductsByType(1, {
        'page': _page,
        'limit': _limit,
      });

      if (response.isSuccess && response.data != null) {
        final list = response.data ?? <HomeHotProduct>[];

        setState(() {
          if (list.length < _limit) {
            _loadEnd = true;
          }
          _hotList.addAll(list);
          _page++;
          _loadingMore = false;
        });
      } else {
        setState(() {
          _loadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _loadingMore = false;
      });
      debugPrint('加载更多商品失败: $e');
    }
  }

  Future<void> _onRefresh() async {
    _page = 1;
    _loadEnd = false;
    _hotList.clear();
    await _loadIndexData();
  }

  void _goSearch() {
    Get.toNamed(AppRoutes.goodsSearch);
  }

  void _goGoodsDetail(int id) {
    Get.toNamed(AppRoutes.goodsDetail, arguments: {'id': id});
  }

  void _goNotice() {
    if (_notesId > 0) {
      Get.toNamed(AppRoutes.newsDetail, arguments: {'id': _notesId});
    }
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
              : EasyRefresh(
                  header: const ClassicHeader(
                    dragText: '下拉刷新',
                    armedText: '松手刷新',
                    processingText: '刷新中...',
                    processedText: '刷新完成',
                    failedText: '刷新失败',
                  ),
                  onRefresh: _onRefresh,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    slivers: [
                      // 顶部Logo
                      SliverToBoxAdapter(child: _buildHeader()),

                      // 轮播图
                      SliverToBoxAdapter(child: _buildBanner()),

                      // 公告
                      if (_notes.isNotEmpty) SliverToBoxAdapter(child: _buildNotice(themeColor)),

                      // 搜索栏
                      SliverToBoxAdapter(child: _buildSearchBar(themeColor)),

                      // 商品列表标题
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                          child: const Text(
                            '推荐商品',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                      ),

                      // 商品列表
                      _hotList.isEmpty
                          ? const SliverToBoxAdapter(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: Text('暂无商品', style: TextStyle(color: Color(0xFF999999))),
                                ),
                              ),
                            )
                          : SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              sliver: SliverGrid(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  childAspectRatio: 0.65,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildGoodsItem(_hotList[index]),
                                  childCount: _hotList.length,
                                ),
                              ),
                            ),

                      // 加载更多提示
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.center,
                          child: Text(
                            _loadEnd ? '我也是有底线的' : (_loadingMore ? '加载中...' : ''),
                            style: const TextStyle(color: Color(0xFF999999), fontSize: 12),
                          ),
                        ),
                      ),

                      // 底部留白
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    ],
                  ),
                ),
        );
      },
    );
  }

  /// 顶部Logo
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 8,
        right: 8,
        bottom: 4,
      ),
      child: Image.asset(
        'assets/images/logos.png',
        width: 120,
        height: 48,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox(
            width: 120,
            height: 48,
            child: Center(
              child: Text(
                '数航商道',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE93323),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 轮播图
  Widget _buildBanner() {
    if (_banners.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(12),
        height: 188,
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
        child: const Center(
          child: Text('暂无轮播图', style: TextStyle(color: Color(0xFF999999))),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(12),
      height: 188,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 188,
          autoPlay: true,
          enlargeCenterPage: false,
          viewportFraction: 1.0,
          autoPlayInterval: const Duration(seconds: 3),
        ),
        items: _banners.map((banner) {
          final imgUrl = banner.imgUrl;
          final url = banner.url;

          return GestureDetector(
            onTap: () {
              if (url.isNotEmpty) {
                // 解析URL跳转
                _handleBannerClick(url);
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imgUrl,
                width: double.infinity,
                height: 188,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handleBannerClick(String url) {
    // 简单处理URL跳转
    if (url.contains('goods_details') || url.contains('id=')) {
      final idMatch = RegExp(r'id=(\d+)').firstMatch(url);
      if (idMatch != null) {
        final id = int.tryParse(idMatch.group(1) ?? '0') ?? 0;
        if (id > 0) {
          Get.toNamed(AppRoutes.goodsDetail, arguments: {'id': id});
        }
      }
    }
  }

  /// 公告
  Widget _buildNotice(ThemeColorData themeColor) {
    return GestureDetector(
      onTap: _goNotice,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Image.asset(
              'assets/images/icon_notice.png',
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.campaign, color: themeColor.primary, size: 24);
              },
            ),
            const SizedBox(width: 4),
            const Text('公告', style: TextStyle(fontSize: 13, color: Color(0xFF333333))),
            Container(
              width: 1,
              height: 13,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: const Color(0xFFDDDDDD),
            ),
            Expanded(
              child: Text(
                _notes,
                style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF999999), size: 20),
          ],
        ),
      ),
    );
  }

  /// 搜索栏
  Widget _buildSearchBar(ThemeColorData themeColor) {
    return GestureDetector(
      onTap: _goSearch,
      child: Container(
        margin: const EdgeInsets.all(12),
        height: 35,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35)),
        child: Row(
          children: [
            Image.asset(
              'assets/images/icon_search.png',
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.search, color: themeColor.primary, size: 24);
              },
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('输入你想搜索的商品', style: TextStyle(color: Color(0xFFA6A6A6), fontSize: 14)),
            ),
            const Text('搜索', style: TextStyle(color: Color(0xFF444444), fontSize: 13)),
          ],
        ),
      ),
    );
  }

  /// 商品卡片
  Widget _buildGoodsItem(HomeHotProduct item) {
    final id = item.id;
    final image = item.image;
    final storeName = item.storeName;
    final keyword = item.keyword;
    final price = item.price.toStringAsFixed(2);

    return GestureDetector(
      onTap: () => _goGoodsDetail(id),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图片
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: CachedNetworkImage(
                imageUrl: image,
                width: double.infinity,
                height: 169,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 169,
                  color: Colors.grey[100],
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 169,
                  color: Colors.grey[100],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
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
                      storeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    if (keyword.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        keyword,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: Color(0xFFE9AD00)),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/xiaofeiquan.png',
                          width: 41,
                          height: 15.5,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFA281D),
                            fontFamily: 'DIN Alternate',
                          ),
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
