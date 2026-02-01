import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../data/providers/lottery_provider.dart';
import '../../data/providers/store_provider.dart';
import '../../theme/theme_colors.dart';

class PointsGoodsDetailPage extends StatefulWidget {
  const PointsGoodsDetailPage({super.key});

  @override
  State<PointsGoodsDetailPage> createState() => _PointsGoodsDetailPageState();
}

class _PointsGoodsDetailPageState extends State<PointsGoodsDetailPage> {
  final PointsMallProvider _pointsMallProvider = PointsMallProvider();
  final StoreProvider _storeProvider = StoreProvider();
  final ScrollController _scrollController = ScrollController();

  int _id = 0;
  Map<String, dynamic> _storeInfo = {};
  List<String> _images = [];
  String _description = '';
  bool _userCollect = false;
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    _id = int.tryParse(Get.parameters['id'] ?? '0') ?? 0;
    _scrollController.addListener(_onScroll);
    if (_id > 0) {
      _getDetail();
    }
  }

  @override
  void dispose() {
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

  Future<void> _getDetail() async {
    final response = await _pointsMallProvider.getPointsGoodsDetail(_id);
    if (response.isSuccess && response.data != null) {
      setState(() {
        _storeInfo = response.data['storeInfo'] ?? response.data;
        _images = List<String>.from(_storeInfo['images'] ?? [_storeInfo['image'] ?? '']);
        _description = response.data['description'] ?? _storeInfo['description'] ?? '';
        _userCollect = _storeInfo['userCollect'] ?? false;
      });
    }
  }

  void _setCollect() async {
    int productId = _storeInfo['product_id'] ?? _id;
    if (_userCollect) {
      final response = await _storeProvider.uncollectProduct(productId);
      if (response.isSuccess) {
        setState(() {
          _userCollect = false;
        });
        FlutterToastPro.showMessage('取消收藏成功');
      }
    } else {
      final response = await _storeProvider.collectProduct(productId);
      if (response.isSuccess) {
        setState(() {
          _userCollect = true;
        });
        FlutterToastPro.showMessage('收藏成功');
      }
    }
  }

  void _goExchange() {
    int stock = _storeInfo['stock'] ?? 0;
    if (stock <= 0) {
      FlutterToastPro.showMessage('库存不足');
      return;
    }

    // TODO: 显示规格选择弹窗并进行兑换
    _showExchangeDialog();
  }

  void _showExchangeDialog() {
    int price = _storeInfo['price'] ?? 0;

    Get.dialog(
      AlertDialog(
        title: const Text('确认兑换'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('商品：${_storeInfo['title'] ?? ''}'),
            const SizedBox(height: 8),
            Text(
              '消耗：$price 消费券',
              style: TextStyle(color: ThemeColors.red.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final response = await _pointsMallProvider.pointsExchange({'id': _id, 'num': 1});
              if (response.isSuccess) {
                FlutterToastPro.showMessage('兑换成功');
              } else {
                FlutterToastPro.showMessage(response.msg);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.red.primary),
            child: const Text('确认'),
          ),
        ],
      ),
    );
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_storeInfo['price'] ?? 0}',
                style: TextStyle(
                  fontSize: 28,
                  color: ThemeColors.red.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(' 消费券', style: TextStyle(fontSize: 16, color: ThemeColors.red.primary)),
              const Spacer(),
              Text(
                '已兑换${_storeInfo['sales'] ?? 0}件',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _storeInfo['title'] ?? '',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ThemeColors.red.primary.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '库存${_storeInfo['stock'] ?? 0}件',
                  style: TextStyle(fontSize: 12, color: ThemeColors.red.primary),
                ),
              ),
            ],
          ),
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
          const Text('商品详情', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(_description, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    int stock = _storeInfo['stock'] ?? 0;

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
              onPressed: stock > 0 ? _goExchange : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: stock > 0 ? ThemeColors.red.primary : Colors.grey[400],
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              child: Text(
                stock > 0 ? '立即兑换' : '库存不足',
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
          EasyRefresh(
            header: const ClassicHeader(
              dragText: '下拉刷新',
              armedText: '松手刷新',
              processingText: '刷新中...',
              processedText: '刷新完成',
              failedText: '刷新失败',
            ),
            onRefresh: _getDetail,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(child: _buildImageSwiper()),
                SliverToBoxAdapter(child: _buildPriceInfo()),
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
                        const Expanded(
                          child: Center(
                            child: Text(
                              '商品详情',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
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
