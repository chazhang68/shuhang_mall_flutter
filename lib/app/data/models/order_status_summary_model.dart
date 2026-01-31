import 'package:shuhang_mall_flutter/constant/app_constant.dart';

/// 订单状态统计模型
class OrderStatusSummary {
  final int orderCount;
  final double sumPrice;
  final int unpaidCount;
  final int unshippedCount;
  final int receivedCount;
  final int evaluatedCount;
  final int completeCount;
  final int refundingCount;
  final int noRefundCount;
  final int refundedCount;
  final int refundCount;
  final int yuePayStatus;
  final int pcOrderCount;
  final bool payWeixinOpen;
  final bool aliPayStatus;
  final int friendPayStatus;

  const OrderStatusSummary({
    required this.orderCount,
    required this.sumPrice,
    required this.unpaidCount,
    required this.unshippedCount,
    required this.receivedCount,
    required this.evaluatedCount,
    required this.completeCount,
    required this.refundingCount,
    required this.noRefundCount,
    required this.refundedCount,
    required this.refundCount,
    required this.yuePayStatus,
    required this.pcOrderCount,
    required this.payWeixinOpen,
    required this.aliPayStatus,
    required this.friendPayStatus,
  });

  factory OrderStatusSummary.fromJson(Map<String, dynamic> json) {
    return OrderStatusSummary(
      orderCount: stringToInt(json['order_count']),
      sumPrice: stringToDouble(json['sum_price']),
      unpaidCount: stringToInt(json['unpaid_count']),
      unshippedCount: stringToInt(json['unshipped_count']),
      receivedCount: stringToInt(json['received_count']),
      evaluatedCount: stringToInt(json['evaluated_count']),
      completeCount: stringToInt(json['complete_count']),
      refundingCount: stringToInt(json['refunding_count']),
      noRefundCount: stringToInt(json['no_refund_count']),
      refundedCount: stringToInt(json['refunded_count']),
      refundCount: stringToInt(json['refund_count']),
      yuePayStatus: stringToInt(json['yue_pay_status']),
      pcOrderCount: stringToInt(json['pc_order_count']),
      payWeixinOpen: _toBool(json['pay_weixin_open']),
      aliPayStatus: _toBool(json['ali_pay_status']),
      friendPayStatus: stringToInt(json['friend_pay_status']),
    );
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
}
