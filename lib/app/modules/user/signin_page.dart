import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';

/// 用户签到页
/// 对应原 pages/users/user_sgin/index.vue
class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final UserProvider _userProvider = UserProvider();
  Map<String, dynamic> userInfo = {};
  List<Map<String, dynamic>> signSystemList = [];
  List<Map<String, dynamic>> signList = [];
  int signIndex = 0;
  int integral = 0;
  bool isDaySigned = false;
  bool showSignSuccess = false;
  int signedDays = 0;
  String dayText = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadUserInfo(), _loadSignConfig(), _loadSignList()]);
  }

  Future<void> _loadUserInfo() async {
    final response = await _userProvider.postSignUser({'sign': 1});
    if (response.isSuccess && response.data != null) {
      final data = Map<String, dynamic>.from(response.data);
      setState(() {
        userInfo = data;
        isDaySigned = data['is_day_sgin'] == true || data['is_day_sgin'] == 1;
        signedDays = _readInt(data['sum_sgin_day']);
        signIndex = _readInt(data['sign_num']);
      });
    }
  }

  Future<void> _loadSignConfig() async {
    final response = await _userProvider.getSignConfig();
    if (response.isSuccess && response.data != null) {
      final list = List<Map<String, dynamic>>.from(response.data);
      setState(() {
        signSystemList = list;
        dayText = _toChineseNumber(list.length);
      });
    }
  }

  Future<void> _loadSignList() async {
    final response = await _userProvider.getSignList({'page': 1, 'limit': 3});
    if (response.isSuccess && response.data != null) {
      setState(() {
        signList = List<Map<String, dynamic>>.from(response.data);
      });
    }
  }

  Future<void> _doSign() async {
    if (isDaySigned) {
      FlutterToastPro.showMessage('您今日已签到!');
      return;
    }

    final response = await _userProvider.setSignIntegral();
    if (response.isSuccess && response.data != null) {
      final data = Map<String, dynamic>.from(response.data);
      final earnedIntegral = _readInt(data['integral']);
      int newIndex = signIndex + 1;
      if (newIndex > signSystemList.length) {
        newIndex = 1;
      }

      setState(() {
        isDaySigned = true;
        signIndex = newIndex;
        signedDays += 1;
        integral = earnedIntegral;
        showSignSuccess = true;
        userInfo['is_day_sgin'] = true;
        userInfo['integral'] = _readInt(userInfo['integral']) + earnedIntegral;
      });

      await _loadSignList();
    }
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

  int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  String _toChineseNumber(int number) {
    const mapping = ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九'];
    final text = number.toString();
    return text.split('').map((e) => mapping[int.tryParse(e) ?? 0]).join();
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
              _SignHeader(
                theme: theme,
                userInfo: userInfo,
                onDetail: () => Get.toNamed(AppRoutes.userSignList),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 签到卡片
                      _SignCard(
                        theme: theme,
                        signSystemList: signSystemList,
                        signIndex: signIndex,
                        isDaySigned: isDaySigned,
                        onSign: _doSign,
                      ),

                      // 累计签到
                      _AccumulatedCard(
                        theme: theme,
                        daysText: _formatDays(signedDays),
                        dayText: dayText,
                        signList: signList,
                        onMore: () => Get.toNamed(AppRoutes.userSignList),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 签到成功弹窗
          if (showSignSuccess)
            _SuccessDialog(theme: theme, integral: integral, onClose: _closeSuccessDialog),
        ],
      ),
    );
  }
}

class _SignHeader extends StatelessWidget {
  final ThemeData theme;
  final Map<String, dynamic> userInfo;
  final VoidCallback onDetail;

  const _SignHeader({required this.theme, required this.userInfo, required this.onDetail});

  @override
  Widget build(BuildContext context) {
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
                onTap: onDetail,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.menu, color: Colors.orange, size: 20),
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
}

class _SignCard extends StatelessWidget {
  final ThemeData theme;
  final List<Map<String, dynamic>> signSystemList;
  final int signIndex;
  final bool isDaySigned;
  final Future<void> Function() onSign;

  const _SignCard({
    required this.theme,
    required this.signSystemList,
    required this.signIndex,
    required this.isDaySigned,
    required this.onSign,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      transform: Matrix4.translationValues(0, -60, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(signSystemList.length, (index) {
              final item = signSystemList[index];
              final isLast = index == signSystemList.length - 1;
              final isSigned = signIndex >= index + 1;

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
          SizedBox(
            width: 200,
            height: 44,
            child: ElevatedButton(
              onPressed: isDaySigned ? null : onSign,
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
}

class _AccumulatedCard extends StatelessWidget {
  final ThemeData theme;
  final String daysText;
  final String dayText;
  final List<Map<String, dynamic>> signList;
  final VoidCallback onMore;

  const _AccumulatedCard({
    required this.theme,
    required this.daysText,
    required this.dayText,
    required this.signList,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      transform: Matrix4.translationValues(0, -60, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const Text('已累计签到', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ...daysText.split('').map((char) {
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
            '据说连续签到第$dayText天可获得超额消费券，一定要坚持签到哦~~~',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          ...signList.map((item) => _SignListItem(item: item)),
          if (signList.length >= 3)
            GestureDetector(
              onTap: onMore,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
}

class _SignListItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const _SignListItem({required this.item});

  @override
  Widget build(BuildContext context) {
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
}

class _SuccessDialog extends StatelessWidget {
  final ThemeData theme;
  final int integral;
  final VoidCallback onClose;

  const _SuccessDialog({required this.theme, required this.integral, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
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
                      onPressed: onClose,
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
