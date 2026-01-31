import 'package:json_annotation/json_annotation.dart';
import 'package:shuhang_mall_flutter/constant/app_constant.dart';

part 'product_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ProductModel {
  final int id;
  final String storeName;
  @JsonKey(fromJson: stringToInt)
  final int cateId;
  final String image;
  @JsonKey(fromJson: stringToInt)
  final int sales;
  @JsonKey(fromJson: stringToDouble)
  final double price;
  final int stock;
  final List<dynamic> activity;
  @JsonKey(fromJson: stringToDouble)
  final double otPrice;
  final int specType;
  final String recommendImage;
  final String unitName;
  final int isVip;
  final int vipPrice;
  final int isVirtual;
  final int presale;
  final String customForm;
  final int virtualType;
  @JsonKey(fromJson: stringToDouble)
  final double giveGxz;
  @JsonKey(fromJson: stringToDouble)
  final double giveRyz;
  final String description;
  final List<dynamic> couponId;
  final int cartButton;
  @JsonKey(name: 'checkCoupon')
  final bool checkCoupon;

  ProductModel({
    required this.id,
    required this.storeName,
    required this.cateId,
    required this.image,
    required this.sales,
    required this.price,
    required this.stock,
    required this.activity,
    required this.otPrice,
    required this.specType,
    required this.recommendImage,
    required this.unitName,
    required this.isVip,
    required this.vipPrice,
    required this.isVirtual,
    required this.presale,
    required this.customForm,
    required this.virtualType,
    required this.giveGxz,
    required this.giveRyz,
    required this.description,
    required this.couponId,
    required this.cartButton,
    required this.checkCoupon,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}
