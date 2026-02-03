import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/data/models/address_model.dart';
import 'package:shuhang_mall_flutter/app/data/providers/order_provider.dart';
import 'package:shuhang_mall_flutter/app/data/providers/public_provider.dart';
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
  final PublicProvider _publicProvider = PublicProvider();

  AddressItem? _selectedAddress;
  Map<String, dynamic>? _selectedCoupon;
  String _remark = '';

  String? _cartId;
  int _pinkId = 0;
  int _couponId = 0;
  String _news = '0';
  int _noCoupon = 0;
  int _addressId = 0;
  int _shippingType = 0;
  int _bargainId = 0;
  int _combinationId = 0;
  int _discountId = 0;
  int _seckillId = 0;
  int _advanceId = 0;
  int _storeId = 0;
  String _from = '';
  int _invoiceId = 0;
  int _virtualType = 0;
  String _payType = '';
  bool _isLoading = false;
  bool _isSubmitting = false;
  String _orderKey = '';
  bool _hasWarnedNoCartId = false;

  final List<_OrderConfirmItemData> _orderItems = <_OrderConfirmItemData>[];
  final List<Map<String, dynamic>> _couponList = <Map<String, dynamic>>[];

  double _goodsTotal = 0;
  double _freight = 0;
  final List<PaymentMethod> _paymentMethods = <PaymentMethod>[];

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
    final args = Get.arguments is Map
        ? Map<String, dynamic>.from(Get.arguments)
        : <String, dynamic>{};
    _cartId = _normalizeCartId(
      params['cartId'] ??
          params['cart_id'] ??
          params['cartIds'] ??
          params['cart_ids'] ??
          params['id'] ??
          args['cartId'] ??
          args['cart_id'] ??
          args['cartIds'] ??
          args['cart_ids'] ??
          args['id'],
    );
    _addressId = _toInt(params['addressId'] ?? args['addressId']);
    _pinkId = _toInt(params['pinkId'] ?? args['pinkId']);
    _couponId = _toInt(params['couponId'] ?? args['couponId']);
    _news =
        params['new'] ??
        params['news'] ??
        args['new']?.toString() ??
        args['news']?.toString() ??
        '0';
    _noCoupon = _toInt(params['noCoupon'] ?? args['noCoupon']);
    _shippingType = _toInt(params['shippingType'] ?? args['shippingType']);
    _bargainId = _toInt(params['bargainId'] ?? args['bargainId']);
    _combinationId = _toInt(params['combinationId'] ?? args['combinationId']);
    _discountId = _toInt(params['discountId'] ?? args['discountId']);
    _seckillId = _toInt(params['seckillId'] ?? args['seckillId']);
    _advanceId = _toInt(params['advanceId'] ?? args['advanceId']);
    _storeId = _toInt(params['storeId'] ?? args['storeId']);
    _invoiceId = _toInt(params['invoiceId'] ?? args['invoiceId']);
    _from = (params['from'] ?? args['from'] ?? '').toString();
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
      if (response.isSuccess && response.data != null && response.msg != 'empty') {
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
    if (_cartId == null || _cartId!.isEmpty) {
      if (!_hasWarnedNoCartId) {
        _hasWarnedNoCartId = true;
        FlutterToastPro.showMessage('请先选择要购买的商品');
      }
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _orderProvider.orderConfirm({
        'cartId': _cartId,
        'new': _news,
        'addressId': _addressId,
        'shipping_type': _shippingType + 1,
      });

      if (response.isSuccess && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final cartInfo = _parseCartInfo(data['cartInfo'] ?? data['cart_info']);
        final priceGroup = data['priceGroup'] ?? data['price_group'];
        final priceGroupPostage = priceGroup is Map
            ? _toDouble(priceGroup['storePostage'] ?? priceGroup['store_postage'])
            : 0.0;

        setState(() {
          _orderItems
            ..clear()
            ..addAll(cartInfo);
          _goodsTotal = _calcGoodsTotalFromItems(cartInfo);
          final apiPostage = _toDouble(data['pay_postage']);
          _freight = apiPostage > 0 ? apiPostage : priceGroupPostage;
          _orderKey = data['orderKey']?.toString() ?? _orderKey;
          _virtualType = _toInt(data['virtual_type'] ?? data['virtualType']);
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

        final goodsCount = _orderItems.fold<int>(0, (sum, item) => sum + item.quantity);

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(title: const Text('提交订单'), backgroundColor: const Color(0xFFF5F5F5)),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _OrderConfirmAddressSection(
                        themeColor: themeColor,
                        selectedAddress: _selectedAddress,
                        onTap: _openAddressList,
                      ),

                      _OrderConfirmGoodsSection(
                        isLoading: _isLoading,
                        items: _orderItems,
                        goodsCount: goodsCount,
                      ),
                      const SizedBox(height: 10),
                      _OrderConfirmPriceSection(
                        goodsTotal: _goodsTotal,
                        freight: _freight,
                        themeColor: themeColor,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              _OrderConfirmBottomBar(
                themeColor: themeColor,
                totalPrice: _totalPrice,
                onSubmit: _submitOrder,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openAddressList() async {
    final result = await Get.toNamed(
      AppRoutes.userAddressList,
      parameters: {
        'cartId': _cartId ?? '',
        'pinkId': _pinkId.toString(),
        'couponId': _couponId.toString(),
        'new': _news,
        'noCoupon': _noCoupon.toString(),
      },
    );

    if (result is int) {
      await _loadAddressDetail(result);
    }
  }

  Future<void> _submitOrder() async {
    if (_virtualType == 0 && _selectedAddress == null) {
      FlutterToastPro.showMessage('请选择收货地址');
      return;
    }

    if (_orderKey.isEmpty) {
      FlutterToastPro.showMessage('订单信息未准备好');
      return;
    }

    await _ensurePaymentMethods();
    _payType = _payType.isNotEmpty ? _payType : _resolveDefaultPayType();
    if (_payType.isEmpty) {
      FlutterToastPro.showMessage('暂无可用支付方式');
      return;
    }

    _createOrder(_payType);
  }

  Future<void> _ensurePaymentMethods() async {
    if (_paymentMethods.isNotEmpty) return;

    double balance = 0;
    try {
      final userResponse = await _userProvider.getUserInfo();
      if (userResponse.isSuccess && userResponse.data != null) {
        balance = userResponse.data!.balance;
      }
    } catch (e) {
      FlutterToastPro.showMessage('获取用户余额失败');
    }

    bool weixinEnabled = true;
    bool alipayEnabled = true;
    bool yueEnabled = true;
    bool offlineEnabled = true;
    bool friendEnabled = true;

    try {
      final configResponse = await _publicProvider.getShopConfig();
      if (configResponse.isSuccess && configResponse.data is Map) {
        final map = Map<String, dynamic>.from(configResponse.data as Map);
        weixinEnabled = _readConfigFlag(map, ['pay_weixin_open', 'pay_weixin', 'weixin_open']);
        alipayEnabled = _readConfigFlag(map, ['ali_pay_status', 'pay_alipay', 'alipay_open']);
        yueEnabled = _readConfigFlag(map, ['yue_pay_status', 'pay_yue', 'yue_open']);
        offlineEnabled = _readConfigFlag(map, [
          'offline_pay_status',
          'pay_offline',
          'offline_open',
        ]);
        friendEnabled = _readConfigFlag(map, ['friend_pay_status', 'pay_friend', 'friend_open']);
      }
    } catch (e) {
      FlutterToastPro.showMessage('获取支付配置失败');
    }

    setState(() {
      _paymentMethods
        ..clear()
        ..addAll([
          PaymentMethod.weixin(enabled: weixinEnabled),
          PaymentMethod.alipay(enabled: alipayEnabled),
          PaymentMethod.yue(userBalance: balance, enabled: yueEnabled),
          PaymentMethod.offline(enabled: offlineEnabled),
          PaymentMethod.friend(enabled: friendEnabled),
        ]);
    });
  }

  String _resolveDefaultPayType() {
    for (final method in _paymentMethods) {
      if (method.enabled) return method.type;
    }
    return '';
  }

  Future<void> _createOrder(String payType) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final payload = _buildOrderCreatePayload(payType);
      final response = await _orderProvider.createOrderWithKey(_orderKey, payload);

      if (response.isSuccess) {
        final orderId = _extractOrderId(response.data);
        if (orderId.isNotEmpty) {
          Get.offNamed(AppRoutes.cashier, arguments: {'order_id': orderId, 'from_type': 'order'});
          return;
        } else {
          FlutterToastPro.showMessage(response.msg.isNotEmpty ? response.msg : '订单创建失败');
        }
      } else {
        FlutterToastPro.showMessage(response.msg.isNotEmpty ? response.msg : '订单创建失败');
      }
    } catch (e) {
      FlutterToastPro.showMessage('提交订单失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Map<String, dynamic> _buildOrderCreatePayload(String payType) {
    return {
      'custom_form': <dynamic>[],
      'real_name': _selectedAddress?.realName ?? '',
      'phone': _selectedAddress?.phone ?? '',
      'addressId': _addressId,
      'couponId': _couponId,
      'useIntegral': 0,
      'bargainId': _bargainId,
      'combinationId': _combinationId,
      'discountId': _discountId,
      'seckill_id': _seckillId,
      'advanceId': _advanceId,
      'pinkId': _pinkId,
      'mark': _remark,
      'store_id': _storeId,
      'from': _from,
      'shipping_type': _shippingType + 1,
      'new': _news,
      'invoice_id': _invoiceId,
      'payType': payType,
    };
  }

  String _extractOrderId(dynamic data) {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final result = map['result'];
      if (result is Map) {
        final id = result['orderId'] ?? result['order_id'] ?? result['orderId'];
        if (id != null) return id.toString();
      }
      final id = map['orderId'] ?? map['order_id'] ?? map['orderId'];
      if (id != null) return id.toString();
    }
    return '';
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String? _normalizeCartId(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      final items = value.map((item) => item.toString()).where((item) => item.isNotEmpty).toList();
      if (items.isEmpty) return null;
      return items.join(',');
    }
    final text = value.toString();
    if (text.isEmpty || text == '0' || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool _readConfigFlag(Map<String, dynamic> map, List<String> keys, {bool defaultValue = true}) {
    for (final key in keys) {
      if (!map.containsKey(key)) continue;
      final value = map[key];
      if (value is bool) return value;
      return _toInt(value) == 1;
    }
    return defaultValue;
  }

  List<_OrderConfirmItemData> _parseCartInfo(dynamic value) {
    final rawList = _extractCartInfoRaw(value);
    return rawList.map(_parseOrderItemData).toList();
  }

  List<Map<String, dynamic>> _extractCartInfoRaw(dynamic value) {
    if (value is List) {
      return value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    }
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      final list = map['valid'] ?? map['cartInfo'] ?? map['cart_info'];
      if (list is List) {
        return list.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
      }
    }
    return <Map<String, dynamic>>[];
  }

  _OrderConfirmItemData _parseOrderItemData(Map<String, dynamic> raw) {
    final productInfo = _asMap(raw['productInfo'] ?? raw['product_info']);
    final cartInfo = _asMap(raw['cart_info']);
    final info = productInfo.isNotEmpty ? productInfo : cartInfo;
    final attrInfo = _asMap(info['attrInfo'] ?? info['attr_info']);

    final name = _readString(info, ['store_name', 'storeName']) ?? '';
    final image = _readString(attrInfo, ['image']) ?? _readString(info, ['image']) ?? '';
    final spec = _readString(attrInfo, ['suk']) ?? '默认';
    final quantity = _readInt(raw, ['cart_num', 'cartNum']) ?? 0;
    final price =
        _readDouble(attrInfo, ['price']) ??
        _readDouble(info, ['price']) ??
        _readDouble(raw, ['price', 'true_price', 'truePrice']) ??
        0.0;

    return _OrderConfirmItemData(
      name: name,
      image: image,
      spec: spec,
      price: price,
      quantity: quantity,
    );
  }

  double _calcGoodsTotalFromItems(List<_OrderConfirmItemData> items) {
    double total = 0;
    for (final item in items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  String? _readString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }

  int? _readInt(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      final parsed = _toInt(value);
      if (parsed > 0) return parsed;
    }
    return null;
  }

  double? _readDouble(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      final parsed = _toDouble(value);
      if (parsed > 0) return parsed;
    }
    return null;
  }
}

String _formatVoucher(double value, {bool showDecimal = true}) {
  if (!showDecimal) {
    return '消费券${value.toStringAsFixed(0)}';
  }
  return '消费券${value.toStringAsFixed(2)}';
}

class _OrderConfirmAddressSection extends StatelessWidget {
  const _OrderConfirmAddressSection({
    required this.themeColor,
    required this.selectedAddress,
    required this.onTap,
  });

  final ThemeColorData themeColor;
  final AddressItem? selectedAddress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: selectedAddress == null
                ? Row(
                    children: [
                      const Text(
                        '设置收货地址',
                        style: TextStyle(color: Color(0xFF333333), fontSize: 14),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: Color(0xFF999999)),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  selectedAddress!.realName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF282828),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  selectedAddress!.phone,
                                  style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${selectedAddress!.province}'
                              '${selectedAddress!.city}'
                              '${selectedAddress!.district}'
                              '${selectedAddress!.detail}',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Color(0xFF999999)),
                    ],
                  ),
          ),
          Image.asset(
            'assets/images/line.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 1.5,
          ),
        ],
      ),
    );
  }
}

class _OrderConfirmGoodsSection extends StatelessWidget {
  const _OrderConfirmGoodsSection({
    required this.isLoading,
    required this.items,
    required this.goodsCount,
  });

  final bool isLoading;
  final List<_OrderConfirmItemData> items;
  final int goodsCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
            ),
            child: Row(
              children: [
                Text(
                  '共$goodsCount件商品',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF282828)),
                ),
              ],
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            ...items.map((item) => _OrderConfirmGoodsItem(item: item)),
        ],
      ),
    );
  }
}

class _OrderConfirmGoodsItem extends StatelessWidget {
  const _OrderConfirmGoodsItem({required this.item});

  final _OrderConfirmItemData item;

  @override
  Widget build(BuildContext context) {
    final image = item.image;
    final name = item.name;
    final spec = item.spec;
    final price = item.price;

    return Container(
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: image.isNotEmpty
                ? CachedImage(imageUrl: image, width: 80, height: 80, borderRadius: 6)
                : const Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF282828)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'x${item.quantity}',
                      style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(spec, style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                const SizedBox(height: 8),
                Text(
                  _formatVoucher(price),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE93323),
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

class _OrderConfirmPriceSection extends StatelessWidget {
  const _OrderConfirmPriceSection({
    required this.goodsTotal,
    required this.freight,
    required this.themeColor,
  });

  final double goodsTotal;
  final double freight;
  final ThemeColorData themeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          _OrderConfirmPriceRow(
            label: '商品总价',
            value: _formatVoucher(goodsTotal),
            valueColor: const Color(0xFF333333),
            isBold: true,
          ),
          const SizedBox(height: 10),
          _OrderConfirmPriceRow(
            label: '运费',
            value: freight > 0 ? _formatVoucher(freight) : '免运费',
            valueColor: const Color(0xFF000000),
          ),
          const Divider(height: 24, color: Color(0xFFF0F0F0)),
          _OrderConfirmPriceRow(
            label: '商品总价',
            value: _formatVoucher(goodsTotal),
            valueColor: themeColor.primary,
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _OrderConfirmPriceRow extends StatelessWidget {
  const _OrderConfirmPriceRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: valueColor ?? const Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}

class _OrderConfirmItemData {
  const _OrderConfirmItemData({
    required this.name,
    required this.image,
    required this.spec,
    required this.price,
    required this.quantity,
  });

  final String name;
  final String image;
  final String spec;
  final double price;
  final int quantity;
}

class _OrderConfirmBottomBar extends StatelessWidget {
  const _OrderConfirmBottomBar({
    required this.themeColor,
    required this.totalPrice,
    required this.onSubmit,
  });

  final ThemeColorData themeColor;
  final double totalPrice;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const Text('合计:', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              _formatVoucher(totalPrice, showDecimal: false),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeColor.primary,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onSubmit,
              child: Container(
                width: 120,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: themeColor.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('提交订单', style: TextStyle(fontSize: 14, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
