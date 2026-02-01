import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';

/// OTC 发布页面 - 适用于发布互换/挂单。
class OtcSendPage extends StatefulWidget {
  const OtcSendPage({super.key});

  @override
  State<OtcSendPage> createState() => _OtcSendPageState();
}

class _OtcSendPageState extends State<OtcSendPage> {
  final UserProvider _userProvider = UserProvider();

  final TextEditingController _xfqPriceController = TextEditingController();
  final TextEditingController _xfqNumController = TextEditingController(text: '1');
  final TextEditingController _fdPriceController = TextEditingController();
  final TextEditingController _fdNumController = TextEditingController(text: '1');

  int _type = 1;
  double? _fdMaxPrice;
  double? _xfqMaxPrice;
  int _otcPayType = 0;
  final Set<int> _payTypes = {};
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadOtcInfo();
  }

  @override
  void dispose() {
    _xfqPriceController.dispose();
    _xfqNumController.dispose();
    _fdPriceController.dispose();
    _fdNumController.dispose();
    super.dispose();
  }

  Future<void> _loadOtcInfo() async {
    try {
      final response = await _userProvider.getOtcInfo();
      if (response.isSuccess && response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);
        final xfqZdj = double.tryParse('${data['xfq_zdj'] ?? ''}');
        final fdZdj = double.tryParse('${data['fd_zdj'] ?? ''}');
        _xfqMaxPrice = xfqZdj;
        _fdMaxPrice = fdZdj;
        _xfqPriceController.text = xfqZdj?.toString() ?? '';
        _fdPriceController.text = fdZdj?.toString() ?? '';
        _otcPayType = int.tryParse('${data['pay_type'] ?? 0}') ?? 0;
      }
    } catch (e) {
      debugPrint('获取 OTC 配置失败: $e');
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;

    if (_otcPayType >= 2) {
      _showMessage('请完善付款方式');
      return;
    }

    final xfqNum = int.tryParse(_xfqNumController.text.trim()) ?? 0;
    final fdNum = int.tryParse(_fdNumController.text.trim()) ?? 0;
    final xfqPrice = double.tryParse(_xfqPriceController.text.trim());
    final fdPrice = double.tryParse(_fdPriceController.text.trim());

    if (_type == 1 && _payTypes.isEmpty) {
      _showMessage('请选择支付方式');
      return;
    }

    if (_type == 1 && xfqPrice != null && _xfqMaxPrice != null && xfqPrice > _xfqMaxPrice!) {
      _showMessage('今日发布最高单位（消费券）${_xfqMaxPrice!}');
      return;
    }

    if (_type == 2) {
      if (fdPrice == null || fdPrice <= 0) {
        _showMessage('请填写福豆购买单价');
        return;
      }
      if (_fdMaxPrice != null && fdPrice > _fdMaxPrice!) {
        _showMessage('今日发布最高单位（消费券）${_fdMaxPrice!}');
        return;
      }
    }

    if (_type == 1 && xfqNum <= 0) {
      _showMessage('请输入有效数量');
      return;
    }
    if (_type == 2 && fdNum <= 0) {
      _showMessage('请输入有效数量');
      return;
    }

    final data = <String, dynamic>{
      'type': _type,
      'xfq_price': _xfqPriceController.text.trim(),
      'xfq_num': _xfqNumController.text.trim(),
      'fd_price': _fdPriceController.text.trim(),
      'fd_num': _fdNumController.text.trim(),
      'pay_type': _payTypes.toList(),
    };

    setState(() {
      _submitting = true;
    });

    try {
      final response = await _userProvider.sendOtc(data);
      if (response.isSuccess) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('发布成功')));
        Get.back();
      } else if (mounted) {
        final message = response.msg.isEmpty ? '发布失败' : response.msg;
        _showMessage(message);
      }
    } catch (e) {
      debugPrint('发布 OTC 失败: $e');
      if (mounted) {
        _showMessage('发布失败');
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTC 发布')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 1, label: Text('互换消费券')),
              ButtonSegment(value: 2, label: Text('互换福豆')),
            ],
            selected: {_type},
            onSelectionChanged: (values) {
              setState(() {
                _type = values.first;
              });
            },
          ),
          const SizedBox(height: 16),
          if (_type == 1) ...[
            _OtcSendTextField(label: '换入单位', controller: _xfqPriceController, enabled: false),
            const SizedBox(height: 12),
            _OtcSendTextField(label: '换入数量（消费券）', controller: _xfqNumController),
            const SizedBox(height: 12),
            const Text('付款方式', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _OtcPayTypeChips(
              selected: _payTypes,
              onChanged: (value) {
                setState(() {
                  _payTypes
                    ..clear()
                    ..addAll(value);
                });
              },
            ),
          ] else ...[
            _OtcSendTextField(label: '换入单位（消费券）', controller: _fdPriceController),
            const SizedBox(height: 12),
            _OtcSendTextField(label: '换入数量（福豆）', controller: _fdNumController),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: Text(_submitting ? '发布中...' : '发布互换'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _OtcSendTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;

  const _OtcSendTextField({required this.label, required this.controller, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }
}

class _OtcPayTypeChips extends StatelessWidget {
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  const _OtcPayTypeChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const items = [(1, '银行卡'), (2, '支付宝'), (3, '微信')];

    return Wrap(
      spacing: 8,
      children: items.map((item) {
        final isSelected = selected.contains(item.$1);
        return FilterChip(
          label: Text(item.$2),
          selected: isSelected,
          onSelected: (value) {
            final next = Set<int>.from(selected);
            if (value) {
              next.add(item.$1);
            } else {
              next.remove(item.$1);
            }
            onChanged(next);
          },
        );
      }).toList(),
    );
  }
}
