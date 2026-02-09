import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';

/// 消费券互转控制器
class CouponTransferController extends GetxController {
  final UserProvider _userProvider = UserProvider();
  final AppController _appController = Get.find<AppController>();

  // 表单控制器
  final phoneController = TextEditingController();
  final amountController = TextEditingController();
  final passwordController = TextEditingController();
  final remarkController = TextEditingController();

  // 状态变量
  final isLoading = false.obs;
  final availableBalance = 0.0.obs; // 可用消费券数量
  final actualAmount = 0.0.obs; // 实际到账数量

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
    _setupAmountListener();

    // 如果从扫码页面传递了手机号，自动填充
    final args = Get.arguments;
    if (args != null && args['phone'] != null) {
      phoneController.text = args['phone'];
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    amountController.dispose();
    passwordController.dispose();
    remarkController.dispose();
    super.onClose();
  }

  /// 加载用户信息
  Future<void> _loadUserInfo() async {
    try {
      final userInfo = _appController.userInfo;
      if (userInfo != null) {
        availableBalance.value = userInfo.balance;
      }
    } catch (e) {
      debugPrint('加载用户信息失败: $e');
    }
  }

  /// 监听转出数量变化
  void _setupAmountListener() {
    amountController.addListener(() {
      final text = amountController.text.trim();
      if (text.isEmpty) {
        actualAmount.value = 0.0;
        return;
      }
      final amount = double.tryParse(text) ?? 0.0;
      actualAmount.value = amount;
    });
  }

  /// 全部转赠
  void transferAll() {
    if (availableBalance.value > 0) {
      amountController.text = availableBalance.value.toStringAsFixed(2);
    }
  }

  /// 确认转赠
  Future<void> confirmTransfer() async {
    if (phoneController.text.trim().isEmpty) {
      EasyLoading.showError('请输入转入手机号');
      return;
    }

    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phoneController.text.trim())) {
      EasyLoading.showError('请输入正确的手机号码');
      return;
    }

    final amountText = amountController.text.trim();
    if (amountText.isEmpty) {
      EasyLoading.showError('请输入转出数量');
      return;
    }

    final amount = double.tryParse(amountText) ?? 0.0;
    if (amount <= 0) {
      EasyLoading.showError('转出数量必须大于0');
      return;
    }

    if (amount > availableBalance.value) {
      EasyLoading.showError('可用消费券不足');
      return;
    }

    if (passwordController.text.trim().isEmpty) {
      EasyLoading.showError('请输入交易密码');
      return;
    }

    try {
      isLoading.value = true;
      EasyLoading.show(status: '转出中...');

      final data = {
        'phone': phoneController.text.trim(),
        'number': amountText,
        'pwd': passwordController.text.trim(),
        'remark': remarkController.text.trim(),
      };

      final response = await _userProvider.zhuanzeng(data);

      EasyLoading.dismiss();

      if (response.isSuccess) {
        EasyLoading.showSuccess('转出成功');
        await Future.delayed(const Duration(milliseconds: 1000));
        Get.back();
      } else {
        EasyLoading.showError(response.msg);
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(e.toString());
      debugPrint('转出失败: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
