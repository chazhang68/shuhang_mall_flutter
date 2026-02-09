// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  uid: (json['uid'] as num).toInt(),
  nickname: json['nickname'] as String,
  avatar: json['avatar'] as String,
  phone: json['phone'] as String,
  realName: json['real_name'] as String?,
  sex: json['sex'] as String?,
  level: (json['level'] as num?)?.toInt(),
  levelName: json['level_name'] as String?,
  isPromoter: json['is_promoter'] == null
      ? false
      : _intToBool(json['is_promoter']),
  spreadUid: (json['spread_uid'] as num?)?.toInt() ?? 0,
  spreadNickname: json['spread_nickname'] as String?,
  balance: json['now_money'] == null ? 0 : stringToDouble(json['now_money']),
  integral: json['integral'] == null ? 0 : stringToDouble(json['integral']),
  brokeragePrice: json['brokerage_price'] == null
      ? 0
      : stringToDouble(json['brokerage_price']),
  fudou: json['fudou'] == null ? 0 : stringToDouble(json['fudou']),
  fdKy: json['fd_ky'] == null ? 0 : stringToDouble(json['fd_ky']),
  fubao: json['fubao'] == null ? 0 : stringToDouble(json['fubao']),
  gxz: json['gxz'] == null ? 0 : stringToDouble(json['gxz']),
  ryz: json['ryz'] == null ? 0 : stringToDouble(json['ryz']),
  xfqSxf: json['xfq_sxf'] == null ? 0 : stringToDouble(json['xfq_sxf']),
  couponCount: _readCouponCount(json, 'coupon_count') == null
      ? 0
      : stringToInt(_readCouponCount(json, 'coupon_count')),
  collectCount: _readCollectCount(json, 'collect_count') == null
      ? 0
      : stringToInt(_readCollectCount(json, 'collect_count')),
  visitCount: _readVisitCount(json, 'visit_count') == null
      ? 0
      : stringToInt(_readVisitCount(json, 'visit_count')),
  orderCount: _readOrderCount(json, 'order_count') == null
      ? 0
      : stringToInt(_readOrderCount(json, 'order_count')),
  isBindPhone: _intToBool(json['is_bind_phone']),
  isRealName: _intToBool(json['is_real_name']),
  isSign: json['is_sign'] == null ? false : _intToBool(json['is_sign']),
  task: (json['task'] as num?)?.toInt() ?? 0,
  vipStatus: (json['vip_status'] as num?)?.toInt(),
  vipEndTime: json['vip_end_time'] as String?,
  addTime: stringToInt(json['add_time']),
  lastLoginTime: stringToInt(json['last_login_time']),
  extra: json['extra'] as Map<String, dynamic>?,
  code: json['code'] as String?,
  agentLevel: json['agent_level'] == null
      ? 0
      : stringToInt(json['agent_level']),
  isVip: json['is_vip'] == null ? false : _intToBool(json['is_vip']),
  h5Open: json['h5_open'] == null ? false : _intToBool(json['h5_open']),
  orderStatusNum: _readOrderStatusNum(json, 'order_status_num') == null
      ? null
      : OrderStatusNum.fromJson(
          _readOrderStatusNum(json, 'order_status_num') as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'uid': instance.uid,
  'nickname': instance.nickname,
  'avatar': instance.avatar,
  'phone': instance.phone,
  'real_name': instance.realName,
  'sex': instance.sex,
  'level': instance.level,
  'level_name': instance.levelName,
  'is_promoter': _boolToInt(instance.isPromoter),
  'spread_uid': instance.spreadUid,
  'spread_nickname': instance.spreadNickname,
  'now_money': instance.balance,
  'integral': instance.integral,
  'brokerage_price': instance.brokeragePrice,
  'fudou': instance.fudou,
  'fd_ky': instance.fdKy,
  'fubao': instance.fubao,
  'gxz': instance.gxz,
  'ryz': instance.ryz,
  'xfq_sxf': instance.xfqSxf,
  'coupon_count': instance.couponCount,
  'collect_count': instance.collectCount,
  'visit_count': instance.visitCount,
  'order_count': instance.orderCount,
  'is_bind_phone': instance.isBindPhone,
  'is_real_name': instance.isRealName,
  'is_sign': instance.isSign,
  'task': instance.task,
  'vip_status': instance.vipStatus,
  'vip_end_time': instance.vipEndTime,
  'add_time': instance.addTime,
  'last_login_time': instance.lastLoginTime,
  'extra': instance.extra,
  'code': instance.code,
  'agent_level': instance.agentLevel,
  'is_vip': _boolToInt(instance.isVip),
  'h5_open': _boolToInt(instance.h5Open),
  'order_status_num': instance.orderStatusNum,
};

OrderStatusNum _$OrderStatusNumFromJson(Map<String, dynamic> json) =>
    OrderStatusNum(
      unpaidCount: json['unpaid_count'] == null
          ? 0
          : stringToInt(json['unpaid_count']),
      unshippedCount: json['unshipped_count'] == null
          ? 0
          : stringToInt(json['unshipped_count']),
      receivedCount: json['received_count'] == null
          ? 0
          : stringToInt(json['received_count']),
      evaluatedCount: json['evaluated_count'] == null
          ? 0
          : stringToInt(json['evaluated_count']),
      refundingCount: json['refunding_count'] == null
          ? 0
          : stringToInt(json['refunding_count']),
    );

Map<String, dynamic> _$OrderStatusNumToJson(OrderStatusNum instance) =>
    <String, dynamic>{
      'unpaid_count': instance.unpaidCount,
      'unshipped_count': instance.unshippedCount,
      'received_count': instance.receivedCount,
      'evaluated_count': instance.evaluatedCount,
      'refunding_count': instance.refundingCount,
    };
