import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/providers/order_provider.dart';
import '../../data/providers/public_provider.dart';
import '../../theme/theme_colors.dart';

class GoodsReturnPage extends StatefulWidget {
  const GoodsReturnPage({super.key});

  @override
  State<GoodsReturnPage> createState() => _GoodsReturnPageState();
}

class _GoodsReturnPageState extends State<GoodsReturnPage> {
  final OrderProvider _orderProvider = OrderProvider();
  final PublicProvider _publicProvider = PublicProvider();
  final TextEditingController _remarkController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  int _id = 0;
  String _orderId = '';
  List<Map<String, dynamic>> _cartIds = [];
  Map<String, dynamic> _status = {};
  List<Map<String, dynamic>> _refundCartInfo = [];
  final List<String> _refundReasonWapImg = [];
  List<String> _refundArray = [];
  int _refundTotalNum = 0;
  int _refundNumIndex = 0;
  int _reasonIndex = 0;
  int _returnGoodsIndex = 0; // 0仅退款 1退货并退款
  bool _isSubmitting = false;

  final List<String> _returnGoodsData = ['仅退款', '退货并退款'];

  @override
  void initState() {
    super.initState();
    _id = int.tryParse(Get.parameters['id'] ?? '0') ?? 0;
    _orderId = Get.parameters['orderId'] ?? '';
    String cartIdsStr = Get.parameters['cartIds'] ?? '';
    if (cartIdsStr.isNotEmpty) {
      try {
        List<dynamic> parsed = List<dynamic>.from(
          cartIdsStr.split(',').map((e) => {'cart_id': int.parse(e)}),
        );
        _cartIds = parsed.cast<Map<String, dynamic>>();
      } catch (e) {
        debugPrint('解析cartIds失败: $e');
      }
    }

    if (_id > 0) {
      _refundGoodsInfo();
      _getRefundReason();
    }
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _refundGoodsInfo() async {
    final response = await _orderProvider.getRefundGoods({'id': _id, 'cart_ids': _cartIds});

    if (response.isSuccess && response.data != null) {
      setState(() {
        _status = response.data['_status'] ?? {};
        List<dynamic> cartInfo = response.data['cartInfo'] ?? [];
        _refundCartInfo = cartInfo.cast<Map<String, dynamic>>();

        // 计算总退货件数
        _refundTotalNum = 0;
        for (var item in _refundCartInfo) {
          _refundTotalNum += (item['cart_num'] as int? ?? 0);
        }

        // 如果只有一件商品，默认选择最大数量
        if (_refundCartInfo.length == 1) {
          _refundNumIndex = _refundTotalNum - 1;
        }
      });
    }
  }

  Future<void> _getRefundReason() async {
    final response = await _orderProvider.getRefundReason();
    if (response.isSuccess && response.data != null) {
      setState(() {
        _refundArray = List<String>.from(response.data);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_refundReasonWapImg.length >= 3) {
      FlutterToastPro.showMessage('最多上传3张图片');
      return;
    }

    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final response = await _publicProvider.uploadFile(filePath: image.path);
      if (response.isSuccess && response.data != null) {
        final data = response.data as Map;
        final url = data['url']?.toString() ?? '';
        if (url.isEmpty) {
          FlutterToastPro.showMessage('图片上传失败');
          return;
        }
        setState(() {
          _refundReasonWapImg.add(url);
        });
      } else {
        FlutterToastPro.showMessage(response.msg.isNotEmpty ? response.msg : '图片上传失败');
      }
    }
  }

  void _deleteImage(int index) {
    setState(() {
      _refundReasonWapImg.removeAt(index);
    });
  }

  void _showReasonPicker() {
    if (_refundArray.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
                  const Text('选择退款原因', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('确定')),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _refundArray.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_refundArray[index]),
                      trailing: _reasonIndex == index
                          ? Icon(Icons.check, color: ThemeColors.red.primary)
                          : null,
                      onTap: () {
                        setState(() {
                          _reasonIndex = index;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReturnTypePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
                  const Text('选择退款类型', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('确定')),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _returnGoodsData.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_returnGoodsData[index]),
                      trailing: _returnGoodsIndex == index
                          ? Icon(Icons.check, color: ThemeColors.red.primary)
                          : null,
                      onTap: () {
                        setState(() {
                          _returnGoodsIndex = index;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNumPicker() {
    if (_refundTotalNum <= 1) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
                  const Text('选择退货件数', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('确定')),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _refundTotalNum,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('${index + 1}'),
                      trailing: _refundNumIndex == index
                          ? Icon(Icons.check, color: ThemeColors.red.primary)
                          : null,
                      onTap: () {
                        setState(() {
                          _refundNumIndex = index;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitRefund() async {
    if (_isSubmitting) return;

    String remark = _remarkController.text.trim();
    if (remark.isEmpty) {
      FlutterToastPro.showMessage('请输入备注');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 如果只有一件商品，使用选择的数量
      List<Map<String, dynamic>> cartIdsData = [];
      if (_refundCartInfo.length == 1) {
        cartIdsData = [
          {'cart_id': _refundCartInfo[0]['id'], 'cart_num': _refundNumIndex + 1},
        ];
      } else {
        cartIdsData = _cartIds;
      }

      final response = await _orderProvider.submitRefundGoods(_id, {
        'text': _refundArray.isNotEmpty ? _refundArray[_reasonIndex] : '',
        'refund_reason_wap_explain': remark,
        'refund_reason_wap_img': _refundReasonWapImg.join(','),
        'refund_type': _returnGoodsIndex == 1 ? 2 : 1,
        'uni': _orderId,
        'cart_ids': cartIdsData,
      });

      if (response.isSuccess) {
        FlutterToastPro.showMessage('申请成功');
        Future.delayed(const Duration(seconds: 1), () {
          Get.offNamed('/user/return-list', parameters: {'isT': '1'});
        });
      } else {
        FlutterToastPro.showMessage(response.msg);
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildGoodsItem(Map<String, dynamic> item) {
    Map<String, dynamic> productInfo = item['productInfo'] ?? {};
    Map<String, dynamic>? attrInfo = productInfo['attrInfo'];
    String image = attrInfo?['image'] ?? productInfo['image'] ?? '';
    double truePrice = double.tryParse((item['truePrice'] ?? 0).toString()) ?? 0;
    double postagePrice = double.tryParse((item['postage_price'] ?? 0).toString()) ?? 0;
    int cartNum = item['cart_num'] ?? 1;
    double totalPrice = truePrice + (postagePrice / cartNum);

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
                  productInfo['store_name'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '¥${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text('x$cartNum', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormItem({
    required String label,
    required String value,
    VoidCallback? onTap,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            const Spacer(),
            Text(value, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            if (showArrow) ...[
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('申请退款'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 商品列表
            ..._refundCartInfo.map((item) => _buildGoodsItem(item)),

            const SizedBox(height: 12),

            // 表单区域
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  // 退货件数
                  _buildFormItem(
                    label: '退货件数',
                    value: _refundCartInfo.length != 1 || _refundTotalNum == 1
                        ? '$_refundTotalNum'
                        : '${_refundNumIndex + 1}',
                    onTap: _refundCartInfo.length == 1 && _refundTotalNum > 1
                        ? _showNumPicker
                        : null,
                    showArrow: _refundCartInfo.length == 1 && _refundTotalNum > 1,
                  ),

                  // 退款类型
                  if (_status['_type'] != 1)
                    _buildFormItem(
                      label: '退款类型',
                      value: _status['_is_back'] == true
                          ? _returnGoodsData[_returnGoodsIndex]
                          : '仅退款',
                      onTap: _status['_is_back'] == true ? _showReturnTypePicker : null,
                      showArrow: _status['_is_back'] == true,
                    ),

                  // 退款原因
                  _buildFormItem(
                    label: '退款原因',
                    value: _refundArray.isNotEmpty ? _refundArray[_reasonIndex] : '请选择',
                    onTap: _showReasonPicker,
                  ),

                  // 备注说明
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('备注说明', style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _remarkController,
                          maxLines: 3,
                          maxLength: 100,
                          decoration: InputDecoration(
                            hintText: '填写备注信息，100字以内',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 上传图片
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('上传图片', style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ..._refundReasonWapImg.asMap().entries.map((entry) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: entry.value,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          Container(width: 80, height: 80, color: Colors.grey[200]),
                                      errorWidget: (context, url, error) {
                                        return Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.image),
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: -8,
                                    right: -8,
                                    child: GestureDetector(
                                      onTap: () => _deleteImage(entry.key),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),

                            if (_refundReasonWapImg.length < 3)
                              GestureDetector(
                                onTap: _uploadImage,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate,
                                        size: 28,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '上传图片',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 提交按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRefund,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.red.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  ),
                  child: Text(
                    _isSubmitting ? '申请中...' : '申请退款',
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
