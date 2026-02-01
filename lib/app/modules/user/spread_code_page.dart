import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../data/providers/user_provider.dart';

/// 推广名片页面 - 对应 pages/users/user_spread_code/index.vue
class SpreadCodePage extends StatefulWidget {
  const SpreadCodePage({super.key});

  @override
  State<SpreadCodePage> createState() => _SpreadCodePageState();
}

class _SpreadCodePageState extends State<SpreadCodePage> {
  final UserProvider _userProvider = UserProvider();
  final PageController _pageController = PageController();

  List<Map<String, dynamic>> posterList = [];
  int currentIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getBanner();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 获取推广海报
  Future<void> _getBanner() async {
    try {
      final response = await _userProvider.spreadBanner();
      if (response.isSuccess && response.data != null) {
        final list = response.data as List? ?? [];
        setState(() {
          posterList = list.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        FlutterToastPro.showMessage('获取海报失败');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      FlutterToastPro.showMessage('生成失败');
    }
  }

  /// 保存图片到相册
  Future<void> _savePoster(int index) async {
    if (posterList.isEmpty || index >= posterList.length) return;

    final poster = posterList[index];
    final url = poster['wap_poster'] ?? '';
    if (url.isEmpty) {
      FlutterToastPro.showMessage('海报地址无效');
      return;
    }

    // 请求权限
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        final result = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('提示'),
            content: const Text('需要获取相册的读取权限保存推广图片'),
            actions: [
              TextButton(onPressed: () => Get.back(result: false), child: const Text('取消')),
              TextButton(onPressed: () => Get.back(result: true), child: const Text('确定')),
            ],
          ),
        );

        if (result != true) return;

        // 再次请求权限
        final newStatus = await Permission.photos.request();
        if (!newStatus.isGranted) {
          FlutterToastPro.showMessage('请在设置中开启相册权限');
          return;
        }
      }
    }

    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      final response = await Dio().get(url, options: Options(responseType: ResponseType.bytes));

      final tempDir = await getTemporaryDirectory();
      final fileName = 'poster_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(response.data);

      await Gal.putImage(file.path);
      Get.back();
      FlutterToastPro.showMessage('保存成功');

      await file.delete();
    } catch (e) {
      Get.back();
      FlutterToastPro.showMessage('保存失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : posterList.isEmpty
          ? const Center(
              child: Text('暂无推广海报', style: TextStyle(color: Colors.white)),
            )
          : _buildPosterSwiper(),
    );
  }

  /// 海报轮播
  Widget _buildPosterSwiper() {
    return GestureDetector(
      onTap: () => _savePoster(currentIndex),
      child: PageView.builder(
        controller: _pageController,
        itemCount: posterList.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return _buildPosterItem(posterList[index]);
        },
      ),
    );
  }

  /// 海报项
  Widget _buildPosterItem(Map<String, dynamic> poster) {
    final url = poster['wap_poster'] ?? '';
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              color: Colors.white,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 60, color: Colors.white54),
                SizedBox(height: 10),
                Text('图片加载失败', style: TextStyle(color: Colors.white54)),
              ],
            ),
          );
        },
      ),
    );
  }
}
