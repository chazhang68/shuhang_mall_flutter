import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/user_provider.dart';
import '../../theme/theme_colors.dart';

/// 提现页面 - 对应 pages/users/user_cash/index.vue
class WithdrawPage extends StatefulWidget {
  const WithdrawPage({super.key});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final UserProvider _userProvider = UserProvider();

  // 表单控制器
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardNumController = TextEditingController();
  final TextEditingController _moneyController = TextEditingController();

  // 提现方式导航
  List<Map<String, dynamic>> navList = [];
  int currentTab = 0;

  // 银行列表
  List<String> bankList = ['请选择银行'];
  int selectedBankIndex = 0;

  // 最低提现金额
  double minPrice = 0.00;

  // 用户信息
  Map<String, dynamic> userInfo = {};

  // 收款码
  String qrcodeUrlW = '';
  String qrcodeUrlZ = '';

  // 是否正在提交
  bool isSubmitting = false;

  // 佣金到账方式
  int brokerageType = 0;

  bool isLoading = true;

  Color get _primaryColor => ThemeColors.red.primary;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumController.dispose();
    _moneyController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([_getUserInfo(), _getExtractBank()]);
    setState(() {
      isLoading = false;
    });
  }

  /// 获取用户信息
  Future<void> _getUserInfo() async {
    try {
      final response = await _userProvider.getSpreadInfo();
      if (response.isSuccess && response.data != null) {
        setState(() {
          userInfo = response.data as Map<String, dynamic>;

          // 设置提现方式导航
          navList = [
            {'name': '银行卡', 'icon': Icons.credit_card, 'id': 0},
            {'name': '微信', 'icon': Icons.wechat, 'id': 1},
            {'name': '支付宝', 'icon': Icons.account_balance_wallet, 'id': 2},
          ];

          // 根据extract_type筛选可用的提现方式
          final extractType = userInfo['extract_type'] as List?;
          if (extractType != null && extractType.isNotEmpty) {
            navList = navList.where((item) {
              return extractType.contains(item['id']);
            }).toList();
          }

          if (navList.isNotEmpty) {
            currentTab = navList[0]['id'];
          }
        });
      }
    } catch (e) {
      // ignore
    }
  }

  /// 获取提现银行信息
  Future<void> _getExtractBank() async {
    try {
      final response = await _userProvider.extractBank();
      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final banks = (data['extractBank'] as List?)?.cast<String>() ?? [];
        setState(() {
          bankList = ['请选择银行', ...banks];
          minPrice = double.tryParse(data['minPrice']?.toString() ?? '0') ?? 0;
          brokerageType = int.tryParse(data['brokerageType']?.toString() ?? '0') ?? 0;
        });
      }
    } catch (e) {
      // ignore
    }
  }

  /// 切换提现方式
  void _switchNav(int tabId) {
    setState(() {
      currentTab = tabId;
      _clearForm();
    });
  }

  /// 清空表单
  void _clearForm() {
    _nameController.clear();
    _cardNumController.clear();
    _moneyController.clear();
    selectedBankIndex = 0;
  }

  /// 提交提现申请
  Future<void> _submitCash() async {
    if (isSubmitting) return;

    Map<String, dynamic> data = {};

    // 验证并收集表单数据
    switch (currentTab) {
      case 0: // 银行卡
        if (_nameController.text.trim().isEmpty) {
          Get.snackbar('提示', '请填写持卡人姓名');
          return;
        }
        if (_cardNumController.text.trim().isEmpty) {
          Get.snackbar('提示', '请填写卡号');
          return;
        }
        if (selectedBankIndex == 0) {
          Get.snackbar('提示', '请选择银行');
          return;
        }
        data = {
          'extract_type': 'bank',
          'name': _nameController.text.trim(),
          'cardnum': _cardNumController.text.trim(),
          'bankname': bankList[selectedBankIndex],
          'money': _moneyController.text.trim(),
        };
        break;
      case 1: // 微信
        if (brokerageType == 0 && _nameController.text.trim().isEmpty) {
          Get.snackbar('提示', '请填写微信号');
          return;
        }
        data = {
          'extract_type': 'weixin',
          'name': _nameController.text.trim(),
          'weixin': _nameController.text.trim(),
          'qrcode_url': qrcodeUrlW,
          'money': _moneyController.text.trim(),
        };
        break;
      case 2: // 支付宝
        if (_nameController.text.trim().isEmpty) {
          Get.snackbar('提示', '请填写支付宝账号');
          return;
        }
        data = {
          'extract_type': 'alipay',
          'name': _nameController.text.trim(),
          'alipay_code': _nameController.text.trim(),
          'qrcode_url': qrcodeUrlZ,
          'money': _moneyController.text.trim(),
        };
        break;
    }

    // 验证金额
    if (_moneyController.text.trim().isEmpty) {
      Get.snackbar('提示', '请填写提现金额');
      return;
    }
    final money = double.tryParse(_moneyController.text.trim()) ?? 0;
    if (money < minPrice) {
      Get.snackbar('提示', '提现金额不能低于$minPrice');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final response = await _userProvider.extractCash(data);
      if (response.isSuccess) {
        Get.snackbar('成功', response.msg);
        await _getUserInfo();
        Get.offNamed('/spread/user');
      } else {
        Get.snackbar('错误', response.msg);
      }
    } catch (e) {
      Get.snackbar('错误', '提现失败');
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('提现'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildNavBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(15),
                    child: _buildForm(),
                  ),
                ),
              ],
            ),
    );
  }

  /// 导航栏
  Widget _buildNavBar() {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.1 * 255).round()),
            blurRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: navList.map((item) {
          final isActive = currentTab == item['id'];
          return Expanded(
            child: GestureDetector(
              onTap: () => _switchNav(item['id']),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: item['id'] != navList.first['id']
                        ? const BorderSide(color: Color(0xFFF0F0F0))
                        : BorderSide.none,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 顶部线条
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 2,
                      height: isActive ? 20 : 10,
                      color: _primaryColor,
                    ),
                    const SizedBox(height: 3),
                    // 图标
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isActive ? _primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _primaryColor),
                      ),
                      child: Icon(
                        item['icon'],
                        size: 12,
                        color: isActive ? Colors.white : _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    // 文字
                    Text(item['name'], style: TextStyle(fontSize: 13, color: _primaryColor)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 表单
  Widget _buildForm() {
    switch (currentTab) {
      case 0:
        return _buildBankForm();
      case 1:
        return _buildWechatForm();
      case 2:
        return _buildAlipayForm();
      default:
        return const SizedBox.shrink();
    }
  }

  /// 银行卡表单
  Widget _buildBankForm() {
    return Column(
      children: [
        _buildTextField(label: '持卡人', hint: '请输入持卡人姓名', controller: _nameController),
        _buildTextField(
          label: '卡号',
          hint: '请填写卡号',
          controller: _cardNumController,
          keyboardType: TextInputType.number,
        ),
        _buildBankPicker(),
        _buildTextField(
          label: '提现',
          hint: '最低提现金额$minPrice',
          controller: _moneyController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        _buildTip(),
        _buildSubmitButton(),
      ],
    );
  }

  /// 微信表单
  Widget _buildWechatForm() {
    return Column(
      children: [
        if (brokerageType == 0)
          _buildTextField(label: '账号', hint: '请填写您的微信账号', controller: _nameController),
        _buildTextField(
          label: '提现',
          hint: '最低提现金额$minPrice',
          controller: _moneyController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        if (brokerageType == 0) _buildQrCodeUpload(isWechat: true),
        _buildTip(),
        _buildSubmitButton(),
      ],
    );
  }

  /// 支付宝表单
  Widget _buildAlipayForm() {
    return Column(
      children: [
        _buildTextField(label: '账号', hint: '请填写您的支付宝账号', controller: _nameController),
        _buildTextField(
          label: '提现',
          hint: '最低提现金额$minPrice',
          controller: _moneyController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        _buildQrCodeUpload(isWechat: false),
        _buildTip(),
        _buildSubmitButton(),
      ],
    );
  }

  /// 文本输入框
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 65,
            child: Text(label, style: const TextStyle(fontSize: 15, color: Color(0xFF333333))),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 银行选择器
  Widget _buildBankPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 65,
            child: Text('银行', style: TextStyle(fontSize: 15, color: Color(0xFF333333))),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _showBankPicker(),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      bankList[selectedBankIndex],
                      style: TextStyle(
                        fontSize: 15,
                        color: selectedBankIndex == 0
                            ? const Color(0xFFBBBBBB)
                            : const Color(0xFF333333),
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Color(0xFF999999)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示银行选择器
  void _showBankPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: bankList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(bankList[index]),
                onTap: () {
                  setState(() {
                    selectedBankIndex = index;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  /// 收款码上传
  Widget _buildQrCodeUpload({required bool isWechat}) {
    final qrcodeUrl = isWechat ? qrcodeUrlW : qrcodeUrlZ;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 65,
            child: Text('收款码', style: TextStyle(fontSize: 15, color: Color(0xFF333333))),
          ),
          if (qrcodeUrl.isNotEmpty)
            Stack(
              children: [
                Image.network(qrcodeUrl, width: 70, height: 70, fit: BoxFit.cover),
                Positioned(
                  right: -7,
                  top: -8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isWechat) {
                          qrcodeUrlW = '';
                        } else {
                          qrcodeUrlZ = '';
                        }
                      });
                    },
                    child: Icon(Icons.cancel, color: _primaryColor, size: 20),
                  ),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: () {
                // TODO: 实现图片上传
                Get.snackbar('提示', '图片上传功能开发中');
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFDDDDDD)),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, size: 24, color: Color(0xFFDDDDDD)),
                    SizedBox(height: 3),
                    Text('上传图片', style: TextStyle(fontSize: 11, color: Color(0xFFBBBBBB))),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 提示信息
  Widget _buildTip() {
    final commissionCount = userInfo['commissionCount'] ?? '0.00';
    final brokenCommission = userInfo['broken_commission'] ?? '0.00';
    final brokenDay = userInfo['broken_day'] ?? 0;

    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
              children: [
                const TextSpan(text: '当前可提现金额: '),
                TextSpan(
                  text: '￥$commissionCount',
                  style: TextStyle(color: _primaryColor),
                ),
                TextSpan(text: ', 冻结佣金：￥$brokenCommission'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '说明: 每笔佣金的冻结期为$brokenDay天，到期后可提现',
            style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }

  /// 提交按钮
  Widget _buildSubmitButton() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _submitCash,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text('提现', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}
