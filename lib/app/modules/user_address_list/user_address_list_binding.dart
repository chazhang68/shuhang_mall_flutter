import 'package:get/get.dart';

import 'user_address_list_controller.dart';

class UserAddressListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserAddressListController>(() => UserAddressListController());
  }
}
