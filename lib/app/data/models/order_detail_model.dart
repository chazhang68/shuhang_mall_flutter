import 'package:shuhang_mall_flutter/constant/app_constant.dart';
import 'package:shuhang_mall_flutter/app/data/models/cart_model.dart';

/// 订单详情模型
class OrderDetailModel {
  final int id;
  final int pid;
  final String orderId;
  final int uid;
  final String realName;
  final String userPhone;
  final String userAddress;
  final int totalNum;
  final double totalPrice;
  final double payPrice;
  final double couponPrice;
  final double payPostage;
  final int paid;
  final int status;
  final int refundStatus;
  final int refundType;
  final String addTimeY;
  final String addTimeH;
  final String payTime;
  final String addTime;
  final String statusPic;
  final bool invoiceFunc;
  final bool specialInvoice;
  final int yuePayStatus;
  final bool payWeixinOpen;
  final bool aliPayStatus;
  final int friendPayStatus;
  final bool orderShippingOpen;
  final OrderStatusInfo statusInfo;
  final OrderLog? orderLog;
  final HelpInfo? helpInfo;
  final List<CartItem> cartInfo;
  final List<CartItem> refundCartInfo;

  const OrderDetailModel({
    required this.id,
    required this.pid,
    required this.orderId,
    required this.uid,
    required this.realName,
    required this.userPhone,
    required this.userAddress,
    required this.totalNum,
    required this.totalPrice,
    required this.payPrice,
    required this.couponPrice,
    required this.payPostage,
    required this.paid,
    required this.status,
    required this.refundStatus,
    required this.refundType,
    required this.addTimeY,
    required this.addTimeH,
    required this.payTime,
    required this.addTime,
    required this.statusPic,
    required this.invoiceFunc,
    required this.specialInvoice,
    required this.yuePayStatus,
    required this.payWeixinOpen,
    required this.aliPayStatus,
    required this.friendPayStatus,
    required this.orderShippingOpen,
    required this.statusInfo,
    required this.orderLog,
    required this.helpInfo,
    required this.cartInfo,
    required this.refundCartInfo,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: stringToInt(json['id']),
      pid: stringToInt(json['pid']),
      orderId: json['order_id']?.toString() ?? '',
      uid: stringToInt(json['uid']),
      realName: json['real_name']?.toString() ?? '',
      userPhone: json['user_phone']?.toString() ?? '',
      userAddress: json['user_address']?.toString() ?? '',
      totalNum: stringToInt(json['total_num']),
      totalPrice: stringToDouble(json['total_price']),
      payPrice: stringToDouble(json['pay_price']),
      couponPrice: stringToDouble(json['coupon_price']),
      payPostage: stringToDouble(json['pay_postage']),
      paid: stringToInt(json['paid']),
      status: stringToInt(json['status']),
      refundStatus: stringToInt(json['refund_status']),
      refundType: stringToInt(json['refund_type']),
      addTimeY: json['add_time_y']?.toString() ?? '',
      addTimeH: json['add_time_h']?.toString() ?? '',
      payTime: json['_pay_time']?.toString() ?? '',
      addTime: json['_add_time']?.toString() ?? '',
      statusPic: json['status_pic']?.toString() ?? '',
      invoiceFunc: _toBool(json['invoice_func']),
      specialInvoice: _toBool(json['special_invoice']),
      yuePayStatus: stringToInt(json['yue_pay_status']),
      payWeixinOpen: _toBool(json['pay_weixin_open']),
      aliPayStatus: _toBool(json['ali_pay_status']),
      friendPayStatus: stringToInt(json['friend_pay_status']),
      orderShippingOpen: _toBool(json['order_shipping_open']),
      statusInfo: OrderStatusInfo.fromJson(_asMap(json['_status'])),
      orderLog: OrderLog.fromJson(_asMap(json['order_log'])),
      helpInfo: HelpInfo.fromJson(_asMap(json['help_info'])),
      cartInfo: _parseCartItems(json['cartInfo']),
      refundCartInfo: _parseCartItems(json['refund_cartInfo']),
    );
  }

  static List<CartItem> _parseCartItems(dynamic value) {
    if (value is! List) return const <CartItem>[];
    return value
        .whereType<Map>()
        .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
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

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }
}

/// 订单状态信息
class OrderStatusInfo {
  final int type;
  final String title;
  final String message;
  final String payType;
  final String deliveryType;

  const OrderStatusInfo({
    required this.type,
    required this.title,
    required this.message,
    required this.payType,
    required this.deliveryType,
  });

  factory OrderStatusInfo.fromJson(Map<String, dynamic> json) {
    return OrderStatusInfo(
      type: stringToInt(json['_type']),
      title: json['_title']?.toString() ?? '',
      message: json['_msg']?.toString() ?? '',
      payType: json['_payType']?.toString() ?? '',
      deliveryType: json['_deliveryType']?.toString() ?? '',
    );
  }
}

/// 订单日志
class OrderLog {
  final String create;
  final String pay;
  final String delivery;
  final String take;
  final String complete;

  const OrderLog({
    required this.create,
    required this.pay,
    required this.delivery,
    required this.take,
    required this.complete,
  });

  factory OrderLog.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty)
      return const OrderLog(create: '', pay: '', delivery: '', take: '', complete: '');
    return OrderLog(
      create: json['create']?.toString() ?? '',
      pay: json['pay']?.toString() ?? '',
      delivery: json['delivery']?.toString() ?? '',
      take: json['take']?.toString() ?? '',
      complete: json['complete']?.toString() ?? '',
    );
  }
}

/// 好友代付信息
class HelpInfo {
  final int payUid;
  final String payNickname;
  final String payAvatar;
  final int helpStatus;

  const HelpInfo({
    required this.payUid,
    required this.payNickname,
    required this.payAvatar,
    required this.helpStatus,
  });

  factory HelpInfo.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty)
      return const HelpInfo(payUid: 0, payNickname: '', payAvatar: '', helpStatus: 0);
    return HelpInfo(
      payUid: stringToInt(json['pay_uid']),
      payNickname: json['pay_nickname']?.toString() ?? '',
      payAvatar: json['pay_avatar']?.toString() ?? '',
      helpStatus: stringToInt(json['help_status']),
    );
  }
}
