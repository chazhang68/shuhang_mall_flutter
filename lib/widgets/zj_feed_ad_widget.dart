import 'package:flutter/material.dart';
import 'package:zjsdk_android/widget/zj_native_express_view.dart';
import 'package:zjsdk_android/event/zj_event.dart';
import 'package:zjsdk_android/event/event_action.dart';
import 'package:shuhang_mall_flutter/app/config/ad_config.dart';

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

  @override
  Widget build(BuildContext context) {
    // 广告加载失败时返回空容器，不占用空间
    if (_hasError) {
      return const SizedBox.shrink();
    }

    // 使用自适应高度：传0或不传height时，广告会根据内容自适应
    final adHeight = widget.height ?? 0;

    return ZJNativeExpressView(
      AdConfig.feedAdId,
      width: widget.width,
      height: adHeight, // 0表示自适应高度
      videoSoundEnable: widget.videoSoundEnable,
      nativeExpressListener: _handleAdEvent,
    );
  }

  void _handleAdEvent(ZJEvent ret) {
    if (ret.action == ZJEventAction.onAdShow) {
      debugPrint('信息流广告展示成功');
      widget.onShow?.call();
    } else if (ret.action == ZJEventAction.onAdClick) {
      debugPrint('信息流广告点击');
      widget.onClick?.call();
    } else if (ret.action == ZJEventAction.onAdClose) {
      debugPrint('信息流广告关闭');
      widget.onClose?.call();
    } else if (ret.action == ZJEventAction.onAdError) {
      debugPrint('信息流广告错误: ${ret.msg}');
      setState(() => _hasError = true);
      widget.onError?.call(ret.msg ?? '未知错误');
    }
  }
}
