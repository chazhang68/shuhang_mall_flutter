import 'package:get/get.dart';
import '../controllers/merchant_settlement_controller.dart';

/// 商家入驻绑定
class MerchantSettlementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MerchantSettlementController>(
      () => MerchantSettlementController(),
    );
  }
}
