import 'package:flutter/material.dart';

/// 应用图标常量
/// 使用 Material Icons 替代原项目的 iconfont
/// 原项目使用 CSS iconfont，Flutter 中使用 Material Icons 或自定义 IconData
class AppIcons {
  AppIcons._();

  // ==================== 导航栏图标 ====================
  static const IconData home = Icons.home_outlined;
  static const IconData homeActive = Icons.home;
  static const IconData category = Icons.category_outlined;
  static const IconData categoryActive = Icons.category;
  static const IconData cart = Icons.shopping_cart_outlined;
  static const IconData cartActive = Icons.shopping_cart;
  static const IconData user = Icons.person_outline;
  static const IconData userActive = Icons.person;

  // ==================== 通用操作图标 ====================
  static const IconData back = Icons.arrow_back_ios;
  static const IconData forward = Icons.arrow_forward_ios;
  static const IconData close = Icons.close;
  static const IconData more = Icons.more_horiz;
  static const IconData moreVert = Icons.more_vert;
  static const IconData menu = Icons.menu;
  static const IconData search = Icons.search;
  static const IconData scan = Icons.qr_code_scanner;
  static const IconData share = Icons.share;
  static const IconData edit = Icons.edit;
  static const IconData delete = Icons.delete_outline;
  static const IconData add = Icons.add;
  static const IconData remove = Icons.remove;
  static const IconData check = Icons.check;
  static const IconData refresh = Icons.refresh;
  static const IconData filter = Icons.filter_list;
  static const IconData sort = Icons.sort;

  // ==================== 用户中心图标 ====================
  static const IconData settings = Icons.settings_outlined;
  static const IconData notification = Icons.notifications_outlined;
  static const IconData message = Icons.message_outlined;
  static const IconData customer = Icons.headset_mic_outlined;
  static const IconData wallet = Icons.account_balance_wallet_outlined;
  static const IconData coupon = Icons.confirmation_number_outlined;
  static const IconData collection = Icons.favorite_outline;
  static const IconData collectionActive = Icons.favorite;
  static const IconData history = Icons.history;
  static const IconData address = Icons.location_on_outlined;
  static const IconData security = Icons.security;
  static const IconData about = Icons.info_outline;
  static const IconData logout = Icons.logout;

  // ==================== 订单相关图标 ====================
  static const IconData order = Icons.receipt_long_outlined;
  static const IconData orderPending = Icons.pending_actions;
  static const IconData orderShipped = Icons.local_shipping_outlined;
  static const IconData orderReceived = Icons.check_circle_outline;
  static const IconData orderComment = Icons.rate_review_outlined;
  static const IconData orderRefund = Icons.assignment_return_outlined;

  // ==================== 商品相关图标 ====================
  static const IconData goods = Icons.shopping_bag_outlined;
  static const IconData addToCart = Icons.add_shopping_cart;
  static const IconData buyNow = Icons.flash_on;
  static const IconData store = Icons.store_outlined;
  static const IconData comment = Icons.comment_outlined;
  static const IconData star = Icons.star_outline;
  static const IconData starFilled = Icons.star;
  static const IconData starHalf = Icons.star_half;

  // ==================== 支付相关图标 ====================
  static const IconData wechatPay = Icons.payment;
  static const IconData alipay = Icons.payment;
  static const IconData bankCard = Icons.credit_card;
  static const IconData balance = Icons.account_balance;
  static const IconData cash = Icons.money;

  // ==================== 物流相关图标 ====================
  static const IconData logistics = Icons.local_shipping;
  static const IconData express = Icons.flight_takeoff;
  static const IconData pickup = Icons.storefront;

  // ==================== 分销相关图标 ====================
  static const IconData spread = Icons.share;
  static const IconData team = Icons.people_outline;
  static const IconData commission = Icons.monetization_on_outlined;
  static const IconData rank = Icons.leaderboard_outlined;
  static const IconData qrcode = Icons.qr_code;
  static const IconData invite = Icons.person_add_outlined;

  // ==================== 积分相关图标 ====================
  static const IconData integral = Icons.stars_outlined;
  static const IconData gift = Icons.card_giftcard;
  static const IconData exchange = Icons.swap_horiz;
  static const IconData lottery = Icons.casino_outlined;

  // ==================== 签到相关图标 ====================
  static const IconData signIn = Icons.edit_calendar;
  static const IconData calendar = Icons.calendar_today;
  static const IconData checked = Icons.check_circle;

  // ==================== 资讯相关图标 ====================
  static const IconData news = Icons.article_outlined;
  static const IconData article = Icons.description_outlined;
  static const IconData notice = Icons.campaign_outlined;
  static const IconData eye = Icons.visibility_outlined;

  // ==================== 会员相关图标 ====================
  static const IconData vip = Icons.workspace_premium;
  static const IconData crown = Icons.emoji_events;
  static const IconData level = Icons.trending_up;
  static const IconData diamond = Icons.diamond_outlined;

  // ==================== 其他图标 ====================
  static const IconData image = Icons.image_outlined;
  static const IconData camera = Icons.camera_alt_outlined;
  static const IconData gallery = Icons.photo_library_outlined;
  static const IconData video = Icons.videocam_outlined;
  static const IconData phone = Icons.phone_outlined;
  static const IconData email = Icons.email_outlined;
  static const IconData location = Icons.location_on_outlined;
  static const IconData time = Icons.access_time;
  static const IconData copy = Icons.content_copy;
  static const IconData link = Icons.link;
  static const IconData lock = Icons.lock_outline;
  static const IconData unlock = Icons.lock_open;
  static const IconData eyeOn = Icons.visibility;
  static const IconData eyeOff = Icons.visibility_off;
  static const IconData arrowUp = Icons.arrow_upward;
  static const IconData arrowDown = Icons.arrow_downward;
  static const IconData arrowLeft = Icons.arrow_back;
  static const IconData arrowRight = Icons.arrow_forward;
  static const IconData expandMore = Icons.expand_more;
  static const IconData expandLess = Icons.expand_less;
  static const IconData empty = Icons.inbox;
  static const IconData error = Icons.error_outline;
  static const IconData warning = Icons.warning_amber;
  static const IconData info = Icons.info_outline;
  static const IconData success = Icons.check_circle_outline;
  static const IconData help = Icons.help_outline;

  // ==================== 附加图标 ====================
  static const IconData systemUpdate = Icons.system_update;
  static const IconData block = Icons.block;
  static const IconData deleteSweep = Icons.delete_sweep;
}
