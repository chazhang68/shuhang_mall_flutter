/// 加入购物车响应模型
class CartAddResponseModel {
  final int cartId;

  const CartAddResponseModel({this.cartId = 0});

  factory CartAddResponseModel.fromJson(Map<String, dynamic> json) {
    return CartAddResponseModel(cartId: _numToInt(json['cartId'] ?? json['cart_id']));
  }
}

int _numToInt(dynamic value, {int defaultValue = 0}) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}
