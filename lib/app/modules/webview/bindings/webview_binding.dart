import 'package:get/get.dart';
import '../controllers/webview_controller.dart';

/// WebView 绑定
class WebViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WebViewPageController>(() => WebViewPageController());
  }
}
