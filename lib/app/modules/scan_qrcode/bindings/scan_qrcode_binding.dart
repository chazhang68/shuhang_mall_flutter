import 'package:get/get.dart';
import '../controllers/scan_qrcode_controller.dart';

/// 扫一扫绑定
class ScanQrcodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScanQrcodeController>(
      () => ScanQrcodeController(),
    );
  }
}
