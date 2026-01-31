import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/data/providers/api_provider.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/theme/theme_colors.dart';
import 'package:shuhang_mall_flutter/widgets/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 商品详情页
/// 对应原 pages/goods_details/index.vue
class GoodsDetailPage extends StatefulWidget {
  const GoodsDetailPage({super.key});

  @override
  State<GoodsDetailPage> createState() => _GoodsDetailPageState();
}

class _GoodsDetailPageState extends State<GoodsDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showTopBar = false;
  int _currentTabIndex = 0;

  // 商品ID
  int _productId = 0;
  // 是否加载中
  bool _isLoading = true;
  // 错误信息
  String? _errorMsg;

  // 商品数据
  Map<String, dynamic> _product = {};
  // 商品详情描述(HTML)
  String _description = '';
  // 商品属性
  List<dynamic> _productAttr = [];
  // 商品规格值
  Map<String, dynamic> _productValue = {};
  // 评论列表
  List<Map<String, dynamic>> _reviews = [];
  // 评论数量
  int _replyCount = 0;
  // 优惠券列表
  List<dynamic> _couponList = [];
  // 活动列表
  // ignore: unused_field
  List<dynamic> _activity = [];
  // 购物车数量
  int _cartCount = 0;
  // 是否已是付费会员
  bool _isMoneyLevel = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    
    // 获取商品ID参数 - 支持两种传参方式
    // 1. arguments: Get.toNamed(route, arguments: {'id': id})
    // 2. parameters: Get.toNamed(route, parameters: {'id': id.toString()})
    final argId = Get.arguments?['id'];
    final paramId = Get.parameters['id'];
    _productId = int.tryParse(argId?.toString() ?? paramId ?? '0') ?? 0;
    
    debugPrint('商品详情页 - 获取到的ID: $_productId (arguments: $argId, parameters: $paramId)');
    
    // 加载商品详情
    _loadProductDetail();
    // 获取购物车数量
    _getCartCount();
    // 获取用户会员信息
    _getUserInfo();
  }

  /// 获取购物车数量
  Future<void> _getCartCount() async {
    try {
      final response = await ApiProvider.instance.get('cart/count');
      if (response.isSuccess && response.data != null) {
        setState(() {
          _cartCount = response.data['count'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('获取购物车数量失败: $e');
    }
  }

  /// 计算VIP节省金额
  String _calculateSavings() {
    final price = double.tryParse(_product['price']?.toString() ?? '0') ?? 0;
    final vipPrice = double.tryParse(_product['vip_price']?.toString() ?? '0') ?? 0;
    final diff = price - vipPrice;
    return diff > 0 ? diff.toStringAsFixed(2) : '0';
  }

  /// 获取SKU图片列表
  List<String> _getSkuImages() {
    final List<String> images = [];
    _productValue.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final img = value['image']?.toString() ?? '';
        if (img.isNotEmpty && !images.contains(img)) {
          images.add(img);
        }
      }
    });
    return images;
  }

  /// 获取用户会员信息
  Future<void> _getUserInfo() async {
    try {
      final response = await ApiProvider.instance.get('user');
      if (response.isSuccess && response.data != null) {
        setState(() {
          _isMoneyLevel = response.data['is_money_level'] == 1;
        });
      }
    } catch (e) {
      debugPrint('获取用户信息失败: $e');
    }
  }

  /// 加载商品详情
  Future<void> _loadProductDetail() async {
    if (_productId <= 0) {
      setState(() {
        _isLoading = false;
        _errorMsg = '商品ID无效';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      debugPrint('正在请求商品详情: product/detail/$_productId');
      final response = await ApiProvider.instance.get(
        'product/detail/$_productId',
        noAuth: true,
      );
      debugPrint('商品详情响应: status=${response.status}, msg=${response.msg}');

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        setState(() {
          _product = data['storeInfo'] ?? {};
          _description = _product['description']?.toString() ?? '';
          _productAttr = (data['productAttr'] as List<dynamic>?) ?? [];
          // productValue 可能是 Map 或 List
          final pv = data['productValue'];
          if (pv is Map<String, dynamic>) {
            _productValue = pv;
          } else {
            _productValue = {};
          }
          // reply 可能是单个对象或列表
          final reply = data['reply'];
          if (reply is List) {
            _reviews = reply.whereType<Map<String, dynamic>>().toList();
          } else if (reply is Map<String, dynamic>) {
            _reviews = [reply];
          } else {
            _reviews = [];
          }
          _replyCount = data['replyCount'] ?? 0;
          _couponList = (data['coupons'] as List<dynamic>?) ?? [];
          _activity = (data['activity'] as List<dynamic>?) ?? [];
          _isLoading = false;
        });
        debugPrint('商品详情加载成功: ${_product['store_name']}');
      } else {
        setState(() {
          _isLoading = false;
          _errorMsg = response.msg.isNotEmpty ? response.msg : '加载失败';
        });
      }
    } catch (e) {
      debugPrint('商品详情请求异常: $e');
      setState(() {
        _isLoading = false;
        _errorMsg = '网络请求失败: $e';
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final showTopBar = _scrollController.offset > 200;
    if (showTopBar != _showTopBar) {
      setState(() {
        _showTopBar = showTopBar;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        final themeColor = controller.themeColor;

        // 加载中状态
        if (_isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text('商品详情'.tr),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // 错误状态
        if (_errorMsg != null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('商品详情'.tr),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMsg!, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadProductDetail,
                    child: Text('重新加载'.tr),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              // 主内容
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // 商品轮播图
                  SliverToBoxAdapter(child: _buildProductImages()),
                  // 商品信息
                  SliverToBoxAdapter(child: _buildProductInfo(themeColor)),
                  // Tab切换
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyTabBarDelegate(
                      tabController: _tabController,
                      themeColor: themeColor,
                      onTabChanged: (index) {
                        setState(() {
                          _currentTabIndex = index;
                        });
                      },
                    ),
                  ),
                  // Tab内容
                  SliverToBoxAdapter(child: _buildTabContent(themeColor)),
                ],
              ),
              // 顶部导航栏
              _buildAppBar(themeColor),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(themeColor),
        );
      },
    );
  }

  Widget _buildAppBar(ThemeColorData themeColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: _showTopBar ? Colors.white : Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              // 返回按钮
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _showTopBar
                        ? Colors.transparent
                        : Colors.black.withAlpha((0.3 * 255).round()),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: _showTopBar ? Colors.black : Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              // 分享按钮
              GestureDetector(
                onTap: _showShareDialog,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _showTopBar
                        ? Colors.transparent
                        : Colors.black.withAlpha((0.3 * 255).round()),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.share,
                    size: 18,
                    color: _showTopBar ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImages() {
    final images = (_product['slider_image'] as List<dynamic>?)?.cast<String>() ?? [];
    final videoLink = _product['video_link']?.toString() ?? '';
    
    if (images.isEmpty) {
      // 如果轮播图为空，尝试使用主图
      final mainImage = _product['image']?.toString() ?? '';
      if (mainImage.isNotEmpty) {
        return GestureDetector(
          onTap: () => _showImagePreview([mainImage], 0),
          child: Container(
            height: 375,
            color: const Color(0xFFF5F5F5),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: mainImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 375,
                  placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (_, __, ___) => const Center(
                    child: Icon(Icons.image, size: 80, color: Colors.grey),
                  ),
                ),
                if (videoLink.isNotEmpty) _buildVideoPlayButton(videoLink),
              ],
            ),
          ),
        );
      }
      return Container(
        height: 375,
        color: const Color(0xFFF5F5F5),
        child: const Center(child: Icon(Icons.image, size: 80, color: Colors.grey)),
      );
    }

    return Stack(
      children: [
        ProductSwiper(
          images: images,
          height: 375,
          onTap: (index) => _showImagePreview(images, index),
        ),
        if (videoLink.isNotEmpty) _buildVideoPlayButton(videoLink),
      ],
    );
  }

  /// 视频播放按钮
  Widget _buildVideoPlayButton(String videoLink) {
    return Positioned(
      left: 15,
      bottom: 50,
      child: GestureDetector(
        onTap: () => _playVideo(videoLink),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(150),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_circle_outline, size: 20, color: Colors.white),
              SizedBox(width: 4),
              Text('播放视频', style: TextStyle(fontSize: 12, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  /// 播放视频
  void _playVideo(String videoLink) {
    Get.to(
      () => _VideoPlayerPage(videoUrl: videoLink),
      fullscreenDialog: true,
    );
  }

  /// 显示图片预览
  void _showImagePreview(List<String> images, int initialIndex) {
    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: CachedNetworkImageProvider(images[index]),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                );
              },
              itemCount: images.length,
              pageController: PageController(initialPage: initialIndex),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
            ),
            Positioned(
              top: MediaQuery.of(Get.context!).padding.top + 10,
              right: 15,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(128),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
      fullscreenDialog: true,
    );
  }

  Widget _buildProductInfo(ThemeColorData themeColor) {
    final price = _product['price']?.toString() ?? '0.00';
    final otPrice = _product['ot_price']?.toString() ?? '';
    final storeName = _product['store_name']?.toString() ?? '';
    final sales = _product['fsales'] ?? _product['sales'] ?? 0;
    final stock = _product['stock'] ?? 0;
    final unitName = _product['unit_name']?.toString() ?? '件';
    final giveIntegral = _product['give_integral'] ?? 0;
    // VIP相关
    final vipPrice = _product['vip_price'];
    final isVip = _product['is_vip'] == 1;
    final specType = _product['spec_type'] == 1;
    // 限购
    final limitType = _product['limit_type'] ?? 0;
    final limitNum = _product['limit_num'] ?? 0;
    // 预售
    final presale = _product['presale'] == true;
    final presaleStartTime = _product['presale_start_time']?.toString() ?? '';
    final presaleEndTime = _product['presale_end_time']?.toString() ?? '';
    final presaleDay = _product['presale_day'] ?? 0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 价格行
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('swp', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: themeColor.price)),
              Text(price, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: themeColor.price)),
              if (specType) Text('起', style: TextStyle(fontSize: 14, color: themeColor.price)),
              // VIP价格
              if (vipPrice != null && (vipPrice is num && vipPrice > 0) && isVip) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('swp$vipPrice', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
              if (otPrice.isNotEmpty && otPrice != '0.00') ...[
                const SizedBox(width: 8),
                Text('swp$otPrice', style: const TextStyle(fontSize: 14, color: Color(0xFF999999), decoration: TextDecoration.lineThrough)),
              ],
            ],
          ),
          const SizedBox(height: 10),
          // 商品名称
          Text(storeName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
          // 限购信息
          if (limitType > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: themeColor.primary.withAlpha(25), borderRadius: BorderRadius.circular(4)),
              child: Text('${limitType == 1 ? "单次限购" : "永久限购"}$limitNum$unitName', style: TextStyle(fontSize: 12, color: themeColor.primary)),
            ),
          ],
          const SizedBox(height: 8),
          // SVIP开通入口
          if (vipPrice != null && (vipPrice is num && vipPrice > 0) && isVip && !_isMoneyLevel) ...[
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.vipPaid),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.card_membership, size: 18, color: Color(0xFFFF8800)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '开通"超级会员"立省${_calculateSavings()}元',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
                      ),
                    ),
                    const Text('立即开通', style: TextStyle(fontSize: 12, color: Color(0xFFFF8800))),
                    const Icon(Icons.chevron_right, size: 16, color: Color(0xFFFF8800)),
                  ],
                ),
              ),
            ),
          ],
          // 销量等信息
          Row(
            children: [
              if (giveIntegral > 0) ...[
                Text(
                  '送消费券: $giveIntegral',
                  style: TextStyle(fontSize: 12, color: themeColor.primary),
                ),
                const SizedBox(width: 20),
              ],
              Text(
                '已售$sales$unitName',
                style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
              const SizedBox(width: 20),
              Text(
                '库存$stock',
                style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
            ],
          ),
          // 优惠券
          if (_couponList.isNotEmpty) ...[
            const SizedBox(height: 15),
            GestureDetector(
              onTap: _showCouponDialog,
              child: Row(
                children: [
                  const Text('优惠券', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: _couponList.take(2).map((coupon) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: themeColor.primary.withAlpha((0.1 * 255).round()),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '满${coupon['use_min_price']}减${coupon['coupon_price']}',
                            style: TextStyle(fontSize: 12, color: themeColor.primary),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 20, color: Color(0xFF999999)),
                ],
              ),
            ),
          ],
          // 活动入口
          if (_activity.isNotEmpty) ...[
            const SizedBox(height: 15),
            Row(
              children: [
                const Text('活动', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
                const SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    children: _activity.map((item) {
                      final type = item['type']?.toString() ?? '';
                      String label = '';
                      Color bgColor = themeColor.primary;
                      if (type == '1') {
                        label = '参与秒杀';
                        bgColor = const Color(0xFFFF4444);
                      } else if (type == '2') {
                        label = '参与砍价';
                        bgColor = const Color(0xFFFF8800);
                      } else if (type == '3') {
                        label = '参与拼团';
                        bgColor = const Color(0xFF00BB00);
                      }
                      return GestureDetector(
                        onTap: () => _goActivity(item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
                          child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
          // 预售信息
          if (presale) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Color(0xFFFF8800)),
                      const SizedBox(width: 4),
                      const Text('预售活动时间：', style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
                    ],
                  ),
                  if (presaleStartTime.isNotEmpty && presaleEndTime.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('$presaleStartTime ~ $presaleEndTime', style: const TextStyle(fontSize: 12, color: Color(0xFF333333))),
                  ],
                  const SizedBox(height: 4),
                  Text('预售结束后 $presaleDay 天内发货', style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 15),
          const Divider(height: 1),
          const SizedBox(height: 15),
          // 规格选择
          GestureDetector(
            onTap: _showSpecDialog,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('选择', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _productAttr.isEmpty ? '该商品无规格' : '请选择规格',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 20, color: Color(0xFF999999)),
                  ],
                ),
                // SKU缩略图预览
                if (_productValue.isNotEmpty && _productValue.length > 1) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(width: 42),
                      Expanded(
                        child: Row(
                          children: [
                            ..._getSkuImages().take(4).map((img) => Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: CachedNetworkImage(
                                  imageUrl: img,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Container(
                                    width: 40, height: 40,
                                    color: const Color(0xFFEEEEEE),
                                  ),
                                ),
                              ),
                            )),
                            Text('共${_productValue.length}种规格可选', style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(ThemeColorData themeColor) {
    switch (_currentTabIndex) {
      case 0:
        return _buildProductDetail();
      case 1:
        return _buildProductParams();
      case 2:
        return _buildProductReviews();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildProductDetail() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('商品详情', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          if (_description.isEmpty)
            Container(
              height: 200,
              color: const Color(0xFFF5F5F5),
              alignment: Alignment.center,
              child: const Text('暂无商品详情', style: TextStyle(color: Colors.grey)),
            )
          else
            Html(
              data: _description,
              style: {
                'img': Style(
                  width: Width(100, Unit.percent),
                  height: Height.auto(),
                  display: Display.block,
                ),
                'video': Style(
                  width: Width(100, Unit.percent),
                  height: Height(300),
                  display: Display.block,
                ),
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProductParams() {
    // 从商品属性中提取规格参数
    final storeName = _product['store_name']?.toString() ?? '';
    final unitName = _product['unit_name']?.toString() ?? '';
    final stock = _product['stock']?.toString() ?? '0';
    final sales = (_product['fsales'] ?? _product['sales'] ?? 0).toString();
    final cateId = _product['cate_id']?.toString() ?? '';
    
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('规格参数', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          if (storeName.isNotEmpty) _buildParamRow('商品名称', storeName),
          if (unitName.isNotEmpty) _buildParamRow('计量单位', unitName),
          _buildParamRow('库存', stock),
          _buildParamRow('销量', sales),
          if (cateId.isNotEmpty) _buildParamRow('分类ID', cateId),
          // 显示商品规格属性
          if (_productAttr.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text('商品规格', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF666666))),
            const SizedBox(height: 10),
            ..._productAttr.map((attr) {
              final attrName = attr['attr_name']?.toString() ?? '';
              final attrValues = (attr['attr_values'] as List<dynamic>?)?.join('、') ?? '';
              return _buildParamRow(attrName, attrValues);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildParamRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF999999))),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF333333))),
          ),
        ],
      ),
    );
  }

  Widget _buildProductReviews() {
    return GetBuilder<AppController>(
      builder: (controller) {
        final themeColor = controller.themeColor;
        
        if (_reviews.isEmpty) {
          return Container(
            color: Colors.white,
            padding: const EdgeInsets.all(50),
            child: Column(
              children: [
                EmptyPage(title: '暂无评价'.tr),
                const SizedBox(height: 20),
                // 查看全部评价按钮
                if (_replyCount > 0)
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.goodsCommentList, arguments: {'id': _productId}),
                    child: Text('查看全部$_replyCount条评价', style: TextStyle(color: themeColor.primary)),
                  ),
              ],
            ),
          );
        }

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 评价头部
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('用户评价($_replyCount)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  if (_replyCount > 1)
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.goodsCommentList, arguments: {'id': _productId}),
                      child: Row(
                        children: [
                          Text('查看全部', style: TextStyle(fontSize: 14, color: themeColor.primary)),
                          Icon(Icons.chevron_right, size: 18, color: themeColor.primary),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 15),
              // 评价列表
              ..._reviews.map((review) => _buildReviewItem(review)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    final avatar = review['avatar']?.toString() ?? '';
    final nickname = review['nickname']?.toString() ?? '匿名用户';
    final comment = review['comment']?.toString() ?? '';
    final pics = (review['pics'] as List<dynamic>?)?.cast<String>() ?? [];
    final addTime = review['add_time']?.toString() ?? '';
    final star = review['star'] ?? 5;
    final sku = review['suk']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息行
          Row(
            children: [
              // 头像
              ClipOval(
                child: avatar.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: avatar,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          width: 36,
                          height: 36,
                          color: const Color(0xFFEEEEEE),
                          child: const Icon(Icons.person, size: 20, color: Colors.grey),
                        ),
                      )
                    : Container(
                        width: 36,
                        height: 36,
                        color: const Color(0xFFEEEEEE),
                        child: const Icon(Icons.person, size: 20, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nickname, style: const TextStyle(fontSize: 14, color: Color(0xFF333333))),
                    const SizedBox(height: 2),
                    // 星级评分
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < star ? Icons.star : Icons.star_border,
                          size: 14,
                          color: const Color(0xFFFFB800),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Text(addTime, style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
            ],
          ),
          const SizedBox(height: 10),
          // 规格
          if (sku.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('规格：$sku', style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
            ),
          // 评价内容
          Text(comment, style: const TextStyle(fontSize: 14, color: Color(0xFF333333), height: 1.5)),
          // 评价图片
          if (pics.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: pics.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _showImagePreview(pics, entry.key),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: entry.value,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeColorData themeColor) {
    final isCollect = _product['userCollect'] == true;
    final stock = _product['stock'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // 首页
            _buildBottomIcon(Icons.home_outlined, '首页', _goHome),
            const SizedBox(width: 15),
            // 客服
            _buildBottomIcon(Icons.headset_mic_outlined, '客服', _goCustomerService),
            const SizedBox(width: 15),
            // 收藏
            _buildBottomIcon(
              isCollect ? Icons.favorite : Icons.favorite_border,
              '收藏',
              _toggleCollect,
              color: isCollect ? themeColor.primary : null,
            ),
            const SizedBox(width: 15),
            // 购物车（带数量角标）
            _buildCartIcon(themeColor),
            const Spacer(),
            // 加入购物车
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: stock > 0 ? () => _showSpecDialog(mode: ProductSpecMode.addCart) : null,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: stock > 0
                        ? LinearGradient(colors: [themeColor.gradientStart, themeColor.gradientEnd])
                        : null,
                    color: stock <= 0 ? Colors.grey : null,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(22)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '加入购物车',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
            ),
            // 立即购买
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: stock > 0 ? () => _showSpecDialog(mode: ProductSpecMode.buyNow) : null,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: stock > 0 ? themeColor.primary : Colors.grey,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(22)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    stock > 0 ? '立即购买' : '已售罄',
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 切换收藏状态
  Future<void> _toggleCollect() async {
    final isCollect = _product['userCollect'] == true;
    final productId = _product['id'];
    
    if (productId == null) return;

    try {
      ApiResponse response;
      if (isCollect) {
        // 取消收藏
        response = await ApiProvider.instance.post(
          'collect/del',
          data: {'id': [productId], 'category': 'product'},
        );
      } else {
        // 添加收藏
        response = await ApiProvider.instance.post(
          'collect/add',
          data: {'id': productId, 'product': 'product'},
        );
      }

      if (response.isSuccess) {
        setState(() {
          _product['userCollect'] = !isCollect;
        });
        Get.snackbar('提示', response.msg.isNotEmpty ? response.msg : (isCollect ? '取消收藏' : '收藏成功'));
      } else {
        Get.snackbar('提示', response.msg.isNotEmpty ? response.msg : '操作失败');
      }
    } catch (e) {
      Get.snackbar('提示', '网络请求失败');
    }
  }

  Widget _buildBottomIcon(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: color ?? const Color(0xFF666666)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF666666))),
        ],
      ),
    );
  }

  /// 购物车图标（带数量角标）
  Widget _buildCartIcon(ThemeColorData themeColor) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.cart),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart_outlined, size: 22, color: Color(0xFF666666)),
              if (_cartCount > 0)
                Positioned(
                  top: -5,
                  right: -8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: themeColor.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      _cartCount > 99 ? '99+' : '$_cartCount',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          const Text('购物车', style: TextStyle(fontSize: 10, color: Color(0xFF666666))),
        ],
      ),
    );
  }

  /// 跳转首页
  void _goHome() {
    Get.offAllNamed(AppRoutes.main);
  }

  /// 跳转活动页面
  void _goActivity(dynamic item) {
    final type = item['type']?.toString() ?? '';
    final id = item['id'];
    if (id == null) return;
    if (type == '1') {
      Get.toNamed(AppRoutes.seckillDetail, arguments: {'id': id, 'time': item['time'], 'status': 1});
    } else if (type == '2') {
      Get.toNamed(AppRoutes.bargainDetail, arguments: {'id': id});
    } else if (type == '3') {
      Get.toNamed(AppRoutes.groupBuyDetail, arguments: {'id': id});
    }
  }

  /// 跳转客服
  void _goCustomerService() {
    Get.toNamed(AppRoutes.chat, arguments: {'productId': _productId});
  }

  /// 显示分享弹窗
  void _showShareDialog() {
    final storeName = _product['store_name']?.toString() ?? '';
    
    Get.bottomSheet(
      GetBuilder<AppController>(
        builder: (controller) {
          final themeColor = controller.themeColor;
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('分享商品', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: const Icon(Icons.close, size: 24, color: Color(0xFF999999)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // 分享选项
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // 复制链接
                        _buildShareItem(
                          icon: Icons.link,
                          label: '复制链接',
                          color: themeColor.primary,
                          onTap: () {
                            final shareUrl = 'https://test.shsd.top/pages/goods_details/index?id=$_productId';
                            Clipboard.setData(ClipboardData(text: shareUrl));
                            Get.back();
                            Get.snackbar('成功', '链接已复制到剪贴板');
                          },
                        ),
                        // 分享
                        _buildShareItem(
                          icon: Icons.share,
                          label: '分享',
                          color: Colors.green,
                          onTap: () {
                            Get.back();
                            final shareText = '$storeName\nhttps://test.shsd.top/pages/goods_details/index?id=$_productId';
                            Clipboard.setData(ClipboardData(text: shareText));
                            Get.snackbar('成功', '分享内容已复制到剪贴板');
                          },
                        ),
                        // 生成海报
                        _buildShareItem(
                          icon: Icons.image,
                          label: '生成海报',
                          color: Colors.orange,
                          onTap: () {
                            Get.back();
                            _showPosterDialog();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildShareItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
        ],
      ),
    );
  }

  /// 显示优惠券弹窗
  void _showCouponDialog() {
    Get.bottomSheet(
      GetBuilder<AppController>(
        builder: (controller) {
          final themeColor = controller.themeColor;
          return Container(
            height: MediaQuery.of(Get.context!).size.height * 0.6,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                // 标题
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('优惠券', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: const Icon(Icons.close, size: 24, color: Color(0xFF999999)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // 优惠券列表
                Expanded(
                  child: _couponList.isEmpty
                      ? Center(child: Text('暂无可用优惠券'.tr, style: const TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _couponList.length,
                          itemBuilder: (context, index) {
                            final coupon = _couponList[index];
                            return _buildCouponItem(coupon, themeColor);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildCouponItem(dynamic coupon, ThemeColorData themeColor) {
    final couponPrice = coupon['coupon_price']?.toString() ?? '0';
    final useMinPrice = coupon['use_min_price']?.toString() ?? '0';
    final couponTitle = coupon['coupon_title']?.toString() ?? '';
    final isUse = coupon['is_use'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: themeColor.primary.withAlpha(50)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 左侧金额
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: themeColor.primary.withAlpha(25),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(7)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('swp', style: TextStyle(fontSize: 12, color: themeColor.primary)),
                    Text(couponPrice, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: themeColor.primary)),
                  ],
                ),
                Text('满$useMinPrice可用', style: TextStyle(fontSize: 10, color: themeColor.primary)),
              ],
            ),
          ),
          // 右侧信息
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(couponTitle.isNotEmpty ? couponTitle : '满减优惠券', 
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('满$useMinPrice元可用', style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                ],
              ),
            ),
          ),
          // 领取按钮
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: isUse > 0 ? null : () => _receiveCoupon(coupon),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isUse > 0 ? Colors.grey : themeColor.primary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  isUse > 0 ? '已领取' : '领取',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 领取优惠券
  Future<void> _receiveCoupon(dynamic coupon) async {
    final couponId = coupon['id'];
    if (couponId == null) return;

    try {
      final response = await ApiProvider.instance.post(
        'coupon/receive/$couponId',
      );

      if (response.isSuccess) {
        // 更新优惠券状态
        setState(() {
          coupon['is_use'] = 1;
        });
        Get.snackbar('成功', response.msg.isNotEmpty ? response.msg : '领取成功');
      } else {
        Get.snackbar('提示', response.msg.isNotEmpty ? response.msg : '领取失败');
      }
    } catch (e) {
      Get.snackbar('提示', '网络请求失败');
    }
  }

  /// 显示海报弹窗
  void _showPosterDialog() {
    final storeName = _product['store_name']?.toString() ?? '';
    final price = _product['price']?.toString() ?? '0';
    final image = _product['image']?.toString() ?? '';
    
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 海报预览
              Container(
                width: 260,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    // 商品图片
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: image.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: image,
                              width: 230,
                              height: 230,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                width: 230, height: 230,
                                color: const Color(0xFFEEEEEE),
                                child: const Icon(Icons.image, size: 60, color: Colors.grey),
                              ),
                            )
                          : Container(
                              width: 230, height: 230,
                              color: const Color(0xFFEEEEEE),
                              child: const Icon(Icons.image, size: 60, color: Colors.grey),
                            ),
                    ),
                    const SizedBox(height: 12),
                    // 商品名称
                    Text(
                      storeName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // 价格
                    Row(
                      children: [
                        Text('swp', style: TextStyle(fontSize: 12, color: Colors.red)),
                        Text(price, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 二维码区域
                    Row(
                      children: [
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFEEEEEE)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.qr_code, size: 50, color: Colors.grey),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('长按或扫描二维码\n查看商品详情', style: TextStyle(fontSize: 11, color: Color(0xFF999999))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 操作按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('取消', style: TextStyle(color: Color(0xFF999999))),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.snackbar('提示', '海报已保存到相册');
                    },
                    child: const Text('保存海报'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSpecDialog({ProductSpecMode mode = ProductSpecMode.addCart}) async {
    // 转换商品规格数据
    final List<Map<String, dynamic>> skuList = [];
    _productValue.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        skuList.add({
          'suk': key,
          ...value,
        });
      }
    });

    final result = await ProductSpecDialog.show(
      product: _product,
      attrs: _productAttr.cast<Map<String, dynamic>>(),
      skus: skuList,
      mode: mode,
    );

    if (result != null) {
      if (mode == ProductSpecMode.buyNow) {
        // 立即购买 - 先加入购物车再跳转
        await _addToCart(result, isNew: true);
      } else {
        // 加入购物车
        await _addToCart(result, isNew: false);
      }
    }
  }

  /// 加入购物车
  Future<void> _addToCart(Map<String, dynamic> specResult, {bool isNew = false}) async {
    final productId = _product['id'];
    if (productId == null) return;

    try {
      final response = await ApiProvider.instance.post(
        'cart/add',
        data: {
          'productId': productId,
          'cartNum': specResult['cart_num'] ?? 1,
          'new': isNew ? 1 : 0,
          'uniqueId': specResult['unique'] ?? '',
          'virtual_type': _product['virtual_type'] ?? 0,
        },
      );

      if (response.isSuccess) {
        if (isNew) {
          // 立即购买 - 跳转到订单确认页
          final cartId = response.data?['cartId'];
          Get.toNamed(AppRoutes.orderConfirm, arguments: {'cartId': cartId, 'new': 1});
        } else {
          Get.snackbar('成功', '已加入购物车');
        }
      } else {
        Get.snackbar('提示', response.msg.isNotEmpty ? response.msg : '加入购物车失败');
      }
    } catch (e) {
      Get.snackbar('提示', '网络请求失败');
    }
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final dynamic themeColor;
  final Function(int) onTabChanged;

  _StickyTabBarDelegate({
    required this.tabController,
    required this.themeColor,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        labelColor: themeColor.primary,
        unselectedLabelColor: const Color(0xFF666666),
        indicatorColor: themeColor.primary,
        indicatorSize: TabBarIndicatorSize.label,
        onTap: onTabChanged,
        tabs: const [
          Tab(text: '商品详情'),
          Tab(text: '规格参数'),
          Tab(text: '用户评价'),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

/// 视频播放页面
class _VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  const _VideoPlayerPage({required this.videoUrl});

  @override
  State<_VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<_VideoPlayerPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('视频播放'),
        elevation: 0,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam, size: 80, color: Colors.white54),
                  const SizedBox(height: 20),
                  const Text('视频播放功能', style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 10),
                  Text(
                    widget.videoUrl,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      // 使用系统浏览器打开视频
                      Get.snackbar('提示', '请在浏览器中播放视频');
                    },
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('在浏览器中打开'),
                  ),
                ],
              ),
      ),
    );
  }
}
