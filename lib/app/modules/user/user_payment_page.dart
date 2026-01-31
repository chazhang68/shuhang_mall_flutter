import 'package:flutter/material.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import '../../data/providers/user_provider.dart';
import '../../theme/theme_colors.dart';

class UserPaymentPage extends StatefulWidget {
  const UserPaymentPage({super.key});

  @override
  State<UserPaymentPage> createState() => _UserPaymentPageState();
}

class _UserPaymentPageState extends State<UserPaymentPage> {
  final UserProvider _userProvider = UserProvider();
  final TextEditingController _customAmountController = TextEditingController();

  double _balance = 0;
  List<Map<String, dynamic>> _picList = [];
  int _activePic = 0;
  String _selectedAmount = '';
  int _recharId = 0;
  List<String> _rechargeAttention = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    _getRechargeList();
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  Future<void> _getUserInfo() async {
    final response = await _userProvider.getUserInfo();
    if (response.isSuccess && response.data != null) {
      setState(() {
        _balance = response.data!.balance;
      });
    }
  }

  Future<void> _getRechargeList() async {
    final response = await _userProvider.getRechargeApi();
    if (response.isSuccess && response.data != null) {
      List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
        response.data['recharge_quota'] ?? [],
      );
      List<String> attention = List<String>.from(response.data['recharge_attention'] ?? []);

      setState(() {
        _picList = list;
        _rechargeAttention = attention;
        if (list.isNotEmpty) {
          _selectedAmount = list[0]['price'].toString();
          _recharId = list[0]['id'] ?? 0;
        }
      });
    }
  }

  void _selectAmount(int index, Map<String, dynamic>? item) {
    setState(() {
      _activePic = index;
      if (item != null) {
        _selectedAmount = item['price'].toString();
        _recharId = item['id'] ?? 0;
        _customAmountController.clear();
      } else {
        _selectedAmount = '';
        _recharId = 0;
      }
    });
  }

  void _onCustomAmountChanged(String value) {
    setState(() {
      _activePic = _picList.length;
      _selectedAmount = value;
      _recharId = 0;
    });
  }

  Future<void> _submitRecharge() async {
    final bool isPackageSelected = _recharId > 0;
    String amount = isPackageSelected ? _selectedAmount : _customAmountController.text;

    if (amount.isEmpty || double.tryParse(amount) == null || double.parse(amount) <= 0) {
      FlutterToastPro.showMessage('请选择或输入充值金额');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: 调用充值接口并处理支付
    FlutterToastPro.showMessage('充值功能开发中，请联系客服');

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ThemeColors.red.primary, ThemeColors.red.primary.withAlpha((0.8 * 255).round())],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Text(
            '我的余额',
            style: TextStyle(fontSize: 14, color: Colors.white.withAlpha((0.8 * 255).round())),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('¥', style: TextStyle(fontSize: 24, color: Colors.white)),
              Text(
                _balance.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('选择充值金额', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: _picList.length + 1,
            itemBuilder: (context, index) {
              if (index < _picList.length) {
                Map<String, dynamic> item = _picList[index];
                bool isActive = _activePic == index;
                double price = double.tryParse(item['price'].toString()) ?? 0;
                double giveMoney = double.tryParse(item['give_money'].toString()) ?? 0;

                return GestureDetector(
                  onTap: () => _selectAmount(index, item),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isActive
                          ? ThemeColors.red.primary.withAlpha((0.1 * 255).round())
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isActive ? ThemeColors.red.primary : Colors.grey[300]!,
                        width: isActive ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${price.toInt()}元',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isActive ? ThemeColors.red.primary : Colors.black87,
                          ),
                        ),
                        if (giveMoney > 0)
                          Text(
                            '赠送${giveMoney.toInt()}元',
                            style: TextStyle(
                              fontSize: 11,
                              color: isActive ? ThemeColors.red.primary : Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              } else {
                // 自定义金额
                bool isActive = _activePic == _picList.length;
                return GestureDetector(
                  onTap: () => _selectAmount(_picList.length, null),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isActive
                          ? ThemeColors.red.primary.withAlpha((0.1 * 255).round())
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isActive ? ThemeColors.red.primary : Colors.grey[300]!,
                        width: isActive ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _customAmountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: _onCustomAmountChanged,
                      decoration: InputDecoration(
                        hintText: '其他',
                        hintStyle: TextStyle(
                          color: isActive ? ThemeColors.red.primary : Colors.grey[500],
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isActive ? ThemeColors.red.primary : Colors.black87,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttention() {
    if (_rechargeAttention.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('注意事项：', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._rechargeAttention.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(item, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('充值'),
        centerTitle: true,
        backgroundColor: ThemeColors.red.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildAmountGrid(),
            _buildAttention(),

            const SizedBox(height: 40),

            // 充值按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRecharge,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.red.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  ),
                  child: Text(
                    _isLoading ? '处理中...' : '立即充值',
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
