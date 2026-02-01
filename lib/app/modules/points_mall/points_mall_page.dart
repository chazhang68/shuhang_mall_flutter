import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/providers/lottery_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme_colors.dart';
import '../../../widgets/empty_page.dart';

class PointsMallPage extends StatefulWidget {
  const PointsMallPage({super.key});

  @override
  State<PointsMallPage> createState() => _PointsMallPageState();
}

class _PointsMallPageState extends State<PointsMallPage> {
  final PointsMallProvider _pointsMallProvider = PointsMallProvider();

  List<Map<String, dynamic>> _imgUrls = [];
  List<Map<String, dynamic>> _goodList = [];

  final List<Map<String, dynamic>> _modelList = [
    {'title': '我的消费券', 'icon': Icons.card_giftcard, 'url': '/user/integral'},
    {'title': '兑换记录', 'icon': Icons.history, 'url': '/points-mall/order'},
  ];

  @override
  void initState() {
    super.initState();
    _getStoreIntegral();
  }

  Future<void> _getStoreIntegral() async {
    final response = await _pointsMallProvider.getStoreIntegral();
    if (response.isSuccess && response.data != null) {
      setState(() {
        _imgUrls = List<Map<String, dynamic>>.from(response.data['banner'] ?? []);
        _goodList = List<Map<String, dynamic>>.from(response.data['list'] ?? []);
      });
    }
  }

  void _goGoodsDetail(Map<String, dynamic> item) {
    Get.toNamed('/points-mall/goods/detail', parameters: {'id': (item['id'] ?? 0).toString()});
  }

  void _jumpMore() {
    Get.toNamed('/points-mall/goods');
  }

  void _jump(String url) {
    Get.toNamed(url);
  }

  Future<void> _jumpLink(String link) async {
    if (link.isEmpty) return;

    if (link.contains('@APPID=')) {
      FlutterToastPro.showMessage('暂不支持打开外部小程序');
      return;
    }

    if (link.startsWith('http')) {
      final uri = Uri.parse(link);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        FlutterToastPro.showMessage('无法打开链接');
      }
      return;
    }

    final uri = Uri.parse(link);
    final path = uri.path;
    final params = uri.queryParameters;

    if (path.contains('/pages/index/index')) {
      Get.offAllNamed(AppRoutes.main);
      return;
    }
    if (path.contains('/pages/goods_cate/goods_cate')) {
      Get.offAllNamed(AppRoutes.category);
      return;
    }
    if (path.contains('/pages/order_addcart/order_addcart')) {
      Get.offAllNamed(AppRoutes.cart);
      return;
    }
    if (path.contains('/pages/user/index')) {
      Get.offAllNamed(AppRoutes.user);
      return;
    }
    if (path.contains('/pages/goods_details/index') || path.contains('/pages/goods_detail/index')) {
      final id = params['id'] ?? '0';
      Get.toNamed(AppRoutes.goodsDetail, parameters: {'id': id});
      return;
    }
    if (path.contains('/pages/extension/news_details/index')) {
      final id = params['id'] ?? '0';
      Get.toNamed(AppRoutes.newsDetail, parameters: {'id': id});
      return;
    }
    if (path.contains('/pages/activity/goods_bargain_details/index')) {
      final id = params['id'] ?? '0';
      final bargain = params['bargain'] ?? '0';
      Get.toNamed(AppRoutes.bargainDetail, parameters: {'id': id, 'bargain': bargain});
      return;
    }
    if (path.contains('/pages/activity/presell_details/index')) {
      final id = params['id'] ?? '0';
      Get.toNamed(AppRoutes.presellDetail, parameters: {'id': id});
      return;
    }
    if (path.contains('/pages/points_mall/integral_goods_details')) {
      final id = params['id'] ?? '0';
      Get.toNamed(AppRoutes.pointsGoodsDetail, parameters: {'id': id});
      return;
    }
    if (path.contains('/pages/points_mall/index')) {
      Get.toNamed(AppRoutes.pointsMall);
      return;
    }

    Get.toNamed(link);
  }

  Widget _buildSwiper() {
    if (_imgUrls.isEmpty) {
      return Container(
        height: 140,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: CarouselSlider(
        items: _imgUrls.map((item) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: GestureDetector(
              onTap: () {
                String link = item['link'] ?? '';
                if (link.isNotEmpty) {
                  _jumpLink(link);
                }
              },
              child: CachedNetworkImage(
                imageUrl: item['img'] ?? '',
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) =>
                    Container(color: Colors.grey[200], child: const Icon(Icons.image)),
              ),
            ),
          );
        }).toList(),
        options: CarouselOptions(
          height: 140,
          viewportFraction: 1.0,
          enableInfiniteScroll: _imgUrls.length > 1,
          autoPlay: _imgUrls.length > 1,
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _modelList.map((item) {
          return GestureDetector(
            onTap: () => _jump(item['url']),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: ThemeColors.red.primary.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(item['icon'], color: ThemeColors.red.primary, size: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  item['title'],
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGoodsSection() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('大家都在换', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: _jumpMore,
                child: Row(
                  children: [
                    Text('查看更多', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[600]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_goodList.isEmpty)
            const EmptyPage(text: '暂无商品，去看点别的吧')
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _goodList.length > 4 ? 4 : _goodList.length,
              itemBuilder: (context, index) {
                final item = _goodList[index];
                return GestureDetector(
                  onTap: () => _goGoodsDetail(item),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.05 * 255).round()),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          child: CachedNetworkImage(
                            imageUrl: item['image'] ?? '',
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: Colors.grey[200]),
                            errorWidget: (context, url, error) =>
                                Container(color: Colors.grey[200], child: const Icon(Icons.image)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${item['price'] ?? 0} 消费券',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: ThemeColors.red.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item['sales'] ?? 0}人兑换',
                                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTaskSection() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('轻松赚消费券', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTaskItem(
            icon: Icons.shopping_cart,
            title: '购买商品',
            subtitle: '购买商品可获得消费券奖励',
            onTap: () => Get.offAllNamed('/'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ThemeColors.red.primary.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: ThemeColors.red.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.red.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('去完成', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('积分商城'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 背景+轮播图
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ThemeColors.red.primary,
                        ThemeColors.red.primary.withAlpha((0.8 * 255).round()),
                      ],
                    ),
                  ),
                ),
                _buildSwiper(),
              ],
            ),

            // 菜单入口
            _buildMenuSection(),

            // 商品列表
            _buildGoodsSection(),

            // 任务列表
            _buildTaskSection(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
