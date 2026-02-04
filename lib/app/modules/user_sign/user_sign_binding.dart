import 'package:get/get.dart';
import 'user_sign_controller.dart';

class UserSignBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserSignController>(() => UserSignController());
  }
}
