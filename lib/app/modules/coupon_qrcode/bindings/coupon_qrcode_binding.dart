import 'package:get/get.dart';
import '../controllers/coupon_qrcode_controller.dart';

/// 消费券二维码绑定
class CouponQrcodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CouponQrcodeController>(() => CouponQrcodeController());
  }
}
