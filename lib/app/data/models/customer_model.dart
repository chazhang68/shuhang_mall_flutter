/// 客服配置模型
class CustomerModel {
  /// 客服类型
  /// 0: 站内客服（自建聊天系统）
  /// 1: 电话客服
  /// 2: 第三方客服（企业微信/其他）
  final String customerType;

  /// 客服电话（当 customerType = 1 时使用）
  final String? customerPhone;

  /// 客服链接（当 customerType = 2 时使用）
  final String? customerUrl;

  /// 企业微信 corpId（当使用企业微信客服时需要）
  final String? customerCorpId;

  CustomerModel({
    required this.customerType,
    this.customerPhone,
    this.customerUrl,
    this.customerCorpId,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      customerType: json['customer_type']?.toString() ?? '0',
      customerPhone: json['customer_phone']?.toString(),
      customerUrl: json['customer_url']?.toString(),
      customerCorpId: json['customer_corpId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_type': customerType,
      'customer_phone': customerPhone,
      'customer_url': customerUrl,
      'customer_corpId': customerCorpId,
    };
  }

  /// 是否是站内客服
  bool get isInternalChat => customerType == '0';

  /// 是否是电话客服
  bool get isPhoneCall => customerType == '1';

  /// 是否是第三方客服
  bool get isThirdParty => customerType == '2';

  /// 是否是企业微信客服
  bool get isWeworkCustomer =>
      isThirdParty && (customerUrl?.contains('work.weixin.qq.com') ?? false);
}
