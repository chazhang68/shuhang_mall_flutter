import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'update_payment_pwd_controller.dart';

class UpdatePaymentPwdView extends GetView<UpdatePaymentPwdController> {
  const UpdatePaymentPwdView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // 浅灰色背景
      appBar: AppBar(
        title: const Text('修改支付密码'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 当前手机号显示区域（灰色背景）
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              color: Colors.white,
              child: Obx(
                () => Text(
                  '当前手机号：${controller.phone}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 新支付密码输入框
            _buildInputCard(
              label: '新支付密码',
              hint: '请输入新支付密码',
              onChanged: controller.updateNewPassword,
              isPassword: true,
            ),

            const SizedBox(height: 1),

            // 确认新支付密码输入框
            _buildInputCard(
              label: '确认新支付密码',
              hint: '请输入新支付密码',
              onChanged: controller.updateEnterPassword,
              isPassword: true,
            ),

            const SizedBox(height: 8),

            // 验证码输入框（带按钮）
            _buildVerificationCard(),

            const SizedBox(height: 40),

            // 保存按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _handleSave(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5A5A), // 红色
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '保存',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建输入卡片
  Widget _buildInputCard({
    required String label,
    required String hint,
    required Function(String) onChanged,
    bool isPassword = false,
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          // 左侧标签
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
          // 右侧输入框
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextFormField(
                onChanged: onChanged,
                obscureText: isPassword,
                maxLength: 6, // 支付密码6位
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFCCCCCC),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  counterText: '', // 隐藏字符计数
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建验证码卡片
  Widget _buildVerificationCard() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          // 左侧标签
          const SizedBox(
            width: 100,
            child: Text(
              '验证码',
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
          // 中间输入框
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextFormField(
                onChanged: controller.updateCaptcha,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '请输入验证码',
                  hintStyle: TextStyle(fontSize: 14, color: Color(0xFFCCCCCC)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
          // 右侧验证码按钮
          Obx(
            () => GestureDetector(
              onTap: controller.disabled
                  ? null
                  : () => controller.sendVerificationCode(),
              child: Text(
                controller.text,
                style: TextStyle(
                  fontSize: 14,
                  color: controller.disabled
                      ? const Color(0xFFCCCCCC)
                      : const Color(0xFFFF5A5A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 处理保存按钮点击
  void _handleSave() async {
    bool success = await controller.editPaymentPassword();
    if (success) {
      Get.back(); // 返回上一页
    }
  }
}
