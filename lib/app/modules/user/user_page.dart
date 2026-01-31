import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';

/// 用户中心页面
/// 对应原 pages/user/index.vue
class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final UserProvider _userProvider = UserProvider();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 延迟加载用户信息，避免在 initState 中直接调用异步方法
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserInfo();
      _setVisit();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 页面恢复时刷新数据（对应 uni-app 的 onShow）
    if (state == AppLifecycleState.resumed) {
      final controller = Get.find<AppController>();
      if (controller.isLogin) {
        _loadUserInfo();
        _setVisit();
      }
    }
  }

  /// 加载用户信息
  Future<void> _loadUserInfo() async {
    final controller = Get.find<AppController>();
    if (!controller.isLogin) return;

    if (_isLoading) return;
    _isLoading = true;

    try {
      final response = await _userProvider.getUserInfo();
      if (response.isSuccess && response.data != null) {
        await controller.updateUserInfo(response.data!);
      }
    } catch (e) {
      debugPrint('获取用户信息失败: $e');
    } finally {
      _isLoading = false;
    }
  }

  /// 记录访问
  Future<void> _setVisit() async {
    try {
      await _userProvider.setVisit({'url': '/pages/user/index'});
    } catch (e) {
      debugPrint('记录访问失败: $e');
    }
  }

  // 订单菜单数据
  final List<_OrderMenuItem> _orderMenu = const [
    _OrderMenuItem(icon: 'assets/images/all@2x.png', title: '全部', route: AppRoutes.orderList),
    _OrderMenuItem(
      icon: 'assets/images/daifukuan@2x.png',
      title: '待付款',
      route: '${AppRoutes.orderList}?status=0',
      status: 'unpaid',
    ),
    _OrderMenuItem(
      icon: 'assets/images/daifahuo@2x.png',
      title: '待发货',
      route: '${AppRoutes.orderList}?status=1',
      status: 'unshipped',
    ),
    _OrderMenuItem(
      icon: 'assets/images/daishouho-2@2x.png',
      title: '待收货',
      route: '${AppRoutes.orderList}?status=2',
      status: 'received',
    ),
    _OrderMenuItem(
      icon: 'assets/images/yiwancheng-2@2x.png',
      title: '已完成',
      route: '${AppRoutes.orderList}?status=3',
      status: 'completed',
    ),
  ];

  // 我的服务菜单数据
  List<_ServiceMenuItem> _getServiceMenu(bool h5Open) {
    return [
      const _ServiceMenuItem(
        icon: 'assets/images/shimingrenzheng.png',
        title: '实名认证',
        route: AppRoutes.userSign,
        show: true,
      ),
      const _ServiceMenuItem(
        icon: 'assets/images/tuandui3@2x.png',
        title: '邀请好友',
        route: AppRoutes.spreadCode,
        show: true,
      ),
      _ServiceMenuItem(
        icon: 'assets/images/shanggong.png',
        title: '兑换宝',
        route: 'shuhangshangdao',
        show: h5Open,
      ),
      const _ServiceMenuItem(
        icon: 'assets/images/ditu3@2x.png',
        title: '地址管理',
        route: AppRoutes.addressList,
        show: true,
      ),
      const _ServiceMenuItem(
        icon: 'assets/images/tuandui3@2x.png',
        title: '我的好友',
        route: AppRoutes.teams,
        show: true,
      ),
      const _ServiceMenuItem(
        icon: 'assets/images/yijianfankui-2@2x.png',
        title: '意见反馈',
        route: AppRoutes.feedback,
        show: true,
      ),
      const _ServiceMenuItem(
        icon: 'assets/images/my-card.png',
        title: '我的信息',
        route: AppRoutes.userInfo,
        show: true,
      ),
    ].where((item) => item.show).toList();
  }

  @override
  bool get wantKeepAlive => true;

  // 复制邀请码
  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    FlutterToastPro.showMessage('邀请码已复制');
  }

  // 跳转到菜单页面
  void _goMenuPage(String route, String? title) {
    final controller = Get.find<AppController>();
    if (!controller.isLogin) {
      Get.toNamed(AppRoutes.login);
      return;
    }

    if (route == 'shuhangshangdao') {
      // 打开外部APP - 兑换宝
      FlutterToastPro.showMessage('功能开发中');
      return;
    }

    Get.toNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.sizeOf(context);

    return GetBuilder<AppController>(
      builder: (controller) {
        final isLogin = controller.isLogin;
        final userInfo = controller.userInfo;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: Stack(
            children: [
              SizedBox(
                width: size.width,
                height: size.height,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/bg_mine@2x.png',
                      width: size.width,
                      height: size.height * 0.4,
                      fit: BoxFit.cover,
                    ),
                    Expanded(child: SizedBox()),
                  ],
                ),
              ),
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _UserHeader(isLogin: isLogin, userInfo: userInfo, onCopyCode: _copyCode),
                  ),
                  SliverToBoxAdapter(
                    child: _OrderSection(
                      isLogin: isLogin,
                      userInfo: userInfo,
                      orderMenu: _orderMenu,
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 16.h)),
                  SliverToBoxAdapter(
                    child: _ServiceSection(
                      serviceMenu: _getServiceMenu(userInfo?.h5Open ?? false),
                      onTap: _goMenuPage,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.isLogin, required this.userInfo, required this.onCopyCode});

  final bool isLogin;
  final dynamic userInfo;
  final ValueChanged<String> onCopyCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: MediaQuery.paddingOf(context).top,
        bottom: 16.h,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UserAvatar(isLogin: isLogin, userInfo: userInfo),
                SizedBox(width: 8.w),
                Expanded(
                  child: _UserInfo(isLogin: isLogin, userInfo: userInfo, onCopyCode: onCopyCode),
                ),
                if (isLogin)
                  Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.userSetting),
                      child: Image.asset(
                        'assets/images/icon_set@2x.png',
                        width: 36.w,
                        height: 36.w,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.settings, color: Colors.black54, size: 44.sp),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.isLogin, required this.userInfo});

  final bool isLogin;
  final dynamic userInfo;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isLogin) {
          Get.toNamed(AppRoutes.userInfo);
        } else {
          Get.toNamed(AppRoutes.login);
        }
      },
      child: Stack(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(60.w),
              border: Border.all(
                color: userInfo?.isVip == true ? const Color(0xFFFFAC65) : Colors.transparent,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(56.r),
              child: isLogin && userInfo?.avatar != null && userInfo!.avatar.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: userInfo.avatar,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Icon(Icons.person, color: Colors.grey, size: 64.sp),
                      errorWidget: (context, url, error) =>
                          Image.asset('assets/images/f.png', fit: BoxFit.cover),
                    )
                  : Image.asset(
                      'assets/images/f.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.person, color: Colors.grey, size: 64.sp),
                    ),
            ),
          ),
          if (isLogin && userInfo != null)
            Positioned(
              right: 10.w,
              bottom: 0,
              child: userInfo.isSign
                  ? Image.asset(
                      'assets/images/duihao@2x.png',
                      width: 28.w,
                      height: 28.w,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF54DC54), Color(0xFF00D900)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check, color: Colors.white, size: 20.sp),
                      ),
                    )
                  : Container(
                      width: 38.w,
                      height: 16.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCDCDC),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        '未实名',
                        style: TextStyle(fontSize: 10.sp, color: Colors.black),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

class _UserInfo extends StatelessWidget {
  const _UserInfo({required this.isLogin, required this.userInfo, required this.onCopyCode});

  final bool isLogin;
  final dynamic userInfo;
  final ValueChanged<String> onCopyCode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isLogin)
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.login),
              child: Text(
                '请点击登录',
                style: TextStyle(fontSize: 18.sp, color: const Color(0xFF333333)),
              ),
            )
          else
            Row(
              children: [
                Flexible(
                  child: Text(
                    userInfo?.nickname ?? '用户',
                    style: TextStyle(fontSize: 18.sp, color: const Color(0xFF333333)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                if (userInfo?.agentLevel != null && userInfo!.agentLevel > 0)
                  Image.asset(
                    'assets/images/${userInfo.agentLevel}.png',
                    width: 18.w,
                    height: 22.w,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                if (userInfo?.isVip == true)
                  Padding(
                    padding: EdgeInsets.only(left: 5.w),
                    child: Image.asset(
                      'assets/images/svip.png',
                      width: 46.w,
                      height: 17.w,
                      errorBuilder: (context, error, stackTrace) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                          ),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                        child: Text(
                          'SVIP',
                          style: TextStyle(color: Colors.white, fontSize: 10.sp),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          if (isLogin &&
              userInfo?.phone != null &&
              userInfo!.phone.isNotEmpty &&
              userInfo.code != null &&
              userInfo.code!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 3.h),
              child: Container(
                height: 20.h,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                decoration: BoxDecoration(
                  color: const Color(0x22333333),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '邀请码：',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      userInfo.code!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    GestureDetector(
                      onTap: () => onCopyCode(userInfo.code!),
                      child: Image.asset(
                        'assets/images/fuzhi-3@2x.png',
                        width: 10.w,
                        height: 10.w,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.copy, size: 11.sp, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (isLogin && (userInfo?.phone == null || userInfo!.phone.isEmpty))
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.bindPhone),
              child: Container(
                margin: EdgeInsets.only(top: 5.h),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCCCCC),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Text(
                  '绑定手机号',
                  style: TextStyle(fontSize: 14.sp, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.isLogin, required this.userInfo});

  final bool isLogin;
  final dynamic userInfo;

  @override
  Widget build(BuildContext context) {
    const accountBgColor = Color(0xFF3B332B);
    const accountTextColor = Color(0xFFEAD9C4);

    final cardWidth = 335.w;

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: cardWidth,
        child: Column(
          children: [
            GestureDetector(
              onTap: () => Get.toNamed('${AppRoutes.ryz}?index=0'),
              child: Container(
                height: 40.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                margin: .symmetric(horizontal: 8.w),
                decoration: BoxDecoration(
                  color: accountBgColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.r),
                    topRight: Radius.circular(10.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/zhanghuguanli@2x.png',
                          width: 14.w,
                          height: 14.w,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.account_balance_wallet,
                            size: 14.sp,
                            color: accountTextColor,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '我的账户',
                          style: TextStyle(fontSize: 12.sp, color: accountTextColor),
                        ),
                      ],
                    ),
                    Image.asset(
                      'assets/images/xia-3@2x.png',
                      width: 6.w,
                      height: 10.w,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.chevron_right, size: 10.sp, color: accountTextColor),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 70.h,
              margin: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(color: const Color(0xFF2E2721)),
              child: Row(
                children: [
                  _AccountItem(
                    label: '仓库积分',
                    value: isLogin ? (userInfo?.fudou ?? 0).toStringAsFixed(2) : '0.00',
                    onTap: () => Get.toNamed('${AppRoutes.ryz}?index=0'),
                  ),
                  _AccountItem(
                    label: '可用积分',
                    value: isLogin ? (userInfo?.fdKy ?? 0).toStringAsFixed(2) : '0.00',
                    onTap: () => Get.toNamed('${AppRoutes.ryz}?index=1'),
                  ),
                  _AccountItem(
                    label: 'SWP',
                    value: isLogin ? (userInfo?.balance ?? 0).toStringAsFixed(2) : '0.00',
                    onTap: () => Get.toNamed('${AppRoutes.ryz}?index=2'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountItem extends StatelessWidget {
  const _AccountItem({required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const accountTextColor = Color(0xFFF3E1C9);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: accountTextColor,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              label,
              style: TextStyle(fontSize: 13.sp, color: accountTextColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderSection extends StatelessWidget {
  const _OrderSection({required this.isLogin, required this.userInfo, required this.orderMenu});

  final bool isLogin;
  final dynamic userInfo;
  final List<_OrderMenuItem> orderMenu;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AccountCard(isLogin: isLogin, userInfo: userInfo),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '我的订单',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E1D26),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.orderList),
                    child: Row(
                      children: [
                        Text(
                          '查看全部',
                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF1E1D26)),
                        ),
                        SizedBox(width: 2.w),
                        Icon(Icons.chevron_right, size: 12.sp, color: const Color(0xFF1E1D26)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = (constraints.maxWidth - 40.w) / 5;

                  return Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 10.w,
                    runSpacing: 0,
                    children: orderMenu.map((item) {
                      int? count;
                      if (isLogin && userInfo?.orderStatusNum != null) {
                        switch (item.status) {
                          case 'unpaid':
                            count = userInfo.orderStatusNum!.unpaidCount;
                            break;
                          case 'unshipped':
                            count = userInfo.orderStatusNum!.unshippedCount;
                            break;
                          case 'received':
                            count = userInfo.orderStatusNum!.receivedCount;
                            break;
                        }
                      }

                      return _OrderItem(
                        icon: item.icon,
                        label: item.title,
                        count: count,
                        itemWidth: itemWidth,
                        onTap: () {
                          if (!isLogin) {
                            Get.toNamed(AppRoutes.login);
                            return;
                          }
                          Get.toNamed(item.route);
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderItem extends StatelessWidget {
  const _OrderItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.itemWidth,
    required this.onTap,
  });

  final String icon;
  final String label;
  final int? count;
  final double itemWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: itemWidth,
        child: Column(
          mainAxisSize: .min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  icon,
                  width: 25.w,
                  height: 25.w,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.receipt_long, size: 25.sp, color: const Color(0xFF666666)),
                ),
                if (count != null && count! > 0)
                  Positioned(
                    top: -7.h,
                    right: -6.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(color: const Color(0xFFFF5A5A), width: 1),
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(fontSize: 10.sp, color: const Color(0xFFFF5A5A)),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 3.h),
            Text(
              label,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF333333)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceSection extends StatelessWidget {
  const _ServiceSection({required this.serviceMenu, required this.onTap});

  final List<_ServiceMenuItem> serviceMenu;
  final void Function(String route, String? title) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '我的服务',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1D26),
            ),
          ),
          SizedBox(height: 12.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final spacing = 10.w;
              final itemWidth = (constraints.maxWidth - spacing * 4) / 5;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: serviceMenu.map((item) {
                  return SizedBox(
                    width: itemWidth,
                    child: _ServiceItem(
                      icon: item.icon,
                      label: item.title,
                      onTap: () => onTap(item.route, item.title),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  const _ServiceItem({required this.icon, required this.label, required this.onTap});

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        spacing: 4.h,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            icon,
            width: 24.w,
            height: 24.w,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.apps, size: 24.sp, color: const Color(0xFF666666)),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: const Color(0xFF333333)),
          ),
        ],
      ),
    );
  }
}

class _OrderMenuItem {
  const _OrderMenuItem({required this.icon, required this.title, required this.route, this.status});

  final String icon;
  final String title;
  final String route;
  final String? status;
}

class _ServiceMenuItem {
  const _ServiceMenuItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.show,
  });

  final String icon;
  final String title;
  final String route;
  final bool show;
}
