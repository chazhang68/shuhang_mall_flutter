import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/data/providers/public_provider.dart';
import 'package:shuhang_mall_flutter/app/data/providers/api_provider.dart';
import 'package:shuhang_mall_flutter/app/modules/home/home_page.dart';
import 'package:shuhang_mall_flutter/app/modules/home/shop_page.dart';
import 'package:shuhang_mall_flutter/app/modules/home/task_page.dart';
import 'package:shuhang_mall_flutter/app/modules/cart/cart_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/user_page.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/utils/cache.dart';
import 'package:shuhang_mall_flutter/widgets/app_update_dialog.dart';

/// 主页面（包含底部导航栏）
/// 对应原 tabBar 配置
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _bottomIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = const [HomePage(), ShopPage(), TaskPage(), CartPage(), UserPage()];

  @override
  void initState() {
    super.initState();
    // 处理 tab 参数
    final args = Get.arguments;
    if (args != null && args is Map && args['tab'] != null) {
      final tabIndex = args['tab'] as int;
      if (tabIndex >= 0 && tabIndex < _pages.length) {
        if (tabIndex != 2) {
          _bottomIndex = tabIndex > 2 ? tabIndex - 1 : tabIndex;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pageController.jumpToPage(tabIndex);
        });
      }
    }
    // 对应 uni-app: app-update 组件 created → 首页加载后自动检查版本更新
    _checkAppUpdate();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      if (index != 2) {
        _bottomIndex = index > 2 ? index - 1 : index;
      }
    });
  }

  Future<void> _onItemTapped(int index) async {
    final controller = Get.find<AppController>();
    final requiresLogin = index == 3 || index == 4;

    if (requiresLogin && !controller.isLogin) {
      await Get.toNamed(AppRoutes.login);
      if (!controller.isLogin) {
        await Get.toNamed(AppRoutes.login);
      }
      return;
    }

    _pageController.jumpToPage(index);
  }

  Future<void> _onBottomTap(int index) async {
    final targetIndex = index >= 2 ? index + 1 : index;
    await _onItemTapped(targetIndex);
    if (!mounted) return;
    if (targetIndex != 2) {
      setState(() {
        _bottomIndex = index;
      });
    }
  }

  Future<void> _onCenterTap() async {
    await _onItemTapped(2);
  }

  /// 自动检查APP版本更新
  /// 对应 uni-app: app-update 组件 created → update() → getUpdateInfo()
  Future<void> _checkAppUpdate() async {
    // 延迟等首页渲染完成（开屏广告之后）
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final type = Platform.isIOS ? 2 : 1;
      final response = await PublicProvider().getUpdateInfo(type);

      if (!response.isSuccess || response.data == null) return;
      // API 返回数组说明没有更新
      if (response.data is List) return;

      final data = response.data as Map<String, dynamic>;
      final newVersion = data['version']?.toString() ?? '';
      final info = data['info']?.toString() ?? '';
      final url = data['url']?.toString() ?? '';
      final isForce = data['is_force'] == 1 || data['is_force'] == true;
      final platform = data['platform']?.toString() ?? '';

      // 后台未配置当前平台的升级数据
      if (platform.isEmpty) return;
      // 对比版本号
      if (!_compareVersion(currentVersion, newVersion)) return;

      // 非强制更新：每天只提示一次
      if (!isForce) {
        final today = DateTime.now().toIso8601String().substring(0, 10);
        final lastPromptDate = Cache.getString(CacheKey.appUpdateTime);
        if (lastPromptDate == today) return;
        await Cache.setString(CacheKey.appUpdateTime, today);
      }

      if (!mounted) return;

      // 获取 App Logo（跟登录页一样从 API 获取）
      String logoUrl = '';
      try {
        final logoResponse = await ApiProvider.instance.get('wechat/get_logo', noAuth: true);
        if (logoResponse.isSuccess && logoResponse.data != null) {
          final logoData = logoResponse.data as Map<String, dynamic>;
          logoUrl = logoData['logo_url']?.toString() ?? '';
        }
      } catch (_) {}

      if (!mounted) return;

      // 显示更新弹窗
      Get.dialog(
        AppUpdateDialog(
          version: newVersion,
          info: info,
          url: url,
          isForce: isForce,
          logoUrl: logoUrl,
        ),
        barrierDismissible: !isForce,
        barrierColor: Colors.black.withAlpha(153),
      );
    } catch (e) {
      debugPrint('自动检查更新失败: $e');
    }
  }

  /// 对比版本号
  bool _compareVersion(String oldVersion, String newVersion) {
    if (oldVersion.isEmpty || newVersion.isEmpty) return false;
    final ov = oldVersion.split('.');
    final nv = newVersion.split('.');
    for (int i = 0; i < ov.length && i < nv.length; i++) {
      final no = int.tryParse(ov[i]) ?? 0;
      final nn = int.tryParse(nv[i]) ?? 0;
      if (nn > no) return true;
      if (nn < no) return false;
    }
    if (nv.length > ov.length && newVersion.startsWith(oldVersion)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        final themeColor = controller.themeColor;
        return Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const NeverScrollableScrollPhysics(),
            children: _pages,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: SizedBox(width: 54.w, height: 54.w),
          bottomNavigationBar: Stack(
            alignment: Alignment.center,
            clipBehavior: .none,
            children: [
              AnimatedBottomNavigationBar.builder(
                itemCount: 4,
                activeIndex: _bottomIndex,
                gapLocation: GapLocation.center,
                notchSmoothness: NotchSmoothness.defaultEdge,
                splashColor: Colors.white,
                elevation: 0,
                leftCornerRadius: 0,
                rightCornerRadius: 0,
                onTap: _onBottomTap,
                height: kBottomNavigationBarHeight + 4,
                tabBuilder: (index, isActive) {
                  final color = isActive ? themeColor.primary : const Color(0xFF999999);
                  final label = switch (index) {
                    0 => '首页',
                    1 => '商城',
                    2 => '购物车',
                    _ => '我的',
                  };
                  final icon = switch (index) {
                    0 => isActive ? Icons.home : Icons.home_outlined,
                    1 => isActive ? Icons.store : Icons.store_outlined,
                    2 => isActive ? Icons.shopping_cart : Icons.shopping_cart_outlined,
                    _ => isActive ? Icons.person : Icons.person_outline,
                  };

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (index == 2)
                          Obx(() {
                            final cartNum = controller.cartNum;
                            if (cartNum > 0) {
                              return badges.Badge(
                                badgeContent: Text(
                                  cartNum > 99 ? '99+' : cartNum.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                ),
                                child: Icon(icon, color: color, size: 26),
                              );
                            }
                            return Icon(icon, color: color, size: 26);
                          })
                        else
                          Icon(icon, color: color, size: 26),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Positioned(
                top: -10.h,
                child: GestureDetector(
                  onTap: _onCenterTap,
                  child: Image.asset('assets/images/main_conter.png', width: 56.w, height: 56.w),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
