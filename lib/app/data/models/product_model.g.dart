// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  id: (json['id'] as num).toInt(),
  storeName: json['store_name'] as String,
  cateId: stringToInt(json['cate_id']),
  image: json['image'] as String,
  sales: stringToInt(json['sales']),
  price: stringToDouble(json['price']),
  stock: (json['stock'] as num).toInt(),
  activity: json['activity'] as List<dynamic>,
  otPrice: stringToDouble(json['ot_price']),
  specType: (json['spec_type'] as num).toInt(),
  recommendImage: json['recommend_image'] as String,
  unitName: json['unit_name'] as String,
  isVip: (json['is_vip'] as num).toInt(),
  vipPrice: (json['vip_price'] as num).toInt(),
  isVirtual: (json['is_virtual'] as num).toInt(),
  presale: (json['presale'] as num).toInt(),
  customForm: json['custom_form'] as String,
  virtualType: (json['virtual_type'] as num).toInt(),
  giveGxz: stringToDouble(json['give_gxz']),
  giveRyz: stringToDouble(json['give_ryz']),
  description: json['description'] as String,
  couponId: json['coupon_id'] as List<dynamic>,
  cartButton: (json['cart_button'] as num).toInt(),
  checkCoupon: json['checkCoupon'] as bool,
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'store_name': instance.storeName,
      'cate_id': instance.cateId,
      'image': instance.image,
      'sales': instance.sales,
      'price': instance.price,
      'stock': instance.stock,
      'activity': instance.activity,
      'ot_price': instance.otPrice,
      'spec_type': instance.specType,
      'recommend_image': instance.recommendImage,
      'unit_name': instance.unitName,
      'is_vip': instance.isVip,
      'vip_price': instance.vipPrice,
      'is_virtual': instance.isVirtual,
      'presale': instance.presale,
      'custom_form': instance.customForm,
      'virtual_type': instance.virtualType,
      'give_gxz': instance.giveGxz,
      'give_ryz': instance.giveRyz,
      'description': instance.description,
      'coupon_id': instance.couponId,
      'cart_button': instance.cartButton,
      'checkCoupon': instance.checkCoupon,
    };
