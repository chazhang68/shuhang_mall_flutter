import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/core/constants/app_images.dart';

/// 启动页 - 品牌Logo展示
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // 显示启动页2秒后跳转广告页
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Get.offAllNamed(AppRoutes.splashAd);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppImages.logo,
                    width: 120,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.image,
                          size: 60,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Text(
                '© 2024 数航商道',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
