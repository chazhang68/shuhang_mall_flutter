/// 省市区节点模型
class CityNode {
  /// 区域 ID
  final int value;

  /// 区域名称
  final String name;

  /// 子级列表
  final List<CityNode> children;

  const CityNode({required this.value, required this.name, required this.children});

  factory CityNode.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['c'] as List<dynamic>? ?? <dynamic>[];
    return CityNode(
      value: _toInt(json['v']),
      name: json['n']?.toString() ?? '',
      children: rawChildren.map((item) => CityNode.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
