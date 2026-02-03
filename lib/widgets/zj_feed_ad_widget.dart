import 'package:flutter/material.dart';
import 'package:zjsdk_android/widget/zj_native_express_view.dart';
import 'package:zjsdk_android/event/zj_event.dart';
import 'package:zjsdk_android/event/event_action.dart';
import 'package:shuhang_mall_flutter/app/config/ad_config.dart';

/// ZJSDK 信息流广告组件
class ZJFeedAdWidget extends StatefulWidget {
  final double width;
  final double height;
  final bool videoSoundEnable;
  final Function()? onShow;
  final Function()? onClick;
  final Function()? onClose;
  final Function(String)? onError;

  const ZJFeedAdWidget({
    super.key,
    required this.width,
    required this.height,
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

  @override
  Widget build(BuildContext context) {
    // 广告加载失败时返回空容器，不占用空间
    if (_hasError) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ZJNativeExpressView(
        AdConfig.feedAdId,
        width: widget.width,
        height: widget.height,
        videoSoundEnable: widget.videoSoundEnable,
        nativeExpressListener: _handleAdEvent,
      ),
    );
  }

  void _handleAdEvent(ZJEvent ret) {
    if (ret.action == ZJEventAction.onAdShow) {
      widget.onShow?.call();
    } else if (ret.action == ZJEventAction.onAdClick) {
      widget.onClick?.call();
    } else if (ret.action == ZJEventAction.onAdClose) {
      widget.onClose?.call();
    } else if (ret.action == ZJEventAction.onAdError) {
      setState(() => _hasError = true);
      widget.onError?.call(ret.msg ?? '未知错误');
    }
  }
}
