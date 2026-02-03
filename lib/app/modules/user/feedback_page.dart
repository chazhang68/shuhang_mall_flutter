import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';

/// 意见反馈页面
/// 对应原 pages/user_suggest/index.vue
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final UserProvider _userProvider = UserProvider();
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // 提交反馈
  Future<void> _submitFeedback() async {
    final content = _contentController.text.trim();
    final phone = _phoneController.text.trim();

    if (content.isEmpty) {
      EasyLoading.showToast('请填写问题或建议');
      return;
    }

    if (phone.isEmpty) {
      EasyLoading.showToast('请填写联系方式');
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    EasyLoading.show(status: '提交中...');

    try {
      final response = await _userProvider.suggest({'text': content, 'phone': phone});

      EasyLoading.dismiss();

      if (response.isSuccess) {
        EasyLoading.showSuccess('提交成功');
        await Future.delayed(const Duration(seconds: 1));
        Get.back();
      } else {
        EasyLoading.showError(response.msg.isNotEmpty ? response.msg : '提交失败');
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('提交失败');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Get.find<AppController>().themeColor;

    return Scaffold(
      appBar: AppBar(title: const Text('意见反馈'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 问题描述输入框
            Container(
              padding: .only(bottom: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 6,
                maxLength: 150,
                decoration: const InputDecoration(
                  hintText: '请输入你遇到的问题或建议(150字以内)',
                  hintStyle: TextStyle(color: Color(0xFF999999), fontSize: 12),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.all(12),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),

            const SizedBox(height: 12),

            // 联系方式输入框
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: TextField(
                controller: _phoneController,
                maxLength: 20,
                decoration: const InputDecoration(
                  isDense: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 12, right: 8),
                    child: Text('联系方式', style: TextStyle(color: Color(0xFF333333), fontSize: 14)),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  hintText: '请输入联系方式',
                  hintStyle: TextStyle(color: Color(0xFF999999), fontSize: 14),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  counterText: '',
                ),
              ),
            ),

            const SizedBox(height: 28),

            // 提交按钮
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor.primary.withValues(alpha: 0.8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(_isLoading ? '提交中...' : '保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
