import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/providers/user_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme_colors.dart';

class UserSpreadPage extends StatefulWidget {
  const UserSpreadPage({super.key});

  @override
  State<UserSpreadPage> createState() => _UserSpreadPageState();
}

class _UserSpreadPageState extends State<UserSpreadPage> {
  final UserProvider _userProvider = UserProvider();

  Map<String, dynamic> _userInfo = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    final response = await _userProvider.getUserInfo();
    if (response.isSuccess && response.data != null) {
      final user = response.data!;
      setState(() {
        _userInfo = {
          'avatar': user.avatar,
          'nickname': user.nickname,
          'brokerage_price': user.brokeragePrice,
          'yesterDay': user.extra?['yesterDay'] ?? 0,
          'extractTotalPrice': user.extra?['extractTotalPrice'] ?? 0,
          'is_agent_level': user.extra?['is_agent_level'] ?? false,
          'agent_level_name': user.extra?['agent_level_name'] ?? '',
        };
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildHeader() {
    String avatar = _userInfo['avatar'] ?? '';
    String nickname = _userInfo['nickname'] ?? '';
    double brokeragePrice = double.tryParse(_userInfo['brokerage_price']?.toString() ?? '0') ?? 0;
    double yesterDay = double.tryParse(_userInfo['yesterDay']?.toString() ?? '0') ?? 0;
    double extractTotal = double.tryParse(_userInfo['extractTotalPrice']?.toString() ?? '0') ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ThemeColors.red.primary, ThemeColors.red.primary.withAlpha((0.8 * 255).round())],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // 用户信息
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: CachedNetworkImage(
                  imageUrl: avatar,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nickname,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (_userInfo['is_agent_level'] == true)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.2 * 255).round()),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _userInfo['agent_level_name'] ?? '分销等级',
                        style: const TextStyle(fontSize: 11, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 当前佣金
          Text(
            brokeragePrice.toStringAsFixed(2),
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
          ),

          const SizedBox(height: 24),

          // 统计信息
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('昨日收益', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(
                      yesterDay.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed('/user/spread-money?type=1'),
                child: Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('累积已提', style: TextStyle(fontSize: 12, color: Colors.white70)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white70),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        extractTotal.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Get.toNamed(AppRoutes.userCash),
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColors.red.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          ),
          child: const Text('立即提现', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.qr_code, 'name': '推广名片', 'route': '/user/spread-code'},
      {'icon': Icons.bar_chart, 'name': '推广人统计', 'route': '/user/promoter-list'},
      {'icon': Icons.account_balance_wallet, 'name': '佣金明细', 'route': '/user/spread-money?type=2'},
      {'icon': Icons.receipt_long, 'name': '推广人订单', 'route': '/user/promoter-order'},
      {'icon': Icons.emoji_events, 'name': '推广人排行', 'route': '/user/promoter-rank'},
      {'icon': Icons.leaderboard, 'name': '佣金排行', 'route': '/user/commission-rank'},
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> item = menuItems[index];
          return GestureDetector(
            onTap: () => Get.toNamed(item['route']),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: ThemeColors.red.primary.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(item['icon'], size: 24, color: ThemeColors.red.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  item['name'],
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('分销中心'),
          centerTitle: true,
          backgroundColor: ThemeColors.red.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('分销中心'),
        centerTitle: true,
        backgroundColor: ThemeColors.red.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(children: [_buildHeader(), _buildWithdrawButton(), _buildMenuGrid()]),
      ),
    );
  }
}
