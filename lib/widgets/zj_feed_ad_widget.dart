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
    debugPrint('🎯 ZJFeedAdWidget: 开始构建，_hasError=$_hasError');

    // 广告加载失败时返回空容器，不占用空间
    if (_hasError) {
      debugPrint('❌ ZJFeedAdWidget: 广告加载失败，返回空容器');
      return const SizedBox.shrink();
    }

    // 使用明确的高度，如果传入的height为null或0，使用默认高度
    final adHeight = (widget.height == null || widget.height == 0)
        ? widget.width *
              0.6 // 默认高度为宽度的0.6倍
        : widget.height!;

    debugPrint(
      '📐 ZJFeedAdWidget: width=${widget.width}, height=$adHeight, adId=${AdConfig.feedAdId}',
    );

    try {
      return ZJNativeExpressView(
        AdConfig.feedAdId,
        width: widget.width,
        height: adHeight,
        videoSoundEnable: widget.videoSoundEnable,
        nativeExpressListener: _handleAdEvent,
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
