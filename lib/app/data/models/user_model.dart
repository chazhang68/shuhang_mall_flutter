/// 用户模型
/// 对应后台返回的用户信息
class UserModel {
  final int uid;
  final String nickname;
  final String avatar;
  final String phone;
  final String? realName;
  final String? sex;        // 性别
  final int? level;
  final String? levelName;
  final bool isPromoter;  // 是否是推广员
  final int spreadUid;    // 推广人ID
  final String? spreadNickname;
  final double balance;   // 余额 (now_money / SWP)
  final double integral;  // 积分（消费券）
  final double brokeragePrice; // 佣金
  final double fudou;     // 仓库积分
  final double fdKy;      // 可用积分
  final double fubao;     // 福宝
  final double gxz;       // 贡献值（燃料值）
  final double ryz;       // 荣誉值
  final int couponCount;  // 优惠券数量
  final int collectCount; // 收藏数量
  final int visitCount;   // 浏览记录数量
  final int orderCount;   // 订单数量
  final bool? isBindPhone;
  final bool? isRealName;  // 是否实名
  final bool isSign;       // 是否实名认证
  final int task;          // 任务完成数量
  final int? vipStatus;    // 会员状态
  final String? vipEndTime;
  final String? addTime;
  final String? lastLoginTime;
  final Map<String, dynamic>? extra;
  
  // 新增字段 - 对应 uni-app 中的字段
  final String? code;        // 邀请码
  final int agentLevel;      // 代理等级
  final bool isVip;          // 是否是VIP
  final bool h5Open;         // 是否开启H5
  final OrderStatusNum? orderStatusNum;  // 订单状态数量

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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? 0,
      nickname: json['nickname'] ?? '',
      avatar: json['avatar'] ?? '',
      phone: json['phone'] ?? '',
      realName: json['real_name'],
      sex: json['sex'],
      level: json['level'],
      levelName: json['level_name'],
      isPromoter: json['is_promoter'] == 1 || json['is_promoter'] == true,
      spreadUid: json['spread_uid'] ?? 0,
      spreadNickname: json['spread_nickname'],
      balance: _parseDouble(json['now_money']),
      integral: _parseDouble(json['integral']),
      brokeragePrice: _parseDouble(json['brokerage_price']),
      fudou: _parseDouble(json['fudou']),
      fdKy: _parseDouble(json['fd_ky']),
      fubao: _parseDouble(json['fubao']),
      gxz: _parseDouble(json['gxz']),
      ryz: _parseDouble(json['ryz']),
      couponCount: json['coupon_count'] ?? 0,
      collectCount: json['collect_count'] ?? 0,
      visitCount: json['visit_count'] ?? 0,
      orderCount: json['order_count'] ?? 0,
      isBindPhone: json['is_bind_phone'],
      isRealName: json['is_real_name'] == 1 || json['is_real_name'] == true,
      isSign: json['is_sign'] == 1 || json['is_sign'] == true,
      task: json['task'] ?? 0,
      vipStatus: json['vip_status'],
      vipEndTime: json['vip_end_time'],
      addTime: json['add_time'],
      lastLoginTime: json['last_login_time'],
      extra: json['extra'],
      code: json['code'],
      agentLevel: json['agent_level'] ?? 0,
      isVip: json['is_vip'] == 1 || json['is_vip'] == true,
      h5Open: json['h5_open'] == 1 || json['h5_open'] == true,
      orderStatusNum: json['orderStatusNum'] != null
          ? OrderStatusNum.fromJson(json['orderStatusNum'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nickname': nickname,
      'avatar': avatar,
      'phone': phone,
      'real_name': realName,
      'sex': sex,
      'level': level,
      'level_name': levelName,
      'is_promoter': isPromoter ? 1 : 0,
      'spread_uid': spreadUid,
      'spread_nickname': spreadNickname,
      'now_money': balance,
      'integral': integral,
      'brokerage_price': brokeragePrice,
      'fudou': fudou,
      'fd_ky': fdKy,
      'fubao': fubao,
      'gxz': gxz,
      'ryz': ryz,
      'coupon_count': couponCount,
      'collect_count': collectCount,
      'visit_count': visitCount,
      'order_count': orderCount,
      'is_bind_phone': isBindPhone,
      'is_real_name': isRealName,
      'is_sign': isSign,
      'task': task,
      'vip_status': vipStatus,
      'vip_end_time': vipEndTime,
      'add_time': addTime,
      'last_login_time': lastLoginTime,
      'extra': extra,
      'code': code,
      'agent_level': agentLevel,
      'is_vip': isVip ? 1 : 0,
      'h5_open': h5Open ? 1 : 0,
      'orderStatusNum': orderStatusNum?.toJson(),
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

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
    String? addTime,
    String? lastLoginTime,
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
class OrderStatusNum {
  final int unpaidCount;      // 待付款
  final int unshippedCount;   // 待发货
  final int receivedCount;    // 待收货
  final int evaluatedCount;   // 待评价
  final int refundingCount;   // 售后/退款

  OrderStatusNum({
    this.unpaidCount = 0,
    this.unshippedCount = 0,
    this.receivedCount = 0,
    this.evaluatedCount = 0,
    this.refundingCount = 0,
  });

  factory OrderStatusNum.fromJson(Map<String, dynamic> json) {
    return OrderStatusNum(
      unpaidCount: json['unpaid_count'] ?? 0,
      unshippedCount: json['unshipped_count'] ?? 0,
      receivedCount: json['received_count'] ?? 0,
      evaluatedCount: json['evaluated_count'] ?? 0,
      refundingCount: json['refunding_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unpaid_count': unpaidCount,
      'unshipped_count': unshippedCount,
      'received_count': receivedCount,
      'evaluated_count': evaluatedCount,
      'refunding_count': refundingCount,
    };
  }
}
