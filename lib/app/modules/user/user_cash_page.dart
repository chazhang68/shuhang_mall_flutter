import 'package:flutter/material.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import '../../data/providers/user_provider.dart';
import '../../theme/theme_colors.dart';

class UserCashPage extends StatefulWidget {
  const UserCashPage({super.key});

  @override
  State<UserCashPage> createState() => _UserCashPageState();
}

class _UserCashPageState extends State<UserCashPage> {
  final UserProvider _userProvider = UserProvider();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardNumController = TextEditingController();
  final TextEditingController _moneyController = TextEditingController();

  int _currentTab = 0;
  List<String> _bankList = [];
  int _selectedBankIndex = 0;
  double _minPrice = 0;
  double _commissionCount = 0;
  double _brokenCommission = 0;
  int _brokenDay = 0;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _navList = [
    {'id': 0, 'name': '银行卡', 'icon': Icons.credit_card},
    {'id': 1, 'name': '微信', 'icon': Icons.chat_bubble},
    {'id': 2, 'name': '支付宝', 'icon': Icons.account_balance_wallet},
  ];

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    _getExtractBank();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumController.dispose();
    _moneyController.dispose();
    super.dispose();
  }

  Future<void> _getUserInfo() async {
    final response = await _userProvider.getUserInfo();
    if (response.isSuccess && response.data != null) {
      final user = response.data!;
      setState(() {
        _commissionCount = user.extra?['commissionCount'] ?? 0;
        _brokenCommission = user.extra?['broken_commission'] ?? 0;
        _brokenDay = user.extra?['broken_day'] ?? 0;
      });
    }
  }

  Future<void> _getExtractBank() async {
    final response = await _userProvider.extractBank();
    if (response.isSuccess && response.data != null) {
      setState(() {
        _bankList = List<String>.from(response.data['extractBank'] ?? []);
        _minPrice = double.tryParse(response.data['minPrice']?.toString() ?? '0') ?? 0;
      });
    }
  }

  void _switchTab(int id) {
    setState(() {
      _currentTab = id;
    });
  }

  Future<void> _submitCash() async {
    String name = _nameController.text.trim();
    String money = _moneyController.text.trim();

    if (name.isEmpty) {
      FlutterToastPro.showMessage('请填写姓名/账号');
      return;
    }

    if (money.isEmpty) {
      FlutterToastPro.showMessage('请填写提现金额');
      return;
    }

    double moneyAmount = double.tryParse(money) ?? 0;
    if (moneyAmount < _minPrice) {
      FlutterToastPro.showMessage('最低提现金额为$_minPrice元');
      return;
    }

    if (moneyAmount > _commissionCount) {
      FlutterToastPro.showMessage('可提现金额不足');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    Map<String, dynamic> data = {
      'extract_type': _currentTab == 0 ? 'bank' : (_currentTab == 1 ? 'weixin' : 'alipay'),
      'money': money,
      'name': name,
    };

    if (_currentTab == 0) {
      String cardNum = _cardNumController.text.trim();
      if (cardNum.isEmpty) {
        FlutterToastPro.showMessage('请填写银行卡号');
        setState(() {
          _isSubmitting = false;
        });
        return;
      }
      data['cardnum'] = cardNum;
      data['bankname'] = _bankList.isNotEmpty ? _bankList[_selectedBankIndex] : '';
    }

    final response = await _userProvider.extractCash(data);

    setState(() {
      _isSubmitting = false;
    });

    if (response.isSuccess) {
      FlutterToastPro.showMessage('提现申请成功');
      _nameController.clear();
      _cardNumController.clear();
      _moneyController.clear();
      _getUserInfo();
    } else {
      FlutterToastPro.showMessage(response.msg);
    }
  }

  Widget _buildNavBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _navList.map((nav) {
          bool isActive = _currentTab == nav['id'];
          return GestureDetector(
            onTap: () => _switchTab(nav['id']),
            child: Column(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive ? ThemeColors.red.primary : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 8),
                Icon(
                  nav['icon'],
                  size: 32,
                  color: isActive ? ThemeColors.red.primary : Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  nav['name'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isActive ? ThemeColors.red.primary : Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBankForm() {
    return Column(
      children: [
        _buildInputField('持卡人', _nameController, '请输入持卡人姓名'),
        _buildInputField('卡号', _cardNumController, '请填写卡号', keyboardType: TextInputType.number),
        _buildBankPicker(),
        _buildInputField(
          '提现',
          _moneyController,
          '最低提现金额$_minPrice',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildWechatForm() {
    return Column(
      children: [
        _buildInputField('账号', _nameController, '请填写您的微信账号'),
        _buildInputField(
          '提现',
          _moneyController,
          '最低提现金额$_minPrice',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildAlipayForm() {
    return Column(
      children: [
        _buildInputField('账号', _nameController, '请填写您的支付宝账号'),
        _buildInputField(
          '提现',
          _moneyController,
          '最低提现金额$_minPrice',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(label, style: const TextStyle(fontSize: 14))),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[400]),
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

  Widget _buildBankPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 60, child: Text('银行', style: TextStyle(fontSize: 14))),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_bankList.isEmpty) return;
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    height: 300,
                    padding: const EdgeInsets.all(16),
                    child: ListView.builder(
                      itemCount: _bankList.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(_bankList[index]),
                        onTap: () {
                          setState(() {
                            _selectedBankIndex = index;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _bankList.isNotEmpty ? _bankList[_selectedBankIndex] : '请选择银行',
                    style: TextStyle(
                      color: _bankList.isNotEmpty ? Colors.black87 : Colors.grey[400],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTips() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              children: [
                const TextSpan(text: '当前可提现金额: '),
                TextSpan(
                  text: '¥$_commissionCount',
                  style: TextStyle(color: ThemeColors.red.primary),
                ),
                TextSpan(text: ', 冻结佣金: ¥$_brokenCommission'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '说明: 每笔佣金的冻结期为$_brokenDay天，到期后可提现',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('提现'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNavBar(),

            const SizedBox(height: 12),

            if (_currentTab == 0) _buildBankForm(),
            if (_currentTab == 1) _buildWechatForm(),
            if (_currentTab == 2) _buildAlipayForm(),

            _buildTips(),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitCash,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.red.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  ),
                  child: Text(
                    _isSubmitting ? '处理中...' : '提现',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
