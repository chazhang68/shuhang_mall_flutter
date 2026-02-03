import 'package:flutter/material.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/data/providers/store_provider.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';

/// 实名认证页面。
///
/// 对应原 pages/sign/sign.vue。
class RealNamePage extends StatefulWidget {
  const RealNamePage({super.key});

  @override
  State<RealNamePage> createState() => _RealNamePageState();
}

class _RealNamePageState extends State<RealNamePage> {
  final StoreProvider _storeProvider = StoreProvider();
  final AppController _appController = Get.find<AppController>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _loading = true;
  bool _submitting = false;
  int _status = -1;
  String _refusalReason = '';
  int _applyId = 0;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    if (!_appController.isLogin) {
      await Get.toNamed(AppRoutes.login);
      if (!_appController.isLogin) {
        return;
      }
    }

    setState(() {
      _loading = true;
    });

    try {
      final response = await _storeProvider.getRealDetails();
      if (response.isSuccess && response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);
        _status = _parseStatus(data['status']);
        _applyId = _parseInt(data['id']);
        _refusalReason = data['refusal_reason']?.toString() ?? '';

        if (_status != -1) {
          _nameController.text = data['name']?.toString() ?? '';
          _cardController.text = data['card_num']?.toString() ?? '';
          _phoneController.text = data['phone']?.toString() ?? '';
        }
      }
    } catch (e) {
      FlutterToastPro.showMessage('获取实名认证信息失败');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  int _parseStatus(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? -1;
  }

  int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> _submit() async {
    if (_submitting) {
      return;
    }
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final requestData = {
        'uid': _appController.uid,
        'phone': _phoneController.text.trim(),
        'card_num': _cardController.text.trim(),
        'name': _nameController.text.trim(),
        'id': _applyId,
      };

      final response = await _storeProvider.createRealName(requestData);
      if (response.isSuccess) {
        await _showSuccessDialog();
        await _loadDetails();
      } else {
        FlutterToastPro.showMessage(response.msg.isNotEmpty ? response.msg : '提交失败');
      }
    } catch (e) {
      FlutterToastPro.showMessage('提交失败');
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  bool _validateForm() {
    final name = _nameController.text.trim();
    final card = _cardController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      FlutterToastPro.showMessage('请输入姓名');
      return false;
    }
    if (card.isEmpty) {
      FlutterToastPro.showMessage('填写身份证号码');
      return false;
    }
    if (phone.isEmpty) {
      FlutterToastPro.showMessage('填写手机号');
      return false;
    }
    final phoneReg = RegExp(r'^1[3-9]\d{9}$');
    if (!phoneReg.hasMatch(phone)) {
      FlutterToastPro.showMessage('请输入正确的手机号');
      return false;
    }
    return true;
  }

  Future<void> _showSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _RealNameSuccessDialog(
          onGoTask: () {
            Navigator.of(context).pop();
            Get.toNamed(AppRoutes.task);
          },
        );
      },
    );
  }

  void _applyAgain() {
    setState(() {
      _status = -1;
      _refusalReason = '';
      _nameController.clear();
      _cardController.clear();
      _phoneController.clear();
    });
  }

  void _goHome() {
    Get.offAllNamed(AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        title: const Text('实名认证'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _RealNameBody(
              status: _status,
              refusalReason: _refusalReason,
              isSubmitting: _submitting,
              nameController: _nameController,
              cardController: _cardController,
              phoneController: _phoneController,
              onSubmit: _submit,
              onGoHome: _goHome,
              onApplyAgain: _applyAgain,
            ),
    );
  }
}

class _RealNameBody extends StatelessWidget {
  const _RealNameBody({
    required this.status,
    required this.refusalReason,
    required this.isSubmitting,
    required this.nameController,
    required this.cardController,
    required this.phoneController,
    required this.onSubmit,
    required this.onGoHome,
    required this.onApplyAgain,
  });

  final int status;
  final String refusalReason;
  final bool isSubmitting;
  final TextEditingController nameController;
  final TextEditingController cardController;
  final TextEditingController phoneController;
  final VoidCallback onSubmit;
  final VoidCallback onGoHome;
  final VoidCallback onApplyAgain;

  @override
  Widget build(BuildContext context) {
    if (status == 0) {
      return _RealNameResultView(
        icon: Icons.check_circle,
        title: '您的认证申请提交成功！',
        actions: [_PrimaryActionButton(label: '返回首页', onPressed: onGoHome)],
      );
    }

    if (status == 1) {
      return _RealNameResultView(
        icon: Icons.verified,
        title: '恭喜，您已通过实名认证！',
        actions: [_PrimaryActionButton(label: '返回首页', onPressed: onGoHome)],
      );
    }

    if (status == 2) {
      return _RealNameResultView(
        icon: Icons.error,
        title: '您的实名认证未通过！',
        reason: refusalReason,
        actions: [
          _PrimaryActionButton(label: '重新申请', onPressed: onApplyAgain),
          const SizedBox(height: 12),
          _OutlineActionButton(label: '返回首页', onPressed: onGoHome),
        ],
      );
    }

    return _RealNameFormView(
      nameController: nameController,
      cardController: cardController,
      phoneController: phoneController,
      isSubmitting: isSubmitting,
      onSubmit: onSubmit,
    );
  }
}

class _RealNameFormView extends StatelessWidget {
  const _RealNameFormView({
    required this.nameController,
    required this.cardController,
    required this.phoneController,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final TextEditingController nameController;
  final TextEditingController cardController;
  final TextEditingController phoneController;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _FormCard(
            children: [
              _LabeledField(
                label: '用户姓名',
                controller: nameController,
                hintText: '请输入姓名',
                keyboardType: TextInputType.name,
              ),
              const Divider(height: 1),
              _LabeledField(
                label: '身份证号',
                controller: cardController,
                hintText: '请输入身份证号',
                keyboardType: TextInputType.text,
              ),
              const Divider(height: 1),
              _LabeledField(
                label: '手机号',
                controller: phoneController,
                hintText: '请输入正确的手机号',
                keyboardType: TextInputType.phone,
              ),
              const Divider(height: 1),
              const SizedBox(height: 24),
              _PrimaryActionButton(
                label: isSubmitting ? '提交中...' : '提交认证',
                onPressed: isSubmitting ? null : onSubmit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF333333))),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RealNameResultView extends StatelessWidget {
  const _RealNameResultView({
    required this.icon,
    required this.title,
    required this.actions,
    this.reason,
  });

  final IconData icon;
  final String title;
  final String? reason;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            if (reason != null && reason!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                reason!,
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            ...actions,
          ],
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _RealNameSuccessDialog extends StatelessWidget {
  const _RealNameSuccessDialog({required this.onGoTask});

  final VoidCallback onGoTask;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 48, color: Theme.of(context).primaryColor),
          const SizedBox(height: 12),
          const Text('实名认证成功', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _PrimaryActionButton(label: '去签到完成任务', onPressed: onGoTask),
        ],
      ),
    );
  }
}
