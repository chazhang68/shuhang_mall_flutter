import 'package:flutter/material.dart';
import 'package:zjsdk_android/widget/zj_native_express_view.dart';
import 'package:zjsdk_android/event/zj_event.dart';
import 'package:zjsdk_android/event/event_action.dart';
import 'package:shuhang_mall_flutter/app/config/ad_config.dart';
import 'package:shuhang_mall_flutter/app/services/ad_manager.dart';

/// ZJSDK 信息流广告组件
class ZJFeedAdWidget extends StatefulWidget {
  final double width;
  final double? height; // 改为可选，null时自适应
  final bool videoSoundEnable;
  final Function()? onShow;
  final Function()? onClick;
  final Function()? onClose;
  final Function(String)? onError;

  const ZJFeedAdWidget({
    super.key,
    required this.width,
    this.height, // 可选高度，不传则自适应
    this.videoSoundEnable = false,
    this.onShow,
    this.onClick,
    this.onClose,
    this.onError,
  });

  @override
  State<ZJFeedAdWidget> createState() => _ZJFeedAdWidgetState();
}

class _ZJFeedAdWidgetState extends State<ZJFeedAdWidget> {
  bool _hasError = false;
  bool _sdkReady = false;

  @override
  void initState() {
    super.initState();
    _ensureSdkReady();
  }

  Future<void> _ensureSdkReady() async {
    if (AdManager.instance.isStarted) {
      if (mounted) setState(() => _sdkReady = true);
      return;
    }

    // SDK未启动，等待启动完成后再渲染广告
    debugPrint('⏳ ZJFeedAdWidget: SDK未启动，等待启动...');
    final started = await AdManager.instance.start();
    if (mounted) {
      if (started && AdManager.instance.isStarted) {
        debugPrint('✅ ZJFeedAdWidget: SDK启动完成，开始加载广告');
        setState(() => _sdkReady = true);
      } else {
        debugPrint('❌ ZJFeedAdWidget: SDK启动失败');
        setState(() => _hasError = true);
        widget.onError?.call('广告SDK启动失败');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎯 ZJFeedAdWidget: 开始构建，_sdkReady=$_sdkReady, _hasError=$_hasError');

    if (_hasError) {
      debugPrint('❌ ZJFeedAdWidget: 广告加载失败，返回空容器');
      return const SizedBox.shrink();
    }

    if (!_sdkReady) {
      // SDK还没准备好，返回占位容器
      final adHeight = (widget.height == null || widget.height == 0)
          ? widget.width / 3.75
          : widget.height!;
      return SizedBox(width: widget.width, height: adHeight);
    }

    // SDK示例推荐使用整数值
    final adWidth = widget.width.roundToDouble();
    final adHeight = (widget.height == null || widget.height == 0)
        ? (widget.width / 3.75).roundToDouble()
        : widget.height!.roundToDouble();

    debugPrint(
      '📐 ZJFeedAdWidget: width=$adWidth, height=$adHeight, adId=${AdConfig.feedAdId}',
    );

    try {
      return SizedBox(
        width: adWidth,
        height: adHeight,
        child: ZJNativeExpressView(
          AdConfig.feedAdId,
          width: adWidth,
          height: adHeight,
          videoSoundEnable: widget.videoSoundEnable,
          nativeExpressListener: _handleAdEvent,
        ),
      );
    } catch (e) {
      debugPrint('⚠️ ZJFeedAdWidget: 创建广告组件异常 - $e');
      setState(() => _hasError = true);
      return const SizedBox.shrink();
    }
  }

  void _handleAdEvent(ZJEvent ret) {
    debugPrint(
      '📢 ZJFeedAdWidget: 收到广告事件 - action=${ret.action}, msg=${ret.msg}',
    );

    if (ret.action == ZJEventAction.onAdShow) {
      debugPrint('✅ 信息流广告展示成功');
      widget.onShow?.call();
    } else if (ret.action == ZJEventAction.onAdClick) {
      debugPrint('👆 信息流广告点击');
      widget.onClick?.call();
    } else if (ret.action == ZJEventAction.onAdClose) {
      debugPrint('❌ 信息流广告关闭');
      widget.onClose?.call();
    } else if (ret.action == ZJEventAction.onAdError) {
      debugPrint('⚠️ 信息流广告错误: ${ret.msg}');
      setState(() => _hasError = true);
      widget.onError?.call(ret.msg ?? '未知错误');
    } else {
      debugPrint('ℹ️ 信息流广告其他事件: ${ret.action}');
    }
  }
}
