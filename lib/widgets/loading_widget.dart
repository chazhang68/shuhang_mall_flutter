import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 加载中组件 - 对应 components/Loading/index.vue
class LoadingWidget extends StatelessWidget {
  final bool loading;
  final bool loaded;
  final String? loadingText;
  final String? loadMoreText;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.loading = false,
    this.loaded = false,
    this.loadingText,
    this.loadMoreText,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (loaded || !loading) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 40,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loading) ...[
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color ?? Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              loadingText ?? '正在加载中'.tr,
              style: TextStyle(fontSize: 13, color: color ?? Colors.black87),
            ),
          ] else ...[
            Text(
              loadMoreText ?? '上拉加载更多'.tr,
              style: TextStyle(fontSize: 13, color: color ?? Colors.black87),
            ),
          ],
        ],
      ),
    );
  }
}

/// 页面级加载组件
class PageLoadingWidget extends StatelessWidget {
  final String? message;

  const PageLoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ],
      ),
    );
  }
}

/// 加载对话框
class LoadingDialog {
  static void show({String? message}) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(message, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                ],
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hide() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
}

/// 底部加载更多组件
class LoadMoreWidget extends StatelessWidget {
  final bool hasMore;
  final bool loading;
  final VoidCallback? onLoadMore;

  const LoadMoreWidget({super.key, this.hasMore = true, this.loading = false, this.onLoadMore});

  @override
  Widget build(BuildContext context) {
    if (!hasMore) {
      return Container(
        height: 50,
        alignment: Alignment.center,
        child: Text('没有更多了'.tr, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      );
    }

    if (loading) {
      return Container(
        height: 50,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(width: 8),
            Text('加载中...'.tr, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onLoadMore,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        child: Text('上拉加载更多'.tr, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ),
    );
  }
}
