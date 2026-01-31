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
      final response = await _userProvider.suggest({
        'text': content,
        'phone': phone,
      });

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
      appBar: AppBar(
        title: const Text('意见反馈'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 问题描述输入框
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  TextField(
                    controller: _contentController,
                    maxLines: 6,
                    maxLength: 150,
                    decoration: const InputDecoration(
                      hintText: '请输入你遇到的问题或建议(150字以内)',
                      hintStyle: TextStyle(color: Color(0xFF999999), fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                      counterText: '',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 8,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${_contentController.text.length}',
                            style: TextStyle(color: themeColor.primary),
                          ),
                          const TextSpan(
                            text: '/150',
                            style: TextStyle(color: Color(0xFF999999)),
                          ),
                        ],
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 联系方式输入框
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _phoneController,
                maxLength: 20,
                decoration: const InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 12, right: 8),
                    child: Text(
                      '联系方式',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  hintText: '请输入联系方式',
                  hintStyle: TextStyle(color: Color(0xFF999999), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  counterText: '',
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 提交按钮
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _isLoading ? '提交中...' : '保存',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
