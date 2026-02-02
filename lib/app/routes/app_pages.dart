import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';

// Home模块
import 'package:shuhang_mall_flutter/app/modules/home/main_page.dart';
import 'package:shuhang_mall_flutter/app/modules/home/home_page.dart';
import 'package:shuhang_mall_flutter/app/modules/home/task_page.dart';

// Splash模块
import 'package:shuhang_mall_flutter/app/modules/splash/splash_page.dart';

// Task模块
import 'package:shuhang_mall_flutter/pages/task/pages/ryz_page.dart' as task_ryz;
import 'package:shuhang_mall_flutter/pages/task/pages/jifen_exchange_page.dart';
import 'package:shuhang_mall_flutter/pages/task/pages/swp_exchange_page.dart';

// Goods模块
import 'package:shuhang_mall_flutter/app/modules/goods/category_page.dart';
import 'package:shuhang_mall_flutter/app/modules/goods/goods_detail_page.dart';
import 'package:shuhang_mall_flutter/app/modules/goods/goods_list_page.dart';
import 'package:shuhang_mall_flutter/app/modules/goods/goods_search_page.dart';

// Cart模块
import 'package:shuhang_mall_flutter/app/modules/cart/cart_page.dart';
import 'package:shuhang_mall_flutter/app/modules/chat/chat_page.dart';

// Order模块
import 'package:shuhang_mall_flutter/app/modules/order/order_confirm_page.dart';
import 'package:shuhang_mall_flutter/app/modules/order/order_list_page.dart';
import 'package:shuhang_mall_flutter/app/modules/order/order_detail_page.dart';
import 'package:shuhang_mall_flutter/app/modules/order/pay_status_page.dart';
import 'package:shuhang_mall_flutter/app/modules/order/logistics_page.dart';
import 'package:shuhang_mall_flutter/app/modules/order/cashier_page.dart';

// User模块
import 'package:shuhang_mall_flutter/app/modules/user/login_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/user_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/address_list_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/address_edit_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/wallet_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/coupon_page.dart';
import 'package:shuhang_mall_flutter/app/modules/real_name/real_name_page.dart';
import 'package:shuhang_mall_flutter/app/modules/real_name/manual_review_page.dart';

// Activity模块
import 'package:shuhang_mall_flutter/app/modules/activity/seckill_list_page.dart';
import 'package:shuhang_mall_flutter/app/modules/activity/bargain_list_page.dart';
import 'package:shuhang_mall_flutter/app/modules/activity/group_buy_list_page.dart';
import 'package:shuhang_mall_flutter/app/modules/activity/presell_list_page.dart';
import 'package:shuhang_mall_flutter/app/modules/activity/seckill_detail_page.dart';
import 'package:shuhang_mall_flutter/app/modules/activity/groupbuy_detail_page.dart';
import 'package:shuhang_mall_flutter/app/modules/activity/bargain_detail_page.dart';
import 'package:shuhang_mall_flutter/app/modules/activity/presell_detail_page.dart';
import 'package:shuhang_mall_flutter/app/modules/activity/groupbuy_status_page.dart';

// Goods模块扩展
import 'package:shuhang_mall_flutter/app/modules/goods/comment_list_page.dart';
import 'package:shuhang_mall_flutter/app/modules/goods/goods_return_page.dart';
import 'package:shuhang_mall_flutter/app/modules/goods/goods_return_list_page.dart';
import 'package:shuhang_mall_flutter/app/modules/goods/goods_logistics_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/user_return_list_page.dart';
import 'package:shuhang_mall_flutter/app/modules/goods/goods_comment_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/coupon_center_page.dart';
import 'package:shuhang_mall_flutter/app/modules/news/news_list_page.dart';
import 'package:shuhang_mall_flutter/app/modules/news/news_detail_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/user_money_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/user_payment_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/user_spread_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/user_address_list_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/user_spread_code_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/promoter_list_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/my_bank_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/feedback_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/bind_phone_page.dart';

// Points Mall模块
import 'package:shuhang_mall_flutter/app/modules/points_mall/points_mall_page.dart';
import 'package:shuhang_mall_flutter/app/modules/points_mall/points_goods_list_page.dart';
import 'package:shuhang_mall_flutter/app/modules/points_mall/points_goods_detail_page.dart';

// Lottery模块
import 'package:shuhang_mall_flutter/app/modules/lottery/lottery_page.dart';
import 'package:shuhang_mall_flutter/app/modules/lottery/lottery_record_page.dart';

// OTC模块
import 'package:shuhang_mall_flutter/app/modules/otc/otc_order_page.dart';
import 'package:shuhang_mall_flutter/app/modules/otc/otc_pay_page.dart';
import 'package:shuhang_mall_flutter/app/modules/otc/otc_pay_type_page.dart';
import 'package:shuhang_mall_flutter/app/modules/otc/otc_send_page.dart';
import 'package:shuhang_mall_flutter/app/modules/otc/otc_shop_page.dart';

// User模块扩展
import 'package:shuhang_mall_flutter/app/modules/user/bill_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/integral_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/team_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/withdraw_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/message_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/vip_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/spread_code_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/spread_money_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/spread_user_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/privacy_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/retrieve_password_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/fudou_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/fubao_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/gxz_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/ryz_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/collection_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/visit_list_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/about_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/user_cancellation_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/bindings/vip_exp_record_binding.dart';
import 'package:shuhang_mall_flutter/app/modules/user/views/vip_exp_record_view.dart';

// User Sign模块（带Binding）
import 'package:shuhang_mall_flutter/app/modules/user_sign/bindings/user_sign_binding.dart';
import 'package:shuhang_mall_flutter/app/modules/user_sign/views/user_sign_view.dart';
import 'package:shuhang_mall_flutter/app/modules/user_sign_record/bindings/user_sign_record_binding.dart';
import 'package:shuhang_mall_flutter/app/modules/user_sign_record/views/user_sign_record_view.dart';

// User Info模块
import 'package:shuhang_mall_flutter/app/modules/user_info/bindings/user_info_binding.dart';
import 'package:shuhang_mall_flutter/app/modules/user_info/views/user_info_view.dart';

// User Address模块
import 'package:shuhang_mall_flutter/app/modules/user_address/bindings/user_address_binding.dart';
import 'package:shuhang_mall_flutter/app/modules/user_address/views/user_address_view.dart';

// User Address List模块
import 'package:shuhang_mall_flutter/app/modules/user_address_list/bindings/user_address_list_binding.dart';
import 'package:shuhang_mall_flutter/app/modules/user_address_list/views/user_address_list_view.dart';

// User Account Safe模块
import 'package:shuhang_mall_flutter/app/modules/user_account_safe/bindings/user_account_safe_binding.dart';
import 'package:shuhang_mall_flutter/app/modules/user_account_safe/views/user_account_safe_view.dart';

// Update Login Password模块
import 'package:shuhang_mall_flutter/app/modules/update_login_pwd/bindings/update_login_pwd_binding.dart';
import 'package:shuhang_mall_flutter/app/modules/update_login_pwd/views/update_login_pwd_view.dart';

// Update Payment Password模块
import 'package:shuhang_mall_flutter/app/modules/update_payment_pwd/bindings/update_payment_pwd_binding.dart';
import 'package:shuhang_mall_flutter/app/modules/update_payment_pwd/views/update_payment_pwd_view.dart';

// User Set模块
import 'package:shuhang_mall_flutter/app/modules/user_set/bindings/user_set_binding.dart';
import 'package:shuhang_mall_flutter/app/modules/user_set/views/user_set_view.dart';

/// 路由页面配置
/// 对应原 pages.json
class AppPages {
  static final pages = [
    // ==================== 启动页 ====================
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      transition: Transition.fadeIn,
    ),

    // ==================== 主框架 ====================
    GetPage(name: AppRoutes.main, page: () => const MainPage(), transition: Transition.fadeIn),

    // ==================== 首页模块 ====================
    GetPage(name: AppRoutes.home, page: () => const HomePage()),
    GetPage(name: AppRoutes.task, page: () => const TaskPage()),

    // ==================== 任务相关页面 ====================
    GetPage(
      name: AppRoutes.taskRyz,
      page: () => const task_ryz.RyzPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.taskJifenExchange,
      page: () => const JifenExchangePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.taskSwpExchange,
      page: () => const SwpExchangePage(),
      transition: Transition.rightToLeft,
    ),

    // ==================== 商品模块 ====================
    GetPage(name: AppRoutes.category, page: () => const CategoryPage()),
    GetPage(
      name: AppRoutes.goodsDetail,
      page: () => const GoodsDetailPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.goodsList,
      page: () => const GoodsListPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.goodsSearch,
      page: () => const GoodsSearchPage(),
      transition: Transition.rightToLeft,
    ),

    // ==================== 购物车模块 ====================
    GetPage(name: AppRoutes.cart, page: () => const CartPage(), transition: Transition.rightToLeft),

    // ==================== OTC 交易 ====================
    GetPage(
      name: AppRoutes.otcShop,
      page: () => const OtcShopPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.otcOrder,
      page: () => const OtcOrderPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.otcSend,
      page: () => const OtcSendPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.otcPay,
      page: () => const OtcPayPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.otcPayType,
      page: () => const OtcPayTypePage(),
      transition: Transition.rightToLeft,
    ),

    // ==================== 订单模块 ====================
    GetPage(
      name: AppRoutes.orderConfirm,
      page: () => const OrderConfirmPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.orderList,
      page: () => const OrderListPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.orderDetail,
      page: () => const OrderDetailPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.orderPayStatus,
      page: () => const PayStatusPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.orderLogistics,
      page: () => const LogisticsPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.cashier,
      page: () => const CashierPage(),
      transition: Transition.rightToLeft,
    ),

    // ==================== 用户模块 ====================
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(name: AppRoutes.user, page: () => const UserPage()),
    GetPage(
      name: AppRoutes.userInfo,
      page: () => const UserInfoView(),
      binding: UserInfoBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.addressList,
      page: () => const AddressListPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.addressEdit,
      page: () => const AddressEditPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.userWallet,
      page: () => const WalletPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.userSetting,
      page: () => const UserSetView(),
      binding: UserSetBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.userCoupon,
      page: () => const CouponPage(),
      transition: Transition.rightToLeft,
    ),

    // ==================== 用户签到（带Binding） ====================
    GetPage(
      name: AppRoutes.userSign,
      page: () => const UserSignView(),
      binding: UserSignBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.userSignList,
      page: () => const UserSignRecordView(),
      binding: UserSignRecordBinding(),
      transition: Transition.rightToLeft,
    ),

    // ==================== 客服 ====================
    GetPage(name: AppRoutes.chat, page: () => const ChatPage(), transition: Transition.rightToLeft),

    // ==================== 实名认证 ====================
    GetPage(
      name: AppRoutes.realName,
      page: () => const RealNamePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.manualReview,
      page: () => const ManualReviewPage(),
      transition: Transition.rightToLeft,
    ),

    // ==================== 活动模块 ====================
    GetPage(
      name: AppRoutes.seckillList,
      page: () => const SeckillListPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.seckillDetail,
      page: () => const SeckillDetailPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.bargainList,
      page: () => const BargainListPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.groupBuyList,
      page: () => const GroupBuyListPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.presellList,
      page: () => const PresellListPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.groupBuyDetail,
      page: () => const GroupBuyDetailPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.bargainDetail,
      page: () => const BargainDetailPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.presellDetail,
      page: () => const PresellDetailPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.groupBuyStatus,
      page: () => const GroupbuyStatusPage(),
      transition: Transition.rightToLeft,
    ),

    // ==================== 商品评论/退货 ====================
    GetPage(
      name: AppRoutes.goodsCommentList,
      page: () => const CommentListPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.goodsReturn,
      page: () => const GoodsReturnPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.goodsReturnList,
      page: () => const GoodsReturnListPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.goodsLogistics,
      page: () => const GoodsLogisticsPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.userReturnList,
      page: () => const UserReturnListPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.goodsComment,
      page: () => const GoodsCommentPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.getCoupon,
      page: () => const CouponCenterPage(),
      transition: Transition.rightToLeft,
    ),

    // ==================== 资讯 ====================
    GetPage(
      name: AppRoutes.newsList,
      page: () => const NewsListPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.newsDetail,
      page: () => const NewsDetailPage(),
      transition: Transition.rightToLeft,
    ),

    // ==================== 用户资产 ====================
    GetPage(
      name: AppRoutes.userMoney,
      page: () => const UserMoneyPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.userBill,
      page: () => const BillPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.userIntegral,
      page: () => const IntegralPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.userCollection,
      page: () => const CollectionPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.userVisitList,
      page: () => const VisitListPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.userPayment,
      page: () => const UserPaymentPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.userSpread,
      page: () => const UserSpreadPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.userCash,
      page: () => const WithdrawPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.userAddressList,
      page: () => const UserAddressListPage(),
      transition: Transition.rightToLeft,
    ),

    // ==================== 积分商城 ====================
    GetPage(
      name: AppRoutes.pointsMall,
      page: () => const PointsMallPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.pointsGoodsList,
      page: () => const PointsGoodsListPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.pointsGoodsDetail,
      page: () => const PointsGoodsDetailPage(),
      transition: Transition.rightToLeft,
    ),

    // ==================== 抽奖 ====================
    GetPage(
      name: AppRoutes.lottery,
      page: () => const LotteryPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.lotteryRecord,
      page: () => const LotteryRecordPage(),
      transition: Transition.rightToLeft,
    ),

    // ==================== 分销推广 ====================
    GetPage(
      name: AppRoutes.spreadTeam,
      page: () => const TeamPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.teams,
      page: () => const TeamPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.spreadUser,
      page: () => const SpreadUserPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.spreadMoney,
      page: () => const SpreadMoneyPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.spreadCode,
      page: () => const SpreadCodePage(),
      transition: Transition.rightToLeft,
    ),

    // ==================== 会员中心 ====================
    GetPage(
      name: AppRoutes.userVip,
      page: () => const VipPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.userMessage,
      page: () => const MessagePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vipExpRecord,
      page: () => const VipExpRecordView(),
      binding: VipExpRecordBinding(),
      transition: Transition.rightToLeft,
    ),

    // ==================== 隐私/关于 ====================
    GetPage(
      name: AppRoutes.userPrivacy,
      page: () => const PrivacyPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.userRetrievePassword,
      page: () => const RetrievePasswordPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.userAbout,
      page: () => const AboutPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.userCancellation,
      page: () => const UserCancellationPage(),
      transition: Transition.rightToLeft,
    ),

    // ==================== 资产页面 ====================
    GetPage(
      name: AppRoutes.fudou,
      page: () => const FudouPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.fubao,
      page: () => const FubaoPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(name: AppRoutes.gxz, page: () => const GxzPage(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.ryz, page: () => const RyzPage(), transition: Transition.rightToLeft),

    // ==================== 用户扩展页面 ====================
    GetPage(
      name: '/user/spread-code',
      page: () => const UserSpreadCodePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/user/promoter-list',
      page: () => const PromoterListPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/user/my-bank',
      page: () => const MyBankPage(),
      transition: Transition.rightToLeft,
    ),

    // ==================== 账户安全 ====================
    GetPage(
      name: AppRoutes.accountSafe,
      page: () => const UserAccountSafeView(),
      binding: UserAccountSafeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.feedback,
      page: () => const FeedbackPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.bindPhone,
      page: () => const BindPhonePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.updateLoginPwd,
      page: () => const UpdateLoginPwdView(),
      binding: UpdateLoginPwdBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.updatePaymentPwd,
      page: () => const UpdatePaymentPwdView(),
      binding: UpdatePaymentPwdBinding(),
      transition: Transition.rightToLeft,
    ),

    // ==================== 地址管理（带Binding） ====================
    GetPage(
      name: AppRoutes.userAddress,
      page: () => const UserAddressView(),
      binding: UserAddressBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.userAddressList,
      page: () => const UserAddressListView(),
      binding: UserAddressListBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
