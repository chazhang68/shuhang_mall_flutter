import 'package:chat_context_menu/chat_context_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/controllers/cart_store.dart';
import 'package:shuhang_mall_flutter/app/data/models/product_detail_model.dart';
import 'package:shuhang_mall_flutter/app/data/providers/order_provider.dart';
import 'package:shuhang_mall_flutter/app/data/providers/public_provider.dart';
import 'package:shuhang_mall_flutter/app/data/providers/store_provider.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/theme/theme_colors.dart';
import 'package:shuhang_mall_flutter/app/services/wechat_service.dart';
import 'package:shuhang_mall_flutter/widgets/widgets.dart';
import 'package:shuhang_mall_flutter/widgets/coupon_tag.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 商品详情页
/// 对应原 pages/goods_details/index.vue
class GoodsDetailPage extends StatefulWidget {
  const GoodsDetailPage({super.key});

  @override
  State<GoodsDetailPage> createState() => _GoodsDetailPageState();
}

class _GoodsDetailPageState extends State<GoodsDetailPage> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  // 商品ID
  int _productId = 0;

  // 是否加载中
  bool _isLoading = true;

  // 错误信息
  String? _errorMsg;

  // 各个区域的 GlobalKey，用于滚动定位
  final GlobalKey _productInfoKey = GlobalKey();
  final GlobalKey _productDetailKey = GlobalKey();
  final GlobalKey _productReviewKey = GlobalKey();

  // 导航列表
  List<String> _navList = [];

  // 各个区域的位置信息

  final StoreProvider _storeProvider = StoreProvider();
  final OrderProvider _orderProvider = OrderProvider();
  final PublicProvider _publicProvider = PublicProvider();
  final UserProvider _userProvider = UserProvider();

  // 商品数据
  ProductStoreInfo? _productInfo;

  // 商品详情描述(HTML)
  String _description = '';

  // 商品属性
  List<ProductAttr> _productAttr = [];

  // 商品规格值
  Map<String, ProductSku> _productValue = {};

  // 评论列表
  List<ProductReply> _reviews = [];

  // 评论数量
  int _replyCount = 0;

  // 优惠券列表
  List<ProductCoupon> _couponList = [];

  // 活动列表
  // ignore: unused_field
  List<ProductActivity> _activity = [];

  // 购物车数量
  int _cartCount = 0;

  // 是否已是付费会员
  bool _isMoneyLevel = false;

  ProductStoreInfo get _storeInfo => _productInfo ?? ProductStoreInfo.empty();

  bool get _hasSpec => _productAttr.isNotEmpty && _productValue.isNotEmpty;

  @override
  void initState() {
    super.initState();
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
      final controller = Get.find<AppController>();
      final response = await _orderProvider.getCartCount();
      if (response.isSuccess && response.data != null) {
        final count = response.data!.count;
        setState(() {
          _cartCount = count;
        });
        await controller.updateCartNum(count);
      }
    } catch (e) {
      debugPrint('获取购物车数量失败: $e');
    }
  }

  /// 计算VIP节省金额
  String _calculateSavings() {
    final price = double.tryParse(_storeInfo.price) ?? 0;
    final vipPrice = double.tryParse(_storeInfo.vipPrice) ?? 0;
    final diff = price - vipPrice;
    return diff > 0 ? diff.toStringAsFixed(2) : '0';
  }

  /// 获取SKU图片列表
  List<String> _getSkuImages() {
    final List<String> images = [];
    for (final sku in _productValue.values) {
      final img = sku.image;
      if (img.isNotEmpty && !images.contains(img)) {
        images.add(img);
      }
    }
    return images;
  }

  /// 获取用户会员信息
  Future<void> _getUserInfo() async {
    try {
      final response = await _userProvider.getUserInfo();
      if (response.isSuccess && response.data != null) {
        setState(() {
          _isMoneyLevel = response.data!.isVip;
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
      final response = await _storeProvider.getProductDetailModel(_productId);
      debugPrint('商品详情响应: status=${response.status}, msg=${response.msg}');

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        setState(() {
          _productInfo = data.storeInfo;
          _description = _normalizeHtml(data.storeInfo.description);
          _productAttr = data.productAttr;
          _productValue = data.productValue;
          _reviews = data.reply;
          _replyCount = data.replyCount;
          _couponList = data.coupons;
          _activity = data.activity;
          _isLoading = false;

          // 构建导航列表（与 uni-app 一致）
          _navList = ['商品'.tr, '详情'.tr];
          if (_replyCount > 0) {
            _navList.insert(1, '评价'.tr);
          }
        });
        debugPrint('商品详情加载成功: ${data.storeInfo.storeName}');

        // 延迟计算区域位置
        Future.delayed(const Duration(milliseconds: 500), () {
          _calculateSectionOffsets();
        });
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
    _scrollController.dispose();
    super.dispose();
  }

  /// 计算各个区域的位置
  void _calculateSectionOffsets() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final offsets = <double>[];

      // 商品信息区域
      final productInfoContext = _productInfoKey.currentContext;
      if (productInfoContext != null) {
        final RenderBox box = productInfoContext.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        offsets.add(position.dy + _scrollController.offset);
      }

      // 商品详情区域
      final productDetailContext = _productDetailKey.currentContext;
      if (productDetailContext != null) {
        final RenderBox box = productDetailContext.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        offsets.add(position.dy + _scrollController.offset);
      }

      // 评价区域
      final productReviewContext = _productReviewKey.currentContext;
      if (productReviewContext != null) {
        final RenderBox box = productReviewContext.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        offsets.add(position.dy + _scrollController.offset);
      }

      if (mounted) {
        setState(() {});
      }
    });
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
                  ElevatedButton(onPressed: _loadProductDetail, child: Text('重新加载'.tr)),
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
                  // 商品信息区域（带 key）
                  SliverToBoxAdapter(
                    child: Container(key: _productInfoKey, child: _buildProductInfo(themeColor)),
                  ),
                  // 商品详情区域（带 key）
                  SliverToBoxAdapter(
                    child: Container(key: _productDetailKey, child: _buildProductDetail()),
                  ),
                  // 评价区域（带 key）
                  if (_replyCount > 0)
                    SliverToBoxAdapter(
                      child: Container(key: _productReviewKey, child: _buildProductReviews()),
                    ),
                ],
              ),
              // 返回和更多按钮
              _buildTopButtons(),
              // 客服浮动按钮
              CustomerFloatButton(productId: _productId, visible: _productId > 0),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(themeColor),
        );
      },
    );
  }

  /// 返回和更多按钮
  Widget _buildTopButtons() {
    return SafeArea(
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
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: .circle,
                ),
                alignment: .center,
                child: Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
              ),
            ),
            const Spacer(),

            ChatContextMenuWrapper(
              backgroundColor: Colors.white,
              borderRadius: .circular(8),
              menuConstraints: BoxConstraints(maxWidth: 124),
              spacing: 0,
              horizontalMargin: 0,
              widgetBuilder: (BuildContext context, void Function() showMenu) {
                return GestureDetector(
                  onTap: showMenu,
                  behavior: .opaque,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: .circle,
                    ),
                    child: Icon(CupertinoIcons.ellipsis, size: 18, color: Colors.white),
                  ),
                );
              },
              menuBuilder: (BuildContext context, void Function() hideMenu) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _contextMenuItem(
                      icon: Icons.home_outlined,
                      label: "首页",
                      onTap: () {
                        hideMenu();
                        _goHome();
                      },
                    ),
                    Divider(indent: 24, height: 1),
                    _contextMenuItem(
                      icon: Icons.search,
                      label: "搜索",
                      onTap: () {
                        hideMenu();
                        Get.toNamed(AppRoutes.goodsSearch);
                      },
                    ),
                    Divider(indent: 24, height: 1),
                    _contextMenuItem(
                      icon: Icons.shopping_cart_outlined,
                      label: "购物车",
                      onTap: () {
                        hideMenu();
                        Get.offAllNamed(AppRoutes.main, arguments: {'tab': 3});
                      },
                    ),
                    Divider(indent: 24, height: 1),
                    _contextMenuItem(
                      icon: Icons.favorite_border,
                      label: "我的收藏",
                      onTap: () {
                        hideMenu();
                        Get.toNamed(AppRoutes.userCollection);
                      },
                    ),
                    Divider(indent: 24, height: 1),
                    _contextMenuItem(
                      icon: Icons.person_outline,
                      label: "个人中心",
                      onTap: () {
                        hideMenu();
                        Get.offAllNamed(AppRoutes.main, arguments: {'tab': 4});
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _contextMenuItem({required IconData icon, required String label, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: .symmetric(horizontal: 6, vertical: 8),
        child: Row(
          spacing: 12,
          children: [
            Icon(icon, size: 20),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 13), textAlign: .start),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImages() {
    final storeInfo = _storeInfo;
    final images = storeInfo.sliderImage;
    final videoLink = storeInfo.videoLink;

    if (images.isEmpty) {
      // 如果轮播图为空，尝试使用主图
      final mainImage = storeInfo.image;
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
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Center(child: Icon(Icons.image, size: 80, color: Colors.grey)),
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
      alignment: .center,
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
      child: GestureDetector(
        onTap: () => _playVideo(videoLink),
        child: Container(
          width: 56,
          height: 56,
          alignment: .center,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: .circle,
            border: .all(color: Colors.white, width: 1.5),
          ),
          child: Icon(Icons.play_arrow, size: 34, color: Colors.white),
        ),
      ),
    );
  }

  /// 播放视频
  void _playVideo(String videoLink) {
    Get.to(() => _VideoPlayerPage(videoUrl: videoLink), fullscreenDialog: true);
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
    final storeInfo = _storeInfo;
    final price = storeInfo.price;
    final storeName = storeInfo.storeName;
    final unitName = storeInfo.unitName;
    final giveIntegral = storeInfo.giveIntegral;
    // VIP相关
    final vipPrice = storeInfo.vipPrice;
    final vipPriceValue = double.tryParse(vipPrice) ?? 0;
    final isVip = storeInfo.isVip;
    final specType = storeInfo.specType;
    // 限购
    final limitType = storeInfo.limitType;
    final limitNum = storeInfo.limitNum;
    // 预售
    final presale = storeInfo.presale;
    final presaleStartTime = storeInfo.presaleStartTime;
    final presaleEndTime = storeInfo.presaleEndTime;
    final presaleDay = storeInfo.presaleDay;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 价格行（带分享按钮）- 与 uni-app 完全一致
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // const CouponTag(fontSize: 12),
                    Text(
                      '消费券',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeColor.price,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: themeColor.price,
                      ),
                    ),
                    if (specType) ...[
                      const SizedBox(width: 2),
                      Text('起', style: TextStyle(fontSize: 14, color: themeColor.price)),
                    ],
                    // VIP价格
                    if (vipPriceValue > 0 && isVip) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '消费券',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              vipPrice,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Image.asset(
                              'assets/images/svip.gif',
                              width: 16,
                              height: 16,
                              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // 分享按钮（与 uni-app 一致）
              GestureDetector(
                onTap: _showShareDialog,
                child: const Icon(Icons.open_in_new, size: 22, color: Color(0xFF666666)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 商品名称
          Text(
            storeName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          // 限购信息
          if (limitType > 0) ...[
            const SizedBox(height: 4),
            Text(
              '${limitType == 1 ? "单次限购" : "永久限购"}$limitNum$unitName',
              style: TextStyle(fontSize: 10, color: themeColor.primary),
            ),
          ],
          // 送消费券信息（与 uni-app 一致的位置）
          if (giveIntegral > 0) ...[
            const SizedBox(height: 12),
            Text('送消费券: $giveIntegral', style: TextStyle(fontSize: 12, color: themeColor.primary)),
          ],
          const SizedBox(height: 8),
          // SVIP开通入口（与 uni-app 一致的位置）
          if (vipPriceValue > 0 && isVip && !_isMoneyLevel) ...[
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
          // 预售信息（与 uni-app 一致的位置）
          if (presale) ...[
            const SizedBox(height: 8),
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
                      const Text(
                        '预售活动时间：',
                        style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                      ),
                    ],
                  ),
                  if (presaleStartTime.isNotEmpty && presaleEndTime.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '$presaleStartTime ~ $presaleEndTime',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '预售结束后 $presaleDay 天内发货',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                  ),
                ],
              ),
            ),
          ],
          if (vipPriceValue > 0 && isVip && !_isMoneyLevel) ...[
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
          // 优惠券（与 uni-app 一致的位置）
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
                            '满${coupon.useMinPrice}减${coupon.couponPrice}',
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
          // 优惠券（与 uni-app 一致的位置）
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
                            '满${coupon.useMinPrice}减${coupon.couponPrice}',
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
                      final type = item.type;
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
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            label,
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
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
                      const Text(
                        '预售活动时间：',
                        style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                      ),
                    ],
                  ),
                  if (presaleStartTime.isNotEmpty && presaleEndTime.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '$presaleStartTime ~ $presaleEndTime',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '预售结束后 $presaleDay 天内发货',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                  ),
                ],
              ),
            ),
          ],
          // 规格选择 - 只有有规格时才显示
          if (_hasSpec) ...[
            const SizedBox(height: 15),
            const Divider(height: 1),
            const SizedBox(height: 15),
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
                          '请选择规格',
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
                              ..._getSkuImages()
                                  .take(4)
                                  .map(
                                    (img) => Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: CachedNetworkImage(
                                          imageUrl: img,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) => Container(
                                            width: 40,
                                            height: 40,
                                            color: const Color(0xFFEEEEEE),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              Text(
                                '共${_productValue.length}种规格可选',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                              ),
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
        ],
      ),
    );
  }

  Widget _buildProductDetail() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey.shade200),
          ),
          // 产品介绍标题
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: const Text(
              '产品介绍',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF333333)),
            ),
          ),
          if (_description.isEmpty)
            Container(
              height: 200,
              color: const Color(0xFFF5F5F5),
              alignment: Alignment.center,
              child: const Text('暂无商品详情', style: TextStyle(color: Colors.grey)),
            )
          else
            HtmlWidget(
              _description,
              customStylesBuilder: (element) {
                if (element.localName == 'img') {
                  return {'width': '100%', 'height': 'auto', 'display': 'block'};
                }
                if (element.localName == 'video') {
                  return {'width': '100%', 'height': '300px', 'display': 'block'};
                }
                if (element.localName == 'body') {
                  return {'margin': '0', 'padding': '0'};
                }
                return null;
              },
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
                    onPressed: () =>
                        Get.toNamed(AppRoutes.goodsCommentList, arguments: {'id': _productId}),
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
                  Text(
                    '用户评价($_replyCount)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (_replyCount > 1)
                    GestureDetector(
                      onTap: () =>
                          Get.toNamed(AppRoutes.goodsCommentList, arguments: {'id': _productId}),
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

  Widget _buildReviewItem(ProductReply review) {
    final avatar = review.avatar;
    final nickname = review.nickname;
    final comment = review.comment;
    final pics = review.pics;
    final addTime = review.addTime;
    final star = review.star;
    final sku = review.sku;

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
                        errorWidget: (context, url, error) => Container(
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
              child: Text(
                '规格：$sku',
                style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
            ),
          // 评价内容
          Text(
            comment,
            style: const TextStyle(fontSize: 14, color: Color(0xFF333333), height: 1.5),
          ),
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
    final storeInfo = _storeInfo;
    final isCollect = storeInfo.userCollect;
    final stock = storeInfo.stock;
    final isOutOfStock = stock <= 0;
    final showCartButton = storeInfo.cartButton;
    final disabledColor = const Color(0xFFCCCCCC);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // 左侧图标组
            Row(
              spacing: 16,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 首页
                _buildBottomIcon(Icons.home_outlined, '首页', _goHome),
                // 收藏
                _buildBottomIcon(
                  isCollect ? Icons.favorite : Icons.favorite_border,
                  '收藏',
                  _toggleCollect,
                  color: isCollect ? themeColor.primary : null,
                ),
                // 购物车（带数量角标）
                _buildCartIcon(themeColor),
              ],
            ),
            const SizedBox(width: 20),
            // 加入购物车（根据 cartButton 字段决定是否显示）
            // 注意：库存不足时依然保持可点击状态（与uni-app一致）
            if (showCartButton)
              Expanded(
                child: GestureDetector(
                  onTap: () => _showSpecDialog(mode: ProductSpecMode.addCart),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [themeColor.gradientStart, themeColor.gradientEnd],
                      ),
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(20),
                        right: Radius.zero,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text('加入购物车', style: TextStyle(fontSize: 14, color: Colors.white)),
                  ),
                ),
              ),
            // 立即购买/已售罄
            Expanded(
              child: GestureDetector(
                onTap: isOutOfStock ? null : () => _showSpecDialog(mode: ProductSpecMode.buyNow),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: isOutOfStock ? disabledColor : themeColor.primary,
                    borderRadius: BorderRadius.horizontal(
                      left: showCartButton ? Radius.zero : const Radius.circular(20),
                      right: const Radius.circular(20),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isOutOfStock ? '已售罄' : '立即购买',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: showCartButton ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _normalizeHtml(String html) {
    if (html.isEmpty) return '';
    var normalized = html;
    normalized = normalized.replaceAllMapped(
      RegExp(r'<img([^>]*?)\s*/>'),
      (match) => '<img${match.group(1) ?? ''}>',
    );
    debugPrint(normalized);
    return normalized.trim();
  }

  /// 切换收藏状态
  Future<void> _toggleCollect() async {
    if (_productInfo == null) return;
    final storeInfo = _storeInfo;
    final isCollect = storeInfo.userCollect;
    final productId = storeInfo.id;

    try {
      final response = isCollect
          ? await _storeProvider.uncollectProduct(productId)
          : await _storeProvider.collectProduct(productId);

      if (response.isSuccess) {
        setState(() {
          _productInfo = storeInfo.copyWith(userCollect: !isCollect);
        });
        FlutterToastPro.showMessage(
          response.msg.isNotEmpty ? response.msg : (isCollect ? '取消收藏' : '收藏成功'),
        );
      } else {
        FlutterToastPro.showMessage(response.msg.isNotEmpty ? response.msg : '操作失败');
      }
    } catch (e) {
      FlutterToastPro.showMessage('网络请求失败');
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
  void _goActivity(ProductActivity item) {
    final type = item.type;
    final id = item.id;
    if (id <= 0) return;
    if (type == '1') {
      Get.toNamed(AppRoutes.seckillDetail, arguments: {'id': id, 'time': item.time, 'status': 1});
    } else if (type == '2') {
      Get.toNamed(AppRoutes.bargainDetail, arguments: {'id': id});
    } else if (type == '3') {
      Get.toNamed(AppRoutes.groupBuyDetail, arguments: {'id': id});
    }
  }

  /// 显示分享弹窗
  void _showShareDialog() {
    final storeName = _storeInfo.storeName;
    final storeDesc = _storeInfo.description;
    final smallImage = _storeInfo.image;
    final shareUrl = 'https://test.shsd.top/pages/goods_details/index?id=$_productId';

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 分享选项
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // 微信好友
                    _buildShareItem(
                      icon: Icons.wechat,
                      label: '微信好友',
                      color: const Color(0xFF07C160),
                      onTap: () async {
                        Get.back();
                        FlutterToastPro.showMessage('正在打开微信...');
                        try {
                          final success = await WechatService().shareWebPageToSession(
                            url: shareUrl,
                            title: storeName,
                            description: storeDesc,
                            thumbnail: smallImage,
                          );
                          if (!success) {
                            // 如果分享失败，复制到剪贴板作为备用方案
                            Clipboard.setData(ClipboardData(text: '$storeName\n$shareUrl'));
                            FlutterToastPro.showMessage('分享内容已复制到剪贴板');
                          }
                        } catch (e) {
                          debugPrint('分享异常: $e');
                          Clipboard.setData(ClipboardData(text: '$storeName\n$shareUrl'));
                          FlutterToastPro.showMessage('分享失败，内容已复制到剪贴板');
                        }
                      },
                    ),
                    // 微信朋友圈
                    _buildShareItem(
                      icon: Icons.camera_alt,
                      label: '微信朋友圈',
                      color: const Color(0xFF07C160),
                      onTap: () async {
                        Get.back();
                        FlutterToastPro.showMessage('正在打开微信...');
                        try {
                          final success = await WechatService().shareWebPageToTimeline(
                            url: shareUrl,
                            title: storeName,
                            description: storeDesc,
                            thumbnail: smallImage,
                          );
                          if (!success) {
                            // 如果分享失败，复制到剪贴板作为备用方案
                            Clipboard.setData(ClipboardData(text: '$storeName\n$shareUrl'));
                            FlutterToastPro.showMessage('分享内容已复制到剪贴板');
                          }
                        } catch (e) {
                          debugPrint('分享异常: $e');
                          Clipboard.setData(ClipboardData(text: '$storeName\n$shareUrl'));
                          FlutterToastPro.showMessage('分享失败，内容已复制到剪贴板');
                        }
                      },
                    ),
                    // 生成海报
                    _buildShareItem(
                      icon: Icons.image,
                      label: '生成海报',
                      color: const Color(0xFF1890FF),
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
                      const Text(
                        '优惠券',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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
                      ? Center(
                          child: Text('暂无可用优惠券'.tr, style: const TextStyle(color: Colors.grey)),
                        )
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

  Widget _buildCouponItem(ProductCoupon coupon, ThemeColorData themeColor) {
    final couponPrice = coupon.couponPrice;
    final useMinPrice = coupon.useMinPrice;
    final couponTitle = coupon.couponTitle;
    final isUse = coupon.isUse;

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
                    const CouponTag(fontSize: 10),
                    const SizedBox(width: 2),
                    Text(
                      couponPrice,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: themeColor.primary,
                      ),
                    ),
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
                  Text(
                    couponTitle.isNotEmpty ? couponTitle : '满减优惠券',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '满$useMinPrice元可用',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                  ),
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
  Future<void> _receiveCoupon(ProductCoupon coupon) async {
    final couponId = coupon.id;
    if (couponId <= 0) return;

    try {
      final response = await _publicProvider.receiveCoupon(couponId);

      if (response.isSuccess) {
        // 更新优惠券状态
        setState(() {
          final index = _couponList.indexWhere((item) => item.id == couponId);
          if (index != -1) {
            _couponList[index] = _couponList[index].copyWith(isUse: 1);
          }
        });
        FlutterToastPro.showMessage(response.msg.isNotEmpty ? response.msg : '领取成功');
      } else {
        FlutterToastPro.showMessage(response.msg.isNotEmpty ? response.msg : '领取失败');
      }
    } catch (e) {
      FlutterToastPro.showMessage('网络请求失败');
    }
  }

  /// 显示海报弹窗
  void _showPosterDialog() {
    final storeInfo = _storeInfo;
    final storeName = storeInfo.storeName;
    final price = storeInfo.price;
    final image = storeInfo.image;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
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
                              errorWidget: (context, url, error) => Container(
                                width: 230,
                                height: 230,
                                color: const Color(0xFFEEEEEE),
                                child: const Icon(Icons.image, size: 60, color: Colors.grey),
                              ),
                            )
                          : Container(
                              width: 230,
                              height: 230,
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
                        const CouponTag(fontSize: 10),
                        const SizedBox(width: 4),
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 二维码区域
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFEEEEEE)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.qr_code, size: 50, color: Colors.grey),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            '长按或扫描二维码\n查看商品详情',
                            style: TextStyle(fontSize: 11, color: Color(0xFF999999)),
                          ),
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
                      FlutterToastPro.showMessage('海报已保存到相册');
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
    if (!_hasSpec) {
      final defaultUnique = _productValue.values.isNotEmpty
          ? _productValue.values.first.unique
          : '';
      await _addToCart({
        'cart_num': 1,
        'unique': defaultUnique,
      }, isNew: mode == ProductSpecMode.buyNow);
      return;
    }
    // 转换商品规格数据
    final List<Map<String, dynamic>> skuList = [];
    _productValue.forEach((key, value) {
      skuList.add(value.toSpecMap(key));
    });

    final result = await ProductSpecDialog.show(
      product: _storeInfo.toSpecMap(),
      attrs: _productAttr.map((e) => e.toSpecMap()).toList(),
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
    if (_productInfo == null) return;
    final productId = _storeInfo.id;

    try {
      final response = await _orderProvider.addCart({
        'productId': productId,
        'cartNum': specResult['cart_num'] ?? 1,
        'new': isNew ? 1 : 0,
        'uniqueId': specResult['unique'] ?? '',
        'virtual_type': _storeInfo.virtualType,
      });

      if (response.isSuccess) {
        await _refreshCartState();
        if (isNew) {
          // 立即购买 - 跳转到订单确认页
          final cartId = response.data?.cartId;
          Get.toNamed(AppRoutes.orderConfirm, arguments: {'cartId': cartId, 'new': 1});
        } else {
          FlutterToastPro.showMessage('已加入购物车');
        }
      } else {
        FlutterToastPro.showMessage(response.msg.isNotEmpty ? response.msg : '加入购物车失败');
      }
    } catch (e) {
      FlutterToastPro.showMessage('网络请求失败');
    }
  }

  Future<void> _refreshCartState() async {
    await CartStore.instance.loadCartList();
    await _getCartCount();
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
  late final Player _player;
  late final VideoController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _player.open(Media(widget.videoUrl));
    _player.stream.playing.listen((playing) {
      if (mounted) {
        setState(() => _isLoading = !playing);
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
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
                children: [
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Video(controller: _controller),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }
}
