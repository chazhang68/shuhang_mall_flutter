import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/modules/home/home_page.dart';
import 'package:shuhang_mall_flutter/app/modules/home/shop_page.dart';
import 'package:shuhang_mall_flutter/app/modules/home/task_page.dart';
import 'package:shuhang_mall_flutter/app/modules/cart/cart_page.dart';
import 'package:shuhang_mall_flutter/app/modules/user/user_page.dart';

/// 主页面（包含底部导航栏）
/// 对应原 tabBar 配置
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = const [
    HomePage(),
    ShopPage(),
    TaskPage(),
    CartPage(),
    UserPage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
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
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: themeColor.primary,
            unselectedItemColor: const Color(0xFF999999),
            selectedFontSize: 10,
            unselectedFontSize: 10,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: '首页',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.store_outlined),
                activeIcon: Icon(Icons.store),
                label: '商城',
              ),
              const BottomNavigationBarItem(
                icon: SizedBox(
                  width: 40,
                  height: 40,
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
                    child: Icon(Icons.check, color: Color(0xFFE93323), size: 24),
                  ),
                ),
                activeIcon: SizedBox(
                  width: 40,
                  height: 40,
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
                    child: Icon(Icons.check, color: Color(0xFFE93323), size: 24),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      child: const Icon(Icons.shopping_cart_outlined),
                    );
                  }
                  return const Icon(Icons.shopping_cart_outlined);
                }),
                activeIcon: Obx(() {
                  final cartNum = controller.cartNum;
                  if (cartNum > 0) {
                    return badges.Badge(
                      badgeContent: Text(
                        cartNum > 99 ? '99+' : cartNum.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      child: const Icon(Icons.shopping_cart),
                    );
                  }
                  return const Icon(Icons.shopping_cart);
                }),
                label: '购物车',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: '我的',
              ),
            ],
          ),
        );
      },
    );
  }
}
