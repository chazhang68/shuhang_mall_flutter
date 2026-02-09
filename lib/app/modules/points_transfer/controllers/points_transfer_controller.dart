import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';

/// 积分转赠控制器
/// 对应原 uni-app 代码中的积分转赠功能
class PointsTransferController extends GetxController {
  final UserProvider _userProvider = UserProvider();
  final AppController _appController = Get.find<AppController>();

  // 表单控制器
  final phoneController = TextEditingController();
  final amountController = TextEditingController();
  final passwordController = TextEditingController();
  final remarkController = TextEditingController();

  // 状态变量
  final isLoading = false.obs;
  final availablePoints = 0.0.obs; // 可用积分数量 fd_ky
  final feeRate = 0.0.obs; // 手续费比例 xfq_sxf
  final feeAmount = 0.0.obs; // 损耗数量
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
        // 从用户信息中获取可用积分和手续费比例
        availablePoints.value = userInfo.integral; // 使用 integral 字段作为可用积分
        // 假设手续费比例为5%，实际应该从后端获取
        feeRate.value = 5.0;
      }
    } catch (e) {
      debugPrint('加载用户信息失败: $e');
    }
  }

  /// 监听转出数量变化，计算手续费和实际到账
  void _setupAmountListener() {
    amountController.addListener(() {
      final text = amountController.text.trim();
      if (text.isEmpty) {
        feeAmount.value = 0.0;
        actualAmount.value = 0.0;
        return;
      }

      // 只允许输入整数
      final amount = double.tryParse(text) ?? 0.0;
      if (amount != amount.floor()) {
        amountController.text = amount.floor().toString();
        return;
      }

      // 计算手续费（保留3位小数）
      feeAmount.value = double.parse((amount * feeRate.value / 100).toStringAsFixed(3));
      // 计算实际到账（保留2位小数）
      actualAmount.value = double.parse((amount - feeAmount.value).toStringAsFixed(2));
    });
  }

  /// 全部转赠
  void transferAll() {
    if (availablePoints.value > 0) {
      amountController.text = availablePoints.value.floor().toString();
    }
  }

  /// 验证表单
  bool _validateForm() {
    if (phoneController.text.trim().isEmpty) {
      EasyLoading.showError('请输入转入手机号');
      return false;
    }

    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phoneController.text.trim())) {
      EasyLoading.showError('请输入正确的手机号码');
      return false;
    }

    if (amountController.text.trim().isEmpty) {
      EasyLoading.showError('请输入转出数量');
      return false;
    }

    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
    if (amount < 1) {
      EasyLoading.showError('转出数量最少1个');
      return false;
    }

    if (amount > availablePoints.value) {
      EasyLoading.showError('可用积分不足');
      return false;
    }

    if (passwordController.text.trim().isEmpty) {
      EasyLoading.showError('请输入交易密码');
      return false;
    }

    return true;
  }

  /// 确认转赠
  Future<void> confirmTransfer() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;
      EasyLoading.show(status: '积分转出中...');

      final data = {
        'phone': phoneController.text.trim(),
        'number': amountController.text.trim(),
        'pwd': passwordController.text.trim(),
        'remark': remarkController.text.trim(),
      };

      // 调用 fudou_zhuan 接口
      final response = await _userProvider.transferPoints(data);

      EasyLoading.dismiss();

      if (response.isSuccess) {
        EasyLoading.showSuccess('转出成功');
        await Future.delayed(const Duration(milliseconds: 1000));
        Get.back();
      } else {
        EasyLoading.showError(response.msg ?? '转出失败');
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
