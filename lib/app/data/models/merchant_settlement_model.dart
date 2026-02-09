/// 商家入驻模型
/// 对应原 pages/annex/settled/index.vue
class MerchantSettlementModel {
  /// 商户名称
  String? merchantName;

  /// 经营者姓名
  String? operatorName;

  /// 身份证号
  String? idCardNumber;

  /// 身份证正面照片
  String? idCardFrontImage;

  /// 身份证反面照片
  String? idCardBackImage;

  /// 营业执照号
  String? businessLicenseNumber;

  /// 营业执照照片
  String? businessLicenseImage;

  /// 其他资质图片列表（最多10张）
  List<String>? qualificationImages;

  /// 联系电话
  String? phone;

  /// 验证码
  String? code;

  /// 申请状态 -1:未申请/重新申请 0:审核中 1:审核通过 2:审核拒绝
  int? status;

  /// 拒绝原因
  String? refusalReason;

  /// 申请ID
  int? id;

  MerchantSettlementModel({
    this.merchantName,
    this.operatorName,
    this.idCardNumber,
    this.idCardFrontImage,
    this.idCardBackImage,
    this.businessLicenseNumber,
    this.businessLicenseImage,
    this.qualificationImages,
    this.phone,
    this.code,
    this.status,
    this.refusalReason,
    this.id,
  });

  factory MerchantSettlementModel.fromJson(Map<String, dynamic> json) {
    return MerchantSettlementModel(
      merchantName: json['merchant_name'] as String?,
      operatorName: json['operator_name'] as String?,
      idCardNumber: json['id_card_number'] as String?,
      idCardFrontImage: json['id_card_front_image'] as String?,
      idCardBackImage: json['id_card_back_image'] as String?,
      businessLicenseNumber: json['business_license_number'] as String?,
      businessLicenseImage: json['business_license_image'] as String?,
      qualificationImages: json['qualification_images'] != null
          ? List<String>.from(json['qualification_images'] as List)
          : null,
      phone: json['phone'] as String?,
      code: json['code'] as String?,
      status: json['status'] as int?,
      refusalReason: json['refusal_reason'] as String?,
      id: json['id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchant_name': merchantName,
      'operator_name': operatorName,
      'id_card_number': idCardNumber,
      'id_card_front_image': idCardFrontImage,
      'id_card_back_image': idCardBackImage,
      'business_license_number': businessLicenseNumber,
      'business_license_image': businessLicenseImage,
      'qualification_images': qualificationImages,
      'phone': phone,
      'code': code,
      'status': status,
      'refusal_reason': refusalReason,
      'id': id,
    };
  }

  /// 转换为提交数据格式
  Map<String, dynamic> toSubmitData() {
    return {
      'merchant_name': merchantName,
      'operator_name': operatorName,
      'id_card_number': idCardNumber,
      'id_card_front_image': idCardFrontImage,
      'id_card_back_image': idCardBackImage,
      'business_license_number': businessLicenseNumber,
      'business_license_image': businessLicenseImage,
      'qualification_images': qualificationImages,
      'phone': phone,
      'code': code,
      if (id != null) 'id': id,
    };
  }
}
