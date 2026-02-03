import 'package:json_annotation/json_annotation.dart';

part 'cart_model.g.dart';

/// 购物车列表响应模型
@JsonSerializable(fieldRename: FieldRename.snake)
class CartListResponse {
  @JsonKey(defaultValue: <CartItem>[])
  final List<CartItem> valid;
  @JsonKey(defaultValue: <CartItem>[])
  final List<CartItem> invalid;
  final CartDeduction? deduction;

  const CartListResponse({
    this.valid = const <CartItem>[],
    this.invalid = const <CartItem>[],
    this.deduction,
  });

  factory CartListResponse.fromJson(Map<String, dynamic> json) => _$CartListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CartListResponseToJson(this);
}

/// 购物车扣减信息
@JsonSerializable(fieldRename: FieldRename.snake)
class CartDeduction {
  @JsonKey(fromJson: _numToInt)
  final int seckillId;
  @JsonKey(fromJson: _numToInt)
  final int bargainId;
  @JsonKey(fromJson: _numToInt)
  final int combinationId;
  @JsonKey(fromJson: _numToInt)
  final int discountId;

  const CartDeduction({
    this.seckillId = 0,
    this.bargainId = 0,
    this.combinationId = 0,
    this.discountId = 0,
  });

  factory CartDeduction.fromJson(Map<String, dynamic> json) => _$CartDeductionFromJson(json);

  Map<String, dynamic> toJson() => _$CartDeductionToJson(this);
}

/// 购物车条目
@JsonSerializable(fieldRename: FieldRename.snake)
class CartItem {
  @JsonKey(fromJson: _numToInt)
  final int id;
  @JsonKey(fromJson: _numToInt)
  final int uid;
  @JsonKey(fromJson: _numToString)
  final String? type;
  @JsonKey(fromJson: _numToInt)
  final int productId;
  final String? productAttrUnique;
  @JsonKey(fromJson: _numToInt)
  final int cartNum;
  @JsonKey(fromJson: _numToInt)
  final int addTime;
  @JsonKey(fromJson: _numToInt)
  final int isPay;
  @JsonKey(fromJson: _numToInt)
  final int isDel;
  @JsonKey(fromJson: _numToInt)
  final int isNew;
  @JsonKey(fromJson: _numToInt)
  final int combinationId;
  @JsonKey(fromJson: _numToInt)
  final int seckillId;
  @JsonKey(fromJson: _numToInt)
  final int bargainId;
  @JsonKey(fromJson: _numToInt)
  final int advanceId;
  @JsonKey(fromJson: _numToInt)
  final int status;
  @JsonKey(name: 'productInfo')
  final ProductInfo? productInfo;
  @JsonKey(fromJson: _numToBool)
  final bool attrStatus;
  @JsonKey(fromJson: _numToDouble)
  final double vipTruePrice;
  @JsonKey(fromJson: _numToDouble)
  final double costPrice;
  @JsonKey(fromJson: _numToInt)
  final int trueStock;
  @JsonKey(name: 'truePrice', fromJson: _numToDouble)
  final double truePrice;
  @JsonKey(name: 'sumPrice', fromJson: _numToDouble)
  final double sumPrice;
  final String? priceType;
  @JsonKey(fromJson: _numToInt)
  final int isValid;

  const CartItem({
    this.id = 0,
    this.uid = 0,
    this.type,
    this.productId = 0,
    this.productAttrUnique,
    this.cartNum = 0,
    this.addTime = 0,
    this.isPay = 0,
    this.isDel = 0,
    this.isNew = 0,
    this.combinationId = 0,
    this.seckillId = 0,
    this.bargainId = 0,
    this.advanceId = 0,
    this.status = 0,
    this.productInfo,
    this.attrStatus = false,
    this.vipTruePrice = 0,
    this.costPrice = 0,
    this.trueStock = 0,
    this.truePrice = 0,
    this.sumPrice = 0,
    this.priceType,
    this.isValid = 0,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemToJson(this);

  double get unitPrice => truePrice > 0 ? truePrice : (productInfo?.price ?? 0);

  CartItem copyWith({int? cartNum}) {
    return CartItem(
      id: id,
      uid: uid,
      type: type,
      productId: productId,
      productAttrUnique: productAttrUnique,
      cartNum: cartNum ?? this.cartNum,
      addTime: addTime,
      isPay: isPay,
      isDel: isDel,
      isNew: isNew,
      combinationId: combinationId,
      seckillId: seckillId,
      bargainId: bargainId,
      advanceId: advanceId,
      status: status,
      productInfo: productInfo,
      attrStatus: attrStatus,
      vipTruePrice: vipTruePrice,
      costPrice: costPrice,
      trueStock: trueStock,
      truePrice: truePrice,
      sumPrice: sumPrice,
      priceType: priceType,
      isValid: isValid,
    );
  }
}

/// 商品信息
@JsonSerializable(fieldRename: FieldRename.snake)
class ProductInfo {
  @JsonKey(fromJson: _numToInt)
  final int id;
  final String? image;
  final String? recommendImage;
  final List<String>? sliderImage;
  final String? storeName;
  final String? storeInfo;
  final String? unitName;
  @JsonKey(fromJson: _numToDouble)
  final double price;
  @JsonKey(fromJson: _numToDouble)
  final double vipPrice;
  @JsonKey(name: 'attrInfo')
  final ProductAttrInfo? attrInfo;

  const ProductInfo({
    this.id = 0,
    this.image,
    this.recommendImage,
    this.sliderImage,
    this.storeName,
    this.storeInfo,
    this.unitName,
    this.price = 0,
    this.vipPrice = 0,
    this.attrInfo,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) => _$ProductInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ProductInfoToJson(this);
}

/// 商品规格信息
@JsonSerializable(fieldRename: FieldRename.snake)
class ProductAttrInfo {
  @JsonKey(fromJson: _numToInt)
  final int id;
  @JsonKey(fromJson: _numToInt)
  final int productId;
  final String? suk;
  @JsonKey(fromJson: _numToInt)
  final int stock;
  @JsonKey(fromJson: _numToInt)
  final int sales;
  @JsonKey(fromJson: _numToDouble)
  final double price;
  final String? image;
  final String? unique;
  @JsonKey(fromJson: _numToDouble)
  final double cost;
  @JsonKey(fromJson: _numToDouble)
  final double vipPrice;

  const ProductAttrInfo({
    this.id = 0,
    this.productId = 0,
    this.suk,
    this.stock = 0,
    this.sales = 0,
    this.price = 0,
    this.image,
    this.unique,
    this.cost = 0,
    this.vipPrice = 0,
  });

  factory ProductAttrInfo.fromJson(Map<String, dynamic> json) => _$ProductAttrInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ProductAttrInfoToJson(this);
}

int _numToInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _numToDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

bool _numToBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase();
    return lower == '1' || lower == 'true';
  }
  return false;
}

String? _numToString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}
