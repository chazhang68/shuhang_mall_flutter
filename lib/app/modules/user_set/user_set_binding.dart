import 'package:get/get.dart';

import 'user_set_controller.dart';

class UserSetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserSetController>(() => UserSetController());
  }
}
