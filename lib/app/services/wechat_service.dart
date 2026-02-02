import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:fluwx/fluwx.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:dio/dio.dart';

/// 微信服务 - 管理微信SDK的初始化、分享、登录等功能
class WechatService {
  static final WechatService _instance = WechatService._internal();
  factory WechatService() => _instance;
  WechatService._internal();

  // 微信AppID（从uni-app manifest.json获取）
  static const String _appId = 'wx277a269f3d736d67';
  static const String _universalLink =
      'https://static-mp-cc15288e-4fe3-4db8-b680-73485a42c03c.next.bspapp.com/uni-universallinks/__UNI__E969FC1/';

  final Fluwx _fluwx = Fluwx();
  bool _isInitialized = false;
  bool _isWxInstalled = false;

  /// 初始化微信SDK
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      debugPrint('[WechatService] 开始初始化微信SDK...');
      debugPrint('[WechatService] AppID: $_appId');
      debugPrint('[WechatService] UniversalLink: $_universalLink');
      
      await _fluwx.registerApi(
        appId: _appId,
        universalLink: _universalLink,
      );
      _isInitialized = true;
      _isWxInstalled = await _fluwx.isWeChatInstalled;
      debugPrint('[WechatService] 微信SDK初始化成功');
      debugPrint('[WechatService] 微信已安装: $_isWxInstalled');
      
      if (!_isWxInstalled) {
        debugPrint('[WechatService] 警告：未检测到微信安装');
      }
    } catch (e, stack) {
      debugPrint('[WechatService] 微信SDK初始化失败: $e');
      debugPrint('[WechatService] Stack: $stack');
      FlutterToastPro.showMessage('微信SDK初始化失败');
    }
  }

  /// 检查微信是否安装
  Future<bool> get isInstalled async {
    if (!_isInitialized) await init();
    return _isWxInstalled;
  }

  /// 分享网页到微信好友
  Future<bool> shareWebPageToSession({
    required String url,
    required String title,
    String? description,
    String? thumbnail,
  }) async {
    return _shareWebPage(
      url: url,
      title: title,
      description: description,
      thumbnail: thumbnail,
      scene: WeChatScene.session,
    );
  }

  /// 分享网页到微信朋友圈
  Future<bool> shareWebPageToTimeline({
    required String url,
    required String title,
    String? description,
    String? thumbnail,
  }) async {
    return _shareWebPage(
      url: url,
      title: title,
      description: description,
      thumbnail: thumbnail,
      scene: WeChatScene.timeline,
    );
  }

  /// 分享网页
  Future<bool> _shareWebPage({
    required String url,
    required String title,
    String? description,
    String? thumbnail,
    required WeChatScene scene,
  }) async {
    debugPrint('[WechatService] ========== 开始分享网页 ==========');
    debugPrint('[WechatService] URL: $url');
    debugPrint('[WechatService] Title: $title');
    debugPrint('[WechatService] Description: $description');
    debugPrint('[WechatService] Thumbnail: $thumbnail');
    debugPrint('[WechatService] Scene: $scene');
    debugPrint('[WechatService] isInitialized: $_isInitialized');
    
    if (!_isInitialized) {
      debugPrint('[WechatService] SDK未初始化，正在初始化...');
      await init();
    }

    // 再次检查初始化状态
    if (!_isInitialized) {
      debugPrint('[WechatService] SDK初始化失败，取消分享');
      FlutterToastPro.showMessage('微信SDK未初始化');
      return false;
    }

    debugPrint('[WechatService] isWxInstalled: $_isWxInstalled');
    if (!_isWxInstalled) {
      debugPrint('[WechatService] 微信未安装，取消分享');
      FlutterToastPro.showMessage('请先安装微信');
      return false;
    }

    try {
      // 下载缩略图
      Uint8List? thumbData;
      if (thumbnail != null && thumbnail.isNotEmpty) {
        debugPrint('[WechatService] 开始下载缩略图...');
        thumbData = await _downloadImage(thumbnail);
        debugPrint('[WechatService] 缩略图下载完成，大小: ${thumbData?.length ?? 0} bytes');
      }

      debugPrint('[WechatService] 创建分享模型...');
      final model = WeChatShareWebPageModel(
        url,
        title: title,
        description: description ?? '',
        scene: scene,
        thumbData: thumbData,
      );
      
      debugPrint('[WechatService] 调用fluwx.share()...');
      final result = await _fluwx.share(model);
      debugPrint('[WechatService] 分享结果: $result');
      debugPrint('[WechatService] ========== 分享完成 ==========');
      
      if (!result) {
        FlutterToastPro.showMessage('分享失败，请重试');
      }
      return result;
    } catch (e, stack) {
      debugPrint('[WechatService] 分享失败: $e');
      debugPrint('[WechatService] Stack: $stack');
      FlutterToastPro.showMessage('分享出错: ${e.toString().substring(0, e.toString().length > 50 ? 50 : e.toString().length)}');
      return false;
    }
  }

  /// 分享图片到微信好友
  Future<bool> shareImageToSession({
    required String imagePath,
    String? title,
    String? description,
  }) async {
    return _shareImage(
      imagePath: imagePath,
      title: title,
      description: description,
      scene: WeChatScene.session,
    );
  }

  /// 分享图片到朋友圈
  Future<bool> shareImageToTimeline({
    required String imagePath,
    String? title,
    String? description,
  }) async {
    return _shareImage(
      imagePath: imagePath,
      title: title,
      description: description,
      scene: WeChatScene.timeline,
    );
  }

  /// 分享图片
  Future<bool> _shareImage({
    required String imagePath,
    String? title,
    String? description,
    required WeChatScene scene,
  }) async {
    if (!_isInitialized) await init();

    if (!_isWxInstalled) {
      FlutterToastPro.showMessage('请先安装微信');
      return false;
    }

    try {
      WeChatImageToShare imageToShare;
      if (imagePath.startsWith('http')) {
        // 网络图片，需要下载
        final imageData = await _downloadImage(imagePath);
        if (imageData == null) {
          FlutterToastPro.showMessage('图片加载失败');
          return false;
        }
        imageToShare = WeChatImageToShare(uint8List: imageData);
      } else {
        // 本地图片
        if (Platform.isIOS) {
          final file = File(imagePath);
          final imageData = await file.readAsBytes();
          imageToShare = WeChatImageToShare(uint8List: imageData);
        } else {
          imageToShare = WeChatImageToShare(localImagePath: imagePath);
        }
      }

      final model = WeChatShareImageModel(
        imageToShare,
        title: title,
        description: description,
        scene: scene,
      );
      final result = await _fluwx.share(model);
      return result;
    } catch (e) {
      debugPrint('分享图片失败: $e');
      FlutterToastPro.showMessage('分享失败');
      return false;
    }
  }

  /// 下载图片并返回字节数据
  Future<Uint8List?> _downloadImage(String url) async {
    try {
      final dio = Dio();
      final response = await dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.data != null) {
        return Uint8List.fromList(response.data!);
      }
    } catch (e) {
      debugPrint('下载图片失败: $e');
    }
    return null;
  }
}
