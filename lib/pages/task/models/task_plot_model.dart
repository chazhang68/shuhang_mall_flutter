import 'task_plant_model.dart';

/// 任务地块模型
/// 对应一个完整的地块数据
class TaskPlotModel {
  final int fieldType; // 田块类型（1-12）
  final int left; // 左侧图标编号
  final int right; // 右侧图标编号
  final List<TaskPlantModel> plants; // 植物列表
  final int? id; // 地块ID
  final String? name; // 地块名称

  TaskPlotModel({
    required this.fieldType,
    required this.left,
    required this.right,
    required this.plants,
    this.id,
    this.name,
  });

  factory TaskPlotModel.fromJson(Map<String, dynamic> json) {
    // 解析植物列表
    List<TaskPlantModel> plantsList = [];
    if (json['plants'] != null) {
      if (json['plants'] is List) {
        plantsList = (json['plants'] as List)
            .map(
              (plant) => TaskPlantModel.fromJson(plant as Map<String, dynamic>),
            )
            .toList();
      }
    }

    return TaskPlotModel(
      fieldType: json['fieldType'] ?? json['field_type'] ?? 1,
      left: json['left'] ?? 0,
      right: json['right'] ?? 0,
      plants: plantsList,
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fieldType': fieldType,
      'field_type': fieldType,
      'left': left,
      'right': right,
      'plants': plants.map((plant) => plant.toJson()).toList(),
      'id': id,
      'name': name,
    };
  }

  TaskPlotModel copyWith({
    int? fieldType,
    int? left,
    int? right,
    List<TaskPlantModel>? plants,
    int? id,
    String? name,
  }) {
    return TaskPlotModel(
      fieldType: fieldType ?? this.fieldType,
      left: left ?? this.left,
      right: right ?? this.right,
      plants: plants ?? this.plants,
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  /// 获取地块中的植物数量
  int get plantCount => plants.length;

  /// 是否有植物
  bool get hasPlants => plants.isNotEmpty;

  /// 获取已完成的植物数量
  int get completedPlantCount =>
      plants.where((plant) => plant.isCompleted).length;

  /// 获取总进度（平均值）
  double get totalProgress {
    if (plants.isEmpty) return 0;
    double sum = plants.fold(0, (prev, plant) => prev + plant.progress);
    return sum / plants.length;
  }
}
