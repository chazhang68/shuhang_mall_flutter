import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/controllers/index_data_controller.dart';
import 'package:shuhang_mall_flutter/app/controllers/hot_words_controller.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';

/// 全局依赖注入
/// 对应原 store/index.js
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // 全局控制器（永久存在）
    Get.put(AppController(), permanent: true);
    Get.put(IndexDataController(), permanent: true);
    Get.put(HotWordsController(), permanent: true);
    // 全局服务提供者
    Get.put(UserProvider(), permanent: true);
  }
}
