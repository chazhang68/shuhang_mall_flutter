import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../data/providers/activity_provider.dart';
import '../../data/providers/store_provider.dart';
import '../../theme/theme_colors.dart';
import '../../routes/app_routes.dart';
import '../../../widgets/countdown_widget.dart';

/// 秒杀详情页面
/// 对应原 pages/activity/goods_seckill_details/index.vue
class SeckillDetailPage extends StatefulWidget {
  const SeckillDetailPage({super.key});

  @override
  State<SeckillDetailPage> createState() => _SeckillDetailPageState();
}

class _SeckillDetailPageState extends State<SeckillDetailPage> {
  final ActivityProvider _activityProvider = ActivityProvider();
  final StoreProvider _storeProvider = StoreProvider();

  int _id = 0;
  Map<String, dynamic> _storeInfo = {};
  List<String> _imgUrls = [];
  int _status = 0; // 0-已结束 1-进行中 2-未开始
  int _datatime = 0;
  bool _isCollected = false;
  bool _isLoading = true;

  // 评价
  int _replyCount = 0;
  int _replyChance = 100;
  Map<String, dynamic> _reply = {};

  Color get _primaryColor => ThemeColors.red.primary;

  @override
  void initState() {
    super.initState();
    _id = int.tryParse(Get.arguments?['id']?.toString() ?? '0') ?? 0;
    if (_id == 0) {
      FlutterToastPro.showMessage('缺少商品ID');
      return;
    }
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final response = await _activityProvider.getSeckillDetail(_id);
      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final storeInfo = data['storeInfo'] as Map<String, dynamic>? ?? {};

        setState(() {
          _storeInfo = storeInfo;
          _imgUrls =
              (storeInfo['slider_image'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              [];
          _status = data['status'] ?? 0;
          _datatime = data['time'] ?? 0;
          _isCollected = storeInfo['userCollect'] == true;
          _replyCount = data['replyCount'] ?? 0;
          _replyChance = data['replyChance'] ?? 100;
          _reply = data['reply'] as Map<String, dynamic>? ?? {};
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        FlutterToastPro.showMessage(response.msg);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      FlutterToastPro.showMessage('获取详情失败');
    }
  }

  Future<void> _toggleCollect() async {
    final productId = _storeInfo['product_id'];
    if (productId == null) return;

    try {
      if (_isCollected) {
        await _storeProvider.uncollectProduct(productId);
      } else {
        await _storeProvider.collectProduct(productId);
      }
      setState(() {
        _isCollected = !_isCollected;
      });
      FlutterToastPro.showMessage(_isCollected ? '收藏成功' : '取消收藏');
    } catch (e) {
      FlutterToastPro.showMessage('操作失败');
    }
  }

  void _goBuy() {
    if (_status != 1) {
      FlutterToastPro.showMessage(_status == 0 ? '活动已结束' : '活动未开始');
      return;
    }

    final quota = _storeInfo['quota'] ?? 0;
    final stock = _storeInfo['stock'] ?? 0;
    if (quota <= 0 || stock <= 0) {
      FlutterToastPro.showMessage('已售罄');
      return;
    }

    Get.toNamed(AppRoutes.orderConfirm, arguments: {'seckill_id': _id, 'cart_num': 1});
  }

  String get _statusText {
    switch (_status) {
      case 0:
        return '已结束';
      case 1:
        return '进行中';
      case 2:
        return '未开始';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      // 顶部轮播图
                      _buildSliverAppBar(),
                      // 价格信息
                      SliverToBoxAdapter(child: _buildPriceSection()),
                      // 商品信息
                      SliverToBoxAdapter(child: _buildInfoSection()),
                      // 评价区域
                      if (_replyCount > 0) SliverToBoxAdapter(child: _buildReviewSection()),
                      // 商品详情
                      SliverToBoxAdapter(child: _buildDescSection()),
                    ],
                  ),
                ),
                // 底部操作栏
                _buildBottomBar(),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 375,
      pinned: true,
      backgroundColor: _primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _imgUrls.isEmpty
            ? Container(color: const Color(0xFFF5F5F5))
            : CarouselSlider(
                options: CarouselOptions(
                  height: 375,
                  viewportFraction: 1.0,
                  autoPlay: _imgUrls.length > 1,
                ),
                items: _imgUrls.map((url) {
                  return CachedNetworkImage(
                    imageUrl: url,
                    width: double.infinity,
                    height: 375,
                    fit: BoxFit.cover,
                  );
                }).toList(),
              ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return Container(
      color: _primaryColor,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 价格
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('¥', style: TextStyle(color: Colors.white, fontSize: 14)),
                  Text(
                    '${_storeInfo['price'] ?? 0}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '¥${_storeInfo['ot_price'] ?? 0}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // 倒计时
          if (_status == 1)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('距秒杀结束仅剩', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                CountdownWidget(
                  endTime: _datatime,
                  textColor: Colors.white,
                  backgroundColor: Colors.white.withAlpha((0.2 * 255).round()),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(
            _storeInfo['title'] ?? '',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          // 销量和库存
          Row(
            children: [
              Text(
                '累计销售：${_storeInfo['total'] ?? 0}${_storeInfo['unit_name'] ?? ''}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
              const SizedBox(width: 20),
              Text(
                '限量剩余：${_storeInfo['quota'] ?? 0}${_storeInfo['unit_name'] ?? ''}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '用户评价($_replyCount)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(
                    AppRoutes.goodsCommentList,
                    arguments: {'product_id': _storeInfo['product_id']},
                  );
                },
                child: Row(
                  children: [
                    Text('$_replyChance%', style: TextStyle(fontSize: 12, color: _primaryColor)),
                    const Text('好评率', style: TextStyle(fontSize: 12, color: Color(0xFF999999))),
                    const Icon(Icons.chevron_right, size: 16, color: Color(0xFF999999)),
                  ],
                ),
              ),
            ],
          ),
          if (_reply.isNotEmpty) ...[const SizedBox(height: 16), _buildReplyItem(_reply)],
        ],
      ),
    );
  }

  Widget _buildReplyItem(Map<String, dynamic> reply) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: reply['avatar'] ?? '',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: const Color(0xFFF5F5F5)),
                errorWidget: (context, url, error) => Container(color: const Color(0xFFF5F5F5)),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              reply['nickname'] ?? '',
              style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          reply['comment'] ?? '',
          style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDescSection() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '产品介绍',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 16),
          HtmlWidget(
            _storeInfo['description'] ?? '暂无介绍',
            customStylesBuilder: (element) {
              if (element.localName == 'body') {
                return {
                  'font-size': '14px',
                  'color': '#666666',
                  'line-height': '1.6',
                  'margin': '0',
                  'padding': '0',
                };
              }
              if (element.localName == 'img') {
                return {'width': '100%', 'display': 'block'};
              }
              if (element.localName == 'table') {
                return {'width': '100%'};
              }
              if (element.localName == 'video') {
                return {'width': '100%'};
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final canBuy = _status == 1 && (_storeInfo['quota'] ?? 0) > 0 && (_storeInfo['stock'] ?? 0) > 0;

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
          // 首页
          GestureDetector(
            onTap: () => Get.offAllNamed(AppRoutes.main),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home, size: 22, color: Color(0xFF666666)),
                Text('首页', style: TextStyle(fontSize: 10, color: Color(0xFF666666))),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // 收藏
          GestureDetector(
            onTap: _toggleCollect,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isCollected ? Icons.favorite : Icons.favorite_border,
                  size: 22,
                  color: _isCollected ? _primaryColor : const Color(0xFF666666),
                ),
                Text(
                  '收藏',
                  style: TextStyle(
                    fontSize: 10,
                    color: _isCollected ? _primaryColor : const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // 购买按钮
          Expanded(
            child: Row(
              children: [
                // 单独购买
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.goodsDetail,
                        arguments: {'id': _storeInfo['product_id']},
                      );
                    },
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9900),
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(22)),
                      ),
                      child: const Text(
                        '单独购买',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                // 立即购买
                Expanded(
                  child: GestureDetector(
                    onTap: canBuy ? _goBuy : null,
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: canBuy ? _primaryColor : const Color(0xFFCCCCCC),
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(22)),
                      ),
                      child: Text(
                        canBuy ? '立即购买' : _statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
