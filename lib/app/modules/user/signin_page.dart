import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';

/// 用户签到页
/// 对应原 pages/users/user_sgin/index.vue
class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  Map<String, dynamic> userInfo = {};
  List<Map<String, dynamic>> signSystemList = [];
  List<Map<String, dynamic>> signList = [];
  int signIndex = 0;
  int integral = 0;
  bool isDaySigned = false;
  bool showSignSuccess = false;
  int signedDays = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadUserInfo(), _loadSignConfig(), _loadSignList()]);
  }

  Future<void> _loadUserInfo() async {
    // TODO: 调用API获取用户签到信息
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      userInfo = {
        'avatar': 'https://via.placeholder.com/100',
        'nickname': '测试用户',
        'integral': 1580,
        'is_day_sgin': false,
        'sum_sgin_day': 15,
        'sign_num': 3,
      };
      isDaySigned = userInfo['is_day_sgin'] ?? false;
      signedDays = userInfo['sum_sgin_day'] ?? 0;
      signIndex = userInfo['sign_num'] ?? 0;
    });
  }

  Future<void> _loadSignConfig() async {
    // TODO: 调用API获取签到配置
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      signSystemList = [
        {'day': '第一天', 'sign_num': 5},
        {'day': '第二天', 'sign_num': 10},
        {'day': '第三天', 'sign_num': 15},
        {'day': '第四天', 'sign_num': 20},
        {'day': '第五天', 'sign_num': 25},
        {'day': '第六天', 'sign_num': 30},
        {'day': '第七天', 'sign_num': 50},
      ];
    });
  }

  Future<void> _loadSignList() async {
    // TODO: 调用API获取签到记录
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      signList = [
        {'title': '签到奖励', 'number': 15, 'add_time': '2024-01-15'},
        {'title': '签到奖励', 'number': 10, 'add_time': '2024-01-14'},
        {'title': '签到奖励', 'number': 5, 'add_time': '2024-01-13'},
      ];
    });
  }

  void _doSign() {
    if (isDaySigned) {
      Get.snackbar('提示', '您今日已签到!');
      return;
    }

    // TODO: 调用签到API
    int newIndex = signIndex + 1;
    if (newIndex > signSystemList.length) {
      newIndex = 1;
    }
    int earnedIntegral = signSystemList.isNotEmpty && signIndex < signSystemList.length
        ? signSystemList[signIndex]['sign_num'] ?? 10
        : 10;

    setState(() {
      isDaySigned = true;
      signIndex = newIndex;
      signedDays++;
      integral = earnedIntegral;
      showSignSuccess = true;
      userInfo['integral'] = (userInfo['integral'] ?? 0) + earnedIntegral;
    });
  }

  void _closeSuccessDialog() {
    setState(() {
      showSignSuccess = false;
    });
  }

  String _formatDays(int days) {
    final str = days.toString().padLeft(4, '0');
    return str;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              _buildHeader(theme),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 签到卡片
                      _buildSignCard(theme),

                      // 累计签到
                      _buildAccumulatedCard(theme),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 签到成功弹窗
          if (showSignSuccess) _buildSuccessDialog(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      color: theme.primaryColor,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 200,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.amber, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        userInfo['avatar'] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userInfo['nickname'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '消费券: ${userInfo['integral'] ?? 0}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.userSignList);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.menu, color: Colors.orange, size: 20),
                      const SizedBox(width: 4),
                      Text('明细', style: TextStyle(color: Colors.orange, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      transform: Matrix4.translationValues(0, -60, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // 签到天数列表
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(signSystemList.length, (index) {
              final item = signSystemList[index];
              final isLast = index == signSystemList.length - 1;
              final isSigned = signIndex > index;

              return Column(
                children: [
                  Text(
                    isLast ? '奖励' : item['day'] ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSigned ? Colors.orange : Colors.grey[300],
                    ),
                    child: isSigned ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '+${item['sign_num']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isSigned ? Colors.orange : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
          ),

          const SizedBox(height: 24),

          // 签到按钮
          SizedBox(
            width: 200,
            height: 44,
            child: ElevatedButton(
              onPressed: isDaySigned ? null : _doSign,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDaySigned ? Colors.grey : theme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              child: Text(
                isDaySigned ? '已签到' : '立即签到',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccumulatedCard(ThemeData theme) {
    final daysStr = _formatDays(signedDays);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      transform: Matrix4.translationValues(0, -60, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const Text('已累计签到', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 16),

          // 天数显示
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ...daysStr.split('').map((char) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 40,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      char,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 8),
              const Text('天', style: TextStyle(fontSize: 16, color: Colors.black87)),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            '据说连续签到第七天可获得超额消费券，一定要坚持签到哦~~~',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),

          // 签到记录列表
          ...signList.map((item) => _buildSignListItem(item)),

          if (signList.length >= 3)
            GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.userSignList);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('点击加载更多', style: TextStyle(fontSize: 14, color: Colors.black87)),
                    Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSignListItem(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['title'] ?? '',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(item['add_time'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
            ],
          ),
          Text(
            '+${item['number']}',
            style: const TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessDialog(ThemeData theme) {
    return GestureDetector(
      onTap: _closeSuccessDialog,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/sign_success.png',
                    width: 100,
                    height: 100,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.check_circle, size: 80, color: theme.primaryColor),
                  ),
                  const SizedBox(height: 16),
                  const Text('签到成功', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('获得$integral消费券', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 120,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _closeSuccessDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('好的', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
