import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../data/providers/lottery_provider.dart';
import '../../theme/theme_colors.dart';
import '../../../widgets/product_spec_dialog.dart';

class PointsGoodsDetailPage extends StatefulWidget {
  const PointsGoodsDetailPage({super.key});

  @override
  State<PointsGoodsDetailPage> createState() => _PointsGoodsDetailPageState();
}

class _PointsGoodsDetailPageState extends State<PointsGoodsDetailPage> {
  final PointsMallProvider _pointsMallProvider = PointsMallProvider();
  final ScrollController _scrollController = ScrollController();

  int _id = 0;
  Map<String, dynamic> _storeInfo = {};
  List<String> _images = [];
  String _description = '';
  double _opacity = 0;
  List<Map<String, dynamic>> _productAttr = [];
  Map<String, dynamic> _productValue = {};
  List<Map<String, dynamic>> _skuArr = [];
  int _currentImageIndex = 0;
  
  // 规格选择相关 - 对应uni-app的attribute
  Map<String, dynamic> _productSelect = {};
  String _attrValue = ''; // 已选规格值
  String _attrTxt = '请选择'; // 规格提示文本

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
        _productAttr =
            (response.data['productAttr'] as List?)
                ?.whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList() ??
            [];
        _productValue = Map<String, dynamic>.from(response.data['productValue'] ?? {});
        
        // 构建SKU数组用于规格图片预览
        _skuArr = [];
        _productValue.forEach((key, value) {
          if (value is Map) {
            _skuArr.add({
              ...Map<String, dynamic>.from(value),
              'suk': key,
            });
          }
        });
        
        // 默认选中第一个有库存的规格 - 对应uni-app的DefaultSelect
        _defaultSelect();
      });
    }
  }

  /// 默认选中规格 - 对应uni-app的DefaultSelect方法
  void _defaultSelect() {
    if (_productAttr.isEmpty) {
      // 无规格商品，使用商品本身信息
      _productSelect = {
        'store_name': _storeInfo['title'],
        'image': _storeInfo['image'],
        'price': _storeInfo['price'],
        'stock': _storeInfo['stock'],
        'quota': _storeInfo['quota'],
        'product_stock': _storeInfo['product_stock'],
        'unique': _storeInfo['unique'] ?? '',
        'cart_num': 1,
      };
      _attrValue = '';
      _attrTxt = '请选择';
      return;
    }

    // 找到第一个有库存的规格
    String? selectedKey;
    for (var entry in _productValue.entries) {
      if (entry.value is Map) {
        final sku = Map<String, dynamic>.from(entry.value as Map);
        final quota = sku['quota'] ?? 0;
        if (quota is int && quota > 0) {
          selectedKey = entry.key;
          break;
        }
      }
    }

    if (selectedKey != null && _productValue[selectedKey] is Map) {
      final sku = Map<String, dynamic>.from(_productValue[selectedKey] as Map);
      _productSelect = {
        'store_name': _storeInfo['title'],
        'image': sku['image'] ?? _storeInfo['image'],
        'price': sku['price'] ?? _storeInfo['price'],
        'stock': sku['stock'] ?? 0,
        'unique': sku['unique'] ?? selectedKey,
        'quota': sku['quota'] ?? 0,
        'quota_show': sku['quota_show'] ?? 0,
        'product_stock': sku['product_stock'] ?? 0,
        'cart_num': 1,
      };
      _attrValue = selectedKey;
      _attrTxt = '已选择';
    } else {
      // 没有库存的情况
      _productSelect = {
        'store_name': _storeInfo['title'],
        'image': _storeInfo['image'],
        'price': _storeInfo['price'],
        'stock': 0,
        'quota': 0,
        'product_stock': 0,
        'unique': '',
        'cart_num': 0,
      };
      _attrValue = '';
      _attrTxt = '请选择';
    }
  }

  void _goExchange() {
    // 参考uni-app: attribute.productSelect.quota > 0 && attribute.productSelect.product_stock > 0
    int quota = _productSelect['quota'] ?? 0;
    int productStock = _productSelect['product_stock'] ?? 0;
    
    if (quota <= 0 || productStock <= 0) {
      FlutterToastPro.showMessage('无法兑换');
      return;
    }

    if (_productAttr.isNotEmpty && _productValue.isNotEmpty) {
      _showSpecDialog();
      return;
    }

    // 没有规格时，直接跳转到订单页面
    String unique = _productSelect['unique'] ?? '';
    Get.toNamed('/points-order', parameters: {
      'unique': unique,
      'num': '1',
    });
  }

  Future<void> _showSpecDialog() async {
    final skuList = _productValue.entries.where((entry) => entry.value is Map).map((entry) {
      final value = Map<String, dynamic>.from(entry.value as Map);
      return {...value, 'suk': entry.key, 'unique': value['unique'] ?? entry.key};
    }).toList();

    final result = await ProductSpecDialog.show(
      product: Map<String, dynamic>.from(_storeInfo),
      attrs: _productAttr,
      skus: skuList,
      mode: ProductSpecMode.buyNow,
    );

    if (result != null) {
      final sku = result['sku'] as Map<String, dynamic>?;
      final quantity = result['quantity'] as int? ?? 1;
      final unique = sku?['unique']?.toString() ?? '';
      
      // 更新选中的规格 - 对应uni-app的ChangeAttr
      if (sku != null) {
        setState(() {
          _productSelect = {
            'store_name': _storeInfo['title'],
            'image': sku['image'] ?? _storeInfo['image'],
            'price': sku['price'] ?? _storeInfo['price'],
            'stock': sku['stock'] ?? 0,
            'unique': unique,
            'quota': sku['quota'] ?? 0,
            'quota_show': sku['quota_show'] ?? 0,
            'product_stock': sku['product_stock'] ?? 0,
            'cart_num': quantity,
          };
          _attrValue = sku['suk'] ?? unique;
          _attrTxt = '已选择';
        });
      }
      
      // 跳转到积分订单页面，与uni-app一致
      Get.toNamed('/points-order', parameters: {
        'unique': unique,
        'num': quantity.toString(),
      });
    }
  }

  Widget _buildImageSwiper() {
    if (_images.isEmpty) {
      return Container(
        height: 375,
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.image, size: 64, color: Colors.grey)),
      );
    }

    return Stack(
      children: [
        SizedBox(
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
              onPageChanged: (index, reason) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
            ),
          ),
        ),
        // 图片指示器
        if (_images.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _images.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == entry.key
                        ? ThemeColors.red.primary
                        : Colors.white.withAlpha((0.5 * 255).round()),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceInfo() {
    final num = _storeInfo['num'] ?? 0; // 限购数量
    final unitName = _storeInfo['unit_name'] ?? '件';
    final productPrice = _storeInfo['product_price']; // 划线价
    final quotaShow = _storeInfo['quota_show'] ?? _storeInfo['quota'] ?? 0; // 限量
    final sales = _storeInfo['sales'] ?? 0; // 已兑换

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 价格行
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image.asset(
                'assets/images/my-point.png',
                width: 20,
                height: 20,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.monetization_on,
                  size: 20,
                  color: ThemeColors.red.primary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${_storeInfo['price'] ?? 0}',
                style: TextStyle(
                  fontSize: 28,
                  color: ThemeColors.red.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(' 消费券', style: TextStyle(fontSize: 16, color: ThemeColors.red.primary)),
            ],
          ),
          const SizedBox(height: 12),
          // 商品标题
          Text(
            _storeInfo['title'] ?? '',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          // 限购数量
          if (num > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '最多可兑换: $num$unitName',
                style: TextStyle(fontSize: 12, color: ThemeColors.red.primary),
              ),
            ),
          const SizedBox(height: 12),
          // 划线价、限量、已兑换
          Row(
            children: [
              if (productPrice != null) ...[
                Text(
                  '划线价：¥$productPrice',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Text(
                '限量: $quotaShow',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Text(
                '已兑换: $sales',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建规格选择区域 - 对应uni-app的attribute区域
  Widget _buildAttrSection() {
    if (_productAttr.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _showSpecDialog,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '$_attrTxt：',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Expanded(
                  child: Text(
                    _attrValue.isNotEmpty ? _attrValue : '请选择规格',
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
            // SKU图片预览 - 对应uni-app的skuArr.length > 1时显示
            if (_skuArr.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    // 显示前4个SKU图片
                    ..._skuArr.take(4).map((sku) {
                      final image = sku['image'] ?? '';
                      return Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: CachedNetworkImage(
                            imageUrl: image,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: Colors.grey[200]),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image, size: 20),
                            ),
                          ),
                        ),
                      );
                    }),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '共${_skuArr.length}种规格可选',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    if (_description.isEmpty) return const SizedBox.shrink();

    // 处理HTML内容，添加图片样式
    String processedHtml = _description.replaceAll(
      RegExp(r'<img'),
      '<img style="max-width:100%;height:auto;display:block"',
    );

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('产品介绍', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          HtmlWidget(
            processedHtml,
            textStyle: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    // 参考uni-app: attribute.productSelect.quota > 0 && attribute.productSelect.product_stock > 0
    int quota = _productSelect['quota'] ?? 0;
    int productStock = _productSelect['product_stock'] ?? 0;
    bool canExchange = quota > 0 && productStock > 0;

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
          Expanded(
            child: ElevatedButton(
              onPressed: canExchange ? _goExchange : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canExchange ? ThemeColors.red.primary : Colors.grey[400],
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              child: Text(
                canExchange ? '立即兑换' : '无法兑换',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
                SliverToBoxAdapter(child: _buildAttrSection()),
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
