import 'package:flutter/material.dart';
import 'package:shuhang_mall_flutter/app/services/customer_service.dart';

/// 客服浮动按钮组件
/// 对应原 components/kefuIcon/index.vue
class CustomerFloatButton extends StatefulWidget {
  /// 商品ID（可选）
  final int? productId;

  /// 初始位置（距离顶部的距离）
  final double? initialTop;

  /// 是否显示
  final bool visible;

  const CustomerFloatButton({Key? key, this.productId, this.initialTop, this.visible = true})
    : super(key: key);

  @override
  State<CustomerFloatButton> createState() => _CustomerFloatButtonState();
}

class _CustomerFloatButtonState extends State<CustomerFloatButton> {
  late double _top;
  final double _right = 15.0;
  final CustomerService _customerService = CustomerService();

  @override
  void initState() {
    super.initState();
    // 设置初始位置
    _top = widget.initialTop ?? 480.0;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return const SizedBox.shrink();
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      top: _top,
      right: _right,
      child: GestureDetector(
        onTap: _handleTap,
        onPanUpdate: (details) {
          setState(() {
            // 更新位置，限制在安全区域内
            double newTop = _top + details.delta.dy;

            // 限制最小和最大位置
            final minTop = statusBarHeight + 66.0;
            final maxTop = screenHeight - bottomPadding - 96.0;

            if (newTop < minTop) {
              newTop = minTop;
            } else if (newTop > maxTop) {
              newTop = maxTop;
            }

            _top = newTop;
          });
        },
        child: Container(
          width: 48.0,
          height: 48.0,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            shape: .circle,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6.0)],
          ),
          child: const Icon(Icons.headset_mic_outlined, size: 24.0, color: Colors.black),
        ),
      ),
    );
  }

  /// 处理点击事件
  void _handleTap() {
    if (widget.productId != null) {
      _customerService.openCustomerWithProduct(widget.productId!);
    } else {
      _customerService.openCustomer();
    }
  }
}
