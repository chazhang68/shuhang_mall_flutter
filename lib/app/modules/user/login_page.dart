import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/app/data/providers/api_provider.dart';
import 'package:shuhang_mall_flutter/app/core/constants/app_images.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/utils/cache.dart';

/// 登录页面
/// 对应原 pages/users/login/index.vue
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
  bool _rememberAccount = false; // 是否记住账号

  // 验证码倒计时
  int _countdown = 0;

  bool get _canSendCode => _countdown == 0;

  final AppController appController = Get.find<AppController>();

  @override
  void initState() {
    super.initState();
    _loadLogo();
    _loadRememberedAccount();
  }

  /// 加载记住的账号
  void _loadRememberedAccount() {
    final rememberAccount = Cache.getBool(CacheKey.rememberAccount) ?? false;
    final rememberedAccount = Cache.getString(CacheKey.rememberedAccount) ?? '';

    setState(() {
      _rememberAccount = rememberAccount;
      if (rememberAccount && rememberedAccount.isNotEmpty) {
        _accountController.text = rememberedAccount;
      }
    });
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
    // 从接口获取 Logo，对应 uni-app: getLogo() -> wechat/get_logo
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: appController.isLogin,
      onPopInvokedWithResult: (canPop, result) {
        if (!canPop) {
          FlutterToastPro.showWaringMessage('请登录后返回');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text('登录'), backgroundColor: Colors.grey[50]),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 30.h),
              // Logo
              _buildLogo(),
              SizedBox(height: 50.h),
              // 表单
              _buildForm(),
              SizedBox(height: 30.h),
              // 登录/注册按钮
              _buildSubmitButton(),
              // 切换登录/注册
              _buildSwitchTabs(),
              // 协议
              _buildProtocol(),
            ],
          ),
        ),
      ),
    );
  }

  /// Logo
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
                errorWidget: (context, url, error) =>
                    Image.asset(AppImages.logo, width: 120, height: 120, fit: BoxFit.cover),
              )
            : Image.asset(AppImages.logo, width: 120, height: 120, fit: BoxFit.cover),
      ),
    );
  }

  /// 表单
  Widget _buildForm() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // 手机号
          _buildInputField(
            controller: _accountController,
            hintText: '输入手机号码',
            prefixIcon: Icons.phone_android,
            keyboardType: TextInputType.phone,
            maxLength: 11,
          ),

          // 密码登录时显示密码
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
                  size: 20.sp,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),

          // 验证码登录或注册时显示验证码
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
                    color: _canSendCode ? Theme.of(context).primaryColor : Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

          // 注册时额外显示密码和支付密码
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

          // 忘记密码
          if (_currentTab == 0)
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Get.toNamed('/user/retrieve-password'),
                child: Row(
                  spacing: 2.w,
                  children: [
                    Icon(CupertinoIcons.question_circle, size: 16.sp),
                    Text('忘记密码', style: TextStyle(fontSize: 14.sp)),
                  ],
                ),
              ),
            ),

          /*        // 记住账号（仅在登录时显示）
          if (_currentTab != 2)
            Row(
              children: [
                Checkbox(
                  value: _rememberAccount,
                  onChanged: (value) => setState(() => _rememberAccount = value ?? false),
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  visualDensity: .compact,
                ),
                const Text('记住账号', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),*/
        ],
      ),
    );
  }

  /// 输入框
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
      margin: EdgeInsets.only(bottom: 12.h),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLength: maxLength,
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          prefixIcon: Icon(prefixIcon, color: Colors.grey, size: 20.sp),
          prefixIconConstraints: BoxConstraints(maxWidth: 36.w, maxHeight: 36.w),
          suffixIcon: suffixIcon,
          suffixIconConstraints: BoxConstraints(maxWidth: 36.w, maxHeight: 36.w),
          filled: false,
          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade200)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          counterText: '',
        ),
      ),
    );
  }

  /// 提交按钮
  Widget _buildSubmitButton() {
    String buttonText = _currentTab == 2 ? '注册' : '登录';
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24.w,
                height: 24.w,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                buttonText,
                style: TextStyle(fontSize: 15.sp, color: Colors.white),
              ),
      ),
    );
  }

  /// 切换登录/注册
  Widget _buildSwitchTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_currentTab == 0)
          TextButton(
            onPressed: () => setState(() => _currentTab = 1),
            child: Text('快速登录', style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
        if (_currentTab == 1)
          TextButton(
            onPressed: () => setState(() => _currentTab = 0),
            child: Text('账号登录', style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
        if (_currentTab == 2) const Text('已有账号', style: TextStyle(color: Colors.grey)),
        const Text(' | ', style: TextStyle(color: Colors.grey)),
        if (_currentTab != 2)
          TextButton(
            onPressed: () => setState(() => _currentTab = 2),
            child: Text('注册', style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
        if (_currentTab == 2)
          TextButton(
            onPressed: () => setState(() => _currentTab = 0),
            child: Text('去登录', style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
      ],
    );
  }

  /// 协议
  Widget _buildProtocol() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          value: _protocol,
          onChanged: (value) => setState(() => _protocol = value ?? false),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          hoverColor: Colors.grey,
        ),
        const Text('已阅读并同意 ', style: TextStyle(fontSize: 12, color: Colors.grey)),
        GestureDetector(
          onTap: () => Get.toNamed('/user/privacy?type=4'),
          child: Text(
            '《用户协议》',
            style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor),
          ),
        ),
        const Text(' 与 ', style: TextStyle(fontSize: 12, color: Colors.grey)),
        GestureDetector(
          onTap: () => Get.toNamed('/user/privacy?type=3'),
          child: Text(
            '《隐私协议》',
            style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor),
          ),
        ),
      ],
    );
  }

  /// 发送验证码
  Future<void> _sendCode() async {
    String phone = _accountController.text.trim();
    if (phone.isEmpty) {
      FlutterToastPro.showMessage('请填写手机号码');
      return;
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      FlutterToastPro.showMessage('请输入正确的手机号码');
      return;
    }
    if (!_protocol) {
      FlutterToastPro.showMessage('请先阅读并同意协议');
      return;
    }

    final response = await _userProvider.sendCode(
      phone: phone,
      type: _currentTab == 2 ? 'register' : 'login',
    );
    if (response.isSuccess) {
      FlutterToastPro.showMessage(response.msg);
      _startCountdown();
    } else {
      FlutterToastPro.showMessage(response.msg);
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

  /// 提交
  Future<void> _submit() async {
    if (!_protocol) {
      FlutterToastPro.showMessage('请先阅读并同意协议');
      return;
    }

    String phone = _accountController.text.trim();
    if (phone.isEmpty) {
      FlutterToastPro.showMessage('请填写手机号码');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_currentTab == 0) {
        // 密码登录
        await _loginWithPassword();
      } else if (_currentTab == 1) {
        // 验证码登录
        await _loginWithCaptcha();
      } else {
        // 注册
        await _register();
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 密码登录
  Future<void> _loginWithPassword() async {
    String account = _accountController.text.trim();
    String password = _passwordController.text;

    if (password.isEmpty) {
      FlutterToastPro.showMessage('请填写密码');
      return;
    }

    final response = await _userProvider.loginH5(account: account, password: password);
    if (response.isSuccess) {
      // 保存记住账号的设置
      await _saveRememberedAccount(account);
      _handleLoginSuccess(response.data);
    } else {
      FlutterToastPro.showMessage(response.msg);
    }
  }

  /// 验证码登录
  Future<void> _loginWithCaptcha() async {
    String phone = _accountController.text.trim();
    String captcha = _captchaController.text.trim();

    if (captcha.isEmpty) {
      FlutterToastPro.showMessage('请填写验证码');
      return;
    }

    final response = await _userProvider.loginMobile(phone: phone, captcha: captcha);
    if (response.isSuccess) {
      // 保存记住账号的设置
      await _saveRememberedAccount(phone);
      _handleLoginSuccess(response.data);
    } else {
      FlutterToastPro.showMessage(response.msg);
    }
  }

  /// 保存记住的账号
  Future<void> _saveRememberedAccount(String account) async {
    await Cache.setBool(CacheKey.rememberAccount, _rememberAccount);
    if (_rememberAccount) {
      await Cache.setString(CacheKey.rememberedAccount, account);
    } else {
      await Cache.remove(CacheKey.rememberedAccount);
    }
  }

  /// 注册
  /// 对应 uni-app: async register()
  Future<void> _register() async {
    String phone = _accountController.text.trim();
    String captcha = _captchaController.text.trim();
    String password = _passwordController.text;
    String payPwd = _payPwdController.text;
    String spread = _spreadController.text.trim();

    // 验证码检查
    if (captcha.isEmpty) {
      FlutterToastPro.showMessage('请填写验证码');
      return;
    }
    // 对应 uni-app: /^[\w\d]+$/i
    if (!RegExp(r'^[\w\d]+$').hasMatch(captcha)) {
      FlutterToastPro.showMessage('请输入正确的验证码');
      return;
    }

    // 密码检查
    if (password.isEmpty) {
      FlutterToastPro.showMessage('请填写密码');
      return;
    }
    // 对应 uni-app: /^([0-9]|[a-z]|[A-Z]){0,6}$/i 密码复杂度检查
    // 如果密码只包含数字或字母且长度<=6，则认为太简单
    if (RegExp(r'^[0-9a-zA-Z]{0,6}$').hasMatch(password)) {
      FlutterToastPro.showMessage('您输入的密码过于简单');
      return;
    }

    // 支付密码检查
    if (payPwd.isEmpty) {
      FlutterToastPro.showMessage('请填写支付6位密码');
      return;
    }
    if (payPwd.length != 6) {
      FlutterToastPro.showMessage('请填写6位数字支付密码');
      return;
    }

    // 邀请码检查
    if (spread.isEmpty) {
      FlutterToastPro.showMessage('请填写邀请码');
      return;
    }

    final response = await _userProvider.register(
      account: phone,
      captcha: captcha,
      password: password,
      payPwd: payPwd,
      spread: spread,
    );

    if (response.isSuccess) {
      FlutterToastPro.showMessage(response.msg.isNotEmpty ? response.msg : '注册成功');
      // 对应 uni-app: that.current = 0 注册成功后切换到登录
      setState(() => _currentTab = 0);
      // 清空表单
      _captchaController.clear();
      _passwordController.clear();
      _payPwdController.clear();
      _spreadController.clear();
    } else {
      FlutterToastPro.showMessage(response.msg);
    }
  }

  /// 处理登录成功
  /// 对应 uni-app: loginMobile/submit 成功回调
  Future<void> _handleLoginSuccess(dynamic data) async {
    if (data == null) {
      FlutterToastPro.showMessage('登录失败');
      return;
    }

    final Map<String, dynamic> loginData = data is Map<String, dynamic> ? data : {};
    final String token = loginData['token']?.toString() ?? '';
    final int expiresTime = loginData['expires_time'] ?? 0;

    if (token.isEmpty) {
      FlutterToastPro.showMessage('登录失败，token为空');
      return;
    }

    // 获取 AppController
    final appController = Get.find<AppController>();

    // 先保存 token，确保后续请求携带鉴权
    await appController.login(token: token, uid: 0, expiresTime: expiresTime);

    // 获取用户信息（登录态依赖 token + userInfo）
    try {
      final userResponse = await _userProvider.getUserInfo();
      if (userResponse.isSuccess && userResponse.data != null) {
        final uid = userResponse.data?.uid ?? 0;

        // 保存完整用户信息到 AppController
        await appController.login(
          token: token,
          uid: uid,
          userInfo: userResponse.data,
          expiresTime: expiresTime,
        );
        Get.back();
      } else {
        await appController.logout();
        FlutterToastPro.showMessage('获取用户信息失败');
      }
    } catch (e) {
      debugPrint('获取用户信息失败: $e');
      await appController.logout();
      FlutterToastPro.showMessage('获取用户信息失败');
    }
  }
}
