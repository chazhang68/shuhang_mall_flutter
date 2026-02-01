import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';

/// OTC 支付页面 - 适用于 OTC 交易支付流程。
class OtcPayPage extends StatefulWidget {
  const OtcPayPage({super.key});

  @override
  State<OtcPayPage> createState() => _OtcPayPageState();
}

class _OtcPayPageState extends State<OtcPayPage> {
  final UserProvider _userProvider = UserProvider();
  Map<String, dynamic>? _order;
  bool _loading = true;

  int get _orderId {
    final args = Get.arguments;
    if (args is Map && args['id'] != null) {
      return int.tryParse('${args['id']}') ?? 0;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _loading = true;
    });

    try {
      final response = await _userProvider.otcOrderInfo(_orderId);
      if (response.isSuccess && response.data is Map) {
        setState(() {
          _order = Map<String, dynamic>.from(response.data as Map);
        });
      }
    } catch (e) {
      debugPrint('获取 OTC 订单失败: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _pay() async {
    if (_orderId == 0) return;
    final response = await _userProvider.payOtc(_orderId);
    if (!mounted) return;
    if (response.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('支付成功')));
      Get.back();
    } else {
      final message = response.msg.isEmpty ? '支付失败' : response.msg;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTC 支付')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
          ? const Center(child: Text('暂无订单数据'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OtcInfoRow(label: '订单号', value: '${_order!['id'] ?? '-'}'),
                  _OtcInfoRow(label: '金额', value: '${_order!['dprice'] ?? '-'}'),
                  _OtcInfoRow(label: '数量', value: '${_order!['number'] ?? '-'}'),
                  _OtcInfoRow(
                    label: '类型',
                    value: _order!['type']?.toString() == '1' ? '消费券' : '福豆',
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(onPressed: _pay, child: const Text('确认支付')),
                  ),
                ],
              ),
            ),
    );
  }
}

class _OtcInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _OtcInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
