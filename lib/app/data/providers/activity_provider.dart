import 'package:shuhang_mall_flutter/app/data/providers/api_provider.dart';

/// 营销活动 API 服务
/// 对应原 api/activity.js
class ActivityProvider {
  final ApiProvider _api = ApiProvider.instance;

  // ==================== 优惠券 ====================

  /// 获取优惠券列表
  Future<ApiResponse> getCouponList(Map<String, dynamic>? params) async {
    return await _api.get('coupons', queryParameters: params, noAuth: true);
  }

  /// 领取优惠券
  Future<ApiResponse> receiveCoupon(int id) async {
    return await _api.post('coupon/receive', data: {'id': id});
  }

  /// 用户优惠券列表
  Future<ApiResponse> getMyCouponList(Map<String, dynamic>? params) async {
    return await _api.get('coupons/user', queryParameters: params);
  }

  /// 订单可用优惠券
  Future<ApiResponse> getOrderCoupon(Map<String, dynamic> data) async {
    return await _api.post('coupons/order', data: data);
  }

  // ==================== 秒杀 ====================

  /// 获取秒杀时间段
  Future<ApiResponse> getSeckillIndex() async {
    return await _api.get('seckill/index', noAuth: true);
  }

  /// 获取秒杀商品列表
  Future<ApiResponse> getSeckillList(Map<String, dynamic>? params) async {
    return await _api.get('seckill/list', queryParameters: params, noAuth: true);
  }

  /// 获取秒杀商品详情
  Future<ApiResponse> getSeckillDetail(int id) async {
    return await _api.get('seckill/detail/$id', noAuth: true);
  }

  // ==================== 拼团 ====================

  /// 获取拼团商品列表
  Future<ApiResponse> getCombinationList(Map<String, dynamic>? params) async {
    return await _api.get('combination/list', queryParameters: params, noAuth: true);
  }

  /// 获取拼团商品详情
  Future<ApiResponse> getCombinationDetail(int id) async {
    return await _api.get('combination/detail/$id', noAuth: true);
  }

  /// 获取拼团头像
  Future<ApiResponse> getCombinationPink(int id) async {
    return await _api.get('combination/pink/$id', noAuth: true);
  }

  /// 取消拼团
  Future<ApiResponse> cancelCombination(int id) async {
    return await _api.post('combination/remove', data: {'id': id});
  }

  /// 拼团海报
  Future<ApiResponse> getCombinationPoster(int id) async {
    return await _api.get('combination/poster/$id');
  }

  // ==================== 砍价 ====================

  /// 获取砍价商品列表
  Future<ApiResponse> getBargainList(Map<String, dynamic>? params) async {
    return await _api.get('bargain/list', queryParameters: params, noAuth: true);
  }

  /// 获取砍价商品详情
  Future<ApiResponse> getBargainDetail(int id) async {
    return await _api.get('bargain/detail/$id', noAuth: true);
  }

  /// 帮砍一刀
  Future<ApiResponse> helpBargain(int id) async {
    return await _api.post('bargain/help', data: {'id': id});
  }

  /// 开始砍价
  Future<ApiResponse> startBargain(int id) async {
    return await _api.post('bargain/start', data: {'id': id});
  }

  /// 砍价用户列表
  Future<ApiResponse> getBargainUserList(int id, Map<String, dynamic>? params) async {
    return await _api.get('bargain/user_list/$id', queryParameters: params, noAuth: true);
  }

  /// 取消砍价
  Future<ApiResponse> cancelBargain(int id) async {
    return await _api.post('bargain/cancel', data: {'id': id});
  }

  // ==================== 预售 ====================

  /// 获取预售商品列表
  Future<ApiResponse> getPresellList(Map<String, dynamic>? params) async {
    return await _api.get('presell/list', queryParameters: params, noAuth: true);
  }

  /// 获取预售商品详情
  Future<ApiResponse> getPresellDetail(int id) async {
    return await _api.get('presell/detail/$id', noAuth: true);
  }

  // ==================== 活动通用 ====================

  /// 获取首页活动数据
  Future<ApiResponse> getActivityList() async {
    return await _api.get('activity/list', noAuth: true);
  }

  /// 获取活动详情
  Future<ApiResponse> getActivityDetail(int id) async {
    return await _api.get('activity/detail/$id', noAuth: true);
  }
}
