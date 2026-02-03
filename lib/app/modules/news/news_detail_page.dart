import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../data/providers/public_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme_colors.dart';

class NewsDetailPage extends StatefulWidget {
  const NewsDetailPage({super.key});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  final PublicProvider _publicProvider = PublicProvider();

  int _id = 0;
  Map<String, dynamic> _articleInfo = {};
  Map<String, dynamic>? _storeInfo;
  String _content = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // 支持 arguments 和 parameters 两种方式获取id
    final args = Get.arguments;
    if (args != null && args is Map && args['id'] != null) {
      _id = args['id'] is int ? args['id'] : int.tryParse(args['id'].toString()) ?? 0;
    } else {
      _id = int.tryParse(Get.parameters['id'] ?? '') ?? 0;
    }

    if (_id > 0) {
      _getArticleDetail();
    } else {
      Get.back();
    }
  }

  Future<void> _getArticleDetail() async {
    final response = await _publicProvider.getArticleDetail(_id);
    if (response.isSuccess && response.data != null) {
      setState(() {
        _articleInfo = response.data;
        _storeInfo = response.data['store_info'];
        _content = response.data['content'] ?? '';
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  void _goToGoodsDetail(int productId) {
    Get.toNamed(AppRoutes.goodsDetail, parameters: {'id': productId.toString()});
  }

  Widget _buildProductCard() {
    if (_storeInfo == null || _storeInfo!['id'] == null) {
      return const SizedBox.shrink();
    }

    String image = _storeInfo!['image'] ?? '';
    String storeName = _storeInfo!['store_name'] ?? '';
    String price = (_storeInfo!['price'] ?? 0).toString();
    String otPrice = (_storeInfo!['ot_price'] ?? 0).toString();
    int productId = _storeInfo!['id'] ?? 0;

    return GestureDetector(
      onTap: () => _goToGoodsDetail(productId),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) =>
                    Container(color: Colors.grey[200], child: const Icon(Icons.image)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¥$price',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.red.primary,
                    ),
                  ),
                  Text(
                    '¥$otPrice',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text('查看商品', style: TextStyle(fontSize: 12, color: Colors.amber)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('资讯详情'), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    String title = _articleInfo['title'] ?? '';
    String cateName = _articleInfo['catename'] ?? '';
    String addTime = _articleInfo['add_time'] ?? '';
    int visit = _articleInfo['visit'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(title.length > 7 ? '${title.substring(0, 7)}...' : title),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.5),
              ),
            ),

            // 标签和时间
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (cateName.isNotEmpty)
                    Text(cateName, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  if (addTime.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Text(addTime, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                  const SizedBox(width: 16),
                  Icon(Icons.remove_red_eye_outlined, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text('$visit', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),

            // 内容
            Padding(
              padding: const EdgeInsets.all(16),
              child: HtmlWidget(
                _content,
                customStylesBuilder: (element) {
                  if (element.localName == 'body') {
                    return {
                      'font-size': '14px',
                      'color': '#8A8B8C',
                      'line-height': '1.7',
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
            ),

            // 关联商品
            _buildProductCard(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
