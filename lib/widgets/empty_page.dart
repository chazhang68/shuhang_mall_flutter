import 'package:flutter/material.dart';

/// 空页面组件 - 对应 components/emptyPage.vue
class EmptyPage extends StatelessWidget {
  final String? title;
  final String? text; // 兼容旧的 text 参数
  final String? subTitle;
  final String? buttonText;
  final VoidCallback? onPressed;
  final Widget? child;
  final EdgeInsetsGeometry? padding;

  const EmptyPage({
    super.key,
    this.title,
    this.text,
    this.subTitle,
    this.buttonText,
    this.onPressed,
    this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(30),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 空页面图标
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 60,
              color: Color(0xFFCCCCCC),
            ),
          ),
          const SizedBox(height: 20),
          // 标题（优先使用 title，其次使用 text）
          Text(
            title ?? text ?? '暂无数据',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          if (subTitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subTitle!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            ),
          ],
          const SizedBox(height: 30),
          if (buttonText != null && onPressed != null) ...[
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(buttonText!),
            ),
          ],
          if (child != null) ...[
            const SizedBox(height: 20),
            child!,
          ],
        ],
      ),
    );
  }
}

/// 搜索结果为空组件
class EmptySearch extends StatelessWidget {
  final String? keyword;
  final VoidCallback? onClearKeyword;

  const EmptySearch({
    super.key,
    this.keyword,
    this.onClearKeyword,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 搜索图标
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.search_off_outlined,
              size: 60,
              color: Color(0xFFCCCCCC),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '没有找到"$keyword"相关商品',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '换个关键词试试吧',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: onClearKeyword,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('清空搜索'),
          ),
        ],
      ),
    );
  }
}

/// 订单为空组件
class EmptyOrder extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final VoidCallback? onPressed;

  const EmptyOrder({
    super.key,
    this.title,
    this.subTitle,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 订单图标
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 60,
              color: Color(0xFFCCCCCC),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title ?? '暂无订单',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          if (subTitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subTitle!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            ),
          ],
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('去逛逛'),
          ),
        ],
      ),
    );
  }
}

/// 优惠券为空组件
class EmptyCoupon extends StatelessWidget {
  final String? title;
  final String? subTitle;

  const EmptyCoupon({
    super.key,
    this.title,
    this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 优惠券图标
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.card_giftcard_outlined,
              size: 60,
              color: Color(0xFFCCCCCC),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title ?? '暂无优惠券',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          if (subTitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subTitle!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            ),
          ],
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // 跳转到首页或其他页面
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('去领取'),
          ),
        ],
      ),
    );
  }
}

/// 地址为空组件
class EmptyAddress extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final VoidCallback? onPressed;

  const EmptyAddress({
    super.key,
    this.title,
    this.subTitle,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 地址图标
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              size: 60,
              color: Color(0xFFCCCCCC),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title ?? '暂无收货地址',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          if (subTitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subTitle!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            ),
          ],
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('添加地址'),
          ),
        ],
      ),
    );
  }
}