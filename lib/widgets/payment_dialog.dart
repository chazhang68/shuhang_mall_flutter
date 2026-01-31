import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';

/// 支付方式弹窗组件 - 对应 components/payment/index.vue
class PaymentDialog extends StatefulWidget {
  final List<PaymentMethod> paymentMethods;
  final double totalPrice;
  final String orderId;
  final bool isCall;
  final Function(String payType)? onPay;
  final VoidCallback? onClose;
  final VoidCallback? onPayComplete;
  final VoidCallback? onPayFail;

  const PaymentDialog({
    super.key,
    required this.paymentMethods,
    required this.totalPrice,
    required this.orderId,
    this.isCall = false,
    this.onPay,
    this.onClose,
    this.onPayComplete,
    this.onPayFail,
  });

  /// 显示支付弹窗
  static Future<void> show({
    required List<PaymentMethod> paymentMethods,
    required double totalPrice,
    required String orderId,
    bool isCall = false,
    Function(String payType)? onPay,
    VoidCallback? onPayComplete,
    VoidCallback? onPayFail,
  }) async {
    await Get.bottomSheet(
      PaymentDialog(
        paymentMethods: paymentMethods,
        totalPrice: totalPrice,
        orderId: orderId,
        isCall: isCall,
        onPay: onPay,
        onClose: () => Get.back(),
        onPayComplete: onPayComplete,
        onPayFail: onPayFail,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  int _selectedIndex = 0;
  bool _isPaying = false;

  @override
  void initState() {
    super.initState();
    // 找到第一个可用的支付方式
    for (int i = 0; i < widget.paymentMethods.length; i++) {
      if (widget.paymentMethods[i].enabled) {
        _selectedIndex = i;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            _buildTitle(),
            // 支付方式列表
            ...widget.paymentMethods.asMap().entries.map((entry) {
              return _buildPaymentItem(entry.key, entry.value);
            }),
            // 支付金额
            _buildPayAmount(),
            // 支付按钮
            _buildPayButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '选择付款方式'.tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF282828),
            ),
          ),
          Positioned(
            right: 0,
            child: GestureDetector(
              onTap: widget.onClose,
              child: const Icon(
                Icons.close,
                size: 22,
                color: Color(0xFF8A8A8A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(int index, PaymentMethod method) {
    if (!method.enabled) {
      return const SizedBox.shrink();
    }

    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        height: 65,
        margin: const EdgeInsets.only(left: 15),
        padding: const EdgeInsets.only(right: 15),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFEEEEEE)),
          ),
        ),
        child: Row(
          children: [
            // 图标
            Icon(
              method.icon,
              size: 24,
              color: method.iconColor,
            ),
            const SizedBox(width: 12),
            // 文字
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    method.name,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF282828),
                    ),
                  ),
                  if (method.description != null) ...[
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        text: method.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                        children: [
                          if (method.type == 'yue' && method.balance != null)
                            TextSpan(
                              text: ' ￥${method.balance!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFFFF9900),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // 选中状态
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 22,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : const Color(0xFFCCCCCC),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayAmount() {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '支付'.tr,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '￥',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Text(
            widget.totalPrice.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return GestureDetector(
      onTap: _isPaying ? null : _handlePay,
      child: Container(
        width: double.infinity,
        height: 45,
        margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(23),
        ),
        alignment: Alignment.center,
        child: _isPaying
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                '去付款'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _handlePay() async {
    if (_selectedIndex < 0 ||
        _selectedIndex >= widget.paymentMethods.length) {
      return;
    }

    final method = widget.paymentMethods[_selectedIndex];

    // 余额支付检查
    if (method.type == 'yue') {
      if (method.balance == null || method.balance! < widget.totalPrice) {
        FlutterToastPro.showMessage( '余额不足'.tr);
        return;
      }
    }

    if (widget.isCall) {
      widget.onPay?.call(method.type);
      return;
    }

    setState(() {
      _isPaying = true;
    });

    try {
      widget.onPay?.call(method.type);
    } finally {
      if (mounted) {
        setState(() {
          _isPaying = false;
        });
      }
    }
  }
}

/// 支付方式模型
class PaymentMethod {
  final String type;
  final String name;
  final String? description;
  final IconData icon;
  final Color iconColor;
  final bool enabled;
  final double? balance;

  const PaymentMethod({
    required this.type,
    required this.name,
    this.description,
    required this.icon,
    required this.iconColor,
    this.enabled = true,
    this.balance,
  });

  /// 微信支付
  static PaymentMethod weixin({bool enabled = true}) {
    return PaymentMethod(
      type: 'weixin',
      name: '微信支付',
      description: '推荐使用微信支付',
      icon: Icons.wechat,
      iconColor: const Color(0xFF09BB07),
      enabled: enabled,
    );
  }

  /// 支付宝支付
  static PaymentMethod alipay({bool enabled = true}) {
    return PaymentMethod(
      type: 'alipay',
      name: '支付宝支付',
      description: '推荐使用支付宝支付',
      icon: Icons.account_balance_wallet,
      iconColor: const Color(0xFF00AAEA),
      enabled: enabled,
    );
  }

  /// 余额支付
  static PaymentMethod yue({
    required double userBalance,
    bool enabled = true,
  }) {
    return PaymentMethod(
      type: 'yue',
      name: '余额支付',
      description: '可用余额',
      icon: Icons.account_balance_wallet_outlined,
      iconColor: const Color(0xFFFF9900),
      enabled: enabled,
      balance: userBalance,
    );
  }

  /// 线下支付
  static PaymentMethod offline({bool enabled = true}) {
    return PaymentMethod(
      type: 'offline',
      name: '线下支付',
      description: '与商家当面支付',
      icon: Icons.storefront,
      iconColor: const Color(0xFFEB6623),
      enabled: enabled,
    );
  }

  /// 好友代付
  static PaymentMethod friend({bool enabled = true}) {
    return PaymentMethod(
      type: 'friend',
      name: '好友代付',
      description: '邀请好友帮忙付款',
      icon: Icons.people,
      iconColor: const Color(0xFFF34C3E),
      enabled: enabled,
    );
  }
}

/// 支付结果弹窗
class PayResultDialog extends StatelessWidget {
  final bool success;
  final String? message;
  final VoidCallback? onConfirm;
  final VoidCallback? onViewOrder;

  const PayResultDialog({
    super.key,
    required this.success,
    this.message,
    this.onConfirm,
    this.onViewOrder,
  });

  static Future<void> show({
    required bool success,
    String? message,
    VoidCallback? onConfirm,
    VoidCallback? onViewOrder,
  }) async {
    await Get.dialog(
      PayResultDialog(
        success: success,
        message: message,
        onConfirm: onConfirm,
        onViewOrder: onViewOrder,
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标
            Icon(
              success ? Icons.check_circle : Icons.error,
              size: 60,
              color: success ? const Color(0xFF09BB07) : const Color(0xFFE93323),
            ),
            const SizedBox(height: 16),
            // 标题
            Text(
              success ? '支付成功'.tr : '支付失败'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ],
            const SizedBox(height: 24),
            // 按钮
            Row(
              children: [
                if (success && onViewOrder != null) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        onViewOrder?.call();
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '查看订单'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      onConfirm?.call();
                    },
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '确定'.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


