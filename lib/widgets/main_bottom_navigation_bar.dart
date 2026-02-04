import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';

/// 主页面底部导航栏（可复用组件）
class MainBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const MainBottomNavigationBar({
    super.key,
    this.currentIndex = 4, // 默认选中"我的"
    this.onTap,
  });

  void _onItemTapped(int index) async {
    if (onTap != null) {
      onTap!(index);
      return;
    }

    // 默认行为：跳转到主页面对应的tab
    final controller = Get.find<AppController>();
    final requiresLogin = index == 3 || index == 4;

    if (requiresLogin && !controller.isLogin) {
      await Get.toNamed(AppRoutes.login);
      if (!controller.isLogin) {
        return;
      }
    }

    // 跳转到主页面，并切换到对应tab
    Get.offAllNamed(AppRoutes.main, arguments: {'tab': index});
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        final themeColor = controller.themeColor;

        return BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: themeColor.primary,
          unselectedItemColor: const Color(0xFF999999),
          selectedFontSize: 16,
          unselectedFontSize: 14,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          iconSize: 28,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 28),
              activeIcon: Icon(Icons.home, size: 28),
              label: '首页',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.store_outlined, size: 28),
              activeIcon: Icon(Icons.store, size: 28),
              label: '商城',
            ),
            const BottomNavigationBarItem(
              icon: SizedBox(
                width: 48,
                height: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: Color(0xFFE93323), width: 2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.check, color: Color(0xFFE93323), size: 28),
                ),
              ),
              activeIcon: SizedBox(
                width: 48,
                height: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: Color(0xFFE93323), width: 2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.check, color: Color(0xFFE93323), size: 28),
                ),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Obx(() {
                final cartNum = controller.cartNum;
                if (cartNum > 0) {
                  return badges.Badge(
                    badgeContent: Text(
                      cartNum > 99 ? '99+' : cartNum.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    child: const Icon(Icons.shopping_cart_outlined, size: 28),
                  );
                }
                return const Icon(Icons.shopping_cart_outlined, size: 28);
              }),
              activeIcon: Obx(() {
                final cartNum = controller.cartNum;
                if (cartNum > 0) {
                  return badges.Badge(
                    badgeContent: Text(
                      cartNum > 99 ? '99+' : cartNum.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    child: const Icon(Icons.shopping_cart, size: 28),
                  );
                }
                return const Icon(Icons.shopping_cart, size: 28);
              }),
              label: '购物车',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 28),
              activeIcon: Icon(Icons.person, size: 28),
              label: '我的',
            ),
          ],
        );
      },
    );
  }
}
