import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/order_provider.dart';
import '../../data/providers/public_provider.dart';
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
  final PublicProvider _publicProvider = PublicProvider();

  String _orderId = '';

  // 支付金额
  double _payPrice = 0;
  double _payPriceShow = 0;
  double _payPostage = 0;
  bool _offlinePostage = false;
  int _invalidTime = 0;
  double _nowMoney = 0;

  // 支付方式
  List<PayMethod> _payMethods = [];
  int _selectedIndex = 0;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _orderId = Get.arguments?['order_id']?.toString() ?? '';
    if (_orderId.isEmpty) {
      Get.snackbar('提示', '请选择要支付的订单');
      return;
    }

    _initPayMethods();
    _loadBasicConfig();
  }

  void _initPayMethods() {
    _payMethods = [
      PayMethod(
        name: '微信支付',
        icon: Icons.wechat,
        iconColor: const Color(0xFF09BB07),
        value: 'weixin',
        title: '使用微信快捷支付',
        enabled: true,
      ),
      PayMethod(
        name: '支付宝支付',
        icon: Icons.account_balance_wallet,
        iconColor: const Color(0xFF00AAEA),
        value: 'alipay',
        title: '使用支付宝支付',
        enabled: true,
      ),
      PayMethod(
        name: 'SWP支付',
        icon: Icons.account_balance,
        iconColor: const Color(0xFFFF9900),
        value: 'yue',
        title: '可用余额',
        enabled: true,
        balance: 0,
      ),
      PayMethod(
        name: '线下支付',
        icon: Icons.store,
        iconColor: const Color(0xFFEB6623),
        value: 'offline',
        title: '使用线下付款',
        enabled: false,
      ),
      PayMethod(
        name: '好友代付',
        icon: Icons.group,
        iconColor: const Color(0xFFF34C3E),
        value: 'friend',
        title: '找微信好友支付',
        enabled: true,
      ),
    ];
  }

  Future<void> _loadBasicConfig() async {
    try {
      final response = await _publicProvider.getShopConfig();
      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        setState(() {
          // 微信支付
          _payMethods[0].enabled = (data['pay_weixin_open'] ?? 0) == 1;
          // 支付宝
          _payMethods[1].enabled = (data['ali_pay_status'] ?? 0) == 1;
          // 余额支付
          _payMethods[2].enabled = (data['yue_pay_status'] ?? 0) == 1;
          // 线下支付
          _payMethods[3].enabled = (data['offline_pay_status'] ?? 0) == 1;
          // 好友代付
          _payMethods[4].enabled = (data['friend_pay_status'] ?? 0) == 1;
        });

        await _loadCashierOrder();
      }
    } catch (e) {
      Get.snackbar('提示', '加载配置失败');
    }
  }

  Future<void> _loadCashierOrder() async {
    try {
      // 这里假设有getCashierOrder方法，实际可能需要用其他方法
      // final response = await _orderProvider.getCashierOrder(_orderId, _fromType);
      final response = await _orderProvider.getOrderDetail(_orderId);

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        setState(() {
          _payPrice = double.tryParse(data['pay_price']?.toString() ?? '0') ?? 0;
          _payPriceShow = _payPrice;
          _payPostage = double.tryParse(data['pay_postage']?.toString() ?? '0') ?? 0;
          _offlinePostage = data['offline_postage'] == true;
          _invalidTime = data['invalid_time'] ?? 0;
          _nowMoney = double.tryParse(data['now_money']?.toString() ?? '0') ?? 0;

          // 更新余额显示
          _payMethods[2].balance = _nowMoney;

          _isLoading = false;

          // 选择第一个可用的支付方式
          for (int i = 0; i < _payMethods.length; i++) {
            if (_payMethods[i].enabled) {
              _selectedIndex = i;
              break;
            }
          }
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        Get.snackbar('提示', response.msg);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar('提示', '获取订单信息失败');
    }
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

    // 余额支付检查
    if (method.value == 'yue' && _nowMoney < _payPriceShow) {
      Get.snackbar('提示', '余额不足');
      return;
    }

    // 好友代付
    if (method.value == 'friend') {
      Get.toNamed('/payment-on-behalf', arguments: {'order_id': _orderId});
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
            Get.snackbar('提示', '支付成功');
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
            Get.snackbar('提示', response.msg);
            break;
          default:
            Get.snackbar('提示', response.msg);
        }
      } else {
        Get.snackbar('提示', response.msg);
      }
    } catch (e) {
      Get.back();
      Get.snackbar('提示', '支付失败');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 头部金额
                _buildHeader(),
                // 支付方式列表
                _buildPayMethods(),
                const Spacer(),
                // 底部按钮
                _buildFooter(),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 50, bottom: 40),
      child: Column(
        children: [
          // 金额
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'SWP',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFE93323),
                ),
              ),
              Text(
                _payPriceShow.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE93323),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 倒计时
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Text(
              '支付剩余时间：${_formatCountdown(_invalidTime)}',
              style: const TextStyle(fontSize: 12, color: Color(0xFFE93323)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayMethods() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(15),
            child: Text('支付方式', style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
          ),
          ...List.generate(_payMethods.length, (index) {
            final method = _payMethods[index];
            if (!method.enabled) return const SizedBox.shrink();

            return _buildPayMethodItem(method, index);
          }),
        ],
      ),
    );
  }

  Widget _buildPayMethodItem(PayMethod method, int index) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onPayMethodSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: Row(
          children: [
            // 图标
            Icon(method.icon, size: 25, color: method.iconColor),
            const SizedBox(width: 14),
            // 文字
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.name, style: const TextStyle(fontSize: 15, color: Color(0xFF333333))),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        method.title,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
                      ),
                      if (method.value == 'yue') ...[
                        const SizedBox(width: 4),
                        Text(
                          'SWP${method.balance?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFFFF9900)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // 选中图标
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 20,
              color: isSelected ? const Color(0xFFE93323) : const Color(0xFFCCCCCC),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
        top: 15,
        bottom: 15 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        children: [
          // 确认支付按钮
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: _confirmPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE93323),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
              ),
              child: const Text('确认支付', style: TextStyle(fontSize: 15, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
          // 暂不支付
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
