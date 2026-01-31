import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';

/// 绑定手机号页面
/// 对应原 pages/users/user_phone/index.vue
class BindPhonePage extends StatefulWidget {
  const BindPhonePage({super.key});

  @override
  State<BindPhonePage> createState() => _BindPhonePageState();
}

class _BindPhonePageState extends State<BindPhonePage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  final UserProvider _userProvider = UserProvider();

  bool _isLoading = false;
  bool _isSendingCode = false;
  int _countdown = 0;

  // type=0 绑定手机号, type=1 修改手机号
  int _type = 0;

  @override
  void initState() {
    super.initState();
    // 获取参数
    _type = int.tryParse(Get.parameters['type'] ?? '0') ?? 0;

    // 检查登录状态
    final controller = Get.find<AppController>();
    if (!controller.isLogin) {
      Get.offNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  /// 发送验证码
  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      EasyLoading.showToast('请填写手机号码');
      return;
    }

    // 验证手机号格式
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      EasyLoading.showToast('请输入正确的手机号码');
      return;
    }

    if (_isSendingCode || _countdown > 0) return;

    setState(() {
      _isSendingCode = true;
    });

    try {
      final response = await _userProvider.sendCode(
        phone: phone,
        type: 'reset',
      );

      if (response.isSuccess) {
        EasyLoading.showToast(response.msg.isNotEmpty ? response.msg : '验证码已发送');
        _startCountdown();
      } else {
        EasyLoading.showToast(response.msg.isNotEmpty ? response.msg : '发送失败');
      }
    } catch (e) {
      EasyLoading.showToast('发送验证码失败');
    } finally {
      setState(() {
        _isSendingCode = false;
      });
    }
  }

  /// 开始倒计时
  void _startCountdown() {
    setState(() {
      _countdown = 60;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_countdown > 0 && mounted) {
        setState(() {
          _countdown--;
        });
        return true;
      }
      return false;
    });
  }

  /// 提交绑定
  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    final captcha = _captchaController.text.trim();

    if (phone.isEmpty) {
      EasyLoading.showToast('请填写手机号码');
      return;
    }

    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      EasyLoading.showToast('请输入正确的手机号码');
      return;
    }

    if (captcha.isEmpty) {
      EasyLoading.showToast('请填写验证码');
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    EasyLoading.show(status: '提交中...');

    try {
      if (_type == 0) {
        // 绑定手机号
        final response = await _userProvider.bindingUserPhone(
          phone: phone,
          captcha: captcha,
        );

        EasyLoading.dismiss();

        if (response.isSuccess) {
          // 检查是否需要确认绑定
          final data = response.data;
          if (data != null && data is Map && data['is_bind'] == true) {
            // 显示确认对话框
            _showBindConfirmDialog(phone, captcha, response.msg);
          } else {
            EasyLoading.showSuccess('绑定成功');
            await Future.delayed(const Duration(seconds: 1));
            Get.offNamed(AppRoutes.userInfo);
          }
        } else {
          EasyLoading.showError(response.msg.isNotEmpty ? response.msg : '绑定失败');
        }
      } else {
        // 修改手机号
        final response = await _userProvider.updatePhone(
          phone: phone,
          captcha: captcha,
        );

        EasyLoading.dismiss();

        if (response.isSuccess) {
          EasyLoading.showSuccess(response.msg.isNotEmpty ? response.msg : '修改成功');
          await Future.delayed(const Duration(seconds: 1));
          Get.offNamed(AppRoutes.userInfo);
        } else {
          EasyLoading.showError(response.msg.isNotEmpty ? response.msg : '修改失败');
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('操作失败');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 显示绑定确认对话框
  void _showBindConfirmDialog(String phone, String captcha, String message) {
    Get.dialog(
      AlertDialog(
        title: const Text('是否绑定账号'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              EasyLoading.showToast('您已取消绑定！');
              Future.delayed(const Duration(seconds: 1), () {
                Get.offNamed(AppRoutes.userInfo);
              });
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _confirmBind(phone, captcha);
            },
            child: const Text('绑定'),
          ),
        ],
      ),
    );
  }

  /// 确认绑定
  Future<void> _confirmBind(String phone, String captcha) async {
    EasyLoading.show(status: '绑定中...');

    try {
      final response = await _userProvider.bindingUserPhone(
        phone: phone,
        captcha: captcha,
        step: 1,
      );

      EasyLoading.dismiss();

      if (response.isSuccess) {
        EasyLoading.showSuccess(response.msg.isNotEmpty ? response.msg : '绑定成功');
        await Future.delayed(const Duration(seconds: 1));
        Get.offNamed(AppRoutes.userInfo);
      } else {
        EasyLoading.showError(response.msg.isNotEmpty ? response.msg : '绑定失败');
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('绑定失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Get.find<AppController>().themeColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_type == 0 ? '绑定手机号' : '修改手机号'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 27),
        child: Column(
          children: [
            // 手机号输入框
            Container(
              height: 55,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
                ),
              ),
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: const InputDecoration(
                  hintText: '填写手机号码',
                  hintStyle: TextStyle(color: Color(0xFFB9B9BC), fontSize: 16),
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),

            // 验证码输入框
            Container(
              height: 55,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _captchaController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        hintText: '填写验证码',
                        hintStyle: TextStyle(color: Color(0xFFB9B9BC), fontSize: 16),
                        border: InputBorder.none,
                        counterText: '',
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _countdown > 0 || _isSendingCode ? null : _sendCode,
                    child: Text(
                      _countdown > 0 ? '${_countdown}s后重发' : '获取验证码',
                      style: TextStyle(
                        fontSize: 16,
                        color: _countdown > 0 ? const Color(0xFFB9B9BC) : themeColor.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 46),

            // 确认按钮
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.5),
                  ),
                ),
                child: Text(
                  _isLoading ? '提交中...' : '确认绑定',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
