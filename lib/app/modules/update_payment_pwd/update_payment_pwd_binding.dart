import 'package:get/get.dart';

import 'update_payment_pwd_controller.dart';

class UpdatePaymentPwdBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpdatePaymentPwdController>(() => UpdatePaymentPwdController());
  }
}
