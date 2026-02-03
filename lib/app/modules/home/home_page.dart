import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marquee/marquee.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/data/models/home_index_model.dart';
import 'package:shuhang_mall_flutter/app/data/providers/public_provider.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/theme/theme_colors.dart';
import 'package:shuhang_mall_flutter/widgets/home_product_card.dart';
import 'package:shuhang_mall_flutter/widgets/zj_feed_ad_widget.dart';

/// 首页
/// 对应原 pages/index/index.vue
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
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
  bool _showAd = true; // 控制广告显示

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadIndexData();
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
    final Size size = MediaQuery.sizeOf(context);

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
                  onLoad: _loadMoreProducts,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // 顶部Logo
                      SliverToBoxAdapter(child: _buildHeader()),

                      // 轮播图
                      SliverToBoxAdapter(child: _buildBanner()),

                      // 公告
                      if (_notes.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Container(
                            width: size.width,
                            height: 32,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            padding: .only(left: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: .center,
                            child: Row(
                              crossAxisAlignment: .center,
                              children: [
                                // 左侧公告图标和文字
                                Image.asset(
                                  'assets/images/icon_notice.png',
                                  width: 24,
                                  height: 24,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.campaign,
                                      color: themeColor.primary,
                                      size: 24,
                                    );
                                  },
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '公告',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF333333),
                                    fontWeight: .bold,
                                    fontStyle: .italic,
                                  ),
                                ),
                                // 分隔线
                                Container(
                                  width: 1.5,
                                  height: 16,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  color: const Color(0xFFDDDDDD),
                                ),
                                // 公告内容 - 点击跳转详情
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _goNotice,
                                    child: Marquee(
                                      text: _notes,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF666666),
                                      ),
                                      scrollAxis: Axis.horizontal,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      blankSpace: 100.0,
                                      velocity: 100.0,
                                      pauseAfterRound: Duration(seconds: 1),
                                      startPadding: 0,
                                      accelerationDuration: Duration(
                                        seconds: 1,
                                      ),
                                      accelerationCurve: Curves.linear,
                                      decelerationDuration: Duration(
                                        milliseconds: 500,
                                      ),
                                      decelerationCurve: Curves.easeOut,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // 搜索栏
                      SliverToBoxAdapter(child: _buildSearchBar(themeColor)),

                      // 广告位 - 对应uni-app的APP-PLUS广告组件
                      if (_showAd)
                        SliverToBoxAdapter(child: _buildAdView())
                      else
                        // 广告关闭后添加间距，避免商品列表紧贴搜索栏
                        const SliverToBoxAdapter(child: SizedBox(height: 12)),

                      // 商品列表
                      _hotList.isEmpty
                          ? const SliverToBoxAdapter(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: Text(
                                    '暂无商品',
                                    style: TextStyle(color: Color(0xFF999999)),
                                  ),
                                ),
                              ),
                            )
                          : SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              sliver: SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                      // 宽高比调整：图片169px + 文字区域约70px = 239px
                                      // 宽度约170px，比例 170/239 ≈ 0.71
                                      childAspectRatio: 0.68,
                                    ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => HomeProductCard(
                                    product: _hotList[index],
                                    onTap: () =>
                                        _goGoodsDetail(_hotList[index].id),
                                  ),
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
                            _loadEnd
                                ? '我也是有底线的'
                                : (_loadingMore ? '加载中...' : ''),
                            style: const TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 12,
                            ),
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
      alignment: Alignment.centerLeft,
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
            child: Align(
              alignment: Alignment.centerLeft,
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
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
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
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  ),
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

  /// 搜索栏
  Widget _buildSearchBar(ThemeColorData themeColor) {
    return GestureDetector(
      onTap: _goSearch,
      child: Container(
        margin: const EdgeInsets.all(12),
        height: 35,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
        ),
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
              child: Text(
                '输入你想搜索的商品',
                style: TextStyle(color: Color(0xFFA6A6A6), fontSize: 13),
              ),
            ),
            const Text(
              '搜索',
              style: TextStyle(color: Color(0xFF444444), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  /// 广告位 - ZJSDK信息流广告
  Widget _buildAdView() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      child: ZJFeedAdWidget(
        width: MediaQuery.of(context).size.width - 24,
        // 不传height参数，使用自适应高度
        videoSoundEnable: false, // 静音，与uni-app一致
        onShow: () => debugPrint('信息流广告展示'),
        onClose: () {
          debugPrint('信息流广告关闭');
          setState(() {
            _showAd = false; // 广告关闭后隐藏
          });
        },
        onError: (error) {
          debugPrint('信息流广告错误: $error');
          setState(() {
            _showAd = false; // 广告加载失败也隐藏
          });
        },
      ),
    );
  }
}
