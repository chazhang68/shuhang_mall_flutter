/// 任务页面数据模型
/// 对应原 pages/task/task.vue 中的数据结构
library;

/// 种子信息
class SeedInfo {
  final int id;
  final String name;
  final String image;
  final int outputNum; // 预计获得积分
  final int activity; // 活跃度
  final int count; // 已有数量
  final int limit; // 限制数量
  final int dhNum; // 兑换所需积分
  final int day; // 生长天数

  SeedInfo({
    required this.id,
    required this.name,
    required this.image,
    required this.outputNum,
    required this.activity,
    required this.count,
    required this.limit,
    required this.dhNum,
    required this.day,
  });

  factory SeedInfo.fromJson(Map<String, dynamic> json) {
    return SeedInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      outputNum: json['output_num'] ?? 0,
      activity: json['activity'] ?? 0,
      count: json['count'] ?? 0,
      limit: json['limit'] ?? 0,
      dhNum: json['dh_num'] ?? 0,
      day: json['day'] ?? 0,
    );
  }
}

/// 植物信息
class PlantInfo {
  final int type; // 植物类型 (0-7)
  final double progress; // 进度百分比 (0-100)
  final int score; // 已领取积分
  final int dkDay; // 当前天数
  final int day; // 总天数

  PlantInfo({
    required this.type,
    required this.progress,
    required this.score,
    required this.dkDay,
    required this.day,
  });

  factory PlantInfo.fromJson(Map<String, dynamic> json) {
    return PlantInfo(
      type: json['type'] ?? 0,
      progress: (json['progress'] ?? 0).toDouble(),
      score: json['score'] ?? 0,
      dkDay: json['dk_day'] ?? 0,
      day: json['day'] ?? 0,
    );
  }
}

/// 地块信息
class PlotInfo {
  final int left; // 左侧图标索引
  final int right; // 右侧图标索引
  final int fieldType; // 田块类型 (1-12)
  final List<PlantInfo> plants; // 植物列表

  PlotInfo({
    required this.left,
    required this.right,
    required this.fieldType,
    required this.plants,
  });

  factory PlotInfo.fromJson(Map<String, dynamic> json) {
    return PlotInfo(
      left: json['left'] ?? 0,
      right: json['right'] ?? 0,
      fieldType: json['fieldType'] ?? 1,
      plants: (json['plants'] as List?)?.map((e) => PlantInfo.fromJson(e)).toList() ?? [],
    );
  }
}

/// 用户任务信息
class UserTaskInfo {
  final int task; // 完成的任务数 (0-8)
  final bool isSign; // 是否实名认证
  final double fudou; // 积分余额

  UserTaskInfo({required this.task, required this.isSign, required this.fudou});

  factory UserTaskInfo.fromJson(Map<String, dynamic> json) {
    return UserTaskInfo(
      task: json['task'] ?? 0,
      isSign: json['is_sign'] ?? false,
      fudou: (json['fudou'] ?? 0).toDouble(),
    );
  }
}
