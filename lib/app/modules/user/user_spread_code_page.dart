import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shuhang_mall_flutter/app/data/providers/public_provider.dart';
import 'package:gal/gal.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// 推广名片/二维码页面
/// 对应原 pages/users/user_spread_code/index.vue
/// 一比一复刻 uni-app 界面
class UserSpreadCodePage extends StatefulWidget {
  const UserSpreadCodePage({super.key});

  @override
  State<UserSpreadCodePage> createState() => _UserSpreadCodePageState();
}

class _UserSpreadCodePageState extends State<UserSpreadCodePage> {
  final PublicProvider _publicProvider = Get.find<PublicProvider>();
  final PageController _pageController = PageController();
  
  List<Map<String, dynamic>> _posterList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPoster();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 获取海报
  /// 对应 uni-app: getBanner()
  Future<void> _loadPoster() async {
    final response = await _publicProvider.getBanner();
    if (response.isSuccess && response.data != null) {
      setState(() {
        _posterList = List<Map<String, dynamic>>.from(response.data);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar('提示', '生成失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 对应 uni-app: sysHeight = uni.getSystemInfoSync().screenHeight + 'px'
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          // 对应 uni-app: uni.showLoading({title:'海报生成中'})
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    '海报生成中',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            )
          : _posterList.isEmpty
              ? const Center(
                  child: Text(
                    '暂无海报',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              // 对应 uni-app: <swiper :style="{height:sysHeight}" :interval="1000" :duration="100">
              : SizedBox(
                  height: screenHeight,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _posterList.length,
                    itemBuilder: (context, index) {
                      // 对应 uni-app: <image :src="item.wap_poster" @click='savePosterPathMp(list[index])'>
                      String posterUrl = _posterList[index]['wap_poster'] ?? '';
                      return GestureDetector(
                        onTap: () => _savePoster(index),
                        child: CachedNetworkImage(
                          imageUrl: posterUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(Icons.error, color: Colors.white, size: 48),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  /// 保存海报
  /// 对应 uni-app: savePosterPathMp -> uni.saveImageToPhotosAlbum
  Future<void> _savePoster(int index) async {
    // 对应 uni-app: uni.showModal({title: '提示', content: '需要获取相册的读取权限保存推广图片'})
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('提示'),
        content: const Text('需要获取相册的读取权限保存推广图片'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final String posterUrl = _posterList[index]['wap_poster'] ?? '';
    if (posterUrl.isEmpty) {
      Get.snackbar('提示', '海报地址为空');
      return;
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // 下载图片
      final response = await Dio().get(
        posterUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      // 保存到临时文件
      final tempDir = await getTemporaryDirectory();
      final fileName = 'poster_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(response.data);

      // 对应 uni-app: uni.saveImageToPhotosAlbum({filePath: url.wap_poster})
      await Gal.putImage(file.path);

      Get.back(); // 关闭 loading
      // 对应 uni-app: uni.showToast({title: '保存成功', icon: 'success'})
      Get.snackbar('提示', '保存成功');

      // 删除临时文件
      await file.delete();
    } catch (e) {
      Get.back(); // 关闭 loading
      debugPrint('保存海报失败: $e');
      // 对应 uni-app: uni.showToast({title: '保存失败', icon: 'error'})
      Get.snackbar('提示', '保存失败');
    }
  }
}
