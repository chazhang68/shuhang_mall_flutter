/// 任务页面 API 服务
/// 对应原 api/user.js 中的任务相关接口

import 'package:shuhang_mall_flutter/app/data/providers/api_service.dart';

class TaskService {
  final ApiService _api = ApiClient.api;

  /// 获取用户信息
  Future<ApiResponse> getUserInfo() async {
    return await _api.get('/user');
  }

  /// 获取任务列表（种子列表）
  Future<ApiResponse> getUserTask() async {
    return await _api.get('/user/task_list');
  }

  /// 获取我的任务（地块列表）
  Future<ApiResponse> getNewMyTask() async {
    return await _api.get('/task/new_my_tasks');
  }

  /// 兑换任务（购买种子）
  Future<ApiResponse> exchangeTask(Map<String, dynamic> data) async {
    return await _api.post('/task/exchange_task', data: data);
  }

  /// 观看广告完成
  Future<ApiResponse> watchOver() async {
    return await _api.get('/watch_over');
  }

  /// 领取奖励
  Future<ApiResponse> lingqu() async {
    return await _api.get('/lingqu');
  }
}
