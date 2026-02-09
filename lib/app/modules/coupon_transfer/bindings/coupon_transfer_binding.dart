import 'package:get/get.dart';
import '../controllers/coupon_transfer_controller.dart';

/// 消费券互转绑定
class CouponTransferBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CouponTransferController>(
      () => CouponTransferController(),
    );
  }
}
