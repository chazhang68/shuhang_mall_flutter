import 'package:shuhang_mall_flutter/app/data/providers/api_provider.dart';
import 'package:shuhang_mall_flutter/app/data/models/user_model.dart';

/// 用户 API 服务
/// 对应原 api/user.js
class UserProvider {
  final ApiProvider _api = ApiProvider.instance;

  // ==================== 用户信息 ====================

  /// 获取用户信息
  Future<ApiResponse<UserModel>> getUserInfo() async {
    return await _api.get<UserModel>('user', fromJsonT: (data) => UserModel.fromJson(data));
  }

  /// 获取新版用户信息
  Future<ApiResponse<UserModel>> newUserInfo() async {
    return await _api.get<UserModel>('userinfo', fromJsonT: (data) => UserModel.fromJson(data));
  }

  /// 获取用户详细信息
  Future<ApiResponse<UserModel>> userInfos() async {
    return await _api.get<UserModel>('user/info', fromJsonT: (data) => UserModel.fromJson(data));
  }

  /// 获取团队信息
  Future<ApiResponse> getTeamInfo() async {
    return await _api.get('user/info');
  }

  // ==================== 登录注册 ====================

  /// H5 用户登录（账号密码）
  Future<ApiResponse> loginH5({required String account, required String password}) async {
    return await _api.post('login', data: {'account': account, 'password': password}, noAuth: true);
  }

  /// 手机号登录
  Future<ApiResponse> loginMobile({required String phone, required String captcha}) async {
    return await _api.post(
      'login/mobile',
      data: {'phone': phone, 'captcha': captcha},
      noAuth: true,
    );
  }

  /// 获取验证码 Key
  Future<ApiResponse> getCodeApi() async {
    return await _api.get('verify_code', noAuth: true);
  }

  /// 发送验证码
  Future<ApiResponse> registerVerify({required String phone, String type = 'register'}) async {
    return await _api.post(
      'register/easy_verify',
      data: {'phone': phone, 'type': type},
      noAuth: true,
    );
  }

  /// 发送验证码
  Future<ApiResponse> sendCode({required String phone, String type = 'login'}) async {
    return await _api.post('register/easy_verify', data: {'phone': phone, 'type': type});
  }

  /// 用户注册
  Future<ApiResponse> register({
    required String account,
    required String captcha,
    required String password,
    String? payPwd,
    String? spread,
  }) async {
    return await _api.post(
      'register',
      data: {
        'account': account,
        'captcha': captcha,
        'password': password,
        'pay_pwd': ?payPwd,
        'spread': ?spread,
      },
      noAuth: true,
    );
  }

  /// 重置密码
  Future<ApiResponse> registerReset({
    required String account,
    required String captcha,
    required String password,
  }) async {
    return await _api.post(
      'register/reset',
      data: {'account': account, 'captcha': captcha, 'password': password},
      noAuth: true,
    );
  }

  /// 退出登录
  Future<ApiResponse> getLogout() async {
    return await _api.get('logout');
  }

  // ==================== 签到 ====================

  /// 签到用户信息
  Future<ApiResponse> postSignUser(Map<String, dynamic> data) async {
    return await _api.post('sign/user', data: data);
  }

  /// 获取签到配置
  Future<ApiResponse> getSignConfig() async {
    return await _api.get('sign/config');
  }

  /// 获取签到列表
  Future<ApiResponse> getSignList(Map<String, dynamic>? params) async {
    return await _api.get('sign/list', queryParameters: params);
  }

  /// 用户签到
  Future<ApiResponse> setSignIntegral() async {
    final response = await _api.post('sign/integral', data: {});
    if (response.status == -1 && response.msg.contains('404')) {
      return await _api.get('sign/integral');
    }
    return response;
  }

  /// 签到列表(年月)
  Future<ApiResponse> getSignMonthList(Map<String, dynamic>? params) async {
    return await _api.get('sign/month', queryParameters: params);
  }

  // ==================== 资产相关 ====================

  /// 获取资金明细
  Future<ApiResponse> getCommissionInfo(Map<String, dynamic>? params, int type) async {
    return await _api.get('spread/commission/$type', queryParameters: params);
  }

  /// 获取福豆列表
  Future<ApiResponse> getFudouList(Map<String, dynamic>? params) async {
    return await _api.get('fudou/list', queryParameters: params);
  }

  /// 获取福宝列表
  Future<ApiResponse> getFubaoList(Map<String, dynamic>? params) async {
    return await _api.get('fubao/list', queryParameters: params);
  }

  /// 获取贡献值列表
  Future<ApiResponse> getGxzList(Map<String, dynamic>? params) async {
    return await _api.get('gxz/list', queryParameters: params);
  }

  /// 获取荣誉值列表
  Future<ApiResponse> getRyzList(Map<String, dynamic>? params) async {
    return await _api.get('ryz/list', queryParameters: params);
  }

  /// 获取积分列表
  Future<ApiResponse> getIntegralList(Map<String, dynamic>? params) async {
    return await _api.get('integral/list', queryParameters: params);
  }

  // ==================== 分销推广 ====================

  /// 获取分销海报
  Future<ApiResponse> spreadBanner() async {
    return await _api.get('spread/banner', queryParameters: {'type': 2});
  }

  /// 获取推广用户
  Future<ApiResponse> spreadPeople(Map<String, dynamic> data) async {
    return await _api.post('spread/people', data: data);
  }

  /// 推广佣金/提现总和
  Future<ApiResponse> spreadCount(int type) async {
    return await _api.get('spread/count/$type');
  }

  /// 推广数据
  Future<ApiResponse> getSpreadInfo() async {
    return await _api.get('commission');
  }

  /// 推广订单
  Future<ApiResponse> spreadOrder(Map<String, dynamic> data) async {
    return await _api.post('spread/order', data: data);
  }

  /// 分销订单
  Future<ApiResponse> divisionOrder(Map<String, dynamic> data) async {
    return await _api.post('division/order', data: data);
  }

  /// 获取推广人排行
  Future<ApiResponse> getRankList(Map<String, dynamic>? params) async {
    return await _api.get('rank', queryParameters: params);
  }

  /// 获取佣金排名
  Future<ApiResponse> getBrokerageRank(Map<String, dynamic>? params) async {
    return await _api.get('brokerage_rank', queryParameters: params);
  }

  // ==================== OTC 交易 ====================

  /// 获取 OTC 折价数据
  Future<ApiResponse> getOtcInfo() async {
    return await _api.get('get_otc_zdj');
  }

  /// 发布 OTC 需求
  Future<ApiResponse> sendOtc(Map<String, dynamic> data) async {
    return await _api.post('send_otc', data: data);
  }

  /// 获取 OTC 市场列表
  Future<ApiResponse> getOtcList(Map<String, dynamic>? params) async {
    return await _api.get('get_otc_list', queryParameters: params);
  }

  /// 获取结算方式
  Future<ApiResponse> getPayType() async {
    return await _api.get('user/pay_type');
  }

  /// 保存结算方式
  Future<ApiResponse> savePayType(Map<String, dynamic> data) async {
    return await _api.post('user/save_pay_type', data: data);
  }

  /// 获取我的 OTC 订单列表
  Future<ApiResponse> getMyOtcList(Map<String, dynamic>? params) async {
    return await _api.get('get_my_otc_list', queryParameters: params);
  }

  /// 获取 OTC 订单详情
  Future<ApiResponse> otcOrderInfo(int id) async {
    return await _api.get('otc_order_info/$id');
  }

  /// OTC 出售/互换
  Future<ApiResponse> saleOtc(Map<String, dynamic> data) async {
    return await _api.post('sale_otc', data: data);
  }

  /// OTC 支付
  Future<ApiResponse> payOtc(int id) async {
    return await _api.get('pay_otc/$id');
  }

  /// 保存收款信息
  Future<ApiResponse> savePayInfo(Map<String, dynamic> data) async {
    return await _api.post('save_pay_info', data: data);
  }

  /// 确认收款
  Future<ApiResponse> okShouKuan(int id) async {
    return await _api.get('ok_shou_kuan/$id');
  }

  /// 确认完成
  Future<ApiResponse> okOver(int id) async {
    return await _api.get('ok_over/$id');
  }

  /// 取消订单
  Future<ApiResponse> cancelOtc(int id) async {
    return await _api.get('cancel/$id');
  }

  /// 消费券支付
  Future<ApiResponse> xfqPay(int id) async {
    return await _api.get('xfq_pay/$id');
  }

  // ==================== 提现 ====================

  /// 提现申请
  Future<ApiResponse> extractCash(Map<String, dynamic> data) async {
    return await _api.post('extract/cash', data: data);
  }

  /// 提现银行/最低金额
  Future<ApiResponse> extractBank() async {
    return await _api.get('extract/bank');
  }

  /// 解绑银行卡
  Future<ApiResponse> unbindBank() async {
    return await _api.get('jiebang');
  }

  // ==================== 会员等级 ====================

  /// 会员等级列表
  Future<ApiResponse> userLevelGrade() async {
    return await _api.get('user/level/grade');
  }

  /// 获取某个等级任务
  Future<ApiResponse> userLevelTask(int id) async {
    return await _api.get('user/level/task/$id');
  }

  /// 检查用户是否可以成为会员
  Future<ApiResponse> userLevelDetection() async {
    return await _api.get('user/level/detection');
  }

  // ==================== 地址管理 ====================

  /// 获取地址列表
  Future<ApiResponse> getAddressList(Map<String, dynamic>? params) async {
    return await _api.get('address/list', queryParameters: params);
  }

  /// 设置默认地址
  Future<ApiResponse> setAddressDefault(int id) async {
    return await _api.post('address/default/set', data: {'id': id});
  }

  /// 添加/编辑地址
  Future<ApiResponse> editAddress(Map<String, dynamic> data) async {
    return await _api.post('address/edit', data: data);
  }

  /// 删除地址
  Future<ApiResponse> delAddress(int id) async {
    return await _api.post('address/del', data: {'id': id});
  }

  /// 获取地址详情
  Future<ApiResponse> getAddressDetail(int id) async {
    return await _api.get('address/detail/$id');
  }

  /// 获取默认地址
  Future<ApiResponse> getAddressDefault() async {
    return await _api.get('address/default');
  }

  // ==================== 用户设置 ====================

  /// 修改用户信息
  Future<ApiResponse> userEdit(Map<String, dynamic> data) async {
    return await _api.post('user/edit', data: data);
  }

  /// 更新用户信息 v2
  Future<ApiResponse> updateUserInfo(Map<String, dynamic> data) async {
    return await _api.post('v2/user/user_update', data: data);
  }

  /// 设置用户分享
  Future<ApiResponse> userShare() async {
    return await _api.post('user/share');
  }

  // ==================== 充值 ====================

  /// 充值金额选择
  Future<ApiResponse> getRechargeApi() async {
    return await _api.get('recharge/index');
  }

  /// 公众号充值
  Future<ApiResponse> rechargeWechat(Map<String, dynamic> data) async {
    return await _api.post('recharge/wechat', data: data);
  }

  /// 小程序充值
  Future<ApiResponse> rechargeRoutine(Map<String, dynamic> data) async {
    return await _api.post('recharge/routine', data: data);
  }

  /// 通用充值
  Future<ApiResponse> recharge(Map<String, dynamic> data) async {
    return await _api.post('recharge/recharge', data: data);
  }

  // ==================== 客服 ====================

  /// 客服列表
  Future<ApiResponse> serviceList() async {
    return await _api.get('user/service/list');
  }

  /// 获取聊天记录
  Future<ApiResponse> getChatRecord(Map<String, dynamic>? params) async {
    return await _api.get('v2/user/service/record', queryParameters: params);
  }

  // ==================== 消息中心 ====================

  /// 消息记录
  Future<ApiResponse> serviceRecord(Map<String, dynamic>? params) async {
    return await _api.get('user/record', queryParameters: params);
  }

  /// 站内信列表
  Future<ApiResponse> messageSystem(Map<String, dynamic>? params) async {
    return await _api.get('user/message_system/list', queryParameters: params);
  }

  /// 站内信详情
  Future<ApiResponse> getMsgDetails(int id) async {
    return await _api.get('user/message_system/detail/$id');
  }

  /// 消息已读/删除
  Future<ApiResponse> msgLookDel(Map<String, dynamic>? params) async {
    return await _api.get('user/message_system/edit_message', queryParameters: params);
  }

  // ==================== 发票 ====================

  /// 发票列表
  Future<ApiResponse> invoiceList(Map<String, dynamic>? params) async {
    return await _api.get('v2/invoice', queryParameters: params, noAuth: true);
  }

  /// 添加/修改发票
  Future<ApiResponse> invoiceSave(Map<String, dynamic> data) async {
    return await _api.post('v2/invoice/save', data: data, noAuth: true);
  }

  /// 删除发票
  Future<ApiResponse> invoiceDelete(int id) async {
    return await _api.get('v2/invoice/del/$id');
  }

  /// 获取默认发票
  Future<ApiResponse> invoiceDefault(int type) async {
    return await _api.get('v2/invoice/get_default/$type');
  }

  /// 发票详情
  Future<ApiResponse> invoiceDetail(int id) async {
    return await _api.get('v2/invoice/detail/$id');
  }

  // ==================== 会员卡 ====================

  /// 会员卡主界面
  Future<ApiResponse> memberCard() async {
    return await _api.get('user/member/card/index');
  }

  /// 卡密领取会员卡
  Future<ApiResponse> memberCardDraw(Map<String, dynamic> data) async {
    return await _api.post('user/member/card/draw', data: data);
  }

  /// 购买会员卡
  Future<ApiResponse> memberCardCreate(Map<String, dynamic> data) async {
    return await _api.post('user/member/card/create', data: data);
  }

  /// 会员优惠券
  Future<ApiResponse> memberCouponsList() async {
    return await _api.get('user/member/coupons/list');
  }

  // ==================== 任务相关 ====================

  /// 获取用户任务
  Future<ApiResponse> getUserTask() async {
    return await _api.get('user/task_list', noAuth: true);
  }

  /// 获取任务数据
  Future<ApiResponse> getTaskData() async {
    return await _api.get('task/data', noAuth: true);
  }

  /// 获取所有任务
  Future<ApiResponse> getAllTask() async {
    return await _api.get('user/task_list');
  }

  /// 兑换任务
  Future<ApiResponse> exchangeTask(Map<String, dynamic> data) async {
    return await _api.post('task/exchange_task', data: data);
  }

  /// 获取我的任务
  Future<ApiResponse> getMyTask(Map<String, dynamic>? params) async {
    return await _api.get('task/my_task', queryParameters: params);
  }

  /// 获取新版我的任务
  Future<ApiResponse> getNewMyTask() async {
    return await _api.get('task/new_my_tasks');
  }

  /// 支付优惠券
  Future<ApiResponse> payCoupon() async {
    return await _api.get('task/pay_coupon');
  }

  /// 看广告
  Future<ApiResponse> watchTv() async {
    return await _api.get('task/watch_tv');
  }

  /// 看广告完成
  Future<ApiResponse> watchOver(Map<String, dynamic>? params) async {
    return await _api.get('watch_over', queryParameters: params);
  }

  /// 领取任务奖励
  Future<ApiResponse> lingqu() async {
    return await _api.get('lingqu');
  }

  // ==================== 转赠相关 ====================

  /// 消费券转赠
  Future<ApiResponse> zhuanzeng(Map<String, dynamic> data) async {
    return await _api.post('user/zhuan_zeng', data: data);
  }

  /// 福豆转赠
  Future<ApiResponse> fudouzhuan(Map<String, dynamic> data) async {
    return await _api.post('user/fudou_zhuan', data: data);
  }

  /// 福宝转赠
  Future<ApiResponse> fubaozhuan(Map<String, dynamic> data) async {
    return await _api.post('user/fubao_zhuan', data: data);
  }

  /// 获取手续费
  Future<ApiResponse> getSxf() async {
    return await _api.get('user/sxf');
  }

  // ==================== 用户协议 ====================

  /// 获取隐私协议
  Future<ApiResponse> getUserAgreement(String type) async {
    return await _api.get('get_agreement/$type', noAuth: true);
  }

  /// 注销用户
  Future<ApiResponse> cancelUser() async {
    return await _api.get('user_cancel');
  }

  // ==================== 其他 ====================

  /// 静默绑定推广人
  Future<ApiResponse> spread(Map<String, dynamic> data) async {
    return await _api.post('user/spread', data: data);
  }

  /// 访问记录
  Future<ApiResponse> setVisit(Map<String, dynamic> data) async {
    return await _api.post('user/set_visit', data: data, noAuth: true);
  }

  /// 用户中心菜单
  Future<ApiResponse> getMenuList() async {
    return await _api.get('menu/user', noAuth: true);
  }

  /// 用户活动状态
  Future<ApiResponse> userActivity() async {
    return await _api.get('user/activity');
  }

  /// 分享海报信息
  Future<ApiResponse> spreadMsg() async {
    return await _api.get('user/spread_info');
  }

  /// 图片转 base64
  Future<ApiResponse> imgToBase(Map<String, dynamic> data) async {
    return await _api.post('image_base64', data: data);
  }

  /// 获取小程序码
  Future<ApiResponse> routineCode(Map<String, dynamic>? params) async {
    return await _api.get('user/routine_code', queryParameters: params);
  }

  /// 会员经验列表
  Future<ApiResponse> getlevelExpList(Map<String, dynamic>? params) async {
    return await _api.get('user/level/expList', queryParameters: params);
  }

  /// 意见反馈
  Future<ApiResponse> suggest(Map<String, dynamic> data) async {
    return await _api.post('suggest', data: data);
  }

  /// 消费券兑换
  Future<ApiResponse> xfqDui(Map<String, dynamic> data) async {
    return await _api.post('xfq_dui', data: data, noAuth: true);
  }

  /// SWP兑换
  Future<ApiResponse> swpDui(Map<String, dynamic> data) async {
    return await _api.post('swp_dui', data: data, noAuth: true);
  }

  /// 获取会员列表
  Future<ApiResponse> getHyList(Map<String, dynamic>? params) async {
    return await _api.get('get_hy_list', queryParameters: params, noAuth: true);
  }

  // ==================== 绑定手机号 ====================

  /// 绑定手机号
  /// 对应 api/api.js: bindingUserPhone
  Future<ApiResponse> bindingUserPhone({
    required String phone,
    required String captcha,
    int step = 0,
  }) async {
    return await _api.post('binding', data: {'phone': phone, 'captcha': captcha, 'step': step});
  }

  /// 修改手机号
  /// 对应 api/api.js: updatePhone
  Future<ApiResponse> updatePhone({required String phone, required String captcha}) async {
    return await _api.post('update/binding', data: {'phone': phone, 'captcha': captcha});
  }

  // ==================== 搜索历史 ====================

  /// 获取搜索历史
  /// 对应 api/api.js: searchList
  Future<ApiResponse> getSearchHistory(Map<String, dynamic>? params) async {
    return await _api.get('v2/user/search_list', queryParameters: params, noAuth: true);
  }

  /// 清空搜索历史
  /// 对应 api/api.js: clearSearch
  Future<ApiResponse> clearSearchHistory() async {
    return await _api.get('v2/user/clean_search');
  }
}
