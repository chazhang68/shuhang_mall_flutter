/// 任务植物模型
/// 对应地块中的植物数据
class TaskPlantModel {
  final int type; // 植物类型（对应图片编号）
  final double progress; // 生长进度（0-100）
  final double score; // 已领取积分
  final int dkDay; // 当前天数
  final int day; // 总天数
  final int? id; // 植物ID
  final String? name; // 植物名称

  TaskPlantModel({
    required this.type,
    required this.progress,
    required this.score,
    required this.dkDay,
    required this.day,
    this.id,
    this.name,
  });

  factory TaskPlantModel.fromJson(Map<String, dynamic> json) {
    return TaskPlantModel(
      type: json['type'] ?? 0,
      progress: _parseDouble(json['progress']),
      score: _parseDouble(json['score']),
      dkDay: json['dk_day'] ?? 0,
      day: json['day'] ?? 0,
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'progress': progress,
      'score': score,
      'dk_day': dkDay,
      'day': day,
      'id': id,
      'name': name,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  TaskPlantModel copyWith({
    int? type,
    double? progress,
    double? score,
    int? dkDay,
    int? day,
    int? id,
    String? name,
  }) {
    return TaskPlantModel(
      type: type ?? this.type,
      progress: progress ?? this.progress,
      score: score ?? this.score,
      dkDay: dkDay ?? this.dkDay,
      day: day ?? this.day,
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  /// 是否已完成
  bool get isCompleted => progress >= 100;

  /// 进度百分比（0-1）
  double get progressPercent => progress / 100;
}
