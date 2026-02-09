import 'package:json_annotation/json_annotation.dart';
import 'package:shuhang_mall_flutter/constant/app_constant.dart';

part 'user_model.g.dart';

/// 用户模型
/// 对应后台返回的用户信息
@JsonSerializable(fieldRename: FieldRename.snake)
class UserModel {
  final int uid;
  final String nickname;
  final String avatar;
  final String phone;
  final String? realName;
  final String? sex; // 性别
  final int? level;
  final String? levelName;
  @JsonKey(fromJson: _intToBool, toJson: _boolToInt)
  final bool isPromoter; // 是否是推广员
  final int spreadUid; // 推广人ID
  final String? spreadNickname;
  @JsonKey(name: 'now_money', fromJson: stringToDouble)
  final double balance; // 余额 (now_money / 消费券)
  @JsonKey(fromJson: stringToDouble)
  final double integral; // 积分（消费券）
  @JsonKey(fromJson: stringToDouble)
  final double brokeragePrice; // 佣金
  @JsonKey(fromJson: stringToDouble)
  final double fudou; // 仓库积分
  @JsonKey(fromJson: stringToDouble)
  final double fdKy; // 可用积分
  @JsonKey(fromJson: stringToDouble)
  final double fubao; // 福宝
  @JsonKey(fromJson: stringToDouble)
  final double gxz; // 贡献值（燃料值）
  @JsonKey(fromJson: stringToDouble)
  final double ryz; // 荣誉值
  @JsonKey(fromJson: stringToDouble)
  final double xfqSxf; // 消费券手续费率（百分比）
  @JsonKey(fromJson: stringToInt, readValue: _readCouponCount)
  final int couponCount; // 优惠券数量
  @JsonKey(fromJson: stringToInt, readValue: _readCollectCount)
  final int collectCount; // 收藏数量
  @JsonKey(fromJson: stringToInt, readValue: _readVisitCount)
  final int visitCount; // 浏览记录数量
  @JsonKey(fromJson: stringToInt, readValue: _readOrderCount)
  final int orderCount; // 订单数量
  @JsonKey(fromJson: _intToBool)
  final bool? isBindPhone;
  @JsonKey(fromJson: _intToBool)
  final bool? isRealName; // 是否实名
  @JsonKey(fromJson: _intToBool)
  final bool isSign; // 是否实名认证
  final int task; // 任务完成数量
  final int? vipStatus; // 会员状态
  final String? vipEndTime;
  @JsonKey(fromJson: stringToInt)
  final int? addTime;
  @JsonKey(fromJson: stringToInt)
  final int? lastLoginTime;
  final Map<String, dynamic>? extra;

  // 新增字段 - 对应 uni-app 中的字段
  final String? code; // 邀请码
  @JsonKey(fromJson: stringToInt)
  final int agentLevel; // 代理等级
  @JsonKey(fromJson: _intToBool, toJson: _boolToInt)
  final bool isVip; // 是否是VIP
  @JsonKey(fromJson: _intToBool, toJson: _boolToInt)
  final bool h5Open; // 是否开启H5
  @JsonKey(readValue: _readOrderStatusNum)
  final OrderStatusNum? orderStatusNum; // 订单状态数量

  UserModel({
    required this.uid,
    required this.nickname,
    required this.avatar,
    required this.phone,
    this.realName,
    this.sex,
    this.level,
    this.levelName,
    this.isPromoter = false,
    this.spreadUid = 0,
    this.spreadNickname,
    this.balance = 0,
    this.integral = 0,
    this.brokeragePrice = 0,
    this.fudou = 0,
    this.fdKy = 0,
    this.fubao = 0,
    this.gxz = 0,
    this.ryz = 0,
    this.xfqSxf = 0,
    this.couponCount = 0,
    this.collectCount = 0,
    this.visitCount = 0,
    this.orderCount = 0,
    this.isBindPhone,
    this.isRealName,
    this.isSign = false,
    this.task = 0,
    this.vipStatus,
    this.vipEndTime,
    this.addTime,
    this.lastLoginTime,
    this.extra,
    this.code,
    this.agentLevel = 0,
    this.isVip = false,
    this.h5Open = false,
    this.orderStatusNum,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    int? uid,
    String? nickname,
    String? avatar,
    String? phone,
    String? realName,
    String? sex,
    int? level,
    String? levelName,
    bool? isPromoter,
    int? spreadUid,
    String? spreadNickname,
    double? balance,
    double? integral,
    double? brokeragePrice,
    double? fudou,
    double? fdKy,
    double? fubao,
    double? gxz,
    double? ryz,
    double? xfqSxf,
    int? couponCount,
    int? collectCount,
    int? visitCount,
    int? orderCount,
    bool? isBindPhone,
    bool? isRealName,
    bool? isSign,
    int? task,
    int? vipStatus,
    String? vipEndTime,
    int? addTime,
    int? lastLoginTime,
    Map<String, dynamic>? extra,
    String? code,
    int? agentLevel,
    bool? isVip,
    bool? h5Open,
    OrderStatusNum? orderStatusNum,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      realName: realName ?? this.realName,
      sex: sex ?? this.sex,
      level: level ?? this.level,
      levelName: levelName ?? this.levelName,
      isPromoter: isPromoter ?? this.isPromoter,
      spreadUid: spreadUid ?? this.spreadUid,
      spreadNickname: spreadNickname ?? this.spreadNickname,
      balance: balance ?? this.balance,
      integral: integral ?? this.integral,
      brokeragePrice: brokeragePrice ?? this.brokeragePrice,
      fudou: fudou ?? this.fudou,
      fdKy: fdKy ?? this.fdKy,
      fubao: fubao ?? this.fubao,
      gxz: gxz ?? this.gxz,
      ryz: ryz ?? this.ryz,
      xfqSxf: xfqSxf ?? this.xfqSxf,
      couponCount: couponCount ?? this.couponCount,
      collectCount: collectCount ?? this.collectCount,
      visitCount: visitCount ?? this.visitCount,
      orderCount: orderCount ?? this.orderCount,
      isBindPhone: isBindPhone ?? this.isBindPhone,
      isRealName: isRealName ?? this.isRealName,
      isSign: isSign ?? this.isSign,
      task: task ?? this.task,
      vipStatus: vipStatus ?? this.vipStatus,
      vipEndTime: vipEndTime ?? this.vipEndTime,
      addTime: addTime ?? this.addTime,
      lastLoginTime: lastLoginTime ?? this.lastLoginTime,
      extra: extra ?? this.extra,
      code: code ?? this.code,
      agentLevel: agentLevel ?? this.agentLevel,
      isVip: isVip ?? this.isVip,
      h5Open: h5Open ?? this.h5Open,
      orderStatusNum: orderStatusNum ?? this.orderStatusNum,
    );
  }
}

/// 订单状态数量模型
@JsonSerializable(fieldRename: FieldRename.snake)
class OrderStatusNum {
  @JsonKey(fromJson: stringToInt)
  final int unpaidCount; // 待付款
  @JsonKey(fromJson: stringToInt)
  final int unshippedCount; // 待发货
  @JsonKey(fromJson: stringToInt)
  final int receivedCount; // 待收货
  @JsonKey(fromJson: stringToInt)
  final int evaluatedCount; // 待评价
  @JsonKey(fromJson: stringToInt)
  final int refundingCount; // 售后/退款

  const OrderStatusNum({
    this.unpaidCount = 0,
    this.unshippedCount = 0,
    this.receivedCount = 0,
    this.evaluatedCount = 0,
    this.refundingCount = 0,
  });

  factory OrderStatusNum.fromJson(Map<String, dynamic> json) => _$OrderStatusNumFromJson(json);

  Map<String, dynamic> toJson() => _$OrderStatusNumToJson(this);
}

bool _intToBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value == '1' || value.toLowerCase() == 'true';
  return false;
}

int _boolToInt(bool value) => value ? 1 : 0;

Object? _readCouponCount(Map json, String key) => json[key] ?? json['couponCount'];

Object? _readCollectCount(Map json, String key) => json[key] ?? json['collectCount'];

Object? _readVisitCount(Map json, String key) => json[key] ?? json['visitCount'];

Object? _readOrderCount(Map json, String key) => json[key] ?? json['orderCount'];

Object? _readOrderStatusNum(Map json, String key) => json[key] ?? json['orderStatusNum'];
