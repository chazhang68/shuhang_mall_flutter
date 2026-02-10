import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../controllers/webview_controller.dart';

/// WebView 页面
/// 对应原 pages/webview/webview.vue
class WebViewPage extends GetView<WebViewPageController> {
  const WebViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 构建平台特定的 WebViewWidget
    final WebViewWidget webViewWidget;
    if (controller.webViewController.platform is AndroidWebViewController) {
      webViewWidget = WebViewWidget.fromPlatformCreationParams(
        params: AndroidWebViewWidgetCreationParams(
          controller: controller.webViewController.platform as AndroidWebViewController,
        ),
      );
    } else {
      webViewWidget = WebViewWidget(controller: controller.webViewController);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final shouldPop = await controller.goBack();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Obx(() => Text(
                controller.title.value.isEmpty ? '加载中...' : controller.title.value,
                style: const TextStyle(fontSize: 18),
              )),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: controller.reload,
              tooltip: '刷新',
            ),
          ],
        ),
        body: Stack(
          children: [
            webViewWidget,
            Obx(() => controller.isLoading.value
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
