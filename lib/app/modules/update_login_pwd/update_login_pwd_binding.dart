import 'package:get/get.dart';

import '../controllers/update_login_pwd_controller.dart';

class UpdateLoginPwdBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpdateLoginPwdController>(
      () => UpdateLoginPwdController(),
    );
  }
}