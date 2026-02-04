import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import '../../controllers/app_controller.dart';
import '../../data/providers/order_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../routes/app_routes.dart';

/// 收银台页面
/// 对应原 pages/goods/cashier/index.vue
class CashierPage extends StatefulWidget {
  const CashierPage({super.key});

  @override
  State<CashierPage> createState() => _CashierPageState();
}

class _CashierPageState extends State<CashierPage> {
  final OrderProvider _orderProvider = OrderProvider();
  final UserProvider _userProvider = UserProvider();

  String _orderId = '';

  // 支付金额
  double _payPrice = 0;
  double _payPriceShow = 0;
  double _payPostage = 0;
  bool _offlinePostage = false;
  int _invalidTime = 0;
  double _nowMoney = 0;
  int _countdownSeconds = 0;
  Timer? _countdownTimer;

  // 支付方式
  List<PayMethod> _payMethods = [];
  int _selectedIndex = 0;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _orderId = Get.arguments?['order_id']?.toString() ?? '';
    if (_orderId.isEmpty) {
      _orderId = Get.arguments?['orderId']?.toString() ?? '';
    }
    if (_orderId.isEmpty) {
      _orderId = Get.parameters['order_id'] ?? '';
    }
    if (_orderId.isEmpty) {
      _orderId = Get.parameters['orderId'] ?? '';
    }
    if (_orderId.isEmpty) {
      FlutterToastPro.showMessage('请选择要支付的订单');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    _initPayMethods();
    _loadCashierOrder();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _initPayMethods() {
    _payMethods = [
      PayMethod(
        name: '消费券支付',
        icon: Icons.card_giftcard,
        iconColor: const Color(0xFFFF9900),
        value: 'xfq',
        title: '可用余额',
        enabled: true,
        balance: 0,
      ),
    ];
  }

  Future<void> _loadCashierOrder() async {
    try {
      final response = await _orderProvider.getOrderPayInfo(_orderId);

      if (response.isSuccess && response.data != null) {
        final data = response.data ?? <String, dynamic>{};

        setState(() {
          _payPrice = _readDouble(data['pay_price']);
          _payPriceShow = _payPrice;
          _payPostage = _readDouble(data['pay_postage']);
          _offlinePostage = _readBool(data['offline_postage']);
          _invalidTime = _readInt(data['invalid_time']);
          if (_invalidTime <= 0) {
            _invalidTime = _readInt(data['stop_time']);
          }
          _nowMoney = _readDouble(data['now_money']);

          // 更新消费券余额显示
          _payMethods[0].balance = _readDouble(data['integral']);
          _payMethods[0].enabled = true;

          _isLoading = false;
          _selectedIndex = 0;
        });
        _syncCountdown();
        _loadVoucherBalanceIfNeeded();
      } else {
        setState(() {
          _isLoading = false;
        });
        FlutterToastPro.showMessage(response.msg);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      FlutterToastPro.showMessage('获取订单信息失败');
    }
  }

  Future<void> _loadVoucherBalanceIfNeeded() async {
    if (_payMethods.isEmpty) return;
    final currentBalance = _payMethods[0].balance ?? 0;
    if (currentBalance > 0) return;

    final cachedIntegral = AppController.to.userInfo?.integral ?? 0;
    if (cachedIntegral > 0) {
      if (!mounted) return;
      setState(() {
        _payMethods[0].balance = cachedIntegral;
      });
      return;
    }

    try {
      final response = await _userProvider.getUserInfo();
      if (!mounted) return;
      if (response.isSuccess && response.data != null) {
        setState(() {
          _payMethods[0].balance = response.data?.integral ?? 0;
        });
      }
    } catch (_) {
      // Ignore balance fetch failures.
    }
  }

  double _readDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == '1' || lower == 'true';
    }
    return false;
  }

  void _syncCountdown() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final raw = _invalidTime;
    final remaining = raw > 1000000000 ? raw - now : raw;
    setState(() {
      _countdownSeconds = remaining > 0 ? remaining : 0;
    });
    _countdownTimer?.cancel();
    if (_countdownSeconds <= 0) return;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdownSeconds <= 0) {
        timer.cancel();
        return;
      }
      setState(() {
        _countdownSeconds -= 1;
      });
    });
  }

  void _onPayMethodSelected(int index) {
    if (!_payMethods[index].enabled) return;

    setState(() {
      _selectedIndex = index;

      // 线下支付时减去运费
      if (_offlinePostage) {
        if (_payMethods[index].value == 'offline') {
          _payPriceShow = _payPrice - _payPostage;
        } else {
          _payPriceShow = _payPrice;
        }
      }
    });
  }

  Future<void> _confirmPay() async {
    final method = _payMethods[_selectedIndex];

    // 消费券支付检查
    if (method.value == 'xfq' && (method.balance ?? 0) < _payPriceShow) {
      FlutterToastPro.showMessage('消费券不足');
      return;
    }

    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      final response = await _orderProvider.payOrder({
        'uni': _orderId,
        'paytype': method.value,
        'type': 0,
      });

      Get.back(); // 关闭loading

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>? ?? {};
        final status = data['status']?.toString() ?? '';

        switch (status) {
          case 'SUCCESS':
            FlutterToastPro.showMessage('支付成功');
            Get.offNamed(
              AppRoutes.orderPayStatus,
              arguments: {
                'order_id': _orderId,
                'msg': response.msg,
                'type': '3',
                'totalPrice': _payPriceShow.toString(),
              },
            );
            break;
          case 'PAY_DEFICIENCY':
            FlutterToastPro.showMessage(response.msg);
            break;
          default:
            FlutterToastPro.showMessage(response.msg);
        }
      } else {
        FlutterToastPro.showMessage(response.msg);
      }
    } catch (e) {
      Get.back();
      FlutterToastPro.showMessage('支付失败');
    }
  }

  void _waitPay() {
    Get.offNamed(
      AppRoutes.orderPayStatus,
      arguments: {
        'order_id': _orderId,
        'msg': '取消支付',
        'type': '3',
        'status': '2',
        'totalPrice': _payPriceShow.toString(),
      },
    );
  }

  String _formatCountdown(int seconds) {
    if (seconds <= 0) return '00:00:00';
    final hours = (seconds / 3600).floor();
    final minutes = ((seconds % 3600) / 60).floor();
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  List<PayMethod> _visiblePayMethods() {
    return _payMethods;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('收银台', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 18),
                _buildPayMethods(),
                const Spacer(),
                _buildFooter(),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 18, bottom: 22),
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE93323),
              ),
              children: [
                TextSpan(text: '消费券', style: TextStyle(fontSize: 16)),
                TextSpan(
                  text: _payPriceShow.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),
          ),
          // Text(
          //   '消费券${_payPriceShow.toStringAsFixed(2)}',
          //   style: const TextStyle(
          //     fontSize: 22,
          //     fontWeight: FontWeight.bold,
          //     color: Color(0xFFE93323),
          //   ),
          // ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '支付剩余时间：${_formatCountdown(_countdownSeconds)}',
              style: const TextStyle(fontSize: 12, color: Color(0xFFE93323)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayMethods() {
    final methods = _visiblePayMethods();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 6),
            child: Text('支付方式', style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
          ),
          ...methods.asMap().entries.map((entry) {
            final method = entry.value;
            final index = _payMethods.indexOf(method);
            final isLast = entry.key == methods.length - 1;
            return Column(
              children: [
                _buildPayMethodItem(method, index),
                if (!isLast)
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPayMethodItem(PayMethod method, int index) {
    final isSelected = _selectedIndex == index;
    final isVoucher = method.value == 'xfq';
    final title = isVoucher ? '消费券支付' : method.name;
    final balanceText = (method.balance ?? 0).toStringAsFixed(2);
    final subtitle = isVoucher
        ? '可用余额 消费券$balanceText'
        : method.value == 'yue'
        ? '可用余额 SWP$balanceText'
        : method.title;

    return GestureDetector(
      onTap: () => _onPayMethodSelected(index),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildPayMethodIcon(method),
            const SizedBox(width: 10),
            // 文字
            Expanded(
              child: Column(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF333333))),

                  _buildPayMethodSubtitle(method, subtitle, balanceText),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 18,
              color: isSelected ? const Color(0xFFE93323) : const Color(0xFFCCCCCC),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayMethodIcon(PayMethod method) {
    if (method.value == 'yue' || method.value == 'xfq') {
      return Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(color: Color(0xFFFF9900), shape: BoxShape.circle),
        alignment: Alignment.center,
        child: const Text(
          '¥',
          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
        ),
      );
    }
    return Icon(method.icon, size: 26, color: method.iconColor);
  }

  Widget _buildPayMethodSubtitle(PayMethod method, String subtitle, String balanceText) {
    if (method.value != 'yue' && method.value != 'xfq') {
      return Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF999999)));
    }

    final prefix = method.value == 'yue' ? ' SWP' : '消费券';
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '可用余额',
            style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
          ),
          TextSpan(
            text: "$prefix$balanceText",
            style: const TextStyle(fontSize: 11, color: Color(0xFFFF9900)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: 24 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _confirmPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE93323),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              child: const Text('确认支付'),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _waitPay,
            child: const Text('暂不支付', style: TextStyle(fontSize: 12, color: Color(0xFFAAAAAA))),
          ),
        ],
      ),
    );
  }
}

// 支付方式模型
class PayMethod {
  final String name;
  final IconData icon;
  final Color iconColor;
  final String value;
  final String title;
  bool enabled;
  double? balance;

  PayMethod({
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.title,
    this.enabled = true,
    this.balance,
  });
}
