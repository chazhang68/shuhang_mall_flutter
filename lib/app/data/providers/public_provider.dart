import 'package:shuhang_mall_flutter/app/data/models/home_index_model.dart';
import 'package:shuhang_mall_flutter/app/data/providers/api_provider.dart';

/// 公共 API 服务
/// 对应原 api/public.js
class PublicProvider {
  final ApiProvider _api = ApiProvider.instance;

  /// 获取商城配置
  Future<ApiResponse> getShopConfig() async {
    return await _api.get('site_config', noAuth: true);
  }

  /// 静默授权
  Future<ApiResponse> silenceAuth(Map<String, dynamic> data) async {
    return await _api.post('silence_auth', data: data, noAuth: true);
  }

  /// 获取系统版本
  Future<ApiResponse> getSystemVersion() async {
    return await _api.get('system_version', noAuth: true);
  }

  /// 获取城市列表
  Future<ApiResponse> getCityList() async {
    return await _api.get('city_list', noAuth: true);
  }

  /// 获取城市列表 v2
  Future<ApiResponse> getCityListV2() async {
    return await _api.get('v2/city', noAuth: true);
  }

  /// 上传文件
  Future<ApiResponse> uploadFile({
    required String filePath,
    String fileKey = 'file',
    Map<String, dynamic>? extraData,
  }) async {
    return await _api.uploadFile(
      'upload/image',
      filePath: filePath,
      fileKey: fileKey,
      extraData: extraData,
    );
  }

  /// 获取图片验证码
  Future<ApiResponse> getVerifyCode() async {
    return await _api.get('ajcaptcha', noAuth: true);
  }

  /// 校验图片验证码
  Future<ApiResponse> checkVerifyCode(Map<String, dynamic> data) async {
    return await _api.post('ajcheck', data: data, noAuth: true);
  }

  /// 获取首页数据
  Future<ApiResponse> getIndexData() async {
    return await _api.get('v2/index', noAuth: true);
  }

  /// 获取首页数据 - 消费券商城
  /// type: 1=消费券商城
  Future<ApiResponse> getIndexDataByType(int type) async {
    return await _api.get('get_index/$type', noAuth: true);
  }

  /// 获取首页数据 - 消费券商城（对象）
  /// type: 1=消费券商城
  Future<ApiResponse<HomeIndexData>> getHomeIndexDataByType(int type) async {
    return await _api.get<HomeIndexData>(
      'get_index/$type',
      noAuth: true,
      fromJsonT: (json) => HomeIndexData.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 获取商品列表
  /// type: 1=消费券商城
  Future<ApiResponse> getProducts(int type, Map<String, dynamic>? params) async {
    return await _api.get('get_products/$type', queryParameters: params, noAuth: true);
  }

  /// 获取首页商品列表（对象）
  /// type: 1=消费券商城
  Future<ApiResponse<List<HomeHotProduct>>> getHomeProductsByType(
    int type,
    Map<String, dynamic>? params,
  ) async {
    return await _api.get<List<HomeHotProduct>>(
      'get_products/$type',
      queryParameters: params,
      noAuth: true,
      fromJsonT: (json) {
        if (json is! List) return <HomeHotProduct>[];
        return json
            .whereType<Map>()
            .map((item) => HomeHotProduct.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      },
    );
  }

  /// 获取首页配置
  Future<ApiResponse> getIndexConfig() async {
    return await _api.get('index', noAuth: true);
  }

  /// 获取 DIY 页面数据
  Future<ApiResponse> getDiyData(int id) async {
    return await _api.get('v2/diy/$id', noAuth: true);
  }

  /// 获取文章列表
  Future<ApiResponse> getArticleList(Map<String, dynamic>? params) async {
    return await _api.get('article/list', queryParameters: params, noAuth: true);
  }

  /// 获取文章详情
  Future<ApiResponse> getArticleDetail(int id) async {
    return await _api.get('article/details/$id', noAuth: true);
  }

  /// 获取热门搜索
  Future<ApiResponse> getHotKeyword() async {
    return await _api.get('search/keyword', noAuth: true);
  }

  /// 获取公告列表
  Future<ApiResponse> getNewsList(Map<String, dynamic>? params) async {
    return await _api.get('article/hot/list', queryParameters: params, noAuth: true);
  }

  /// 获取公告详情
  Future<ApiResponse> getNewsDetail(int id) async {
    return await _api.get('article/detail/$id', noAuth: true);
  }

  /// 获取可领取优惠券列表
  Future<ApiResponse> getCoupons(Map<String, dynamic>? params) async {
    return await _api.get('coupons', queryParameters: params, noAuth: true);
  }

  /// 领取优惠券
  Future<ApiResponse> receiveCoupon(int id) async {
    return await _api.post('coupon/receive/$id');
  }

  /// 获取文章分类列表
  Future<ApiResponse> getArticleCategoryList() async {
    return await _api.get('article/category/list', noAuth: true);
  }

  /// 获取文章轮播图
  Future<ApiResponse> getArticleBannerList() async {
    return await _api.get('article/banner/list', noAuth: true);
  }

  /// 根据分类获取文章列表
  Future<ApiResponse> getArticleListByCid(int cid, Map<String, dynamic>? params) async {
    return await _api.get('article/list/$cid', queryParameters: params, noAuth: true);
  }

  /// 获取推广海报/Banner列表
  Future<ApiResponse> getBanner() async {
    return await _api.get('spread/banner', noAuth: true);
  }

  /// 获取客服类型配置
  Future<ApiResponse> getCustomerType() async {
    return await _api.get('get_customer_type', noAuth: true);
  }
}
