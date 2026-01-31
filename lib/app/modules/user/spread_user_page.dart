import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import '../../data/providers/user_provider.dart';
import '../../theme/theme_colors.dart';

/// 推广用户页面 - 对应 pages/users/user_spread_user/index.vue
class SpreadUserPage extends StatefulWidget {
  const SpreadUserPage({super.key});

  @override
  State<SpreadUserPage> createState() => _SpreadUserPageState();
}

class _SpreadUserPageState extends State<SpreadUserPage> {
  final UserProvider _userProvider = UserProvider();

  Map<String, dynamic> userInfo = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  /// 获取用户信息
  Future<void> _getUserInfo() async {
    try {
      final response = await _userProvider.getSpreadInfo();
      if (response.isSuccess) {
        setState(() {
          userInfo = response.data as Map<String, dynamic>? ?? {};
          isLoading = false;
        });

        // 检查推广权限
        if (userInfo['spread_status'] != true) {
          FlutterToastPro.showMessage( '您目前暂无推广权限');
          Future.delayed(const Duration(seconds: 2), () {
            Get.offNamed('/home');
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      FlutterToastPro.showMessage( '获取用户信息失败');
    }
  }

  /// 跳转到提现记录
  void _goToWithdrawRecord() {
    Get.toNamed('/spread/money', arguments: {'type': 1});
  }

  /// 跳转到分佣等级
  void _goToDistributionLevel() {
    Get.toNamed('/user/distribution/level');
  }

  Color get _primaryColor => ThemeColors.red.primary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('我的推广'),
        backgroundColor: ThemeColors.red.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [_buildHeader(), _buildWithdrawButton(), _buildFunctionList()],
              ),
            ),
    );
  }

  /// 头部信息
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_primaryColor, _primaryColor.withAlpha((0.8 * 255).round())],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 用户头像和昵称
          _buildUserInfo(),
          const SizedBox(height: 15),
          // 当前佣金
          Text(
            '${userInfo['brokerage_price'] ?? '0.00'}',
            style: const TextStyle(fontSize: 45, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // 昨日收益和累计已提
          _buildProfitInfo(),
          // 代理商申请入口
          if (_shouldShowAgentApply()) _buildAgentApply(),
        ],
      ),
    );
  }

  /// 用户信息
  Widget _buildUserInfo() {
    return Column(
      children: [
        // 头像
        ClipOval(
          child: Image.network(
            userInfo['avatar'] ?? '',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 50,
                height: 50,
                color: Colors.grey[300],
                child: const Icon(Icons.person, color: Colors.white),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // 昵称
        Text(
          userInfo['nickname'] ?? '',
          style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // 分销等级
        if (userInfo['is_agent_level'] == true) ...[
          const SizedBox(height: 5),
          GestureDetector(
            onTap: _goToDistributionLevel,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryColor.withAlpha((0.7 * 255).round()), _primaryColor],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userInfo['agent_level_name'] ?? '分销等级',
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  const Icon(Icons.chevron_right, size: 14, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 收益信息
  Widget _buildProfitInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildProfitItem('昨日收益', '${userInfo['yesterDay'] ?? '0.00'}', onTap: null),
        _buildProfitItem(
          '累积已提',
          '${userInfo['extractTotalPrice'] ?? '0.00'}',
          onTap: _goToWithdrawRecord,
          showArrow: true,
        ),
      ],
    );
  }

  Widget _buildProfitItem(
    String title,
    String value, {
    VoidCallback? onTap,
    bool showArrow = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                if (showArrow) const Icon(Icons.chevron_right, size: 14, color: Colors.white),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 是否显示代理商申请
  bool _shouldShowAgentApply() {
    final divisionOpen = userInfo['division_open'] == true;
    final agentApplyOpen = userInfo['agent_apply_open'] == true;
    final isDivision = userInfo['is_division'] == true;
    final divisionInvite = userInfo['division_invite'];
    final divisionStatus = userInfo['division_status'] == true;
    final isAgent = userInfo['is_agent'] == true;

    return divisionOpen &&
        agentApplyOpen &&
        ((isDivision && divisionInvite != null && divisionStatus) || (!isDivision && !isAgent));
  }

  /// 代理商申请入口
  Widget _buildAgentApply() {
    return Positioned(
      top: 26,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: const BoxDecoration(
          color: Color(0xFFFFF1DB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            bottomLeft: Radius.circular(15),
          ),
        ),
        child: userInfo['is_division'] == true
            ? Text(
                '邀请码：${userInfo['division_invite']}',
                style: const TextStyle(fontSize: 11, color: Color(0xFFA56A15)),
              )
            : GestureDetector(
                onTap: () => Get.toNamed('/annex/settled'),
                child: const Text(
                  '代理商申请',
                  style: TextStyle(fontSize: 11, color: Color(0xFFA56A15)),
                ),
              ),
      ),
    );
  }

  /// 提现按钮
  Widget _buildWithdrawButton() {
    return Transform.translate(
      offset: const Offset(0, -16),
      child: Container(
        width: 130,
        height: 40,
        decoration: BoxDecoration(
          color: _primaryColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFFF5F5F5), width: 8),
        ),
        child: TextButton(
          onPressed: () => Get.toNamed('/user/withdraw'),
          child: const Text('立即提现', style: TextStyle(fontSize: 14, color: Colors.white)),
        ),
      ),
    );
  }

  /// 功能列表
  Widget _buildFunctionList() {
    final isDivisionOpen = userInfo['division_open'] == true;
    final isAgent = userInfo['is_agent'] == true;
    final isDivision = userInfo['is_division'] == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _buildFunctionItem(
            icon: Icons.qr_code,
            title: '推广名片',
            onTap: () => Get.toNamed('/spread/code'),
          ),
          _buildFunctionItem(
            icon: Icons.bar_chart,
            title: '推广人统计',
            onTap: () => Get.toNamed('/promoter/list'),
          ),
          _buildFunctionItem(
            icon: Icons.account_balance_wallet,
            title: '佣金明细',
            onTap: () => Get.toNamed('/spread/money', arguments: {'type': 2}),
          ),
          if ((isDivisionOpen && !isAgent && !isDivision) || !isDivisionOpen)
            _buildFunctionItem(
              icon: Icons.receipt_long,
              title: '推广人订单',
              onTap: () => Get.toNamed('/promoter/order'),
            ),
          if (isDivisionOpen && (isAgent || isDivision))
            _buildFunctionItem(
              icon: Icons.receipt_long,
              title: isDivision ? '事业部推广订单' : '代理推广订单',
              onTap: () => Get.toNamed('/promoter/order', arguments: {'type': 1}),
            ),
          _buildFunctionItem(
            icon: Icons.leaderboard,
            title: '推广人排行',
            onTap: () => Get.toNamed('/promoter/rank'),
          ),
          _buildFunctionItem(
            icon: Icons.trending_up,
            title: '佣金排行',
            onTap: () => Get.toNamed('/commission/rank'),
          ),
          if (isDivisionOpen && isAgent)
            _buildFunctionItem(
              icon: Icons.people,
              title: '员工列表',
              onTap: () => Get.toNamed('/staff/list'),
            ),
        ],
      ),
    );
  }

  /// 功能项
  Widget _buildFunctionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final width = (MediaQuery.of(context).size.width - 30) / 2;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 120,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35, color: _primaryColor),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 15, color: Color(0xFF666666))),
          ],
        ),
      ),
    );
  }
}


