import 'package:shuhang_mall_flutter/app/data/models/cart_add_response_model.dart';
import 'package:shuhang_mall_flutter/app/data/models/cart_count_model.dart';
import 'package:shuhang_mall_flutter/app/data/models/cart_model.dart';
import 'package:shuhang_mall_flutter/app/data/models/order_detail_model.dart';
import 'package:shuhang_mall_flutter/app/data/models/order_list_model.dart';
import 'package:shuhang_mall_flutter/app/data/models/order_status_summary_model.dart';
import 'package:shuhang_mall_flutter/app/data/providers/api_provider.dart';

/// 订单 API 服务
/// 对应原 api/order.js
class OrderProvider {
  final ApiProvider _api = ApiProvider.instance;

  // ==================== 订单操作 ====================

  /// 获取购物车列表
  Future<ApiResponse<CartListResponse>> getCartList({
    int page = 1,
    int limit = 20,
    int status = 1,
  }) async {
    return await _api.get<CartListResponse>(
      'cart/list',
      queryParameters: {'page': page, 'limit': limit, 'status': status},
      fromJsonT: (json) => CartListResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 添加购物车
  Future<ApiResponse<CartAddResponseModel>> addCart(Map<String, dynamic> data) async {
    return await _api.post<CartAddResponseModel>(
      'cart/add',
      data: data,
      fromJsonT: (json) => CartAddResponseModel.fromDynamic(json),
    );
  }

  /// 删除购物车
  Future<ApiResponse> deleteCart(List<int> ids) async {
    return await _api.post('cart/del', data: {'ids': ids});
  }

  /// 修改购物车数量
  Future<ApiResponse> changeCartNum({required int id, required int number}) async {
    return await _api.post('cart/num', data: {'id': id, 'number': number});
  }

  /// 获取购物车数量
  Future<ApiResponse<CartCountModel>> getCartCount() async {
    return await _api.get<CartCountModel>(
      'cart/count',
      fromJsonT: (json) => CartCountModel.fromJson(json as Map<String, dynamic>),
    );
  }

  // ==================== 订单确认 ====================

  /// 订单确认页面数据
  Future<ApiResponse> orderConfirm(Map<String, dynamic> data) async {
    return await _api.post('order/confirm', data: data);
  }

  /// 计算订单金额
  Future<ApiResponse> orderComputed(Map<String, dynamic> data) async {
    return await _api.post('order/computed', data: data);
  }

  /// 创建订单
  Future<ApiResponse> createOrder(Map<String, dynamic> data) async {
    return await _api.post('order/create', data: data);
  }

  /// 创建订单（带 key）
  Future<ApiResponse> createOrderWithKey(String key, Map<String, dynamic> data) async {
    return await _api.post('order/create/$key', data: data);
  }

  /// 获取当前金额可用优惠券
  Future<ApiResponse> getCouponsOrderPrice(double price, Map<String, dynamic> params) async {
    return await _api.get('coupons/order/$price', queryParameters: params);
  }

  // ==================== 订单列表 ====================

  /// 获取订单列表
  Future<ApiResponse<List<OrderListItem>>> getOrderList(Map<String, dynamic>? params) async {
    return await _api.get<List<OrderListItem>>(
      'order/list',
      queryParameters: params,
      fromJsonT: (json) {
        if (json is! List) return <OrderListItem>[];
        return json
            .whereType<Map>()
            .map((item) => OrderListItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      },
    );
  }

  /// 获取订单详情
  Future<ApiResponse<OrderDetailModel>> getOrderDetail(String orderId) async {
    return await _api.get<OrderDetailModel>(
      'order/detail/$orderId',
      fromJsonT: (json) => OrderDetailModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 获取订单支付信息（原始数据）
  Future<ApiResponse<Map<String, dynamic>>> getOrderPayInfo(String orderId) async {
    return await _api.get<Map<String, dynamic>>(
      'order/detail/$orderId',
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );
  }

  /// 订单赠送优惠券
  Future<ApiResponse<List<Map<String, dynamic>>>> orderCoupon(String orderId) async {
    return await _api.post<List<Map<String, dynamic>>>(
      'v2/order/product_coupon/$orderId',
      fromJsonT: (json) {
        if (json is! List) return <Map<String, dynamic>>[];
        return json.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
      },
    );
  }

  /// 获取订单状态数量
  Future<ApiResponse<OrderStatusSummary>> getOrderStatusNum() async {
    return await _api.get<OrderStatusSummary>(
      'order/data',
      fromJsonT: (json) => OrderStatusSummary.fromJson(json as Map<String, dynamic>),
    );
  }

  // ==================== 订单操作 ====================

  /// 取消订单
  Future<ApiResponse> cancelOrder(String orderId) async {
    return await _api.post('order/cancel', data: {'id': orderId});
  }

  /// 删除订单
  Future<ApiResponse> deleteOrder(String orderId) async {
    return await _api.post('order/del', data: {'uni': orderId});
  }

  /// 确认收货
  Future<ApiResponse> takeOrder(String orderId) async {
    return await _api.post('order/take', data: {'uni': orderId});
  }

  /// 再次购买
  Future<ApiResponse> againOrder(String orderId) async {
    return await _api.post('order/again', data: {'uni': orderId});
  }

  // ==================== 支付 ====================

  /// 支付订单
  Future<ApiResponse> payOrder(Map<String, dynamic> data) async {
    return await _api.post('order/pay', data: data);
  }

  /// 获取支付方式
  Future<ApiResponse> getPayType() async {
    return await _api.get('pay/config');
  }

  /// 余额支付
  Future<ApiResponse> balancePay(Map<String, dynamic> data) async {
    return await _api.post('order/pay/balance', data: data);
  }

  /// 微信支付
  Future<ApiResponse> wechatPay(Map<String, dynamic> data) async {
    return await _api.post('order/pay/wechat', data: data);
  }

  /// 支付宝支付
  Future<ApiResponse> aliPay(Map<String, dynamic> data) async {
    return await _api.post('order/pay/alipay', data: data);
  }

  // ==================== 物流 ====================

  /// 获取物流信息
  Future<ApiResponse> getExpress(String orderId) async {
    return await _api.get('order/express/$orderId');
  }

  // ==================== 退款 ====================

  /// 获取退货商品信息
  Future<ApiResponse> getRefundGoods(Map<String, dynamic> data) async {
    return await _api.post('order/refund/cart_info', data: data);
  }

  /// 提交退款申请
  Future<ApiResponse> submitRefundGoods(int id, Map<String, dynamic> data) async {
    return await _api.post('order/refund/apply/$id', data: data);
  }

  /// 获取可退货商品列表
  Future<ApiResponse> getRefundGoodsList(int id) async {
    return await _api.get('order/refund/cart_info/$id');
  }

  /// 申请退款
  Future<ApiResponse> applyRefund(Map<String, dynamic> data) async {
    return await _api.post('order/refund/apply', data: data);
  }

  /// 获取退款理由
  Future<ApiResponse> getRefundReason() async {
    return await _api.get('order/refund/reason');
  }

  /// 退款订单列表
  Future<ApiResponse> getRefundList(Map<String, dynamic>? params) async {
    return await _api.get('order/refund/list', queryParameters: params);
  }

  /// 退款订单详情
  Future<ApiResponse> getRefundDetail(int id) async {
    return await _api.get('order/refund/detail/$id');
  }

  /// 取消退款
  Future<ApiResponse> cancelRefund(int id) async {
    return await _api.post('order/refund/cancel', data: {'id': id});
  }

  /// 退回商品
  Future<ApiResponse> refundExpress(Map<String, dynamic> data) async {
    return await _api.post('order/refund/express', data: data);
  }

  // ==================== 评价 ====================

  /// 提交评价
  Future<ApiResponse> submitComment(Map<String, dynamic> data) async {
    return await _api.post('order/comment', data: data);
  }

  /// 获取待评价商品
  Future<ApiResponse> getOrderProduct(String orderId) async {
    return await _api.get('order/product/$orderId');
  }

  // ==================== 代付 ====================

  /// 好友代付详情
  Future<ApiResponse> friendDetail(String orderId) async {
    return await _api.get('order/friend_detail', queryParameters: {'order_id': orderId});
  }

  /// 代付支付
  Future<ApiResponse> friendPay(Map<String, dynamic> data) async {
    return await _api.post('order/friend_pay', data: data);
  }

  // ==================== 发票 ====================

  /// 申请开票
  Future<ApiResponse> makeUpInvoice(Map<String, dynamic> data) async {
    return await _api.post('v2/order/make_up_invoice', data: data);
  }

  // ==================== 订单核销 ====================

  /// 获取核销订单详情
  Future<ApiResponse> getVerifyOrder(String verifyCode) async {
    return await _api.get('order/verify/$verifyCode');
  }

  /// 确认核销
  Future<ApiResponse> confirmVerify(String verifyCode) async {
    return await _api.post('order/verify', data: {'verify_code': verifyCode});
  }
}
