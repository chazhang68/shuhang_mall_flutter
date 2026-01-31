import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/user_provider.dart';
import '../../theme/theme_colors.dart';

/// 团队页面 - 对应 pages/users/team/team.vue
class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final UserProvider _userProvider = UserProvider();

  Map<String, dynamic> userInfo = {};
  Map<String, dynamic> teamInfo = {};
  bool isLoading = true;

  Color get _primaryColor => ThemeColors.red.primary;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_getUserInfo(), _getTeamInfo()]);
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
        });
      }
    } catch (e) {
      // ignore
    }
  }

  /// 获取团队信息
  Future<void> _getTeamInfo() async {
    // TODO: 调用实际的团队API
    // 这里使用模拟数据
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      teamInfo = {
        'level_name': 'VIP会员',
        'next_name': '金牌会员',
        'team_num': 128,
        'bg_team': 85,
        'min_team': 43,
        'team_hy': 50,
        'next_team': 100,
        'team_bl': 50,
        'min_hy': 20,
        'next_min': 50,
        'min_bl': 40,
        'yxzt': 15,
        'next_zt': 30,
        'ztbl': 50,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(children: [_buildHeader(), _buildTeamStats(), _buildProgressSection()]),
            ),
    );
  }

  /// 头部区域
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            // 头像
            ClipOval(
              child: Image.network(
                userInfo['avatar'] ?? '',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey,
                  child: const Icon(Icons.person, color: Colors.white, size: 30),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 等级信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teamInfo['level_name'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '下一等级：${teamInfo['next_name'] ?? ''}',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            // 装饰图标
            const Icon(Icons.stars, color: Colors.amber, size: 50),
          ],
        ),
      ),
    );
  }

  /// 团队统计
  Widget _buildTeamStats() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCircleProgress(
            value: teamInfo['team_num'] ?? 0,
            label: '团队总人数',
            color: _primaryColor,
          ),
          _buildCircleProgress(
            value: teamInfo['bg_team'] ?? 0,
            label: '大区人数',
            color: _primaryColor,
          ),
          _buildCircleProgress(
            value: teamInfo['min_team'] ?? 0,
            label: '小区人数',
            color: _primaryColor,
          ),
        ],
      ),
    );
  }

  /// 圆形进度
  Widget _buildCircleProgress({required int value, required String label, required Color color}) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 5,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                '$value',
                style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
      ],
    );
  }

  /// 进度条区域
  Widget _buildProgressSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          _buildProgressItem(
            title: '团队总活跃',
            current: teamInfo['team_hy'] ?? 0,
            target: teamInfo['next_team'] ?? 100,
            percent: (teamInfo['team_bl'] ?? 0) / 100,
            color: const Color(0xFFFEB52A),
          ),
          const SizedBox(height: 20),
          _buildProgressItem(
            title: '小区活跃',
            current: teamInfo['min_hy'] ?? 0,
            target: teamInfo['next_min'] ?? 50,
            percent: (teamInfo['min_bl'] ?? 0) / 100,
            color: const Color(0xFFFF0014),
          ),
          const SizedBox(height: 20),
          _buildProgressItem(
            title: '有效直推',
            current: teamInfo['yxzt'] ?? 0,
            target: teamInfo['next_zt'] ?? 30,
            percent: (teamInfo['ztbl'] ?? 0) / 100,
            color: const Color(0xFFFF00DD),
          ),
        ],
      ),
    );
  }

  /// 进度项
  Widget _buildProgressItem({
    required String title,
    required int current,
    required int target,
    required double percent,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF333333))),
        const SizedBox(height: 8),
        Stack(
          children: [
            // 进度条背景
            Container(
              height: 15,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            // 进度条
            FractionallySizedBox(
              widthFactor: percent > 1 ? 1 : percent,
              child: Container(
                height: 15,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color.withAlpha((0.6 * 255).round()), color]),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            // 左侧数值
            Positioned(
              left: 7,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text('$current', style: const TextStyle(fontSize: 11, color: Colors.white)),
              ),
            ),
            // 右侧数值
            Positioned(
              right: 7,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  '$target',
                  style: TextStyle(
                    fontSize: 11,
                    color: percent > 0.9 ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
