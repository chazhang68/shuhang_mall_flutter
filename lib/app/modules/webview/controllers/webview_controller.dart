import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';

/// WebView 控制器
/// 对应原 pages/webview/webview.vue
class WebViewPageController extends GetxController {
  late final WebViewController webViewController;
  final isLoading = true.obs;
  final url = ''.obs;
  final title = ''.obs;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _initWebView();
  }

  /// 初始化 WebView
  void _initWebView() {
    // 获取 URL 参数（base64 编码）
    final encodedUrl = Get.parameters['url'] ?? '';

    if (encodedUrl.isEmpty) {
      Get.back();
      return;
    }

    try {
      // 解码 base64 URL
      final decodedUrl = utf8.decode(base64.decode(encodedUrl));
      debugPrint('解码后的 URL: $decodedUrl');

      // 添加 token 参数
      final appController = Get.find<AppController>();
      final token = appController.token;

      String finalUrl = decodedUrl;
      if (finalUrl.contains('?')) {
        finalUrl += '&token=$token';
      } else {
        finalUrl += '?token=$token';
      }

      url.value = finalUrl;
      debugPrint('最终 URL: $finalUrl');

      // 根据平台创建 WebView 控制器
      late final PlatformWebViewControllerCreationParams params;
      if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        params = WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        );
      } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
        params = AndroidWebViewControllerCreationParams();
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }

      // 初始化 WebView 控制器
      webViewController = WebViewController.fromPlatformCreationParams(params)
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              debugPrint('WebView 加载进度: $progress%');
            },
            onPageStarted: (String url) {
              isLoading.value = true;
            },
            onPageFinished: (String url) {
              isLoading.value = false;
              // 获取页面标题
              webViewController.getTitle().then((pageTitle) {
                if (pageTitle != null && pageTitle.isNotEmpty) {
                  title.value = pageTitle;
                }
              });
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('WebView 加载错误: ${error.description}');
            },
          ),
        )
        ..loadRequest(Uri.parse(finalUrl));

      // 配置 Android 平台特定功能
      if (webViewController.platform is AndroidWebViewController) {
        final androidController = webViewController.platform as AndroidWebViewController;
        androidController.setMediaPlaybackRequiresUserGesture(false);

        // 设置文件选择器回调
        androidController.setOnShowFileSelector(_onShowFileSelector);
      }

      // 配置 iOS 平台特定功能
      if (webViewController.platform is WebKitWebViewController) {
        final wkController = webViewController.platform as WebKitWebViewController;
        wkController.setAllowsBackForwardNavigationGestures(true);
      }
    } catch (e) {
      debugPrint('WebView 初始化失败: $e');
      Get.back();
    }
  }

  /// 处理文件选择器（支持相机和相册）
  Future<List<String>> _onShowFileSelector(FileSelectorParams params) async {
    try {
      debugPrint('文件选择器被调用，接受类型: ${params.acceptTypes}');

      // 判断是否接受图片
      final acceptsImages = params.acceptTypes.any((type) =>
        type.contains('image') || type == '*/*' || type.isEmpty
      );

      if (!acceptsImages) {
        debugPrint('不支持的文件类型');
        return [];
      }

      // 显示选择对话框：相机或相册
      final source = await Get.dialog<ImageSource>(
        AlertDialog(
          title: const Text('选择图片来源'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照'),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('取消'),
            ),
          ],
        ),
      );

      if (source == null) {
        return [];
      }

      // 根据是否支持多选来选择图片
      if (params.mode == FileSelectorMode.openMultiple) {
        // 多选模式（仅相册支持）
        if (source == ImageSource.gallery) {
          final List<XFile> images = await _imagePicker.pickMultiImage(
            maxWidth: 1920,
            maxHeight: 1920,
            imageQuality: 85,
          );
          return images.map((image) => image.path).toList();
        } else {
          // 相机只能单选
          final XFile? image = await _imagePicker.pickImage(
            source: source,
            maxWidth: 1920,
            maxHeight: 1920,
            imageQuality: 85,
          );
          return image != null ? [image.path] : [];
        }
      } else {
        // 单选模式
        final XFile? image = await _imagePicker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );
        return image != null ? [image.path] : [];
      }
    } catch (e) {
      debugPrint('文件选择失败: $e');
      return [];
    }
  }

  /// 返回上一页
  Future<bool> goBack() async {
    if (await webViewController.canGoBack()) {
      await webViewController.goBack();
      return false; // 不退出页面
    }
    return true; // 退出页面
  }

  /// 刷新页面
  void reload() {
    webViewController.reload();
  }
}
