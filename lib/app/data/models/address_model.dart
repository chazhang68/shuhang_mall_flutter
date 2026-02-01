/// 地址列表项模型
class AddressItem {
  final int id;
  final String realName;
  final String phone;
  final String province;
  final String city;
  final String district;
  final String detail;
  final int isDefault;
  final int cityId;

  const AddressItem({
    required this.id,
    required this.realName,
    required this.phone,
    required this.province,
    required this.city,
    required this.district,
    required this.detail,
    required this.isDefault,
    required this.cityId,
  });

  factory AddressItem.fromJson(Map<String, dynamic> json) {
    return AddressItem(
      id: _toInt(json['id']),
      realName: json['real_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      province: json['province']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      detail: json['detail']?.toString() ?? '',
      isDefault: _toInt(json['is_default']),
      cityId: _toInt(json['city_id']),
    );
  }

  AddressItem copyWith({int? isDefault}) {
    return AddressItem(
      id: id,
      realName: realName,
      phone: phone,
      province: province,
      city: city,
      district: district,
      detail: detail,
      isDefault: isDefault ?? this.isDefault,
      cityId: cityId,
    );
  }
}

/// 地址详情模型
class AddressDetail extends AddressItem {
  final int uid;
  final String postCode;
  final String longitude;
  final String latitude;

  const AddressDetail({
    required super.id,
    required super.realName,
    required super.phone,
    required super.province,
    required super.city,
    required super.district,
    required super.detail,
    required super.isDefault,
    required super.cityId,
    required this.uid,
    required this.postCode,
    required this.longitude,
    required this.latitude,
  });

  factory AddressDetail.fromJson(Map<String, dynamic> json) {
    return AddressDetail(
      id: _toInt(json['id']),
      uid: _toInt(json['uid']),
      realName: json['real_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      province: json['province']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      detail: json['detail']?.toString() ?? '',
      isDefault: _toInt(json['is_default']),
      cityId: _toInt(json['city_id']),
      postCode: json['post_code']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      latitude: json['latitude']?.toString() ?? '',
    );
  }
}

/// 地址编辑响应
class AddressEditResponse {
  final String id;

  const AddressEditResponse({required this.id});

  factory AddressEditResponse.fromJson(Map<String, dynamic> json) {
    return AddressEditResponse(id: json['id']?.toString() ?? '');
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
