import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/user_provider.dart';
import '../../theme/theme_colors.dart';

/// 找回密码页面
/// 对应原 pages/users/retrievePassword/index.vue
class RetrievePasswordPage extends StatefulWidget {
  const RetrievePasswordPage({super.key});

  @override
  State<RetrievePasswordPage> createState() => _RetrievePasswordPageState();
}

class _RetrievePasswordPageState extends State<RetrievePasswordPage> {
  final UserProvider _userProvider = UserProvider();
  
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  int _countdown = 0;
  Timer? _timer;
  
  Color get _primaryColor => ThemeColors.red.primary;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 发送验证码
  Future<void> _sendCode() async {
    String phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      Get.snackbar('提示', '请填写手机号码');
      return;
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      Get.snackbar('提示', '请输入正确的手机号码');
      return;
    }

    try {
      final response = await _userProvider.registerVerify(
        phone: phone,
        type: 'reset',
      );
      if (response.isSuccess) {
        Get.snackbar('提示', response.msg.isNotEmpty ? response.msg : '验证码已发送');
        _startCountdown();
      } else {
        Get.snackbar('提示', response.msg);
      }
    } catch (e) {
      Get.snackbar('提示', '发送失败');
    }
  }

  /// 开始倒计时
  void _startCountdown() {
    setState(() {
      _countdown = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  /// 重置密码
  Future<void> _resetPassword() async {
    String phone = _phoneController.text.trim();
    String code = _codeController.text.trim();
    String password = _passwordController.text.trim();

    if (phone.isEmpty) {
      Get.snackbar('提示', '请填写手机号码');
      return;
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      Get.snackbar('提示', '请输入正确的手机号码');
      return;
    }
    if (code.isEmpty) {
      Get.snackbar('提示', '请填写验证码');
      return;
    }
    if (password.isEmpty) {
      Get.snackbar('提示', '请填写新密码');
      return;
    }
    if (password.length < 6) {
      Get.snackbar('提示', '密码长度不能少于6位');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _userProvider.registerReset(
        account: phone,
        captcha: code,
        password: password,
      );
      if (response.isSuccess) {
        Get.snackbar('提示', response.msg.isNotEmpty ? response.msg : '密码重置成功');
        await Future.delayed(const Duration(seconds: 1));
        Get.back();
      } else {
        Get.snackbar('提示', response.msg);
      }
    } catch (e) {
      Get.snackbar('提示', '重置失败');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '找回密码',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _primaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(Icons.lock_reset, size: 50, color: _primaryColor),
            ),
            const SizedBox(height: 40),
            // 手机号
            _buildInputField(
              controller: _phoneController,
              hintText: '输入手机号码',
              prefixIcon: Icons.phone_android,
              keyboardType: TextInputType.phone,
              maxLength: 11,
            ),
            // 验证码
            _buildInputField(
              controller: _codeController,
              hintText: '填写验证码',
              prefixIcon: Icons.sms,
              keyboardType: TextInputType.number,
              maxLength: 6,
              suffixWidget: TextButton(
                onPressed: _countdown > 0 ? null : _sendCode,
                child: Text(
                  _countdown > 0 ? '${_countdown}s' : '获取验证码',
                  style: TextStyle(
                    color: _countdown > 0 ? Colors.grey : _primaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            // 新密码
            _buildInputField(
              controller: _passwordController,
              hintText: '填写您的新密码',
              prefixIcon: Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 30),
            // 确认按钮
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        '确认',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            // 返回登录
            TextButton(
              onPressed: () => Get.back(),
              child: Text('立即登录', style: TextStyle(color: _primaryColor)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    int? maxLength,
    Widget? suffixWidget,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLength: maxLength,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
          prefixIcon: Icon(prefixIcon, color: Colors.grey, size: 22),
          suffixIcon: suffixWidget,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          counterText: '',
        ),
      ),
    );
  }
}
