import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/modules/home/home_page.dart';
import 'package:shuhang_mall_flutter/app/modules/home/shop_page.dart';
import 'package:shuhang_mall_flutter/app/modules/home/task_page.dart';
import 'package:shuhang_mall_flutter/app/modules/cart/cart_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/user_page.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';

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
