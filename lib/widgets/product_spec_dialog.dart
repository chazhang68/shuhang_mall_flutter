import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'cached_image.dart';

/// 商品规格选择弹窗 - 对应 components/productWindow/index.vue
class ProductSpecDialog extends StatefulWidget {
  final Map<String, dynamic> product;
  final List<Map<String, dynamic>> attrs;
  final List<Map<String, dynamic>> skus;
  final int initialQuantity;
  final ProductSpecMode mode;
  final Function(Map<String, dynamic> sku, int quantity)? onConfirm;

  const ProductSpecDialog({
    super.key,
    required this.product,
    required this.attrs,
    required this.skus,
    this.initialQuantity = 1,
    this.mode = ProductSpecMode.addCart,
    this.onConfirm,
  });

  /// 显示规格选择弹窗
  static Future<Map<String, dynamic>?> show({
    required Map<String, dynamic> product,
    required List<Map<String, dynamic>> attrs,
    required List<Map<String, dynamic>> skus,
    int initialQuantity = 1,
    ProductSpecMode mode = ProductSpecMode.addCart,
  }) async {
    return await Get.bottomSheet<Map<String, dynamic>>(
      ProductSpecDialog(
        product: product,
        attrs: attrs,
        skus: skus,
        initialQuantity: initialQuantity,
        mode: mode,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<ProductSpecDialog> createState() => _ProductSpecDialogState();
}

class _ProductSpecDialogState extends State<ProductSpecDialog> {
  late Map<String, String> _selectedAttrs;
  late int _quantity;
  Map<String, dynamic>? _selectedSku;

  @override
  void initState() {
    super.initState();
    _selectedAttrs = {};
    _quantity = widget.initialQuantity;
    _initDefaultSelection();
  }

  void _initDefaultSelection() {
    // 初始化默认选中第一个可选规格
    for (var attr in widget.attrs) {
      final attrName = attr['attr_name'] ?? '';
      final values = attr['attr_values'] as List? ?? [];
      if (values.isNotEmpty) {
        _selectedAttrs[attrName] = values.first.toString();
      }
    }
    _updateSelectedSku();
  }

  void _updateSelectedSku() {
    // 根据选中的规格找到对应的SKU
    final attrKey = _selectedAttrs.values.join(',');
    for (var sku in widget.skus) {
      if (sku['suk'] == attrKey || sku['unique'] == attrKey) {
        _selectedSku = sku;
        return;
      }
    }
    // 如果没找到精确匹配，尝试模糊匹配
    if (widget.skus.isNotEmpty) {
      _selectedSku = widget.skus.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.75;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 商品信息头部
          _buildHeader(),
          // 规格选择区域
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 规格属性
                  ...widget.attrs.map((attr) => _buildAttrSection(attr)),
                  // 数量选择
                  _buildQuantitySection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // 底部按钮
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final price = _selectedSku?['price'] ?? widget.product['price'] ?? '0';
    final stock = _selectedSku?['stock'] ?? widget.product['stock'] ?? 0;
    final image = _selectedSku?['image'] ?? widget.product['image'] ?? '';

    return Container(
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品图片
          CachedImage(imageUrl: image, width: 100, height: 100, borderRadius: 8),
          const SizedBox(width: 12),
          // 商品信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 价格
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '￥',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      TextSpan(
                        text: '$price',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // 库存
                Text('库存: $stock', style: const TextStyle(fontSize: 13, color: Color(0xFF999999))),
                const SizedBox(height: 8),
                // 已选规格
                Text(
                  '已选: ${_selectedAttrs.values.join(' ')}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                ),
              ],
            ),
          ),
          // 关闭按钮
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(Icons.close, size: 22, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }

  Widget _buildAttrSection(Map<String, dynamic> attr) {
    final attrName = attr['attr_name'] ?? '';
    final values = attr['attr_values'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(
          attrName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: values.map((value) {
            final valueStr = value.toString();
            final isSelected = _selectedAttrs[attrName] == valueStr;
            final isDisabled = _isAttrValueDisabled(attrName, valueStr);

            return GestureDetector(
              onTap: isDisabled
                  ? null
                  : () {
                      setState(() {
                        _selectedAttrs[attrName] = valueStr;
                        _updateSelectedSku();
                      });
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor.withAlpha((0.1 * 255).round())
                      : isDisabled
                      ? const Color(0xFFF5F5F5)
                      : Colors.white,
                  border: Border.all(
                    color: isSelected ? Theme.of(context).primaryColor : const Color(0xFFE0E0E0),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  valueStr,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : isDisabled
                        ? const Color(0xFF999999)
                        : const Color(0xFF333333),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  bool _isAttrValueDisabled(String attrName, String value) {
    // 检查该规格值是否有对应的库存
    // 这里简化处理，实际需要根据其他已选规格来判断
    return false;
  }

  Widget _buildQuantitySection() {
    final stock = _selectedSku?['stock'] ?? widget.product['stock'] ?? 999;
    final maxStock = stock is int ? stock : int.tryParse('$stock') ?? 999;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '数量',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
            // 数量选择器
            QuantitySelector(
              value: _quantity,
              min: 1,
              max: maxStock,
              onChange: (value) {
                setState(() {
                  _quantity = value;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    String buttonText;
    switch (widget.mode) {
      case ProductSpecMode.addCart:
        buttonText = '加入购物车'.tr;
        break;
      case ProductSpecMode.buyNow:
        buttonText = '立即购买'.tr;
        break;
      case ProductSpecMode.selectOnly:
        buttonText = '确定'.tr;
        break;
    }

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: GestureDetector(
          onTap: _handleConfirm,
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(23),
            ),
            alignment: Alignment.center,
            child: Text(buttonText, style: const TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  void _handleConfirm() {
    if (_selectedSku == null) {
      Get.snackbar('提示'.tr, '请选择规格'.tr);
      return;
    }

    final result = {'sku': _selectedSku, 'quantity': _quantity, 'attrs': _selectedAttrs};

    if (widget.onConfirm != null) {
      widget.onConfirm?.call(_selectedSku!, _quantity);
    }

    Get.back(result: result);
  }
}

/// 规格选择模式
enum ProductSpecMode {
  addCart, // 加入购物车
  buyNow, // 立即购买
  selectOnly, // 仅选择规格
}

/// 数量选择器组件
class QuantitySelector extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final Function(int)? onChange;
  final double size;

  const QuantitySelector({
    super.key,
    required this.value,
    this.min = 1,
    this.max = 999,
    this.onChange,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 减号
        GestureDetector(
          onTap: value > min
              ? () {
                  onChange?.call(value - 1);
                }
              : null,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.remove,
              size: 16,
              color: value > min ? const Color(0xFF333333) : const Color(0xFFCCCCCC),
            ),
          ),
        ),
        // 数量
        Container(
          width: 50,
          height: size,
          alignment: Alignment.center,
          child: Text('$value', style: const TextStyle(fontSize: 14, color: Color(0xFF333333))),
        ),
        // 加号
        GestureDetector(
          onTap: value < max
              ? () {
                  onChange?.call(value + 1);
                }
              : null,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.add,
              size: 16,
              color: value < max ? const Color(0xFF333333) : const Color(0xFFCCCCCC),
            ),
          ),
        ),
      ],
    );
  }
}
