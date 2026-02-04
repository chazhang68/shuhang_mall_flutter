import 'package:get/get.dart';
import '../controllers/user_sign_controller.dart';

class UserSignBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserSignController>(() => UserSignController());
  }
}