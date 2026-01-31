import 'package:shuhang_mall_flutter/constant/app_constant.dart';
import 'package:shuhang_mall_flutter/app/data/models/cart_model.dart';

/// 订单列表项模型
class OrderListItem {
  final int id;
  final String orderId;
  final int totalNum;
  final double payPrice;
  final int status;
  final String deliveryType;
  final int shippingType;
  final bool isAllRefund;
  final int refundCount;
  final OrderListStatusInfo statusInfo;
  final List<CartItem> cartInfo;

  const OrderListItem({
    required this.id,
    required this.orderId,
    required this.totalNum,
    required this.payPrice,
    required this.status,
    required this.deliveryType,
    required this.shippingType,
    required this.isAllRefund,
    required this.refundCount,
    required this.statusInfo,
    required this.cartInfo,
  });

  factory OrderListItem.fromJson(Map<String, dynamic> json) {
    return OrderListItem(
      id: stringToInt(json['id']),
      orderId: json['order_id']?.toString() ?? '',
      totalNum: stringToInt(json['total_num']),
      payPrice: stringToDouble(json['pay_price']),
      status: stringToInt(json['status']),
      deliveryType: json['delivery_type']?.toString() ?? '',
      shippingType: stringToInt(json['shipping_type']),
      isAllRefund: _toBool(json['is_all_refund']),
      refundCount: _refundCount(json['refund']),
      statusInfo: OrderListStatusInfo.fromJson(_asMap(json['_status'])),
      cartInfo: _parseCartItems(json['cartInfo']),
    );
  }

  static List<CartItem> _parseCartItems(dynamic value) {
    if (value is! List) return const <CartItem>[];
    return value
        .whereType<Map>()
        .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == '1' || lower == 'true';
    }
    return false;
  }

  static int _refundCount(dynamic value) {
    if (value is List) return value.length;
    return 0;
  }
}

/// 订单状态信息
class OrderListStatusInfo {
  final int type;
  final String title;
  final String message;

  const OrderListStatusInfo({required this.type, required this.title, required this.message});

  factory OrderListStatusInfo.fromJson(Map<String, dynamic> json) {
    return OrderListStatusInfo(
      type: stringToInt(json['_type']),
      title: json['_title']?.toString() ?? '',
      message: json['_msg']?.toString() ?? '',
    );
  }
}
