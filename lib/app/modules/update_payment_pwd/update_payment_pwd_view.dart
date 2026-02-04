import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/update_payment_pwd_controller.dart';

class UpdatePaymentPwdView extends GetView<UpdatePaymentPwdController> {
  const UpdatePaymentPwdView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('修改支付密码'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Form(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 当前手机号显示
                Obx(
                  () => Text(
                    '当前手机号：${controller.phone}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 55),

                // 新支付密码输入
                _buildPasswordField(
                  label: '新支付密码',
                  hint: '请输入新支付密码',
                  controller: TextEditingController(),
                  onChanged: controller.updateNewPassword,
                  isPassword: true,
                  maxLength: 6, // 支付密码通常为6位
                ),

                const SizedBox(height: 1),

                // 确认新支付密码输入
                _buildPasswordField(
                  label: '确认新支付密码',
                  hint: '请再次输入新支付密码',
                  controller: TextEditingController(),
                  onChanged: controller.updateEnterPassword,
                  isPassword: true,
                  maxLength: 6, // 支付密码通常为6位
                ),

                const SizedBox(height: 1),

                // 验证码输入行
                _buildVerificationCodeField(),

                const SizedBox(height: 75),

                // 保存按钮
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _handleSave(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text(
                      '保存',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 构建密码输入字段
  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required Function(String) onChanged,
    bool isPassword = false,
    int? maxLength,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.1 * 255).round()),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80, // 对应原25%宽度
            child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: TextFormField(
              controller: controller,
              onChanged: onChanged,
              obscureText: isPassword,
              maxLength: maxLength,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建验证码输入行
  Widget _buildVerificationCodeField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.1 * 255).round()),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 80, // 对应原25%宽度
            child: Text('验证码', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 3,
            child: TextFormField(
              onChanged: controller.updateCaptcha,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '请输入验证码',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.disabled ? null : () => controller.sendVerificationCode(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.disabled ? Colors.grey.shade300 : Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Text(
                  controller.text,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
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
