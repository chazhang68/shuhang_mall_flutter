import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/app/data/providers/api_provider.dart';
import 'package:shuhang_mall_flutter/app/core/constants/app_images.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/utils/cache.dart';

/// 登录页面 - 优化版本
/// 增强错误处理和用户反馈机制
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final UserProvider _userProvider = Get.find<UserProvider>();

  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  final TextEditingController _payPwdController = TextEditingController();
  final TextEditingController _spreadController = TextEditingController();

  int _currentTab = 0; // 0: 密码登录, 1: 验证码登录, 2: 注册
  bool _protocol = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _logoUrl = '';

  // 验证码倒计时
  int _countdown = 0;
  bool get _canSendCode => _countdown == 0;

  @override
  void initState() {
    super.initState();
    _ensureBackUrl();
    _loadLogo();
  }

  void _ensureBackUrl() {
    final cached = Cache.getString(CacheKey.backUrl) ?? '';
    if (cached.isNotEmpty) {
      return;
    }

    final previousRoute = Get.previousRoute;
    if (previousRoute.isNotEmpty && !previousRoute.contains('/login')) {
      Cache.setString(CacheKey.backUrl, previousRoute);
    }
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    _captchaController.dispose();
    _payPwdController.dispose();
    _spreadController.dispose();
    super.dispose();
  }

  Future<void> _loadLogo() async {
    try {
      final response = await ApiProvider.instance.get(
        'wechat/get_logo',
        noAuth: true,
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 60),
              _buildLogo(),
              const SizedBox(height: 60),
              _buildForm(),
              const SizedBox(height: 40),
              _buildSubmitButton(),
              const SizedBox(height: 20),
              _buildSwitchTabs(),
              const SizedBox(height: 30),
              _buildProtocol(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: ClipOval(
        child: _logoUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: _logoUrl,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[200], width: 120, height: 120),
                errorWidget: (context, url, error) => Image.asset(
                  AppImages.logo,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                AppImages.logo,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInputField(
            controller: _accountController,
            hintText: '输入手机号码',
            prefixIcon: Icons.phone_android,
            keyboardType: TextInputType.phone,
            maxLength: 11,
          ),
          if (_currentTab == 0)
            _buildInputField(
              controller: _passwordController,
              hintText: '填写登录密码',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
          if (_currentTab == 1 || _currentTab == 2)
            _buildInputField(
              controller: _captchaController,
              hintText: '填写验证码',
              prefixIcon: Icons.security,
              keyboardType: TextInputType.number,
              maxLength: 6,
              suffixIcon: TextButton(
                onPressed: _canSendCode ? _sendCode : null,
                child: Text(
                  _canSendCode ? '获取验证码' : '${_countdown}s',
                  style: TextStyle(
                    color: _canSendCode
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          if (_currentTab == 2) ...[
            _buildInputField(
              controller: _passwordController,
              hintText: '填写登录密码',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
            ),
            _buildInputField(
              controller: _payPwdController,
              hintText: '填写6位数字支付密码',
              prefixIcon: Icons.payment,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            _buildInputField(
              controller: _spreadController,
              hintText: '填写邀请码',
              prefixIcon: Icons.card_giftcard,
              maxLength: 8,
            ),
          ],
          if (_currentTab == 0)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => Get.toNamed('/user/retrieve-password'),
                child: const Text(
                  '忘记密码',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),
        ],
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
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          counterText: '',
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    String buttonText = _currentTab == 2 ? '注册' : '登录';
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildSwitchTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_currentTab == 0)
          TextButton(
            onPressed: () => setState(() => _currentTab = 1),
            child: Text(
              '快速登录',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        if (_currentTab == 1)
          TextButton(
            onPressed: () => setState(() => _currentTab = 0),
            child: Text(
              '账号登录',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        if (_currentTab == 2)
          const Text('已有账号', style: TextStyle(color: Colors.grey)),
        const Text(' | ', style: TextStyle(color: Colors.grey)),
        if (_currentTab != 2)
          TextButton(
            onPressed: () => setState(() => _currentTab = 2),
            child: Text(
              '注册',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        if (_currentTab == 2)
          TextButton(
            onPressed: () => setState(() => _currentTab = 0),
            child: Text(
              '去登录',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
      ],
    );
  }

  Widget _buildProtocol() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          value: _protocol,
          onChanged: (value) => setState(() => _protocol = value ?? false),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const Text(
          '已阅读并同意 ',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        GestureDetector(
          onTap: () => Get.toNamed('/user/privacy?type=4'),
          child: Text(
            '《用户协议》',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        const Text(' 与 ', style: TextStyle(fontSize: 12, color: Colors.grey)),
        GestureDetector(
          onTap: () => Get.toNamed('/user/privacy?type=3'),
          child: Text(
            '《隐私协议》',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  /// 发送验证码 - 增强错误处理
  Future<void> _sendCode() async {
    String phone = _accountController.text.trim();

    // 输入验证
    if (phone.isEmpty) {
      _showError('请填写手机号码');
      return;
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      _showError('请输入正确的手机号码');
      return;
    }
    if (!_protocol) {
      _showError('请先阅读并同意协议');
      return;
    }

    try {
      final response = await _userProvider.sendCode(
        phone: phone,
        type: _currentTab == 2 ? 'register' : 'login',
      );

      if (response.isSuccess) {
        _showSuccess(response.msg.isEmpty ? '验证码已发送' : response.msg);
        _startCountdown();
      } else {
        _handleApiError(response);
      }
    } catch (e) {
      _showError('发送验证码失败: ${e.toString()}');
    }
  }

  /// 开始倒计时
  void _startCountdown() {
    setState(() => _countdown = 60);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_countdown > 0) {
        setState(() => _countdown--);
        return true;
      }
      return false;
    });
  }

  /// 提交 - 增强错误处理
  Future<void> _submit() async {
    if (!_protocol) {
      _showError('请先阅读并同意协议');
      return;
    }

    String phone = _accountController.text.trim();
    if (phone.isEmpty) {
      _showError('请填写手机号码');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_currentTab == 0) {
        await _loginWithPassword();
      } else if (_currentTab == 1) {
        await _loginWithCaptcha();
      } else {
        await _register();
      }
    } catch (e) {
      _showError('操作失败: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 密码登录 - 增强错误处理
  Future<void> _loginWithPassword() async {
    String account = _accountController.text.trim();
    String password = _passwordController.text;

    if (password.isEmpty) {
      _showError('请填写密码');
      return;
    }

    try {
      final response = await _userProvider.loginH5(
        account: account,
        password: password,
      );
      if (response.isSuccess) {
        await _handleLoginSuccess(response.data);
      } else {
        _handleApiError(response);
      }
    } catch (e) {
      _showError('登录失败: ${e.toString()}');
    }
  }

  /// 验证码登录 - 增强错误处理
  Future<void> _loginWithCaptcha() async {
    String phone = _accountController.text.trim();
    String captcha = _captchaController.text.trim();

    if (captcha.isEmpty) {
      _showError('请填写验证码');
      return;
    }

    try {
      final response = await _userProvider.loginMobile(
        phone: phone,
        captcha: captcha,
      );
      if (response.isSuccess) {
        await _handleLoginSuccess(response.data);
      } else {
        _handleApiError(response);
      }
    } catch (e) {
      _showError('登录失败: ${e.toString()}');
    }
  }

  /// 注册 - 增强错误处理
  Future<void> _register() async {
    String phone = _accountController.text.trim();
    String captcha = _captchaController.text.trim();
    String password = _passwordController.text;
    String payPwd = _payPwdController.text;
    String spread = _spreadController.text.trim();

    // 验证码检查
    if (captcha.isEmpty) {
      _showError('请填写验证码');
      return;
    }
    if (!RegExp(r'^[\w\d]+$').hasMatch(captcha)) {
      _showError('请输入正确的验证码');
      return;
    }

    // 密码检查
    if (password.isEmpty) {
      _showError('请填写密码');
      return;
    }
    if (RegExp(r'^[0-9a-zA-Z]{0,6}$').hasMatch(password)) {
      _showError('您输入的密码过于简单');
      return;
    }

    // 支付密码检查
    if (payPwd.isEmpty) {
      _showError('请填写支付6位密码');
      return;
    }
    if (payPwd.length != 6) {
      _showError('请填写6位数字支付密码');
      return;
    }

    // 邀请码检查
    if (spread.isEmpty) {
      _showError('请填写邀请码');
      return;
    }

    try {
      final response = await _userProvider.register(
        account: phone,
        captcha: captcha,
        password: password,
        payPwd: payPwd,
        spread: spread,
      );

      if (response.isSuccess) {
        _showSuccess(response.msg.isNotEmpty ? response.msg : '注册成功');
        setState(() => _currentTab = 0);
        _clearForm();
      } else {
        _handleApiError(response);
      }
    } catch (e) {
      _showError('注册失败: ${e.toString()}');
    }
  }

  /// 处理登录成功 - 增强错误处理
  Future<void> _handleLoginSuccess(dynamic data) async {
    if (data == null) {
      _showError('登录失败');
      return;
    }

    final Map<String, dynamic> loginData = data is Map<String, dynamic>
        ? data
        : {};
    final String token = loginData['token']?.toString() ?? '';
    final int expiresTime = loginData['expires_time'] ?? 0;

    if (token.isEmpty) {
      _showError('登录失败，token为空');
      return;
    }

    try {
      // 先保存 token
      final appController = Get.find<AppController>();
      await appController.login(token: token, uid: 0, expiresTime: expiresTime);

      // 短暂延迟确保token生效
      await Future.delayed(const Duration(milliseconds: 100));

      // 获取用户信息
      final userResponse = await _userProvider.getUserInfo();
      if (userResponse.isSuccess && userResponse.data != null) {
        final uid = userResponse.data?.uid ?? 0;

        // 保存完整用户信息
        await appController.login(
          token: token,
          uid: uid,
          userInfo: userResponse.data,
          expiresTime: expiresTime,
        );

        _showSuccess('登录成功');
        _navigateAfterLogin();
      } else {
        await appController.logout();
        _handleApiError(userResponse);
      }
    } catch (e) {
      // 发生错误时回滚
      final appController = Get.find<AppController>();
      await appController.logout();
      _showError('获取用户信息失败: ${e.toString()}');
    }
  }

  /// 登录后跳转
  void _navigateAfterLogin() {
    String backUrl = Cache.getString(CacheKey.backUrl) ?? '';
    Cache.remove(CacheKey.backUrl);

    debugPrint('准备跳转，backUrl: $backUrl');

    // 使用 Future.delayed 确保在当前帧和所有回调完成后再导航
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      debugPrint('开始执行跳转');
      if (backUrl.isEmpty || backUrl.contains('/login')) {
        debugPrint('跳转到主页');
        Get.offAllNamed(AppRoutes.main);
      } else {
        debugPrint('跳转到: $backUrl');
        Get.offAllNamed(backUrl);
      }
    });
  }

  /// 清空表单
  void _clearForm() {
    _captchaController.clear();
    _passwordController.clear();
    _payPwdController.clear();
    _spreadController.clear();
  }

  /// 显示成功消息
  void _showSuccess(String message) {
    FlutterToastPro.showMessage(message, type: 'success');
  }

  /// 显示错误消息
  void _showError(String message) {
    FlutterToastPro.showMessage(message, type: 'error');
  }

  /// 处理API错误
  void _handleApiError(ApiResponse response) {
    String message = response.msg;

    // 根据不同错误码提供更友好的提示
    switch (response.status) {
      case 110002:
      case 110003:
      case 110004:
        message = '登录已过期，请重新登录';
        break;
      case 100103:
        message = response.msg;
        break;
      case 401:
        message = '认证失败，请检查账号密码';
        break;
      case 403:
        message = '权限不足';
        break;
      case 404:
        message = '请求的资源不存在';
        break;
      case 500:
        message = '服务器内部错误';
        break;
      default:
        if (message.isEmpty) {
          message = '操作失败';
        }
    }

    _showError(message);
  }
}
