/// 任务种子模型
/// 对应种子商店中的种子数据
class TaskSeedModel {
  final int id;
  final String name;
  final String image;
  final double dhNum; // 兑换所需积分
  final double outputNum; // 预计获得积分
  final int activity; // 活跃度
  final int count; // 已购买数量
  final int limit; // 限购数量
  final int day; // 生长天数
  final String? description; // 描述

  TaskSeedModel({
    required this.id,
    required this.name,
    required this.image,
    required this.dhNum,
    required this.outputNum,
    required this.activity,
    required this.count,
    required this.limit,
    required this.day,
    this.description,
  });

  factory TaskSeedModel.fromJson(Map<String, dynamic> json) {
    return TaskSeedModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      dhNum: _parseDouble(json['dh_num']),
      outputNum: _parseDouble(json['output_num']),
      activity: json['activity'] ?? 0,
      count: json['count'] ?? 0,
      limit: json['limit'] ?? 0,
      day: json['day'] ?? 0,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'dh_num': dhNum,
      'output_num': outputNum,
      'activity': activity,
      'count': count,
      'limit': limit,
      'day': day,
      'description': description,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  TaskSeedModel copyWith({
    int? id,
    String? name,
    String? image,
    double? dhNum,
    double? outputNum,
    int? activity,
    int? count,
    int? limit,
    int? day,
    String? description,
  }) {
    return TaskSeedModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      dhNum: dhNum ?? this.dhNum,
      outputNum: outputNum ?? this.outputNum,
      activity: activity ?? this.activity,
      count: count ?? this.count,
      limit: limit ?? this.limit,
      day: day ?? this.day,
      description: description ?? this.description,
    );
  }
}
