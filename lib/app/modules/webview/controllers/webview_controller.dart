import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/data/providers/public_provider.dart';

/// WebView 控制器
/// 对应原 pages/webview/webview.vue
class WebViewPageController extends GetxController {
  late final WebViewController webViewController;
  final isLoading = true.obs;
  final url = ''.obs;
  final title = ''.obs;
  final ImagePicker _imagePicker = ImagePicker();
  final PublicProvider _publicProvider = PublicProvider();

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
              // 注入脚本：拦截上传请求，使用 Flutter 端上传的图片 URL
              webViewController.runJavaScript('''
                (function() {
                  if (window._flutterUploadInterceptorInstalled) return;
                  window._flutterUploadInterceptorInstalled = true;

                  // 拦截 XMLHttpRequest 上传请求
                  var origOpen = XMLHttpRequest.prototype.open;
                  var origSend = XMLHttpRequest.prototype.send;
                  XMLHttpRequest.prototype.open = function(method, url) {
                    this._url = url;
                    this._method = method;
                    return origOpen.apply(this, arguments);
                  };
                  XMLHttpRequest.prototype.send = function(body) {
                    var xhr = this;
                    // 如果有 Flutter 上传的 URL 且是上传请求
                    if (window._flutterUploadedUrl && this._url && this._url.indexOf('upload') !== -1 && body instanceof FormData) {
                      var flutterUrl = window._flutterUploadedUrl;
                      window._flutterUploadedUrl = null;
                      console.log('XHR拦截: 使用Flutter上传的URL: ' + flutterUrl);

                      var responseBody = JSON.stringify({status:200, msg:'success', data:{url: flutterUrl}});
                      // 异步模拟响应，让调用方的后续代码先执行
                      setTimeout(function() {
                        Object.defineProperty(xhr, 'status', { value: 200, writable: false, configurable: true });
                        Object.defineProperty(xhr, 'readyState', { value: 4, writable: false, configurable: true });
                        Object.defineProperty(xhr, 'responseText', { value: responseBody, writable: false, configurable: true });
                        Object.defineProperty(xhr, 'response', { value: responseBody, writable: false, configurable: true });
                        if (xhr.onreadystatechange) xhr.onreadystatechange();
                        xhr.dispatchEvent(new Event('load'));
                        xhr.dispatchEvent(new Event('loadend'));
                        if (xhr.onload) xhr.onload();
                      }, 50);
                      return;
                    }
                    return origSend.apply(this, arguments);
                  };

                  // 同时拦截 fetch 上传请求
                  var origFetch = window.fetch;
                  window.fetch = function(input, init) {
                    var reqUrl = typeof input === 'string' ? input : (input && input.url ? input.url : '');
                    if (window._flutterUploadedUrl && reqUrl.indexOf('upload') !== -1 && init && init.body instanceof FormData) {
                      var flutterUrl = window._flutterUploadedUrl;
                      window._flutterUploadedUrl = null;
                      console.log('Fetch拦截: 使用Flutter上传的URL: ' + flutterUrl);
                      var responseBody = JSON.stringify({status:200, msg:'success', data:{url: flutterUrl}});
                      return Promise.resolve(new Response(responseBody, {status: 200, headers: {'Content-Type': 'application/json'}}));
                    }
                    return origFetch.apply(this, arguments);
                  };

                  console.log('上传拦截脚本已注入');
                })();
              ''');
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
  /// Flutter 端压缩并上传图片，然后通过 JS 变量传递 URL，
  /// 同时返回压缩文件的 URI 给 WebView，让 H5 触发上传流程，
  /// 但 XHR 拦截脚本会用 Flutter 上传的 URL 替代实际上传
  Future<List<String>> _onShowFileSelector(FileSelectorParams params) async {
    try {
      debugPrint('文件选择器被调用，接受类型: ${params.acceptTypes}');

      // 判断是否接受图片
      final acceptsImages =
          params.acceptTypes.isEmpty ||
          params.acceptTypes.any((type) => type.contains('image') || type == '*/*');

      if (!acceptsImages) {
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
          actions: [TextButton(onPressed: () => Get.back(), child: const Text('取消'))],
        ),
      );

      if (source == null) {
        return [];
      }

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 80,
      );
      if (image == null) {
        return [];
      }

      debugPrint('图片路径: ${image.path}');
      final file = File(image.path);
      if (file.existsSync()) {
        debugPrint('文件大小: ${(file.lengthSync() / 1024).toStringAsFixed(1)} KB');
      }

      // 在 Flutter 端直接上传图片到服务器
      final response = await _publicProvider.uploadFile(filePath: image.path);
      if (response.isSuccess && response.data != null) {
        final imageUrl = response.data['url'] as String?;
        debugPrint('上传成功，图片URL: $imageUrl');
        if (imageUrl != null) {
          // 先通过 JS 设置全局变量，XHR 拦截脚本会使用这个 URL
          await webViewController.runJavaScript('''
            window._flutterUploadedUrl = '$imageUrl';
            console.log('设置Flutter上传URL: $imageUrl');
          ''');
        }
      } else {
        debugPrint('上传失败: ${response.msg}');
      }

      // 返回压缩文件的 file:// URI，让 H5 认为用户选择了文件并触发上传流程
      // H5 的 XHR 上传请求会被拦截脚本拦截，使用 Flutter 上传的 URL
      final fileUri = File(image.path).uri.toString();
      debugPrint('返回文件URI给WebView: $fileUri');
      return [fileUri];
    } catch (e, stackTrace) {
      debugPrint('文件选择失败: $e');
      debugPrint('堆栈跟踪: $stackTrace');
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
