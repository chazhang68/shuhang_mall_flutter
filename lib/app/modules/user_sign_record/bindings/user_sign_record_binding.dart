import 'package:get/get.dart';
import '../controllers/user_sign_record_controller.dart';

class UserSignRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserSignRecordController>(() => UserSignRecordController());
  }
}