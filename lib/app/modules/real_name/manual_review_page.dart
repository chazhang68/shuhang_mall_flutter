import 'package:flutter/material.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/data/providers/public_provider.dart';
import 'package:shuhang_mall_flutter/app/data/providers/store_provider.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';

/// 实名认证人工审核页面。
///
/// 对应原 pages/rg_sign/rg_sign.vue。
class ManualReviewPage extends StatefulWidget {
  const ManualReviewPage({super.key});

  @override
  State<ManualReviewPage> createState() => _ManualReviewPageState();
}

class _ManualReviewPageState extends State<ManualReviewPage> {
  final StoreProvider _storeProvider = StoreProvider();
  final PublicProvider _publicProvider = PublicProvider();
  final ImagePicker _picker = ImagePicker();
  final AppController _appController = Get.find<AppController>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _frontImageUrl;
  String? _backImageUrl;
  bool _frontUploading = false;
  bool _backUploading = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _ensureLogin();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardController.dispose();
    _bankController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _ensureLogin() async {
    if (!_appController.isLogin) {
      await Get.toNamed(AppRoutes.login);
    }
  }

  Future<void> _pickImage({required bool isFront}) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return;
    }

    setState(() {
      if (isFront) {
        _frontUploading = true;
      } else {
        _backUploading = true;
      }
    });

    try {
      final response = await _publicProvider.uploadFile(filePath: picked.path);
      if (response.isSuccess && response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);
        final url = data['url']?.toString() ?? '';
        if (url.isEmpty) {
          FlutterToastPro.showMessage('上传失败');
        } else {
          setState(() {
            if (isFront) {
              _frontImageUrl = url;
            } else {
              _backImageUrl = url;
            }
          });
        }
      } else {
        FlutterToastPro.showMessage('上传失败');
      }
    } catch (e) {
      FlutterToastPro.showMessage('上传失败');
    } finally {
      if (mounted) {
        setState(() {
          _frontUploading = false;
          _backUploading = false;
        });
      }
    }
  }

  void _removeImage({required bool isFront}) {
    setState(() {
      if (isFront) {
        _frontImageUrl = null;
      } else {
        _backImageUrl = null;
      }
    });
  }

  bool _validateForm() {
    if (_frontImageUrl == null || _frontImageUrl!.isEmpty) {
      FlutterToastPro.showMessage('请上传身份证正面');
      return false;
    }
    if (_backImageUrl == null || _backImageUrl!.isEmpty) {
      FlutterToastPro.showMessage('请上传身份证反面');
      return false;
    }
    if (_nameController.text.trim().isEmpty) {
      FlutterToastPro.showMessage('请输入姓名');
      return false;
    }
    if (_cardController.text.trim().isEmpty) {
      FlutterToastPro.showMessage('填写身份证号码');
      return false;
    }
    if (_bankController.text.trim().isEmpty) {
      FlutterToastPro.showMessage('填写银行卡号');
      return false;
    }
    if (_phoneController.text.trim().isEmpty) {
      FlutterToastPro.showMessage('填写银行预留手机号');
      return false;
    }
    return true;
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
        'bank_code': _bankController.text.trim(),
        'images': {'obverseUrl': _frontImageUrl, 'reverseUrl': _backImageUrl},
        'type': 2,
      };

      final response = await _storeProvider.createRealName(requestData);
      if (response.isSuccess) {
        FlutterToastPro.showMessage('提交成功');
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Get.back();
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('人工审核'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SectionTitle(title: '身份信息'),
            const SizedBox(height: 12),
            _FormCard(
              children: [
                _LabeledField(
                  label: '用户姓名',
                  controller: _nameController,
                  hintText: '请输入姓名',
                  keyboardType: TextInputType.name,
                ),
                const Divider(height: 1),
                _LabeledField(
                  label: '身份证号',
                  controller: _cardController,
                  hintText: '请输入身份证号',
                  keyboardType: TextInputType.text,
                ),
                const Divider(height: 1),
                _LabeledField(
                  label: '银行卡号',
                  controller: _bankController,
                  hintText: '请输入银行卡号',
                  keyboardType: TextInputType.number,
                ),
                const Divider(height: 1),
                _LabeledField(
                  label: '预留手机号',
                  controller: _phoneController,
                  hintText: '请输入银行卡手机号',
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: '上传证件材料'),
            const SizedBox(height: 12),
            _UploadCard(
              title: '身份证正面',
              imageUrl: _frontImageUrl,
              isUploading: _frontUploading,
              onUpload: () => _pickImage(isFront: true),
              onRemove: () => _removeImage(isFront: true),
            ),
            const SizedBox(height: 12),
            _UploadCard(
              title: '身份证反面',
              imageUrl: _backImageUrl,
              isUploading: _backUploading,
              onUpload: () => _pickImage(isFront: false),
              onRemove: () => _removeImage(isFront: false),
            ),
            const SizedBox(height: 24),
            _PrimaryActionButton(
              label: _submitting ? '提交中...' : '确认',
              onPressed: _submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              decoration: InputDecoration(hintText: hintText, border: InputBorder.none),
            ),
          ),
        ],
      ),
    );
  }
}

/// 身份证上传卡片，仅用于人工审核页面。
class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.title,
    required this.imageUrl,
    required this.isUploading,
    required this.onUpload,
    required this.onRemove,
  });

  final String title;
  final String? imageUrl;
  final bool isUploading;
  final VoidCallback onUpload;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 3 / 2,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: hasImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Icon(Icons.error));
                          },
                        ),
                      )
                    : Center(
                        child: isUploading
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.photo_camera_outlined),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isUploading ? null : onUpload,
                    icon: const Icon(Icons.upload),
                    label: Text(hasImage ? '重新上传' : '上传'),
                  ),
                ),
                const SizedBox(width: 12),
                if (hasImage)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('删除'),
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

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
