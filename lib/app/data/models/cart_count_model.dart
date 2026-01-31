/// 购物车数量响应模型
class CartCountModel {
  final int count;
  final List<int> ids;
  final String sumPrice;

  const CartCountModel({this.count = 0, this.ids = const <int>[], this.sumPrice = ''});

  factory CartCountModel.fromJson(Map<String, dynamic> json) {
    return CartCountModel(
      count: _numToInt(json['count']),
      ids: _parseIds(json['ids']),
      sumPrice: json['sum_price']?.toString() ?? '',
    );
  }
}

int _numToInt(dynamic value, {int defaultValue = 0}) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

List<int> _parseIds(dynamic value) {
  if (value is List) {
    return value.map((item) => _numToInt(item)).toList();
  }
  if (value is String && value.isNotEmpty) {
    return value.split(',').map((item) => _numToInt(item.trim())).where((id) => id > 0).toList();
  }
  return const <int>[];
}
