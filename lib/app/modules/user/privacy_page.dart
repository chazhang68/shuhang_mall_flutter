import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import '../../data/providers/user_provider.dart';
import '../../theme/theme_colors.dart';
import 'package:flutter_html/flutter_html.dart';

/// 隐私政策/用户协议页面
/// 对应原 pages/users/privacy/index.vue
class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  final UserProvider _userProvider = UserProvider();

  String _content = '';
  String _title = '协议详情';
  bool _isLoading = true;

  Color get _primaryColor => ThemeColors.red.primary;

  @override
  void initState() {
    super.initState();
    _loadAgreement();
  }

  Future<void> _loadAgreement() async {
    // 获取路由参数 type: 3(隐私政策) / 4(用户协议) 等
    // 支持两种传参方式: arguments 和 URL parameters
    final type = Get.arguments?['type']?.toString() ?? Get.parameters['type'] ?? 'privacy';

    try {
      final response = await _userProvider.getUserAgreement(type);
      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        setState(() {
          _content = data['content'] ?? '';
          _title = data['title'] ?? '协议详情';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        FlutterToastPro.showMessage( response.msg);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      FlutterToastPro.showMessage( '加载失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _title,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _content.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(50),
                        child: Text('暂无内容', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ),
                    )
                  : Html(
                      data: _content,
                      style: {
                        "body": Style(
                          fontSize: FontSize(14),
                          lineHeight: LineHeight(2.0),
                          color: const Color(0xFF333333),
                        ),
                        "img": Style(width: Width(100, Unit.percent), display: Display.block),
                        "table": Style(width: Width(100, Unit.percent)),
                        "video": Style(width: Width(100, Unit.percent)),
                      },
                    ),
            ),
    );
  }
}


