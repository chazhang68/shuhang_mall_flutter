import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/app/data/models/user_model.dart';

/// SWP兑换积分页面
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
  bool _loading = false;

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
      Get.snackbar('提示', '请输入兑换数量');
      return;
    }

    if (_jfnum < 1) {
      Get.snackbar('提示', '兑换数量最少1个');
      return;
    }

    final nowMoney = _userInfo?.balance ?? 0;
    if (_jfnum > nowMoney) {
      Get.snackbar('提示', '可用SWP不足');
      return;
    }

    if (_loading) return;

    setState(() => _loading = true);

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final response = await _userProvider.swpDui({
        'number': _jfnum.toString(),
      });
      Get.back();

      if (response.isSuccess) {
        Get.snackbar('提示', '兑换成功');
        _controller.clear();
        setState(() => _jfnum = 0);
        await _getUserInfo();
      } else {
        Get.snackbar('提示', response.msg);
      }
    } catch (e) {
      Get.back();
      Get.snackbar('提示', '兑换失败: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('SWP兑换积分'),
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(7),
                    ],
                    decoration: const InputDecoration(
                      hintText: '请输入兑换数量',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '可用SWP数量${_userInfo?.balance ?? 0}个',
                        style: const TextStyle(fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: _allJifen,
                        child: const Text(
                          '全部兑换',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFFF5A5A),
                          ),
                        ),
                      ),
                    ],
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
                    '$_jfnum个',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFF5A5A),
                    ),
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
