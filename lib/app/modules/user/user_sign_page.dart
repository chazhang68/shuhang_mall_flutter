import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/providers/user_provider.dart';
import '../../theme/theme_colors.dart';

class UserSignPage extends StatefulWidget {
  const UserSignPage({super.key});

  @override
  State<UserSignPage> createState() => _UserSignPageState();
}

class _UserSignPageState extends State<UserSignPage> {
  final UserProvider _userProvider = UserProvider();

  Map<String, dynamic> _userInfo = {};
  List<Map<String, dynamic>> _signSystemList = [];
  List<Map<String, dynamic>> _signList = [];
  List<String> _signCount = ['0', '0', '0', '0'];
  int _signIndex = 0;
  int _day = 7;
  bool _active = false;
  int _integral = 0;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    _getSignSystem();
    _getSignList();
  }

  String _prefixInteger(int num, int length) {
    return num.toString().padLeft(length, '0');
  }

  Future<void> _getUserInfo() async {
    final response = await _userProvider.postSignUser({'sign': 1});
    if (response.isSuccess && response.data != null) {
      setState(() {
        _userInfo = response.data;
        int sumSignDay = _userInfo['sum_sgin_day'] ?? 0;
        String sumStr = _prefixInteger(sumSignDay, 4);
        _signCount = sumStr.split('');
        _signIndex = _userInfo['sign_num'] ?? 0;
      });
    }
  }

  Future<void> _getSignSystem() async {
    final response = await _userProvider.getSignConfig();
    if (response.isSuccess && response.data != null) {
      setState(() {
        _signSystemList = List<Map<String, dynamic>>.from(response.data);
        _day = _signSystemList.length;
      });
    }
  }

  Future<void> _getSignList() async {
    final response = await _userProvider.getSignList({'page': 1, 'limit': 3});
    if (response.isSuccess && response.data != null) {
      setState(() {
        _signList = List<Map<String, dynamic>>.from(response.data['list'] ?? response.data);
      });
    }
  }

  Future<void> _goSign() async {
    if (_userInfo['is_day_sgin'] == true) {
      FlutterToastPro.showMessage( '今日已签到');
      return;
    }

    final response = await _userProvider.setSignIntegral();
    if (response.isSuccess && response.data != null) {
      setState(() {
        _integral = response.data['integral'] ?? 0;
        _active = true;
      });
    } else {
      FlutterToastPro.showMessage( response.msg);
    }
  }

  void _close() {
    setState(() {
      _active = false;
    });
    _getUserInfo();
    _getSignList();
  }

  void _goSignList() {
    Get.toNamed('/user/sign-list');
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ThemeColors.red.primary, ThemeColors.red.primary.withAlpha((0.8 * 255).round())],
        ),
      ),
      child: Row(
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: _userInfo['avatar'] ?? '',
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[300]),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.person, size: 32, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userInfo['nickname'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '消费券: ${_userInfo['integral'] ?? 0}',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _goSignList,
            child: Column(
              children: [
                const Icon(Icons.list, color: Colors.white, size: 24),
                const Text('明细', style: TextStyle(fontSize: 12, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignProgress() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 10)],
      ),
      child: Column(
        children: [
          // 签到进度
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _signSystemList.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> item = entry.value;
              bool isLast = index == _signSystemList.length - 1;
              bool isSigned = _signIndex >= index + 1;

              return Column(
                children: [
                  Text(
                    isLast ? '奖励' : (item['day'] ?? '第${index + 1}天'),
                    style: TextStyle(
                      fontSize: 12,
                      color: isLast ? ThemeColors.red.primary : Colors.grey[600],
                      fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSigned || isLast ? ThemeColors.red.primary : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(isSigned ? Icons.check : Icons.star, size: 14, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '+${item['sign_num'] ?? 0}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSigned ? ThemeColors.red.primary : Colors.grey[500],
                      fontWeight: isSigned ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // 签到按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _userInfo['is_day_sgin'] == true ? null : _goSign,
              style: ElevatedButton.styleFrom(
                backgroundColor: _userInfo['is_day_sgin'] == true
                    ? Colors.grey[400]
                    : ThemeColors.red.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              child: Text(
                _userInfo['is_day_sgin'] == true ? '已签到' : '立即签到',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 10)],
      ),
      child: Column(
        children: [
          const Text('已累计签到', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ..._signCount.map((digit) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 36,
                  height: 48,
                  decoration: BoxDecoration(
                    color: ThemeColors.red.primary.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      digit,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.red.primary,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 8),
              const Text('天', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '据说连续签到第$_day天可获得超额消费券，一定要坚持签到哦~~~',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),

          const SizedBox(height: 20),

          // 签到记录
          ..._signList.map((item) {
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
                      Text(item['title'] ?? '', style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        item['add_time'] ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  Text(
                    '+${item['number'] ?? 0}',
                    style: TextStyle(
                      fontSize: 16,
                      color: ThemeColors.red.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),

          if (_signList.length >= 3)
            TextButton(
              onPressed: _goSignList,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('点击加载更多', style: TextStyle(color: Colors.grey[600])),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[600]),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuccessDialog() {
    if (!_active) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _close,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(48),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 64, color: ThemeColors.red.primary),
                const SizedBox(height: 16),
                const Text('签到成功', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(
                  '获得$_integral消费券',
                  style: TextStyle(fontSize: 16, color: ThemeColors.red.primary),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _close,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.red.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  ),
                  child: const Text('好的'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('签到'),
        centerTitle: true,
        backgroundColor: ThemeColors.red.primary,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                _buildSignProgress(),
                _buildSignStats(),
                const SizedBox(height: 32),
              ],
            ),
          ),
          _buildSuccessDialog(),
        ],
      ),
    );
  }
}


