// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartListResponse _$CartListResponseFromJson(Map<String, dynamic> json) =>
    CartListResponse(
      valid:
          (json['valid'] as List<dynamic>?)
              ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      invalid:
          (json['invalid'] as List<dynamic>?)
              ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      deduction: json['deduction'] == null
          ? null
          : CartDeduction.fromJson(json['deduction'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CartListResponseToJson(CartListResponse instance) =>
    <String, dynamic>{
      'valid': instance.valid,
      'invalid': instance.invalid,
      'deduction': instance.deduction,
    };

CartDeduction _$CartDeductionFromJson(Map<String, dynamic> json) =>
    CartDeduction(
      seckillId: json['seckill_id'] == null ? 0 : _numToInt(json['seckill_id']),
      bargainId: json['bargain_id'] == null ? 0 : _numToInt(json['bargain_id']),
      combinationId: json['combination_id'] == null
          ? 0
          : _numToInt(json['combination_id']),
      discountId: json['discount_id'] == null
          ? 0
          : _numToInt(json['discount_id']),
    );

Map<String, dynamic> _$CartDeductionToJson(CartDeduction instance) =>
    <String, dynamic>{
      'seckill_id': instance.seckillId,
      'bargain_id': instance.bargainId,
      'combination_id': instance.combinationId,
      'discount_id': instance.discountId,
    };

CartItem _$CartItemFromJson(Map<String, dynamic> json) => CartItem(
  id: json['id'] == null ? 0 : _numToInt(json['id']),
  uid: json['uid'] == null ? 0 : _numToInt(json['uid']),
  type: json['type'] as String?,
  productId: json['product_id'] == null ? 0 : _numToInt(json['product_id']),
  productAttrUnique: json['product_attr_unique'] as String?,
  cartNum: json['cart_num'] == null ? 0 : _numToInt(json['cart_num']),
  addTime: json['add_time'] == null ? 0 : _numToInt(json['add_time']),
  isPay: json['is_pay'] == null ? 0 : _numToInt(json['is_pay']),
  isDel: json['is_del'] == null ? 0 : _numToInt(json['is_del']),
  isNew: json['is_new'] == null ? 0 : _numToInt(json['is_new']),
  combinationId: json['combination_id'] == null
      ? 0
      : _numToInt(json['combination_id']),
  seckillId: json['seckill_id'] == null ? 0 : _numToInt(json['seckill_id']),
  bargainId: json['bargain_id'] == null ? 0 : _numToInt(json['bargain_id']),
  advanceId: json['advance_id'] == null ? 0 : _numToInt(json['advance_id']),
  status: json['status'] == null ? 0 : _numToInt(json['status']),
  productInfo: json['productInfo'] == null
      ? null
      : ProductInfo.fromJson(json['productInfo'] as Map<String, dynamic>),
  attrStatus: json['attr_status'] == null
      ? false
      : _numToBool(json['attr_status']),
  vipTruePrice: json['vip_true_price'] == null
      ? 0
      : _numToDouble(json['vip_true_price']),
  costPrice: json['cost_price'] == null ? 0 : _numToDouble(json['cost_price']),
  trueStock: json['true_stock'] == null ? 0 : _numToInt(json['true_stock']),
  truePrice: json['true_price'] == null ? 0 : _numToDouble(json['true_price']),
  sumPrice: json['sum_price'] == null ? 0 : _numToDouble(json['sum_price']),
  priceType: json['price_type'] as String?,
  isValid: json['is_valid'] == null ? 0 : _numToInt(json['is_valid']),
);

Map<String, dynamic> _$CartItemToJson(CartItem instance) => <String, dynamic>{
  'id': instance.id,
  'uid': instance.uid,
  'type': instance.type,
  'product_id': instance.productId,
  'product_attr_unique': instance.productAttrUnique,
  'cart_num': instance.cartNum,
  'add_time': instance.addTime,
  'is_pay': instance.isPay,
  'is_del': instance.isDel,
  'is_new': instance.isNew,
  'combination_id': instance.combinationId,
  'seckill_id': instance.seckillId,
  'bargain_id': instance.bargainId,
  'advance_id': instance.advanceId,
  'status': instance.status,
  'productInfo': instance.productInfo,
  'attr_status': instance.attrStatus,
  'vip_true_price': instance.vipTruePrice,
  'cost_price': instance.costPrice,
  'true_stock': instance.trueStock,
  'true_price': instance.truePrice,
  'sum_price': instance.sumPrice,
  'price_type': instance.priceType,
  'is_valid': instance.isValid,
};

ProductInfo _$ProductInfoFromJson(Map<String, dynamic> json) => ProductInfo(
  id: json['id'] == null ? 0 : _numToInt(json['id']),
  image: json['image'] as String?,
  recommendImage: json['recommend_image'] as String?,
  sliderImage: (json['slider_image'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  storeName: json['store_name'] as String?,
  storeInfo: json['store_info'] as String?,
  unitName: json['unit_name'] as String?,
  price: json['price'] == null ? 0 : _numToDouble(json['price']),
  vipPrice: json['vip_price'] == null ? 0 : _numToDouble(json['vip_price']),
  attrInfo: json['attrInfo'] == null
      ? null
      : ProductAttrInfo.fromJson(json['attrInfo'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProductInfoToJson(ProductInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'image': instance.image,
      'recommend_image': instance.recommendImage,
      'slider_image': instance.sliderImage,
      'store_name': instance.storeName,
      'store_info': instance.storeInfo,
      'unit_name': instance.unitName,
      'price': instance.price,
      'vip_price': instance.vipPrice,
      'attrInfo': instance.attrInfo,
    };

ProductAttrInfo _$ProductAttrInfoFromJson(Map<String, dynamic> json) =>
    ProductAttrInfo(
      id: json['id'] == null ? 0 : _numToInt(json['id']),
      productId: json['product_id'] == null ? 0 : _numToInt(json['product_id']),
      suk: json['suk'] as String?,
      stock: json['stock'] == null ? 0 : _numToInt(json['stock']),
      sales: json['sales'] == null ? 0 : _numToInt(json['sales']),
      price: json['price'] == null ? 0 : _numToDouble(json['price']),
      image: json['image'] as String?,
      unique: json['unique'] as String?,
      cost: json['cost'] == null ? 0 : _numToDouble(json['cost']),
      vipPrice: json['vip_price'] == null ? 0 : _numToDouble(json['vip_price']),
    );

Map<String, dynamic> _$ProductAttrInfoToJson(ProductAttrInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'suk': instance.suk,
      'stock': instance.stock,
      'sales': instance.sales,
      'price': instance.price,
      'image': instance.image,
      'unique': instance.unique,
      'cost': instance.cost,
      'vip_price': instance.vipPrice,
    };
