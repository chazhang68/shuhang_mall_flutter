import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../data/providers/activity_provider.dart';
import '../../data/providers/store_provider.dart';
import '../../theme/theme_colors.dart';

class PresellDetailPage extends StatefulWidget {
  const PresellDetailPage({super.key});

  @override
  State<PresellDetailPage> createState() => _PresellDetailPageState();
}

class _PresellDetailPageState extends State<PresellDetailPage> {
  final ActivityProvider _activityProvider = ActivityProvider();
  final StoreProvider _storeProvider = StoreProvider();
  final RefreshController _refreshController = RefreshController();
  final ScrollController _scrollController = ScrollController();

  int _id = 0;
  Map<String, dynamic> _storeInfo = {};
  List<String> _images = [];
  String _description = '';
  List<dynamic> _couponList = [];
  int _replyCount = 0;
  int _replyChance = 0;
  Map<String, dynamic> _reply = {};
  int _payStatus = 1; // 1-未开始 2-进行中 3-已结束
  bool _userCollect = false;

  Map<String, dynamic> _attr = {'cartAttr': false, 'productAttr': [], 'productSelect': {}};

  double _opacity = 0;
  final int _navActive = 0;
  final List<String> _navList = ['商品', '评价', '详情'];

  @override
  void initState() {
    super.initState();
    _id = int.tryParse(Get.parameters['id'] ?? '0') ?? 0;
    _scrollController.addListener(_onScroll);
    if (_id > 0) {
      _getPresellDetail();
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    double offset = _scrollController.offset;
    double newOpacity = (offset / 200).clamp(0.0, 1.0);
    if (newOpacity != _opacity) {
      setState(() {
        _opacity = newOpacity;
      });
    }
  }

  Future<void> _getPresellDetail() async {
    final response = await _activityProvider.getPresellDetail(_id);
    if (response.isSuccess && response.data != null) {
      setState(() {
        _storeInfo = response.data['storeInfo'] ?? {};
        _images = List<String>.from(_storeInfo['images'] ?? []);
        _description = response.data['description'] ?? '';
        _couponList = response.data['couponList'] ?? [];
        _replyCount = response.data['replyCount'] ?? 0;
        _replyChance = response.data['replyChance'] ?? 0;
        _reply = response.data['reply'] ?? {};
        _payStatus = response.data['pay_status'] ?? 1;
        _userCollect = _storeInfo['userCollect'] ?? false;
        _attr = {
          'cartAttr': false,
          'productAttr': response.data['productAttr'] ?? [],
          'productSelect': response.data['productSelect'] ?? {},
        };
      });
    }
    _refreshController.refreshCompleted();
  }

  void _setCollect() async {
    if (_userCollect) {
      final response = await _storeProvider.uncollectProduct(_storeInfo['product_id'] ?? 0);
      if (response.isSuccess) {
        setState(() {
          _userCollect = false;
        });
        FlutterToastPro.showMessage( '取消收藏成功');
      }
    } else {
      final response = await _storeProvider.collectProduct(_storeInfo['product_id'] ?? 0);
      if (response.isSuccess) {
        setState(() {
          _userCollect = true;
        });
        FlutterToastPro.showMessage( '收藏成功');
      }
    }
  }

  void _goBuy() {
    if (_payStatus == 1) {
      FlutterToastPro.showMessage( '活动未开始');
      return;
    }
    if (_payStatus == 3) {
      FlutterToastPro.showMessage( '活动已结束');
      return;
    }
    // TODO: 跳转到订单确认页面
    Get.toNamed('/order/confirm', parameters: {'presellId': _id.toString()});
  }

  Widget _buildImageSwiper() {
    if (_images.isEmpty) {
      return Container(
        height: 375,
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.image, size: 64, color: Colors.grey)),
      );
    }

    return SizedBox(
      height: 375,
      child: CarouselSlider(
        items: _images.map((url) {
          return CachedNetworkImage(
            imageUrl: url,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[200]),
            errorWidget: (context, url, error) =>
                Container(color: Colors.grey[200], child: const Icon(Icons.image)),
          );
        }).toList(),
        options: CarouselOptions(
          height: 375,
          viewportFraction: 1.0,
          enableInfiniteScroll: _images.length > 1,
          autoPlay: _images.length > 1,
        ),
      ),
    );
  }

  Widget _buildPriceInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '¥',
                    style: TextStyle(
                      fontSize: 16,
                      color: ThemeColors.red.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_storeInfo['price'] ?? 0}',
                    style: TextStyle(
                      fontSize: 28,
                      color: ThemeColors.red.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_storeInfo['spec_type'] == true)
                    Text('起', style: TextStyle(fontSize: 14, color: ThemeColors.red.primary)),
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ThemeColors.red.primary.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '预售价',
                      style: TextStyle(fontSize: 12, color: ThemeColors.red.primary),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  // TODO: 分享
                },
                icon: const Icon(Icons.share),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '划线价: ¥${_storeInfo['ot_price'] ?? 0}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              Text(
                '已预订: ${_storeInfo['sales'] ?? 0}${_storeInfo['unit_name'] ?? '件'}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _storeInfo['title'] ?? '',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [const Text('预售活动时间：', style: TextStyle(fontSize: 14))]),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: ThemeColors.red.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${_storeInfo['start_time'] ?? ''} ~ ${_storeInfo['stop_time'] ?? ''}',
                        style: TextStyle(fontSize: 14, color: ThemeColors.red.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '预售结束后${_storeInfo['deliver_time'] ?? 0}天内发货',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponRow() {
    if (_couponList.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          // TODO: 显示优惠券弹窗
        },
        child: Row(
          children: [
            const Text('优惠券：', style: TextStyle(fontSize: 14)),
            Expanded(
              child: Wrap(
                spacing: 8,
                children: _couponList.take(2).map((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: ThemeColors.red.primary.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '满${item['use_min_price']}减${item['coupon_price']}',
                      style: TextStyle(fontSize: 12, color: ThemeColors.red.primary),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildAttrRow() {
    List productAttr = _attr['productAttr'] ?? [];
    if (productAttr.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          // TODO: 显示规格选择弹窗
        },
        child: Row(
          children: [
            const Text('请选择：', style: TextStyle(fontSize: 14)),
            Expanded(
              child: Text('规格', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluation() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '用户评价($_replyCount)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: () {
                  Get.toNamed(
                    '/goods/comment-list',
                    parameters: {'productId': (_storeInfo['product_id'] ?? 0).toString()},
                  );
                },
                child: Row(
                  children: [
                    Text(
                      '$_replyChance%',
                      style: TextStyle(fontSize: 14, color: ThemeColors.red.primary),
                    ),
                    const Text('好评率', style: TextStyle(fontSize: 14)),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
          if (_replyCount > 0 && _reply.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: _reply['avatar'] ?? '',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[300]),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _reply['nickname'] ?? '',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _reply['comment'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('产品介绍', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(_description, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Get.offAllNamed('/');
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.home_outlined, size: 24),
                Text('首页', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          const SizedBox(width: 24),
          InkWell(
            onTap: _setCollect,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _userCollect ? Icons.favorite : Icons.favorite_border,
                  size: 24,
                  color: _userCollect ? ThemeColors.red.primary : null,
                ),
                Text('收藏', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: ElevatedButton(
              onPressed: _payStatus == 2 ? _goBuy : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _payStatus == 2 ? ThemeColors.red.primary : Colors.grey[400],
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              child: Text(
                _payStatus == 1 ? '未开始' : (_payStatus == 3 ? '已结束' : '立即购买'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            onRefresh: _getPresellDetail,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(child: _buildImageSwiper()),
                SliverToBoxAdapter(child: _buildPriceInfo()),
                SliverToBoxAdapter(child: _buildCouponRow()),
                SliverToBoxAdapter(child: _buildAttrRow()),
                SliverToBoxAdapter(child: _buildEvaluation()),
                SliverToBoxAdapter(child: _buildDescription()),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
          // 顶部导航栏
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white.withAlpha((_opacity * 255).round()),
              child: SafeArea(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: _opacity > 0.5 ? Colors.black : Colors.white,
                        ),
                      ),
                      if (_opacity > 0.5)
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _navList.asMap().entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  entry.value,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: _navActive == entry.key
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: _navActive == entry.key
                                        ? ThemeColors.red.primary
                                        : Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
}


