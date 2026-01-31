import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/app/data/models/user_model.dart';

/// 积分兑换SWP页面
/// 对应原 pages/users/jifendswp/jifendswp.vue
class JifenExchangePage extends StatefulWidget {
  const JifenExchangePage({super.key});

  @override
  State<JifenExchangePage> createState() => _JifenExchangePageState();
}

class _JifenExchangePageState extends State<JifenExchangePage> {
  final UserProvider _userProvider = UserProvider();
  final TextEditingController _controller = TextEditingController();

  UserModel? _userInfo;
  double _jfnum = 0; // 兑换数量
  double _xfqsxfnum = 0; // 手续费数量
  double _dznum = 0; // 到账数量
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
      setState(() {
        _jfnum = 0;
        _xfqsxfnum = 0;
        _dznum = 0;
      });
      return;
    }

    final value = double.tryParse(text) ?? 0;
    final sxfRate = 0.0; // 手续费率暂时为0，需要从配置获取

    setState(() {
      _jfnum = value;
      _xfqsxfnum = double.parse((value * sxfRate).toStringAsFixed(2));
      _dznum = double.parse((value - _xfqsxfnum).toStringAsFixed(2));
    });
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
    final jifen = (_userInfo?.fdKy ?? 0).floor();
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

    final fdKy = _userInfo?.fdKy ?? 0;
    if (_jfnum > fdKy) {
      Get.snackbar('提示', '可用积分不足');
      return;
    }

    if (_loading) return;

    setState(() => _loading = true);

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final response = await _userProvider.xfqDui({
        'number': _jfnum.toString(),
      });
      Get.back();

      if (response.isSuccess) {
        Get.snackbar('提示', '兑换成功');
        _controller.clear();
        setState(() {
          _xfqsxfnum = 0;
          _dznum = 0;
        });
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
        title: const Text('积分兑换SWP'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(7),
                      ],
                      decoration: const InputDecoration(
                        hintText: '请输入兑换数量',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '可用积分数量${_userInfo?.fdKy ?? 0}个',
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

            // 手续费信息
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        const Text('手续费', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 12),
                        Text(
                          '0%', // 手续费率暂时为0
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFFF5A5A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('损耗数量', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 12),
                        Text(
                          '$_xfqsxfnum个',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFFF5A5A),
                          ),
                        ),
                      ],
                    ),
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
                    '$_dznum个',
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
