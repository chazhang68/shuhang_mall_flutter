import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/providers/order_provider.dart';
import '../../theme/theme_colors.dart';

class GoodsCommentPage extends StatefulWidget {
  const GoodsCommentPage({super.key});

  @override
  State<GoodsCommentPage> createState() => _GoodsCommentPageState();
}

class _GoodsCommentPageState extends State<GoodsCommentPage> {
  final OrderProvider _orderProvider = OrderProvider();
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String _unique = '';
  Map<String, dynamic> _productInfo = {};
  int _cartNum = 0;
  final List<String> _pics = [];
  bool _isSubmitting = false;

  // 评分项
  final List<Map<String, dynamic>> _scoreList = [
    {'name': '商品质量', 'stars': 5, 'index': -1},
    {'name': '服务态度', 'stars': 5, 'index': -1},
  ];

  @override
  void initState() {
    super.initState();
    _unique = Get.parameters['unique'] ?? '';
    if (_unique.isNotEmpty) {
      _getOrderProduct();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _getOrderProduct() async {
    final response = await _orderProvider.getOrderProduct(_unique);
    if (response.isSuccess && response.data != null) {
      setState(() {
        _productInfo = response.data['productInfo'] ?? {};
        _cartNum = response.data['cart_num'] ?? 1;
      });
    }
  }

  void _setStars(int scoreIndex, int starIndex) {
    setState(() {
      _scoreList[scoreIndex]['index'] = starIndex;
    });
  }

  Future<void> _uploadPic() async {
    if (_pics.length >= 8) {
      FlutterToastPro.showMessage( '最多上传8张图片');
      return;
    }

    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // TODO: 上传图片到服务器
      setState(() {
        _pics.add(image.path);
      });
    }
  }

  void _deletePic(int index) {
    setState(() {
      _pics.removeAt(index);
    });
  }

  Future<void> _submitComment() async {
    if (_isSubmitting) return;

    String comment = _commentController.text.trim();
    if (comment.isEmpty) {
      FlutterToastPro.showMessage( '请填写你对宝贝的心得');
      return;
    }

    int productScore = _scoreList[0]['index'] + 1;
    int serviceScore = _scoreList[1]['index'] + 1;

    if (productScore <= 0 || serviceScore <= 0) {
      FlutterToastPro.showMessage( '请为商品评分');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _orderProvider.submitComment({
        'comment': comment,
        'product_score': productScore,
        'service_score': serviceScore,
        'pics': _pics,
        'unique': _unique,
      });

      if (response.isSuccess) {
        FlutterToastPro.showMessage( '评价成功');
        Future.delayed(const Duration(seconds: 1), () {
          Get.back();
        });
      } else {
        FlutterToastPro.showMessage( response.msg);
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildProductInfo() {
    Map<String, dynamic>? attrInfo = _productInfo['attrInfo'];
    String image = _productInfo['image'] ?? '';
    String storeName = _productInfo['store_name'] ?? '';
    String price = (attrInfo?['price'] ?? _productInfo['price'] ?? 0).toString();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '¥$price',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text('x$_cartNum', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSection() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: _scoreList.asMap().entries.map((entry) {
          int scoreIndex = entry.key;
          Map<String, dynamic> item = entry.value;
          int currentIndex = item['index'] ?? -1;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text(item['name'] ?? '', style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 16),
                Row(
                  children: List.generate(5, (starIndex) {
                    bool isSelected = currentIndex >= starIndex;
                    return GestureDetector(
                      onTap: () => _setStars(scoreIndex, starIndex),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          isSelected ? Icons.star : Icons.star_border,
                          size: 28,
                          color: isSelected ? Colors.orange : Colors.grey[400],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Text(
                  currentIndex >= 0 ? '${currentIndex + 1}星' : '',
                  style: TextStyle(fontSize: 14, color: Colors.orange[700]),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _commentController,
            maxLines: 5,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: '商品满足你的期待么？说说你的想法，分享给想买的他们吧',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ..._pics.asMap().entries.map((entry) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        entry.value,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 72,
                            height: 72,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: GestureDetector(
                        onTap: () => _deletePic(entry.key),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              if (_pics.length < 8)
                GestureDetector(
                  onTap: _uploadPic,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 28, color: Colors.grey[400]),
                        const SizedBox(height: 4),
                        Text('上传图片', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('评价订单'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProductInfo(),
            _buildScoreSection(),
            _buildCommentInput(),

            const SizedBox(height: 32),

            // 提交按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.red.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  ),
                  child: Text(
                    _isSubmitting ? '提交中...' : '立即评价',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}


