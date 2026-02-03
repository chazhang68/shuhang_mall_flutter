import 'package:flutter/material.dart';
import 'package:zjsdk_android/widget/zj_banner_view.dart';
import 'package:zjsdk_android/event/zj_event.dart';
import 'package:zjsdk_android/event/event_action.dart';
import 'package:shuhang_mall_flutter/app/config/ad_config.dart';

/// ZJSDK 横幅广告组件
class ZJBannerAdWidget extends StatefulWidget {
  final double width;
  final double height;
  final Function()? onShow;
  final Function()? onClick;
  final Function()? onClose;
  final Function(String)? onError;

  const ZJBannerAdWidget({
    super.key,
    required this.width,
    required this.height,
    this.onShow,
    this.onClick,
    this.onClose,
    this.onError,
  });

  @override
  State<ZJBannerAdWidget> createState() => _ZJBannerAdWidgetState();
}

class _ZJBannerAdWidgetState extends State<ZJBannerAdWidget> {
  bool _isLoaded = false;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(
          child: Text('广告加载失败', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ZJBannerView(
        AdConfig.bannerAdId,
        width: widget.width,
        height: widget.height,
        refreshInterval: 30, // 30秒自动刷新
        bannerListener: _handleAdEvent,
      ),
    );
  }

  void _handleAdEvent(ZJEvent ret) {
    if (ret.action == ZJEventAction.onAdShow) {
      setState(() => _isLoaded = true);
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
