import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shuhang_mall_flutter/app/data/providers/public_provider.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';

/// OTC 结算方式页面 - 适用于银行卡/支付宝/微信收款信息维护。
class OtcPayTypePage extends StatefulWidget {
  const OtcPayTypePage({super.key});

  @override
  State<OtcPayTypePage> createState() => _OtcPayTypePageState();
}

class _OtcPayTypePageState extends State<OtcPayTypePage> with TickerProviderStateMixin {
  final UserProvider _userProvider = UserProvider();
  final PublicProvider _publicProvider = PublicProvider();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _bankNumberController = TextEditingController();
  final TextEditingController _alipayController = TextEditingController();
  final TextEditingController _wechatController = TextEditingController();

  String _name = '';
  String _alipayCode = '';
  String _wechatCode = '';
  bool _saving = false;

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPayType();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bankNameController.dispose();
    _bankNumberController.dispose();
    _alipayController.dispose();
    _wechatController.dispose();
    super.dispose();
  }

  Future<void> _loadPayType() async {
    try {
      final response = await _userProvider.getPayType();
      if (response.isSuccess && response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);
        setState(() {
          _name = data['name']?.toString() ?? '';
          _bankNameController.text = data['bank_name']?.toString() ?? '';
          _bankNumberController.text = data['bank_number']?.toString() ?? '';
          _alipayController.text = data['alipay']?.toString() ?? '';
          _wechatController.text = data['wechat']?.toString() ?? '';
          _alipayCode = data['alipay_code']?.toString() ?? '';
          _wechatCode = data['wechat_code']?.toString() ?? '';
        });
      }
    } catch (e) {
      debugPrint('获取结算方式失败: $e');
    }
  }

  Future<void> _save() async {
    if (_saving) return;

    final index = _tabController.index;
    if (index == 0) {
      if (_bankNameController.text.trim().isEmpty) {
        _showMessage('请填写银行名称');
        return;
      }
      if (_bankNumberController.text.trim().isEmpty) {
        _showMessage('请填写银行卡号');
        return;
      }
    }
    if (index == 1) {
      if (_alipayController.text.trim().isEmpty) {
        _showMessage('请填写支付宝账号');
        return;
      }
      if (_alipayCode.isEmpty) {
        _showMessage('请上传支付宝收款码');
        return;
      }
    }
    if (index == 2) {
      if (_wechatController.text.trim().isEmpty) {
        _showMessage('请填写微信号');
        return;
      }
      if (_wechatCode.isEmpty) {
        _showMessage('请上传微信收款码');
        return;
      }
    }

    setState(() {
      _saving = true;
    });

    final data = <String, dynamic>{
      'name': _name,
      'bank_name': _bankNameController.text.trim(),
      'bank_number': _bankNumberController.text.trim(),
      'alipay': _alipayController.text.trim(),
      'wechat': _wechatController.text.trim(),
      'alipay_code': _alipayCode,
      'wechat_code': _wechatCode,
    };

    try {
      final response = await _userProvider.savePayType(data);
      if (!mounted) return;
      if (response.isSuccess) {
        _showMessage('保存成功');
        await _loadPayType();
      } else {
        final message = response.msg.isEmpty ? '保存失败' : response.msg;
        _showMessage(message);
      }
    } catch (e) {
      debugPrint('保存结算方式失败: $e');
      if (mounted) {
        _showMessage('保存失败');
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _pickImage(bool isAlipay) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final response = await _publicProvider.uploadFile(filePath: picked.path);
    if (response.isSuccess && response.data != null) {
      final data = response.data as Map;
      final url = data['url']?.toString() ?? '';
      if (!mounted) return;
      setState(() {
        if (isAlipay) {
          _alipayCode = url;
        } else {
          _wechatCode = url;
        }
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _previewImage(String url) {
    if (url.isEmpty) return;
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          child: AspectRatio(aspectRatio: 1, child: Image.network(url, fit: BoxFit.contain)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('结算方式'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '银行卡'),
            Tab(text: '支付宝'),
            Tab(text: '微信'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _BankFormSection(
                  name: _name,
                  bankNameController: _bankNameController,
                  bankNumberController: _bankNumberController,
                ),
                _AlipayFormSection(
                  name: _name,
                  accountController: _alipayController,
                  codeUrl: _alipayCode,
                  onUpload: () => _pickImage(true),
                  onRemove: () => setState(() => _alipayCode = ''),
                  onPreview: () => _previewImage(_alipayCode),
                ),
                _WechatFormSection(
                  name: _name,
                  accountController: _wechatController,
                  codeUrl: _wechatCode,
                  onUpload: () => _pickImage(false),
                  onRemove: () => setState(() => _wechatCode = ''),
                  onPreview: () => _previewImage(_wechatCode),
                ),
              ],
            ),
          ),
          _TipsBar(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? '保存中...' : '保存'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BankFormSection extends StatelessWidget {
  final String name;
  final TextEditingController bankNameController;
  final TextEditingController bankNumberController;

  const _BankFormSection({
    required this.name,
    required this.bankNameController,
    required this.bankNumberController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ReadonlyRow(label: '姓名', value: name),
        const SizedBox(height: 12),
        _InputRow(label: '银行名称', controller: bankNameController),
        const SizedBox(height: 12),
        _InputRow(
          label: '银行卡号',
          controller: bankNumberController,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}

class _AlipayFormSection extends StatelessWidget {
  final String name;
  final TextEditingController accountController;
  final String codeUrl;
  final VoidCallback onUpload;
  final VoidCallback onRemove;
  final VoidCallback onPreview;

  const _AlipayFormSection({
    required this.name,
    required this.accountController,
    required this.codeUrl,
    required this.onUpload,
    required this.onRemove,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ReadonlyRow(label: '姓名', value: name),
        const SizedBox(height: 12),
        _InputRow(label: '支付宝账号', controller: accountController),
        const SizedBox(height: 12),
        _UploadSection(
          title: '请上传支付宝收款码',
          url: codeUrl,
          onUpload: onUpload,
          onRemove: onRemove,
          onPreview: onPreview,
        ),
      ],
    );
  }
}

class _WechatFormSection extends StatelessWidget {
  final String name;
  final TextEditingController accountController;
  final String codeUrl;
  final VoidCallback onUpload;
  final VoidCallback onRemove;
  final VoidCallback onPreview;

  const _WechatFormSection({
    required this.name,
    required this.accountController,
    required this.codeUrl,
    required this.onUpload,
    required this.onRemove,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ReadonlyRow(label: '姓名', value: name),
        const SizedBox(height: 12),
        _InputRow(label: '微信号', controller: accountController),
        const SizedBox(height: 12),
        _UploadSection(
          title: '请上传微信收款码',
          url: codeUrl,
          onUpload: onUpload,
          onRemove: onRemove,
          onPreview: onPreview,
        ),
      ],
    );
  }
}

class _ReadonlyRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReadonlyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text(label)),
        Expanded(child: Text(value.isEmpty ? '-' : value)),
      ],
    );
  }
}

class _InputRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _InputRow({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }
}

class _UploadSection extends StatelessWidget {
  final String title;
  final String url;
  final VoidCallback onUpload;
  final VoidCallback onRemove;
  final VoidCallback onPreview;

  const _UploadSection({
    required this.title,
    required this.url,
    required this.onUpload,
    required this.onRemove,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (url.isEmpty)
          OutlinedButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.upload),
            label: const Text('上传图片'),
          )
        else
          Stack(
            alignment: Alignment.topRight,
            children: [
              GestureDetector(
                onTap: onPreview,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(url, width: 80, height: 80, fit: BoxFit.cover),
                ),
              ),
              IconButton(onPressed: onRemove, icon: const Icon(Icons.close, size: 18)),
            ],
          ),
      ],
    );
  }
}

class _TipsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text('温馨提示：请保存与实名信息匹配的结算方式，否则造成损失由自己承担！', style: TextStyle(fontSize: 12)),
    );
  }
}
