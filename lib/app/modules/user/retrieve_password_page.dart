import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/api_provider.dart';
import '../../core/constants/app_images.dart';

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
  String _logoUrl = '';

  // 对应 uni-app: background-image: linear-gradient(to bottom, #eb5447 0, #ff8e3b 100%)
  static const Color _gradientStart = Color(0xFFEB5447);
  static const Color _gradientEnd = Color(0xFFFF8E3B);
  // 对应 uni-app: background: linear-gradient(to right, #f35447 0, #ff8e3c 100%)
  static const Color _btnGradientStart = Color(0xFFF35447);
  static const Color _btnGradientEnd = Color(0xFFFF8E3C);

  @override
  void initState() {
    super.initState();
    _loadLogo();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 加载Logo
  Future<void> _loadLogo() async {
    try {
      final response = await ApiProvider.instance.get('wechat/get_logo', noAuth: true);
      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        setState(() {
          _logoUrl = data['logo_url']?.toString() ?? '';
        });
      }
    } catch (e) {
      debugPrint('获取Logo失败: $e');
    }
  }

  /// 发送验证码
  Future<void> _sendCode() async {
    String phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      FlutterToastPro.showMessage('请填写手机号码');
      return;
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      FlutterToastPro.showMessage('请输入正确的手机号码');
      return;
    }

    try {
      final response = await _userProvider.registerVerify(
        phone: phone,
        type: 'reset',
      );
      if (response.isSuccess) {
        FlutterToastPro.showMessage(response.msg.isNotEmpty ? response.msg : '验证码已发送');
        _startCountdown();
      } else {
        FlutterToastPro.showMessage(response.msg);
      }
    } catch (e) {
      FlutterToastPro.showMessage('发送失败');
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
      FlutterToastPro.showMessage('请填写手机号码');
      return;
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      FlutterToastPro.showMessage('请输入正确的手机号码');
      return;
    }
    if (code.isEmpty) {
      FlutterToastPro.showMessage('请填写验证码');
      return;
    }
    if (password.isEmpty) {
      FlutterToastPro.showMessage('请填写新密码');
      return;
    }
    if (password.length < 6) {
      FlutterToastPro.showMessage('密码长度不能少于6位');
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
        FlutterToastPro.showMessage(response.msg.isNotEmpty ? response.msg : '密码重置成功');
        await Future.delayed(const Duration(seconds: 1));
        Get.back();
      } else {
        FlutterToastPro.showMessage(response.msg);
      }
    } catch (e) {
      FlutterToastPro.showMessage('重置失败');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // 对应 uni-app: background-image: linear-gradient(to bottom, #eb5447, #ff8e3b)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_gradientStart, _gradientEnd],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 顶部返回按钮
                _buildAppBar(),
                // shading 区域 - Logo
                SizedBox(height: 20.h),
                _buildLogo(),
                SizedBox(height: 15.h),
                // whiteBg 白色卡片区域
                _buildWhiteCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 顶部导航栏
  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  /// Logo 区域
  /// 对应 uni-app: .shading .pictrue - 圆形白色半透明背景 + logo图片
  Widget _buildLogo() {
    return Container(
      width: 86.w,
      height: 86.w,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(204),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: _logoUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: _logoUrl,
                width: 86.w,
                height: 86.w,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.white, width: 86.w, height: 86.w),
                errorWidget: (context, url, error) =>
                    Image.asset(AppImages.logo, width: 86.w, height: 86.w, fit: BoxFit.cover),
              )
            : Image.asset(AppImages.logo, width: 86.w, height: 86.w, fit: BoxFit.cover),
      ),
    );
  }

  /// 白色卡片表单区域
  /// 对应 uni-app: .whiteBg
  Widget _buildWhiteCard() {
    return Container(
      width: 310.w,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.fromLTRB(15.w, 22.h, 15.w, 30.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          // 标题
          Text(
            '找回密码',
            style: TextStyle(
              fontSize: 18.sp,
              color: const Color(0xFF282828),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10.h),
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
            prefixIcon: Icons.sms_outlined,
            keyboardType: TextInputType.number,
            maxLength: 6,
            suffixWidget: GestureDetector(
              onTap: _countdown > 0 ? null : _sendCode,
              child: Container(
                width: 75.w,
                height: 25.h,
                decoration: BoxDecoration(
                  color: _countdown > 0 ? Colors.grey : _gradientStart,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  _countdown > 0 ? '${_countdown}s' : '获取验证码',
                  style: TextStyle(color: Colors.white, fontSize: 12.sp),
                ),
              ),
            ),
          ),
          // 新密码
          _buildInputField(
            controller: _passwordController,
            hintText: '填写您的新密码',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
          ),
          SizedBox(height: 24.h),
          // 确认按钮
          _buildSubmitButton(),
          SizedBox(height: 15.h),
          // 立即登录
          GestureDetector(
            onTap: () => Get.back(),
            child: Text(
              '立即登录',
              style: TextStyle(color: _gradientStart, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  /// 输入框
  /// 对应 uni-app: .list .item
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
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEDEDED), width: 0.5)),
      ),
      padding: EdgeInsets.only(top: 18.h, bottom: 6.h),
      child: Row(
        children: [
          Icon(prefixIcon, color: Colors.grey, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              maxLength: maxLength,
              style: TextStyle(fontSize: 15.sp),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15.sp),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                counterText: '',
              ),
            ),
          ),
          if (suffixWidget case final widget?) widget,
        ],
      ),
    );
  }

  /// 确认按钮
  /// 对应 uni-app: .logon - 渐变背景圆角按钮
  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _resetPassword,
      child: Container(
        width: double.infinity,
        height: 43.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_btnGradientStart, _btnGradientEnd],
          ),
          borderRadius: BorderRadius.circular(21.5.r),
        ),
        alignment: Alignment.center,
        child: _isLoading
            ? SizedBox(
                width: 24.w,
                height: 24.w,
                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                '确认',
                style: TextStyle(
                  fontSize: 17.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
