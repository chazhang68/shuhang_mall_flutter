import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/theme/theme_colors.dart';

/// 钱包页面
/// 对应原 pages/users/user_money/index.vue
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, dynamic> _walletData = {
    'now_money': 1888.88,
    'commission_count': 520.00,
    'integral': 9999,
  };

  final List<Map<String, dynamic>> _billList = [
    {'id': 1, 'title': '购买商品', 'pm': 0, 'number': 199.00, 'add_time': '2024-01-15 10:30:00'},
    {'id': 2, 'title': '充值', 'pm': 1, 'number': 500.00, 'add_time': '2024-01-14 15:20:00'},
    {'id': 3, 'title': '佣金收入', 'pm': 1, 'number': 88.88, 'add_time': '2024-01-13 09:15:00'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        final themeColor = controller.themeColor;

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [_buildHeader(themeColor)];
            },
            body: Column(
              children: [
                // Tab栏
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: themeColor.primary,
                    unselectedLabelColor: const Color(0xFF666666),
                    indicatorColor: themeColor.primary,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: const [
                      Tab(text: '全部'),
                      Tab(text: '收入'),
                      Tab(text: '支出'),
                    ],
                  ),
                ),
                // 账单列表
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBillList(_billList),
                      _buildBillList(_billList.where((e) => e['pm'] == 1).toList()),
                      _buildBillList(_billList.where((e) => e['pm'] == 0).toList()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeColorData themeColor) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: themeColor.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [themeColor.gradientStart, themeColor.gradientEnd],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text('我的余额', style: TextStyle(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 8),
                Text(
                  '¥${(_walletData['now_money'] as double).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                // 操作按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton('充值', Icons.add_circle_outline, () {
                      // 充值
                    }),
                    const SizedBox(width: 50),
                    _buildActionButton('提现', Icons.arrow_circle_up_outlined, () {
                      Get.toNamed(AppRoutes.userCash);
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      title: const Text('我的钱包'),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.2 * 255).round()),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildBillList(List<Map<String, dynamic>> bills) {
    if (bills.isEmpty) {
      return const Center(
        child: Text('暂无记录', style: TextStyle(fontSize: 14, color: Color(0xFF999999))),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: bills.length,
      itemBuilder: (context, index) {
        return _buildBillItem(bills[index]);
      },
    );
  }

  Widget _buildBillItem(Map<String, dynamic> bill) {
    final isIncome = bill['pm'] == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          // 图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isIncome
                  ? const Color(0xFF4CAF50).withAlpha((0.1 * 255).round())
                  : const Color(0xFFF44336).withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              size: 20,
              color: isIncome ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
            ),
          ),
          const SizedBox(width: 12),
          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill['title'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 4),
                Text(
                  bill['add_time'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                ),
              ],
            ),
          ),
          // 金额
          Text(
            '${isIncome ? '+' : '-'}¥${(bill['number'] as double).toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isIncome ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
            ),
          ),
        ],
      ),
    );
  }
}
