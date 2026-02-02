import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/services/customer_service.dart';
import 'package:shuhang_mall_flutter/widgets/customer_float_button.dart';

/// 客服功能测试页面
/// 用于测试和演示客服功能
class CustomerTestPage extends StatefulWidget {
  const CustomerTestPage({Key? key}) : super(key: key);

  @override
  State<CustomerTestPage> createState() => _CustomerTestPageState();
}

class _CustomerTestPageState extends State<CustomerTestPage> {
  final CustomerService _customerService = CustomerService();
  bool _showFloatButton = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('客服功能测试'),
        backgroundColor: Colors.red,
      ),
      body: Stack(
        children: [
          // 主要内容
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 说明卡片
                _buildInfoCard(),
                const SizedBox(height: 20),

                // 功能测试区域
                _buildTestSection(),
                const SizedBox(height: 20),

                // 浮动按钮控制
                _buildFloatButtonControl(),
                const SizedBox(height: 20),

                // 客服类型说明
                _buildCustomerTypeInfo(),
              ],
            ),
          ),

          // 客服浮动按钮
          if (_showFloatButton)
            CustomerFloatButton(
              productId: 123,
              initialTop: 200,
              visible: _showFloatButton,
            ),
        ],
      ),
    );
  }

  /// 信息卡片
  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  '客服系统说明',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '本页面用于测试客服功能，支持三种客服类型：\n'
              '1. 站内客服 - 跳转到聊天页面\n'
              '2. 电话客服 - 拨打客服电话\n'
              '3. 第三方客服 - 打开企业微信或其他客服链接',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  /// 测试功能区域
  Widget _buildTestSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '功能测试',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 基础调用
            _buildTestButton(
              icon: Icons.headset_mic,
              title: '打开客服（基础）',
              subtitle: '不带任何参数',
              onTap: () {
                _customerService.openCustomer();
              },
            ),
            const Divider(height: 24),

            // 带商品ID
            _buildTestButton(
              icon: Icons.shopping_bag,
              title: '打开客服（带商品ID）',
              subtitle: '传递商品ID: 123',
              onTap: () {
                _customerService.openCustomerWithProduct(123);
              },
            ),
            const Divider(height: 24),

            // 自定义路径
            _buildTestButton(
              icon: Icons.link,
              title: '打开客服（自定义路径）',
              subtitle: '使用自定义聊天路径',
              onTap: () {
                _customerService.openCustomer(
                  url: '/pages/extension/customer_list/chat',
                  productId: 456,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 测试按钮
  Widget _buildTestButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: Colors.red),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  /// 浮动按钮控制
  Widget _buildFloatButtonControl() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '浮动按钮控制',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('显示浮动按钮'),
              subtitle: const Text('可拖动调整位置'),
              value: _showFloatButton,
              onChanged: (value) {
                setState(() {
                  _showFloatButton = value;
                });
              },
              activeColor: Colors.red,
            ),
            if (_showFloatButton)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Text(
                  '提示：浮动按钮可以拖动调整位置',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 客服类型说明
  Widget _buildCustomerTypeInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '客服类型说明',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildTypeItem(
              type: '类型 0',
              title: '站内客服',
              description: '跳转到自建聊天页面',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),

            _buildTypeItem(
              type: '类型 1',
              title: '电话客服',
              description: '直接拨打客服电话',
              color: Colors.green,
            ),
            const SizedBox(height: 12),

            _buildTypeItem(
              type: '类型 2',
              title: '第三方客服',
              description: '企业微信客服或其他第三方链接',
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  /// 类型说明项
  Widget _buildTypeItem({
    required String type,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            type,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
