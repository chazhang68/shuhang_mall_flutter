import 'package:get/get.dart';

import '../controllers/user_account_safe_controller.dart';

class UserAccountSafeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserAccountSafeController>(
      () => UserAccountSafeController(),
    );
  }
}