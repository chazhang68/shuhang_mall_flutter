import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:shuhang_mall_flutter/app/theme/theme_colors.dart';
import 'package:shuhang_mall_flutter/app/core/constants/app_images.dart';

/// APP版本更新弹窗
/// 对应原 components/update/app-update.vue
class AppUpdateDialog extends StatefulWidget {
  final String version;
  final String info;
  final String url;
  final bool isForce;
  final String logoUrl;

  const AppUpdateDialog({
    super.key,
    required this.version,
    required this.info,
    required this.url,
    this.isForce = false,
    this.logoUrl = '',
  });

  @override
  State<AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<AppUpdateDialog> {
  bool _isDownloading = false;
  double _progress = 0.0;
  CancelToken? _cancelToken;

  Color get _primaryColor => ThemeColors.red.primary;

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isForce && !_isDownloading,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 主体卡片 - update_bg.png 作为整个弹窗背景
              Container(
                width: 290.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.r),
                  image: const DecorationImage(
                    image: AssetImage(AppImages.updateBg),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 顶部 App Logo
                    Padding(
                      padding: EdgeInsets.only(top: 40.h),
                      child: ClipOval(
                        child: widget.logoUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: widget.logoUrl,
                                width: 80.w,
                                height: 80.w,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Container(color: Colors.grey[200], width: 80.w, height: 80.w),
                                errorWidget: (context, url, error) =>
                                    Image.asset(AppImages.logo, width: 80.w, height: 80.w, fit: BoxFit.cover),
                              )
                            : Image.asset(AppImages.logo, width: 80.w, height: 80.w, fit: BoxFit.cover),
                      ),
                    ),
                    // 内容区域
                    Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 25.h, 24.w, 30.h),
                      child: Column(
                        children: [
                          Text(
                            '发现新版本 ${widget.version}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          // 升级描述
                          ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: 150.h),
                            child: SingleChildScrollView(
                              child: Text(
                                widget.info.isNotEmpty ? widget.info : '修复已知问题，优化用户体验',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13.sp, color: const Color(0xFF666666), height: 1.5),
                              ),
                            ),
                          ),
                          SizedBox(height: 25.h),
                          // 下载进度条
                          if (_isDownloading) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: LinearProgressIndicator(
                                value: _progress,
                                minHeight: 8.h,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              '下载中 ${(_progress * 100).toStringAsFixed(0)}%',
                              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF666666)),
                            ),
                          ] else ...[
                            // 立即升级按钮
                            SizedBox(
                              width: double.infinity,
                              height: 42.h,
                              child: ElevatedButton(
                                onPressed: _handleUpdate,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                ),
                                child: Text(
                                  '立即升级',
                                  style: TextStyle(fontSize: 15.sp, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 关闭按钮（非强制更新且未下载时显示）
              if (!widget.isForce && !_isDownloading) ...[
                SizedBox(height: 15.h),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 35.w,
                    height: 35.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 20.w),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 处理更新
  Future<void> _handleUpdate() async {
    if (widget.url.isEmpty) return;

    // iOS 跳转 App Store
    if (Platform.isIOS) {
      final uri = Uri.parse(widget.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    // Android 内部下载 APK
    setState(() {
      _isDownloading = true;
      _progress = 0.0;
    });

    try {
      final dir = await getTemporaryDirectory();
      final savePath = '${dir.path}/app_update_${widget.version}.apk';
      _cancelToken = CancelToken();

      await Dio().download(
        widget.url,
        savePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            setState(() {
              _progress = received / total;
            });
          }
        },
      );

      // 下载完成，打开安装
      await OpenFilex.open(savePath);

      if (mounted && !widget.isForce) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) return;
      debugPrint('下载更新失败: $e');
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _progress = 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('下载失败，请重试')),
        );
      }
    }
  }
}
