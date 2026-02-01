/// 路由名称常量
/// 对应原 pages.json 中的路由配置
abstract class AppRoutes {
  // ==================== 主要 Tab 页面 ====================
  static const String main = '/main';
  static const String home = '/home';
  static const String category = '/category';
  static const String cart = '/cart';
  static const String user = '/user';
  static const String task = '/task';

  // ==================== 任务相关页面 ====================
  static const String taskRyz = '/task/ryz';
  static const String taskJifenExchange = '/task/jifen-exchange';
  static const String taskSwpExchange = '/task/swp-exchange';

  // ==================== 引导页 ====================
  static const String guide = '/guide';
  static const String splash = '/splash';

  // ==================== 登录注册 ====================
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String bindPhone = '/bind-phone';

  // ==================== 商品相关 ====================
  static const String goodsDetail = '/goods/detail';
  static const String goodsList = '/goods/list';
  static const String goodsSearch = '/goods/search';
  static const String goodsComment = '/goods/comment';
  static const String goodsCommentList = '/goods/comment-list';

  // ==================== 订单相关 ====================
  static const String orderConfirm = '/order/confirm';
  static const String orderDetail = '/order/detail';
  static const String orderList = '/order/list';
  static const String orderPayStatus = '/order/pay-status';
  static const String cashier = '/order/cashier';
  static const String orderLogistics = '/order/logistics';
  static const String orderReturn = '/order/return';
  static const String orderReturnList = '/order/return-list';
  static const String orderRefundGoods = '/order/refund-goods';

  // ==================== 用户中心 ====================
  static const String userInfo = '/user/info';
  static const String userSetting = '/user/setting';
  static const String userWallet = '/user/wallet';
  static const String userBill = '/user/bill';
  static const String userIntegral = '/user/integral';
  static const String userCoupon = '/user/coupon';
  static const String userSign = '/user/sign';
  static const String userSignList = '/user/sign-list';
  static const String userMoney = '/user/money';
  static const String userVip = '/user/vip';
  static const String userLevel = '/user/level';
  static const String userCollection = '/user/collection';
  static const String userVisitList = '/user/visit-list';
  static const String userCash = '/user/cash';
  static const String userSpread = '/user/spread';
  static const String userAddressList = '/user/address-list';
  static const String userAddress = '/user/address';
  static const String userPayment = '/user/payment';
  static const String userAbout = '/user/about';
  static const String userPrivacy = '/user/privacy';
  static const String userRetrievePassword = '/user/retrieve-password';
  static const String userCancellation = '/user/cancellation';
  static const String userMessage = '/user/message';
  static const String userMessageDetail = '/user/message-detail';
  static const String vipExpRecord = '/user/vip-exp-record';

  // ==================== 地址管理 ====================
  static const String addressList = '/address/list';
  static const String addressEdit = '/address/edit';

  // ==================== 分销推广 ====================
  static const String spreadUser = '/spread/user';
  static const String spreadCode = '/spread/code';
  static const String spreadMoney = '/spread/money';
  static const String spreadRank = '/spread/rank';
  static const String spreadOrder = '/spread/order';
  static const String spreadTeam = '/spread/team';
  static const String distributionLevel = '/distribution/level';

  // ==================== 商品 ====================
  static const String goodsReturn = '/goods/return';
  static const String goodsReturnList = '/goods/return-list';
  static const String goodsLogistics = '/goods/logistics';
  static const String userReturnList = '/user/return-list';

  // ==================== 发票管理 ====================
  static const String invoiceList = '/invoice/list';
  static const String invoiceForm = '/invoice/form';
  static const String invoiceOrder = '/invoice/order';

  // ==================== 营销活动 ====================
  static const String bargainList = '/activity/bargain';
  static const String bargainDetail = '/activity/bargain/detail';
  static const String groupBuyList = '/activity/group-buy';
  static const String groupBuyDetail = '/activity/group-buy/detail';
  static const String groupBuyStatus = '/activity/group-buy/status';
  static const String seckillList = '/activity/seckill';
  static const String seckillDetail = '/activity/seckill/detail';
  static const String presellList = '/activity/presell';
  static const String presellDetail = '/activity/presell/detail';

  // ==================== 抽奖 ====================
  static const String lottery = '/lottery';
  static const String lotteryRecord = '/lottery/record';

  // ==================== 积分商城 ====================
  static const String pointsMall = '/points-mall';
  static const String pointsGoodsList = '/points-mall/goods';
  static const String pointsGoodsDetail = '/points-mall/goods/detail';
  static const String pointsOrderList = '/points-mall/order';
  static const String pointsOrderDetail = '/points-mall/order/detail';

  // ==================== 资讯公告 ====================
  static const String newsList = '/news/list';
  static const String newsDetail = '/news/detail';

  // ==================== 客服 ====================
  static const String chat = '/chat';
  static const String serviceList = '/service/list';

  // ==================== 实名认证 ====================
  static const String realName = '/real-name';
  static const String alipayAuth = '/alipay-auth';
  static const String manualReview = '/manual-review';

  // ==================== OTC 交易 ====================
  static const String otcShop = '/otc/shop';
  static const String otcOrder = '/otc/order';
  static const String otcSend = '/otc/send';
  static const String otcPay = '/otc/pay';

  // ==================== 特殊页面 ====================
  static const String farmer = '/farmer';
  static const String video = '/video';
  static const String ecology = '/ecology';
  static const String honor = '/honor';
  static const String active = '/active';
  static const String webView = '/web-view';
  static const String feedback = '/feedback';

  // ==================== 账户资产 ====================
  static const String fudou = '/asset/fudou';
  static const String fubao = '/asset/fubao';
  static const String gxz = '/asset/gxz';
  static const String ryz = '/asset/ryz';
  static const String myBank = '/asset/bank';
  static const String setBank = '/asset/set-bank';
  static const String zhuanzeng = '/asset/transfer';
  static const String fudouTransfer = '/asset/fudou-transfer';
  static const String jifenExchange = '/asset/jifen-exchange';
  static const String swpExchange = '/asset/swp-exchange';

  // ==================== 管理后台 ====================
  static const String adminStatistics = '/admin/statistics';
  static const String adminOrderList = '/admin/order-list';
  static const String adminOrder = '/admin/order';
  static const String adminOrderDetail = '/admin/order-detail';
  static const String adminDelivery = '/admin/delivery';
  static const String adminOrderCancel = '/admin/order-cancel';

  // ==================== 门店 ====================
  static const String storeList = '/store/list';
  static const String offlinePay = '/offline/pay';
  static const String offlineResult = '/offline/result';

  // ==================== 会员卡 ====================
  static const String vipActive = '/vip/active';
  static const String vipPaid = '/vip/paid';
  static const String vipCoupon = '/vip/coupon';
  static const String vipClause = '/vip/clause';

  // ==================== 其他 ====================
  static const String scanLogin = '/scan-login';
  static const String paymentOnBehalf = '/payment-on-behalf';
  static const String paymentOnBehalfStatus = '/payment-on-behalf/status';
  static const String staffList = '/staff/list';
  static const String getCoupon = '/get-coupon';
  static const String liveList = '/live/list';
  static const String hotNewGoods = '/hot-new-goods';
  static const String editArea = '/edit-area';
  static const String updateLoginPwd = '/update-login-pwd';
  static const String updatePaymentPwd = '/update-payment-pwd';
  static const String accountSafe = '/account-safe';
  static const String teams = '/teams';
}
