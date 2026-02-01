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
    final response = await _userProvider.getUserInfo();
    if (response.isSuccess && response.data != null) {
      setState(() {
        userInfo = response.data!.toJson();
      });
    }
  }

  /// 获取团队信息
  Future<void> _getTeamInfo() async {
    final response = await _userProvider.getTeamInfo();
    if (response.isSuccess && response.data != null) {
      setState(() {
        teamInfo = Map<String, dynamic>.from(response.data);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _TeamHeader(primaryColor: _primaryColor, userInfo: userInfo, teamInfo: teamInfo),
                  _TeamStats(primaryColor: _primaryColor, teamInfo: teamInfo),
                  _ProgressSection(teamInfo: teamInfo),
                ],
              ),
            ),
    );
  }
}

class _TeamHeader extends StatelessWidget {
  final Color primaryColor;
  final Map<String, dynamic> userInfo;
  final Map<String, dynamic> teamInfo;

  const _TeamHeader({required this.primaryColor, required this.userInfo, required this.teamInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: primaryColor,
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
            const Icon(Icons.stars, color: Colors.amber, size: 50),
          ],
        ),
      ),
    );
  }
}

class _TeamStats extends StatelessWidget {
  final Color primaryColor;
  final Map<String, dynamic> teamInfo;

  const _TeamStats({required this.primaryColor, required this.teamInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _CircleProgress(value: teamInfo['team_num'] ?? 0, label: '团队总人数', color: primaryColor),
          _CircleProgress(value: teamInfo['bg_team'] ?? 0, label: '大区人数', color: primaryColor),
          _CircleProgress(value: teamInfo['min_team'] ?? 0, label: '小区人数', color: primaryColor),
        ],
      ),
    );
  }
}

class _CircleProgress extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _CircleProgress({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
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
}

class _ProgressSection extends StatelessWidget {
  final Map<String, dynamic> teamInfo;

  const _ProgressSection({required this.teamInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          _ProgressItem(
            title: '团队总活跃',
            current: teamInfo['team_hy'] ?? 0,
            target: teamInfo['next_team'] ?? 100,
            percent: (teamInfo['team_bl'] ?? 0) / 100,
            color: const Color(0xFFFEB52A),
          ),
          const SizedBox(height: 20),
          _ProgressItem(
            title: '小区活跃',
            current: teamInfo['min_hy'] ?? 0,
            target: teamInfo['next_min'] ?? 50,
            percent: (teamInfo['min_bl'] ?? 0) / 100,
            color: const Color(0xFFFF0014),
          ),
          const SizedBox(height: 20),
          _ProgressItem(
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
}

class _ProgressItem extends StatelessWidget {
  final String title;
  final int current;
  final int target;
  final double percent;
  final Color color;

  const _ProgressItem({
    required this.title,
    required this.current,
    required this.target,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF333333))),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 15,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
            Positioned(
              left: 7,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text('$current', style: const TextStyle(fontSize: 11, color: Colors.white)),
              ),
            ),
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
