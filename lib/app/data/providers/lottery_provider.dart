import 'package:shuhang_mall_flutter/app/data/providers/api_provider.dart';

/// 抽奖 API 服务
/// 对应原 api/lottery.js
class LotteryProvider {
  final ApiProvider _api = ApiProvider.instance;

  /// 获取抽奖配置
  Future<ApiResponse> getLotteryConfig() async {
    return await _api.get('lottery/config', noAuth: true);
  }

  /// 抽奖
  Future<ApiResponse> lottery(int id) async {
    return await _api.post('lottery/draw', data: {'id': id});
  }

  /// 获取中奖记录
  Future<ApiResponse> getLotteryRecord(Map<String, dynamic>? params) async {
    return await _api.get('lottery/record', queryParameters: params);
  }

  /// 获取中奖用户列表
  Future<ApiResponse> getLotteryUserList(Map<String, dynamic>? params) async {
    return await _api.get('lottery/user_list', queryParameters: params, noAuth: true);
  }

  /// 兑换奖品
  Future<ApiResponse> exchangePrize(Map<String, dynamic> data) async {
    return await _api.post('lottery/exchange', data: data);
  }
}

/// 积分商城 API 服务
/// 对应原 api/points_mall.js
class PointsMallProvider {
  final ApiProvider _api = ApiProvider.instance;

  /// 获取积分商城首页数据
  Future<ApiResponse> getStoreIntegral() async {
    return await _api.get('integral/index', noAuth: true);
  }

  /// 获取积分商品列表
  Future<ApiResponse> getPointsGoodsList(Map<String, dynamic>? params) async {
    return await _api.get('points/goods', queryParameters: params, noAuth: true);
  }

  /// 获取积分商品详情
  Future<ApiResponse> getPointsGoodsDetail(int id) async {
    return await _api.get('points/goods/$id', noAuth: true);
  }

  /// 积分兑换
  Future<ApiResponse> pointsExchange(Map<String, dynamic> data) async {
    return await _api.post('points/exchange', data: data);
  }

  /// 获取积分订单列表
  Future<ApiResponse> getPointsOrderList(Map<String, dynamic>? params) async {
    return await _api.get('points/order', queryParameters: params);
  }

  /// 获取积分订单详情
  Future<ApiResponse> getPointsOrderDetail(int id) async {
    return await _api.get('points/order/$id');
  }
}
