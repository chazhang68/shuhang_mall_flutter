import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/app/data/models/user_model.dart';

/// 消费券兑换积分页面
/// 对应原 pages/users/swpdjifen/swpdjifen.vue
class SwpExchangePage extends StatefulWidget {
  const SwpExchangePage({super.key});

  @override
  State<SwpExchangePage> createState() => _SwpExchangePageState();
}

class _SwpExchangePageState extends State<SwpExchangePage> {
  final UserProvider _userProvider = UserProvider();
  final TextEditingController _controller = TextEditingController();

  UserModel? _userInfo;
  double _jfnum = 0; // 兑换数量
  double xfqSxf = 0;
  bool _loading = false;

  /// 手续费（损耗数量）
  double get _sunhaoNum {
    return _jfnum * (xfqSxf / 100);
  }

  /// 实际到账数量
  double get _actualNum {
    return _jfnum - _sunhaoNum;
  }

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    _controller.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    final text = _controller.text;
    if (text.isEmpty) {
      setState(() => _jfnum = 0);
      return;
    }

    final value = double.tryParse(text) ?? 0;
    setState(() => _jfnum = value);
  }

  Future<void> _getUserInfo() async {
    try {
      final response = await _userProvider.newUserInfo();
      if (response.isSuccess && response.data != null) {
        setState(() {
          _userInfo = response.data;
          xfqSxf = _userInfo?.xfqSxf ?? 0;
          developer.log('消费券手续费率: $xfqSxf');
        });
      }
    } catch (e) {
      debugPrint('获取用户信息失败: $e');
    }
  }

  void _allJifen() {
    final jifen = (_userInfo?.balance ?? 0).floor();
    _controller.text = jifen.toString();
  }

  Future<void> _xfqZhuan() async {
    if (_jfnum <= 0) {
      FlutterToastPro.showMessage('请输入兑换数量');
      return;
    }

    if (_jfnum < 1) {
      FlutterToastPro.showMessage('兑换数量最少1个');
      return;
    }

    final nowMoney = _userInfo?.balance ?? 0;
    if (_jfnum > nowMoney) {
      FlutterToastPro.showMessage('可用消费券不足');
      return;
    }

    if (_loading) return;

    setState(() => _loading = true);

    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      final response = await _userProvider.swpDui({'number': _jfnum.toString()});
      Get.back();

      if (response.isSuccess) {
        FlutterToastPro.showMessage('兑换成功');
        _controller.clear();
        setState(() => _jfnum = 0);
        await _getUserInfo();
      } else {
        FlutterToastPro.showMessage(response.msg);
      }
    } catch (e) {
      Get.back();
      FlutterToastPro.showMessage('兑换失败: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('消费券兑换积分'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // 兑换数量输入
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '兑换数量',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
                    ),
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [LengthLimitingTextInputFormatter(7)],
                      decoration: InputDecoration(
                        hintText: '请输入兑换数量',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 12.w),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '可用消费券数量${_userInfo?.balance ?? 0}个',
                        style: const TextStyle(fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: _allJifen,
                        child: const Text(
                          '全部兑换',
                          style: TextStyle(fontSize: 12, color: Color(0xFFFF5A5A)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            // 手续费
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                spacing: 4.w,
                children: [
                  const Text('手续费', style: TextStyle(fontSize: 12)),
                  Text('$xfqSxf%', style: const TextStyle(fontSize: 12, color: Color(0xFFFF5A5A))),
                  Spacer(),
                  const Text('损耗数量', style: TextStyle(fontSize: 12)),
                  Text(
                    '${_sunhaoNum.toStringAsFixed(2)}个',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFFF5A5A)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // 实际到账
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('实际到账数量', style: TextStyle(fontSize: 12)),
                  Text(
                    '${_actualNum.toStringAsFixed(2)}个',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFFF5A5A)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // 兑换按钮
            GestureDetector(
              onTap: _xfqZhuan,
              child: Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5A5A),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Center(
                  child: Text(
                    '兑换',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
