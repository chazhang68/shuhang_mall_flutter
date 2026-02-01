import 'package:flutter/material.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:get/get.dart';

/// 客服聊天页面。
///
/// 对应原 uni-app 的 /pages/extension/customer_list/chat。
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final productId = args?['productId']?.toString() ?? '';
    final toUid = args?['to_uid']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('客服'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.support_agent, size: 56, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('客服聊天功能正在接入中', style: TextStyle(fontSize: 16, color: Color(0xFF666666))),
              if (productId.isNotEmpty || toUid.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'productId: $productId  to_uid: $toUid',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    FlutterToastPro.showMessage('客服功能开发中');
                  },
                  child: const Text('联系人工客服'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
