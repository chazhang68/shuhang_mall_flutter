/// 任务交易记录模型
/// 对应积分/SWP交易记录
class TaskRecordModel {
  final int id;
  final String title; // 标题
  final double num; // 数量（积分）
  final double? number; // 数量（SWP）
  final int pm; // 0=支出, 1=收入
  final String addTime; // 添加时间
  final String? mark; // 备注
  final int? status; // 状态

  TaskRecordModel({
    required this.id,
    required this.title,
    required this.num,
    this.number,
    required this.pm,
    required this.addTime,
    this.mark,
    this.status,
  });

  factory TaskRecordModel.fromJson(Map<String, dynamic> json) {
    return TaskRecordModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      num: _parseDouble(json['num']),
      number: json['number'] != null ? _parseDouble(json['number']) : null,
      pm: json['pm'] ?? 0,
      addTime: json['add_time'] ?? '',
      mark: json['mark'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'num': num,
      'number': number,
      'pm': pm,
      'add_time': addTime,
      'mark': mark,
      'status': status,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  TaskRecordModel copyWith({
    int? id,
    String? title,
    double? num,
    double? number,
    int? pm,
    String? addTime,
    String? mark,
    int? status,
  }) {
    return TaskRecordModel(
      id: id ?? this.id,
      title: title ?? this.title,
      num: num ?? this.num,
      number: number ?? this.number,
      pm: pm ?? this.pm,
      addTime: addTime ?? this.addTime,
      mark: mark ?? this.mark,
      status: status ?? this.status,
    );
  }

  /// 是否是收入
  bool get isIncome => pm == 1;

  /// 是否是支出
  bool get isExpense => pm == 0;

  /// 获取显示的数量（优先使用number，其次使用num）
  double get displayAmount => number ?? num;

  /// 获取带符号的数量字符串
  String get signedAmount =>
      '${isIncome ? '+' : '-'}${displayAmount.toStringAsFixed(2)}';
}
