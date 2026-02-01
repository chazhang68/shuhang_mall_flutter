import 'package:shuhang_mall_flutter/app/data/models/product_detail_model.dart';
import 'package:shuhang_mall_flutter/app/data/providers/api_provider.dart';

/// 商品 API 服务
/// 对应原 api/store.js
class StoreProvider {
  final ApiProvider _api = ApiProvider.instance;

  // ==================== 商品列表 ====================

  /// 获取商品列表
  Future<ApiResponse> getProductList(Map<String, dynamic>? params) async {
    return await _api.get('products', queryParameters: params, noAuth: true);
  }

  /// 搜索商品
  Future<ApiResponse> searchProduct(Map<String, dynamic>? params) async {
    return await _api.get('search', queryParameters: params, noAuth: true);
  }

  /// 获取商品详情
  Future<ApiResponse> getProductDetail(int id) async {
    return await _api.get('product/detail/$id', noAuth: true);
  }

  /// 获取商品详情(对象)
  Future<ApiResponse<ProductDetailModel>> getProductDetailModel(int id) async {
    return await _api.get<ProductDetailModel>(
      'product/detail/$id',
      noAuth: true,
      fromJsonT: (json) => ProductDetailModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 获取商品 SKU
  Future<ApiResponse> getProductSku(int id) async {
    return await _api.get('product/sku/$id', noAuth: true);
  }

  // ==================== 分类 ====================

  /// 获取分类列表
  Future<ApiResponse> getCategoryList() async {
    return await _api.get('category', noAuth: true);
  }

  /// 获取子分类列表
  Future<ApiResponse> getSubCategory(int pid) async {
    return await _api.get('category/$pid', noAuth: true);
  }

  // ==================== 收藏 ====================

  /// 收藏商品
  Future<ApiResponse> collectProduct(int id) async {
    return await _api.post('collect/add', data: {'id': id, 'product': 'product'});
  }

  /// 取消收藏
  Future<ApiResponse> uncollectProduct(int id) async {
    return await _api.post(
      'collect/del',
      data: {
        'id': [id],
        'category': 'product',
      },
    );
  }

  /// 收藏列表
  Future<ApiResponse> getCollectList(Map<String, dynamic>? params) async {
    return await _api.get('collect/user', queryParameters: params);
  }

  /// 批量取消收藏
  Future<ApiResponse> batchUncollect(List<int> ids) async {
    return await _api.post('collect/del/batch', data: {'ids': ids});
  }

  /// 批量收藏
  Future<ApiResponse> collectAll(List<int> ids, {String category = 'product'}) async {
    return await _api.post('collect/all', data: {'id': ids.join(','), 'category': category});
  }

  // ==================== 浏览记录 ====================

  /// 添加浏览记录
  Future<ApiResponse> addVisit(int id) async {
    return await _api.post('user/visit', data: {'id': id, 'type': 'product'});
  }

  /// 浏览记录列表
  Future<ApiResponse> getVisitList(Map<String, dynamic>? params) async {
    return await _api.get('user/visit', queryParameters: params);
  }

  /// 删除浏览记录
  Future<ApiResponse> deleteVisit(List<int> ids) async {
    return await _api.post('user/visit/del', data: {'ids': ids});
  }

  // ==================== 评价 ====================

  /// 商品评价列表
  Future<ApiResponse> getReplyList(int id, Map<String, dynamic>? params) async {
    return await _api.get('reply/list/$id', queryParameters: params, noAuth: true);
  }

  /// 评价统计
  Future<ApiResponse> getReplyCount(int id) async {
    return await _api.get('reply/config/$id', noAuth: true);
  }

  // ==================== 门店 ====================

  /// 获取门店列表
  Future<ApiResponse> getStoreList(Map<String, dynamic>? params) async {
    return await _api.get('store_list', queryParameters: params, noAuth: true);
  }

  /// 获取门店详情
  Future<ApiResponse> getStoreDetail(int id) async {
    return await _api.get('store/detail/$id', noAuth: true);
  }

  // ==================== 热门推荐 ====================

  /// 获取精品推荐
  Future<ApiResponse> getBestProducts(Map<String, dynamic>? params) async {
    return await _api.get('groom/list/1', queryParameters: params, noAuth: true);
  }

  /// 获取热门推荐
  Future<ApiResponse> getHotProducts(Map<String, dynamic>? params) async {
    return await _api.get('groom/list/2', queryParameters: params, noAuth: true);
  }

  /// 获取新品推荐
  Future<ApiResponse> getNewProducts(Map<String, dynamic>? params) async {
    return await _api.get('groom/list/3', queryParameters: params, noAuth: true);
  }

  /// 获取促销商品
  Future<ApiResponse> getPromoteProducts(Map<String, dynamic>? params) async {
    return await _api.get('groom/list/4', queryParameters: params, noAuth: true);
  }

  // ==================== 实名认证 ====================

  /// 提交实名认证信息
  /// 对应原 api/store.js 的 createRealName
  Future<ApiResponse> createRealName(Map<String, dynamic> data) async {
    return await _api.post('user/real_name', data: data);
  }

  /// 获取实名认证详情
  /// 对应原 api/store.js 的 getRealDetails
  Future<ApiResponse> getRealDetails() async {
    return await _api.get('user/apply/info', noAuth: true);
  }
}
