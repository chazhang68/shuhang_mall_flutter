/// 加入购物车响应模型
class CartAddResponseModel {
  final int cartId;
  final String cartIdStr;

  const CartAddResponseModel({this.cartId = 0, this.cartIdStr = ''});

  String get cartIdValue {
    if (cartIdStr.isNotEmpty) return cartIdStr;
    if (cartId > 0) return cartId.toString();
    return '';
  }

  factory CartAddResponseModel.fromDynamic(dynamic json) {
    if (json is Map) {
      return CartAddResponseModel.fromJson(Map<String, dynamic>.from(json));
    }
    if (json is int) {
      return CartAddResponseModel(cartId: json, cartIdStr: json.toString());
    }
    if (json is double) {
      final value = json.toInt();
      return CartAddResponseModel(cartId: value, cartIdStr: value.toString());
    }
    if (json is String) {
      return CartAddResponseModel(cartId: int.tryParse(json) ?? 0, cartIdStr: json);
    }
    return const CartAddResponseModel();
  }

  factory CartAddResponseModel.fromJson(Map<String, dynamic> json) {
    final direct = _numToInt(json['cartId'] ?? json['cart_id'] ?? json['id']);
    if (direct > 0) {
      return CartAddResponseModel(cartId: direct, cartIdStr: direct.toString());
    }

    final directRaw = _numToString(json['cartId'] ?? json['cart_id'] ?? json['id']);
    if (directRaw.isNotEmpty) {
      return CartAddResponseModel(cartId: _numToInt(directRaw), cartIdStr: directRaw);
    }

    final data = json['data'];
    if (data is Map) {
      final nested = _numToInt(data['cartId'] ?? data['cart_id'] ?? data['id']);
      if (nested > 0) {
        return CartAddResponseModel(cartId: nested, cartIdStr: nested.toString());
      }
      final nestedRaw = _numToString(data['cartId'] ?? data['cart_id'] ?? data['id']);
      if (nestedRaw.isNotEmpty) {
        return CartAddResponseModel(cartId: _numToInt(nestedRaw), cartIdStr: nestedRaw);
      }
    }

    final result = json['result'];
    if (result is Map) {
      final nested = _numToInt(result['cartId'] ?? result['cart_id'] ?? result['id']);
      if (nested > 0) {
        return CartAddResponseModel(cartId: nested, cartIdStr: nested.toString());
      }
      final nestedRaw = _numToString(result['cartId'] ?? result['cart_id'] ?? result['id']);
      if (nestedRaw.isNotEmpty) {
        return CartAddResponseModel(cartId: _numToInt(nestedRaw), cartIdStr: nestedRaw);
      }
    }

    return const CartAddResponseModel();
  }
}

int _numToInt(dynamic value, {int defaultValue = 0}) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

String _numToString(dynamic value) {
  if (value == null) return '';
  return value.toString();
}
