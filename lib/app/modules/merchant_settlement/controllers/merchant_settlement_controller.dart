import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shuhang_mall_flutter/app/data/providers/store_provider.dart';
import 'package:shuhang_mall_flutter/app/data/providers/public_provider.dart';

/// 商家入驻控制器
/// 对应原 pages/annex/settled/index.vue
class MerchantSettlementController extends GetxController {
  final StoreProvider _storeProvider = StoreProvider();
  final PublicProvider _publicProvider = PublicProvider();
  final ImagePicker _imagePicker = ImagePicker();

  // 表单控制器
  final merchantNameController = TextEditingController();
  final operatorNameController = TextEditingController();
  final idCardNumberController = TextEditingController();
  final businessLicenseNumberController = TextEditingController();
  final phoneController = TextEditingController();
  final codeController = TextEditingController();
  final inviteCodeController = TextEditingController();

  // 状态变量
  final isLoading = false.obs;
  final status = (-1).obs; // -1:未申请 0:审核中 1:审核通过 2:审核拒绝
  final refusalReason = ''.obs;
  final isAgree = false.obs; // 是否同意协议
  final showProtocol = false.obs; // 是否显示协议弹窗
  final protocol = ''.obs; // 协议内容

  // 图片相关
  final idCardFrontImage = ''.obs; // 身份证正面
  final idCardBackImage = ''.obs; // 身份证反面
  final businessLicenseImage = ''.obs; // 营业执照
  final qualificationImages = <String>[].obs; // 其他资质图片（最多10张）

  // 验证码相关
  final isCodeSending = false.obs;
  final codeCountdown = 0.obs;
  final verifyCodeKey = ''.obs;

  int? applicationId;

  @override
  void onInit() {
    super.onInit();
    _loadSettlementInfo();
  }

  @override
  void onClose() {
    merchantNameController.dispose();
    operatorNameController.dispose();
    idCardNumberController.dispose();
    businessLicenseNumberController.dispose();
    phoneController.dispose();
    codeController.dispose();
    inviteCodeController.dispose();
    super.onClose();
  }

  /// 加载商家入驻信息
  Future<void> _loadSettlementInfo() async {
    isLoading.value = true;
    try {
      final response = await _storeProvider.getMerchantSettlementInfo();
      if (response.isSuccess && response.data != null) {
        final data = response.data;
        status.value = data['status'] ?? -1;

        if (status.value != -1) {
          // 已有申请记录，填充表单
          merchantNameController.text = data['agent_name'] ?? '';
          operatorNameController.text = data['name'] ?? '';
          phoneController.text = data['phone'] ?? '';
          inviteCodeController.text = data['division_invite'] ?? '';

          if (data['images'] != null) {
            qualificationImages.value = List<String>.from(data['images']);
          }

          if (status.value == 2) {
            refusalReason.value = data['refusal_reason'] ?? '';
          }

          applicationId = data['id'];
        }
      }
    } catch (e) {
      debugPrint('加载商家入驻信息失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 获取商家入驻协议
  Future<void> loadMerchantAgreement() async {
    try {
      final response = await _storeProvider.getMerchantAgreement();
      if (response.isSuccess && response.data != null) {
        protocol.value = response.data['content'] ?? '';
        showProtocol.value = true;
      }
    } catch (e) {
      EasyLoading.showError('获取协议失败');
    }
  }

  /// 发送验证码
  Future<void> sendVerifyCode() async {
    if (isCodeSending.value || codeCountdown.value > 0) return;

    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      EasyLoading.showError('请输入手机号');
      return;
    }

    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      EasyLoading.showError('请输入正确的手机号码');
      return;
    }

    try {
      isCodeSending.value = true;

      // 获取验证码key
      final keyResponse = await _storeProvider.getVerifyCodeKey();
      if (!keyResponse.isSuccess || keyResponse.data == null) {
        EasyLoading.showError('获取验证码失败');
        return;
      }

      verifyCodeKey.value = keyResponse.data['key'] ?? '';

      // 发送验证码
      final response = await _storeProvider.sendVerifyCode({
        'phone': phone,
        'type': 'register',
        'key': verifyCodeKey.value,
      });

      if (response.isSuccess) {
        EasyLoading.showSuccess(response.msg ?? '验证码已发送');
        _startCountdown();
      } else {
        EasyLoading.showError(response.msg ?? '发送验证码失败');
      }
    } catch (e) {
      EasyLoading.showError('发送验证码失败');
    } finally {
      isCodeSending.value = false;
    }
  }

  /// 开始倒计时
  void _startCountdown() {
    codeCountdown.value = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (codeCountdown.value > 0) {
        codeCountdown.value--;
        return true;
      }
      return false;
    });
  }

  /// 选择身份证正面照片
  Future<void> pickIdCardFrontImage() async {
    final image = await _pickImage();
    if (image != null) {
      idCardFrontImage.value = image;
    }
  }

  /// 选择身份证反面照片
  Future<void> pickIdCardBackImage() async {
    final image = await _pickImage();
    if (image != null) {
      idCardBackImage.value = image;
    }
  }

  /// 选择营业执照照片
  Future<void> pickBusinessLicenseImage() async {
    final image = await _pickImage();
    if (image != null) {
      businessLicenseImage.value = image;
    }
  }

  /// 添加资质图片
  Future<void> addQualificationImage() async {
    if (qualificationImages.length >= 10) {
      EasyLoading.showError('最多上传10张图片');
      return;
    }

    final image = await _pickImage();
    if (image != null) {
      qualificationImages.add(image);
    }
  }

  /// 删除资质图片
  void removeQualificationImage(int index) {
    if (index >= 0 && index < qualificationImages.length) {
      qualificationImages.removeAt(index);
    }
  }

  /// 选择图片并上传
  Future<String?> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;

      // 上传图片
      final response = await _publicProvider.uploadFile(filePath: image.path);
      if (response.isSuccess && response.data != null) {
        return response.data['url'] as String?;
      } else {
        EasyLoading.showError('图片上传失败');
        return null;
      }
    } catch (e) {
      EasyLoading.showError('选择图片失败');
      return null;
    }
  }

  /// 删除身份证正面照片
  void removeIdCardFrontImage() {
    idCardFrontImage.value = '';
  }

  /// 删除身份证反面照片
  void removeIdCardBackImage() {
    idCardBackImage.value = '';
  }

  /// 删除营业执照照片
  void removeBusinessLicenseImage() {
    businessLicenseImage.value = '';
  }

  /// 切换协议同意状态
  void toggleAgree() {
    isAgree.value = !isAgree.value;
  }

  /// 验证表单
  bool _validateForm() {
    if (merchantNameController.text.trim().isEmpty) {
      EasyLoading.showError('请输入代理商名称');
      return false;
    }

    if (operatorNameController.text.trim().isEmpty) {
      EasyLoading.showError('请输入姓名');
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      EasyLoading.showError('请输入手机号');
      return false;
    }

    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phoneController.text.trim())) {
      EasyLoading.showError('请输入正确的手机号码');
      return false;
    }

    if (codeController.text.trim().isEmpty) {
      EasyLoading.showError('填写验证码');
      return false;
    }

    if (qualificationImages.isEmpty) {
      EasyLoading.showError('请上传营业执照');
      return false;
    }

    if (!isAgree.value) {
      EasyLoading.showError('请勾选并同意入驻协议');
      return false;
    }

    return true;
  }

  /// 提交申请
  Future<void> submitApplication() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      final data = {
        'agent_name': merchantNameController.text.trim(),
        'name': operatorNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'code': codeController.text.trim(),
        'division_invite': inviteCodeController.text.trim(),
        'images': qualificationImages.toList(),
        'id': applicationId ?? 0,
      };

      final response = await _storeProvider.createMerchantSettlement(data);

      if (response.isSuccess) {
        EasyLoading.showSuccess('提交成功');
        // 延迟刷新状态
        await Future.delayed(const Duration(milliseconds: 1000));
        await _loadSettlementInfo();
      } else {
        EasyLoading.showError(response.msg ?? '提交失败');
      }
    } catch (e) {
      EasyLoading.showError('提交失败');
    } finally {
      isLoading.value = false;
    }
  }

  /// 重新申请
  void applyAgain() {
    status.value = -1;
    refusalReason.value = '';
  }

  /// 返回首页
  void goHome() {
    Get.offAllNamed('/home');
  }
}
