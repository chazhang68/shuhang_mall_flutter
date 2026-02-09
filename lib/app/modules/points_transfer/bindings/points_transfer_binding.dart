import 'package:get/get.dart';
import '../controllers/points_transfer_controller.dart';

/// 积分转赠绑定
class PointsTransferBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PointsTransferController>(
      () => PointsTransferController(),
    );
  }
}
