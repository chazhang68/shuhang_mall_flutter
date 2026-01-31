import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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

class _UserPageState extends State<UserPage> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
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

  /// 下拉刷新
  /// 对应 uni-app: onPullDownRefresh -> onLoadFun
  Future<void> _onRefresh() async {
    final controller = Get.find<AppController>();
    if (!controller.isLogin) {
      // 未登录跳转登录页
      Get.toNamed(AppRoutes.login);
      return;
    }
    await _loadUserInfo();
    _setVisit();
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
  final List<Map<String, dynamic>> _orderMenu = [
    {
      'icon': 'assets/images/all@2x.png',
      'title': '全部',
      'route': AppRoutes.orderList,
      'status': null,
    },
    {
      'icon': 'assets/images/daifukuan@2x.png',
      'title': '待付款',
      'route': '${AppRoutes.orderList}?status=0',
      'status': 'unpaid',
    },
    {
      'icon': 'assets/images/daifahuo@2x.png',
      'title': '待发货',
      'route': '${AppRoutes.orderList}?status=1',
      'status': 'unshipped',
    },
    {
      'icon': 'assets/images/daishouho-2@2x.png',
      'title': '待收货',
      'route': '${AppRoutes.orderList}?status=2',
      'status': 'received',
    },
    {
      'icon': 'assets/images/yiwancheng-2@2x.png',
      'title': '已完成',
      'route': '${AppRoutes.orderList}?status=3',
      'status': 'completed',
    },
  ];

  // 我的服务菜单数据
  List<Map<String, dynamic>> _getServiceMenu(bool h5Open) {
    return [
      {
        'icon': 'assets/images/shimingrenzheng.png',
        'title': '实名认证',
        'route': AppRoutes.userSign,
        'show': true,
      },
      {
        'icon': 'assets/images/tuandui3@2x.png',
        'title': '邀请好友',
        'route': AppRoutes.spreadCode,
        'show': true,
      },
      {
        'icon': 'assets/images/shanggong.png',
        'title': '兑换宝',
        'route': 'shuhangshangdao',
        'show': h5Open,  // 根据 h5_open 控制显示
      },
      {
        'icon': 'assets/images/ditu3@2x.png',
        'title': '地址管理',
        'route': AppRoutes.addressList,
        'show': true,
      },
      {
        'icon': 'assets/images/tuandui3@2x.png',
        'title': '我的好友',
        'route': AppRoutes.teams,
        'show': true,
      },
      {
        'icon': 'assets/images/yijianfankui-2@2x.png',
        'title': '意见反馈',
        'route': AppRoutes.feedback,
        'show': true,
      },
      {
        'icon': 'assets/images/my-card.png',
        'title': '我的信息',
        'route': AppRoutes.userInfo,
        'show': true,
      },
    ].where((item) => item['show'] == true).toList();
  }

  @override
  bool get wantKeepAlive => true;

  // 复制邀请码
  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    Get.snackbar(
      '提示',
      '邀请码已复制',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
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
      Get.snackbar('提示', '功能开发中', snackPosition: SnackPosition.TOP);
      return;
    }

    Get.toNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GetBuilder<AppController>(
      builder: (controller) {
        final themeColor = controller.themeColor;
        final isLogin = controller.isLogin;
        final userInfo = controller.userInfo;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              slivers: [
                // 顶部用户信息区域
                SliverToBoxAdapter(
                  child: _buildUserHeader(controller, themeColor, isLogin, userInfo),
                ),

                // 我的订单区域
                SliverToBoxAdapter(
                  child: _buildOrderSection(controller, themeColor, isLogin, userInfo),
                ),

                // 我的服务区域
                SliverToBoxAdapter(
                  child: _buildServiceSection(controller, themeColor, userInfo),
                ),

                // 底部留白
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建用户头部区域
  Widget _buildUserHeader(AppController controller, themeColor, bool isLogin, userInfo) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg_mine@2x.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 顶部设置按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isLogin)
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.userSetting),
                      child: Image.asset(
                        'assets/images/icon_set@2x.png',
                        width: 36,
                        height: 36,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.settings, color: Colors.black54, size: 28),
                      ),
                    ),
                ],
              ),
            ),

            // 用户信息行
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                children: [
                  // 头像
                  _buildAvatar(isLogin, userInfo),
                  const SizedBox(width: 16),
                  // 用户信息
                  Expanded(
                    child: _buildUserInfo(isLogin, userInfo),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 账户信息卡片
            _buildAccountCard(isLogin, userInfo),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// 构建头像
  Widget _buildAvatar(bool isLogin, userInfo) {
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: userInfo?.isVip == true
                    ? const Color(0xFFFFAC65)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: isLogin && userInfo?.avatar != null && userInfo!.avatar.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: userInfo.avatar,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Icon(Icons.person, color: Colors.grey, size: 32),
                      errorWidget: (context, url, error) =>
                          Image.asset('assets/images/f.png', fit: BoxFit.cover),
                    )
                  : Image.asset(
                      'assets/images/f.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person, color: Colors.grey, size: 32),
                    ),
            ),
          ),
          // 实名认证状态
          if (isLogin && userInfo != null)
            Positioned(
              right: 5,
              bottom: 0,
              child: userInfo.isSign
                  ? Image.asset(
                      'assets/images/duihao@2x.png',
                      width: 18,
                      height: 18,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF54DC54), Color(0xFF00D900)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 12),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCDCDC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '未实名',
                        style: TextStyle(fontSize: 9, color: Colors.black),
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  /// 构建用户信息
  Widget _buildUserInfo(bool isLogin, userInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 昵称和VIP标识
        if (!isLogin)
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.login),
            child: const Text(
              '请点击登录',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          )
        else
          Row(
            children: [
              Flexible(
                child: Text(
                  userInfo?.nickname ?? '用户',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // 代理等级图标
              if (userInfo?.agentLevel != null && userInfo!.agentLevel > 0)
                Image.asset(
                  'assets/images/${userInfo.agentLevel}.png',
                  width: 19,
                  height: 23,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              // VIP标识
              if (userInfo?.isVip == true)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Image.asset(
                    'assets/images/svip.png',
                    width: 50,
                    height: 18,
                    errorBuilder: (context, error, stackTrace) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'SVIP',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ),
            ],
          ),

        // 邀请码 - uni-app: v-if="userInfo.phone" 只有绑定手机号后才显示
        if (isLogin && userInfo?.phone != null && userInfo!.phone.isNotEmpty && userInfo.code != null && userInfo.code!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '邀请码：',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    userInfo.code!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _copyCode(userInfo.code!),
                    child: Image.asset(
                      'assets/images/fuzhi-3@2x.png',
                      width: 12,
                      height: 12,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.copy, size: 12, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 绑定手机号提示
        if (isLogin && (userInfo?.phone == null || userInfo!.phone.isEmpty))
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.bindPhone),
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFCCCCCC),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                '绑定手机号',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  /// 构建账户信息卡片
  Widget _buildAccountCard(bool isLogin, userInfo) {
    const accountBgColor = Color(0xFF363028);
    const accountTextColor = Color(0xFFF3E1C9);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          // 我的账户标题栏
          GestureDetector(
            onTap: () => Get.toNamed('${AppRoutes.ryz}?index=0'),
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: const BoxDecoration(
                color: accountBgColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/zhanghuguanli@2x.png',
                        width: 15,
                        height: 15,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.account_balance_wallet,
                                size: 15, color: accountTextColor),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        '我的账户',
                        style: TextStyle(fontSize: 12, color: accountTextColor),
                      ),
                    ],
                  ),
                  Image.asset(
                    'assets/images/xia-3@2x.png',
                    width: 7,
                    height: 11,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.chevron_right, size: 14, color: accountTextColor),
                  ),
                ],
              ),
            ),
          ),

          // 账户数值区域
          Container(
            height: 65,
            decoration: const BoxDecoration(
              color: Color(0xFF2C2722),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                _buildAccountItem(
                  '仓库积分',
                  isLogin ? (userInfo?.fudou ?? 0).toStringAsFixed(2) : '0.00',
                  () => Get.toNamed('${AppRoutes.ryz}?index=0'),
                ),
                _buildAccountItem(
                  '可用积分',
                  isLogin ? (userInfo?.fdKy ?? 0).toStringAsFixed(2) : '0.00',
                  () => Get.toNamed('${AppRoutes.ryz}?index=1'),
                ),
                _buildAccountItem(
                  'SWP',
                  isLogin ? (userInfo?.balance ?? 0).toStringAsFixed(2) : '0.00',
                  () => Get.toNamed('${AppRoutes.ryz}?index=2'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建账户数值项
  Widget _buildAccountItem(String label, String value, VoidCallback onTap) {
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
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: accountTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: accountTextColor),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建订单区域
  Widget _buildOrderSection(AppController controller, themeColor, bool isLogin, userInfo) {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // 标题栏
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '我的订单',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E1D26),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.orderList),
                    child: Row(
                      children: const [
                        Text(
                          '查看全部',
                          style: TextStyle(fontSize: 12, color: Color(0xFF1E1D26)),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right, size: 14, color: Color(0xFF1E1D26)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 订单状态
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _orderMenu.map((item) {
                int? count;
                if (isLogin && userInfo?.orderStatusNum != null) {
                  switch (item['status']) {
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

                return _buildOrderItem(
                  item['icon'] as String,
                  item['title'] as String,
                  count,
                  () {
                    if (!isLogin) {
                      Get.toNamed(AppRoutes.login);
                      return;
                    }
                    Get.toNamed(item['route'] as String);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建订单项
  Widget _buildOrderItem(String icon, String label, int? count, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  icon,
                  width: 27,
                  height: 27,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.receipt_long, size: 27, color: Color(0xFF666666)),
                ),
                if (count != null && count > 0)
                  Positioned(
                    top: -8,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFF5A5A), width: 1),
                      ),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFFF5A5A),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建服务区域
  Widget _buildServiceSection(AppController controller, themeColor, userInfo) {
    // 根据 h5_open 获取服务菜单
    final h5Open = userInfo?.h5Open ?? false;
    final serviceMenu = _getServiceMenu(h5Open);
    
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                '我的服务',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E1D26),
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
                mainAxisSpacing: 15,
              ),
              itemCount: serviceMenu.length,
              itemBuilder: (context, index) {
                final item = serviceMenu[index];
                return _buildServiceItem(
                  item['icon'] as String,
                  item['title'] as String,
                  () => _goMenuPage(item['route'] as String, item['title'] as String),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建服务项
  Widget _buildServiceItem(String icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            icon,
            width: 26,
            height: 26,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.apps, size: 26, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 9),
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
          ),
        ],
      ),
    );
  }
}
