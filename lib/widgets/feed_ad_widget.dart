import 'package:flutter/material.dart';
import 'package:flutter_unionad/flutter_unionad.dart';
import 'package:shuhang_mall_flutter/app/config/ad_config.dart';
import 'package:shuhang_mall_flutter/app/services/ad_manager.dart';

/// 信息流广告组件
/// 用于首页商品列表中展示
class FeedAdWidget extends StatefulWidget {
  /// 广告宽度
  final double? width;
  
  /// 广告高度（0表示自适应）
  final double? height;

  const FeedAdWidget({
    super.key,
    this.width,
    this.height,
  });

  @override
  State<FeedAdWidget> createState() => _FeedAdWidgetState();
}

class _FeedAdWidgetState extends State<FeedAdWidget> {
  bool _adFailed = false;
  bool _sdkReady = false;

  @override
  void initState() {
    super.initState();
    _checkSdkAndLoad();
  }

  Future<void> _checkSdkAndLoad() async {
    // 确保SDK已初始化
    if (!AdManager.instance.isInitialized) {
      final success = await AdManager.instance.init();
      if (!success) {
        if (mounted) {
          setState(() {
            _adFailed = true;
          });
        }
        return;
      }
    }
    if (mounted) {
      setState(() {
        _sdkReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果加载失败或SDK未就绪，返回空容器
    if (_adFailed || !_sdkReady) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final adWidth = widget.width ?? screenWidth - 24; // 减去左右边距
    final adHeight = widget.height ?? AdConfig.feedAdExpressHeight;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.hardEdge,
      child: FlutterUnionad.nativeAdView(
        // Android广告位ID
        androidCodeId: AdConfig.feedAdId,
        // iOS广告位ID
        iosCodeId: AdConfig.feedAdId,
        // 是否支持DeepLink
        supportDeepLink: true,
        // 广告尺寸
        expressViewWidth: adWidth,
        expressViewHeight: adHeight,
        // 广告回调
        callBack: FlutterUnionadNativeCallBack(
          onShow: () {
            debugPrint('信息流广告展示成功');
          },
          onClick: () {
            debugPrint('信息流广告被点击');
          },
          onDislike: (dynamic message) {
            debugPrint('用户不喜欢广告: $message');
            setState(() {
              _adFailed = true;
            });
          },
          onFail: (dynamic error) {
            debugPrint('信息流广告加载失败: $error');
            setState(() {
              _adFailed = true;
            });
          },
        ),
      ),
    );
  }
}
