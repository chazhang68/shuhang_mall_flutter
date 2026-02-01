import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/data/models/address_model.dart';
import 'package:shuhang_mall_flutter/app/data/models/cart_model.dart';
import 'package:shuhang_mall_flutter/app/data/providers/order_provider.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
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
  final UserProvider _userProvider = UserProvider();
  final OrderProvider _orderProvider = OrderProvider();

  AddressItem? _selectedAddress;
  Map<String, dynamic>? _selectedCoupon;
  String _remark = '';
  int _payType = 0; // 0: 在线支付

  String? _cartId;
  int _pinkId = 0;
  int _couponId = 0;
  String _news = '0';
  int _noCoupon = 0;
  int _addressId = 0;
  int _shippingType = 1;
  bool _isLoading = false;
  String _orderKey = '';

  final List<CartItem> _orderItems = <CartItem>[];
  final List<Map<String, dynamic>> _couponList = <Map<String, dynamic>>[];

  double _goodsTotal = 0;
  double _freight = 0;

  double get _couponDiscount {
    return _selectedCoupon?['coupon_price']?.toDouble() ?? 0.0;
  }

  double get _totalPrice {
    return _goodsTotal - _couponDiscount + _freight;
  }

  @override
  void initState() {
    super.initState();
    _bindParams();
    _loadInitialAddress();
    _loadOrderConfirm();
  }

  void _bindParams() {
    final params = Get.parameters;
    _cartId = params['cartId'];
    _addressId = _toInt(params['addressId']);
    _pinkId = _toInt(params['pinkId']);
    _couponId = _toInt(params['couponId']);
    _news = params['new'] ?? params['news'] ?? '0';
    _noCoupon = _toInt(params['noCoupon']);
  }

  Future<void> _loadInitialAddress() async {
    if (_addressId > 0) {
      await _loadAddressDetail(_addressId);
      return;
    }

    await _loadDefaultAddress();
  }

  Future<void> _loadDefaultAddress() async {
    try {
      final response = await _userProvider.getAddressDefault();
      if (response.isSuccess && response.data != null) {
        setState(() {
          _selectedAddress = AddressItem.fromJson(response.data as Map<String, dynamic>);
          _addressId = _selectedAddress?.id ?? _addressId;
        });
        _loadOrderConfirm();
      }
    } catch (e) {
      FlutterToastPro.showMessage('获取默认地址失败: $e');
    }
  }

  Future<void> _loadAddressDetail(int id) async {
    try {
      final response = await _userProvider.getAddressDetail(id);
      if (response.isSuccess && response.data != null) {
        setState(() {
          _selectedAddress = AddressItem.fromJson(response.data as Map<String, dynamic>);
        });
        _addressId = id;
        _loadOrderConfirm();
      }
    } catch (e) {
      FlutterToastPro.showMessage('获取地址详情失败: $e');
    }
  }

  Future<void> _loadOrderConfirm() async {
    if (_cartId == null || _cartId!.isEmpty) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _orderProvider.orderConfirm({
        'cartId': _cartId,
        'new': _news,
        'addressId': _addressId,
        'shipping_type': _shippingType,
      });

      if (response.isSuccess && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final cartInfo = _parseCartInfo(data['cartInfo'] ?? data['cart_info']);

        setState(() {
          _orderItems
            ..clear()
            ..addAll(cartInfo);
          final apiTotal = _toDouble(data['total_price']);
          _goodsTotal = apiTotal > 0 ? apiTotal : _calcGoodsTotal(cartInfo);
          _freight = _toDouble(data['pay_postage']);
          _orderKey = data['orderKey']?.toString() ?? _orderKey;
        });

        await _loadCouponList();
      } else {
        FlutterToastPro.showMessage(response.msg);
      }
    } catch (e) {
      FlutterToastPro.showMessage('获取订单信息失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCouponList() async {
    if (_cartId == null || _cartId!.isEmpty) return;

    try {
      final response = await _orderProvider.getCouponsOrderPrice(_goodsTotal, {
        'cartId': _cartId,
        'new': _news,
        'shippingType': _shippingType,
      });

      if (response.isSuccess && response.data is List) {
        setState(() {
          _couponList
            ..clear()
            ..addAll(List<Map<String, dynamic>>.from(response.data as List));
          _selectedCoupon = _resolveSelectedCoupon();
          _couponId = _selectedCoupon?['id'] ?? _couponId;
        });
      }
    } catch (e) {
      FlutterToastPro.showMessage('获取优惠券失败: $e');
    }
  }

  Map<String, dynamic>? _resolveSelectedCoupon() {
    if (_couponId <= 0) return _selectedCoupon;
    for (final item in _couponList) {
      if (item['id'] == _couponId) {
        return item;
      }
    }
    return _selectedCoupon;
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
        final result = await Get.toNamed(
          AppRoutes.userAddressList,
          parameters: {
            if (_cartId != null) 'cartId': _cartId!,
            'pinkId': _pinkId.toString(),
            'couponId': _couponId.toString(),
            'new': _news,
            'noCoupon': _noCoupon.toString(),
          },
        );

        if (result is int) {
          await _loadAddressDetail(result);
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
                              _selectedAddress!.realName,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _selectedAddress!.phone,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_selectedAddress!.province}${_selectedAddress!.city}'
                          '${_selectedAddress!.district}${_selectedAddress!.detail}',
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
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            ..._orderItems.map(_buildGoodsItem),
        ],
      ),
    );
  }

  Widget _buildGoodsItem(CartItem item) {
    final productInfo = item.productInfo;
    final image = productInfo?.attrInfo?.image ?? productInfo?.image ?? '';
    final name = productInfo?.storeName ?? '';
    final spec = productInfo?.attrInfo?.suk ?? '';
    final price = item.unitPrice;

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
            child: image.isNotEmpty
                ? CachedImage(imageUrl: image, width: 80, height: 80, borderRadius: 8)
                : const Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          // 商品信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(spec, style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '¥${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE93323),
                      ),
                    ),
                    Text(
                      'x${item.cartNum}',
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
        final result = await CouponDialog.show(
          couponList: _couponList,
          selectedId: _selectedCoupon?['id'],
        );
        if (result != null) {
          setState(() {
            _selectedCoupon = result;
            _couponId = result['id'] ?? 0;
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
      FlutterToastPro.showMessage('请选择收货地址');
      return;
    }

    // 提交订单逻辑
    Get.toNamed(AppRoutes.orderPayStatus, parameters: {'order_id': '123456', 'remark': _remark});
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  List<CartItem> _parseCartInfo(dynamic value) {
    if (value is! List) return <CartItem>[];
    return value
        .whereType<Map>()
        .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  double _calcGoodsTotal(List<CartItem> items) {
    double total = 0;
    for (final item in items) {
      total += item.unitPrice * item.cartNum;
    }
    return total;
  }
}
