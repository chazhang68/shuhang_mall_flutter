import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/theme/theme_colors.dart';
import 'package:shuhang_mall_flutter/widgets/widgets.dart';

/// 订单确认页
/// 对应原 pages/goods/order_confirm/index.vue
class OrderConfirmPage extends StatefulWidget {
  const OrderConfirmPage({super.key});

  @override
  State<OrderConfirmPage> createState() => _OrderConfirmPageState();
}

class _OrderConfirmPageState extends State<OrderConfirmPage> {
  Map<String, dynamic>? _selectedAddress;
  Map<String, dynamic>? _selectedCoupon;
  String _remark = '';
  int _payType = 0; // 0: 在线支付

  // 示例商品数据
  final List<Map<String, dynamic>> _orderItems = [
    {'id': 1, 'name': '示例商品名称', 'image': '', 'spec': '规格: 默认', 'price': 199.00, 'count': 2},
  ];

  // 示例地址数据
  final List<Map<String, dynamic>> _addressList = [
    {
      'id': 1,
      'real_name': '张三',
      'phone': '13800138000',
      'province': '广东省',
      'city': '深圳市',
      'district': '南山区',
      'detail': '科技园路xxx号',
      'is_default': 1,
    },
  ];

  double get _goodsTotal {
    return _orderItems.fold(0.0, (sum, item) {
      return sum + (item['price'] as double) * (item['count'] as int);
    });
  }

  double get _couponDiscount {
    return _selectedCoupon?['coupon_price']?.toDouble() ?? 0.0;
  }

  double get _freight {
    return 0.0; // 包邮
  }

  double get _totalPrice {
    return _goodsTotal - _couponDiscount + _freight;
  }

  @override
  void initState() {
    super.initState();
    _initDefaultAddress();
  }

  void _initDefaultAddress() {
    final defaultAddr = _addressList.firstWhereOrNull((addr) => addr['is_default'] == 1);
    if (defaultAddr != null) {
      _selectedAddress = defaultAddr;
    } else if (_addressList.isNotEmpty) {
      _selectedAddress = _addressList.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        final themeColor = controller.themeColor;

        return Scaffold(
          appBar: AppBar(title: const Text('确认订单')),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 收货地址
                      _buildAddressSection(themeColor),
                      const SizedBox(height: 10),
                      // 商品列表
                      _buildGoodsSection(),
                      const SizedBox(height: 10),
                      // 优惠券
                      _buildCouponSection(themeColor),
                      const SizedBox(height: 10),
                      // 订单备注
                      _buildRemarkSection(),
                      const SizedBox(height: 10),
                      // 支付方式
                      _buildPayTypeSection(themeColor),
                      const SizedBox(height: 10),
                      // 价格明细
                      _buildPriceDetail(themeColor),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // 底部结算栏
              _buildBottomBar(themeColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddressSection(ThemeColorData themeColor) {
    return GestureDetector(
      onTap: () async {
        final result = await AddressPickerDialog.show(
          addressList: _addressList,
          selectedId: _selectedAddress?['id'],
          onAddAddress: () {
            Get.toNamed(AppRoutes.addressEdit);
          },
        );
        if (result != null) {
          setState(() {
            _selectedAddress = result;
          });
        }
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(15),
        child: _selectedAddress == null
            ? Row(
                children: [
                  Icon(Icons.add_location_alt_outlined, color: themeColor.primary),
                  const SizedBox(width: 10),
                  Text('请选择收货地址', style: TextStyle(color: themeColor.primary, fontSize: 14)),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Color(0xFF999999)),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, color: Color(0xFF333333), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _selectedAddress!['real_name'] ?? '',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _selectedAddress!['phone'] ?? '',
                              style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_selectedAddress!['province']}${_selectedAddress!['city']}${_selectedAddress!['district']}${_selectedAddress!['detail']}',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF999999)),
                ],
              ),
      ),
    );
  }

  Widget _buildGoodsSection() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // 店铺信息
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
            ),
            child: const Row(
              children: [
                Icon(Icons.store, size: 18, color: Color(0xFF333333)),
                SizedBox(width: 8),
                Text('官方自营店', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // 商品列表
          ...(_orderItems.map((item) => _buildGoodsItem(item))),
        ],
      ),
    );
  }

  Widget _buildGoodsItem(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品图片
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: item['image'] != null && item['image'].toString().isNotEmpty
                ? CachedImage(imageUrl: item['image'], width: 80, height: 80, borderRadius: 8)
                : const Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          // 商品信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  item['spec'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '¥${(item['price'] as double).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE93323),
                      ),
                    ),
                    Text(
                      'x${item['count']}',
                      style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection(ThemeColorData themeColor) {
    return GestureDetector(
      onTap: () async {
        final result = await CouponDialog.show(couponList: [], selectedId: _selectedCoupon?['id']);
        if (result != null) {
          setState(() {
            _selectedCoupon = result;
          });
        }
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            const Text('优惠券', style: TextStyle(fontSize: 14)),
            const Spacer(),
            Text(
              _selectedCoupon != null && _selectedCoupon!['coupon_price'] > 0
                  ? '-¥${_selectedCoupon!['coupon_price']}'
                  : '暂无可用',
              style: TextStyle(
                fontSize: 14,
                color: _selectedCoupon != null ? themeColor.primary : const Color(0xFF999999),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Color(0xFF999999), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRemarkSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          const Text('订单备注', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 15),
          Expanded(
            child: TextField(
              onChanged: (value) {
                _remark = value;
              },
              decoration: const InputDecoration(
                hintText: '选填，可填写您的特殊需求',
                hintStyle: TextStyle(fontSize: 13, color: Color(0xFF999999)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayTypeSection(ThemeColorData themeColor) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('支付方式', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildPayTypeItem(0, '在线支付', Icons.payment, themeColor),
        ],
      ),
    );
  }

  Widget _buildPayTypeItem(int type, String label, IconData icon, themeColor) {
    final isSelected = _payType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _payType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF666666)),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 14)),
            const Spacer(),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? themeColor.primary : const Color(0xFFCCCCCC),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDetail(ThemeColorData themeColor) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          _buildPriceRow('商品总价', '¥${_goodsTotal.toStringAsFixed(2)}'),
          if (_couponDiscount > 0)
            _buildPriceRow(
              '优惠券',
              '-¥${_couponDiscount.toStringAsFixed(2)}',
              valueColor: themeColor.primary,
            ),
          _buildPriceRow('运费', _freight > 0 ? '¥${_freight.toStringAsFixed(2)}' : '免运费'),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
          Text(value, style: TextStyle(fontSize: 13, color: valueColor ?? const Color(0xFF333333))),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeColorData themeColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const Text('合计: ', style: TextStyle(fontSize: 14)),
            Text(
              '¥${_totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: themeColor.price),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _submitOrder,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                decoration: BoxDecoration(
                  color: themeColor.primary,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Text('提交订单', style: TextStyle(fontSize: 15, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitOrder() {
    if (_selectedAddress == null) {
      FlutterToastPro.showMessage( '请选择收货地址');
      return;
    }

    // 提交订单逻辑
    Get.toNamed(AppRoutes.orderPayStatus, parameters: {'order_id': '123456', 'remark': _remark});
  }
}


