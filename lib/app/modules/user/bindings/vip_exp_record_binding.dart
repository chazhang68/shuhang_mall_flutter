import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/modules/user/controllers/vip_exp_record_controller.dart';

class VipExpRecordBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VipExpRecordController>(
      () => VipExpRecordController(),
    );
  }
}