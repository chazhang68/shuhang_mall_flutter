import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/providers/public_provider.dart';
import '../../../data/models/user_model.dart';

/// 个人信息控制器
/// 对应原 pages/users/user_info/index.vue
class UserInfoController extends GetxController {
  final UserProvider _userProvider = UserProvider();
  final PublicProvider _publicProvider = PublicProvider();
  final ImagePicker _picker = ImagePicker();

  // 用户信息
  final Rx<UserModel?> _userInfo = Rx<UserModel?>(null);
  UserModel? get userInfo => _userInfo.value;

  // 昵称（单独管理以便实时更新）
  final RxString _nickname = ''.obs;
  String get nickname => _nickname.value;

  // 头像URL
  final RxString _avatar = ''.obs;
  String get avatar => _avatar.value;

  // 性别选项 - 对应 uni-app 的 genderArray
  final List<String> genderOptions = ["男", "女"];

  // 当前选中的性别索引 - 对应 uni-app 的 genderIndex
  final RxInt _genderIndex = 0.obs;
  int get genderIndex => _genderIndex.value;

  // 加载状态
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    getUserInfo();
  }

  /// 获取用户信息
  /// 对应 uni-app 的 getUserInfo 方法
  Future<void> getUserInfo() async {
    try {
      _isLoading.value = true;

      final response = await _userProvider.getUserInfo();
      if (response.isSuccess && response.data != null) {
        _userInfo.value = response.data!;
        _nickname.value = response.data!.nickname;
        _avatar.value = response.data!.avatar;

        // 设置性别索引 - 对应 uni-app 的逻辑
        String sex = response.data!.sex ?? '';
        if (sex == '女') {
          _genderIndex.value = 1;
        } else {
          _genderIndex.value = 0;
        }
      }
    } catch (e) {
      debugPrint('获取用户信息失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// 更新昵称
  void updateNickname(String value) {
    _nickname.value = value;
    if (_userInfo.value != null) {
      _userInfo.value = _userInfo.value!.copyWith(nickname: value);
    }
  }

  /// 更新性别索引
  /// 对应 uni-app 的 changeGender 方法
  void updateGenderIndex(int index) {
    _genderIndex.value = index;
  }

  /// 从相机拍照
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        await _uploadImage(File(image.path));
      }
    } catch (e) {
      debugPrint('拍照失败: $e');
      EasyLoading.showToast('拍照失败');
    }
  }

  /// 从相册选择
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        await _uploadImage(File(image.path));
      }
    } catch (e) {
      debugPrint('选择图片失败: $e');
      EasyLoading.showToast('选择图片失败');
    }
  }

  /// 上传图片
  /// 对应 uni-app 的 uploadImageChange
  Future<void> _uploadImage(File imageFile) async {
    try {
      EasyLoading.show(status: '上传中...');

      final response = await _publicProvider.uploadFile(filePath: imageFile.path);
      if (response.isSuccess && response.data != null) {
        // 更新头像
        String imageUrl = response.data['url'] ?? '';
        _avatar.value = imageUrl;
        if (_userInfo.value != null) {
          _userInfo.value = _userInfo.value!.copyWith(avatar: imageUrl);
        }
        EasyLoading.dismiss();
      } else {
        EasyLoading.showError(response.msg.isNotEmpty ? response.msg : '上传失败');
      }
    } catch (e) {
      debugPrint('上传头像失败: $e');
      EasyLoading.showError('上传失败');
    }
  }

  /// 保存用户信息
  /// 对应 uni-app 的 formSubmit 方法
  Future<bool> saveUserInfo() async {
    try {
      _isLoading.value = true;

      // 构建更新数据 - 对应 uni-app 的 update_userInfo
      Map<String, dynamic> updateData = {
        'nickname': _nickname.value,
        'avatar': _avatar.value,
        'sex': genderOptions[_genderIndex.value],
      };

      final response = await _userProvider.userEdit(updateData);
      if (response.isSuccess) {
        // 显示成功提示 - 对应 uni-app 的 Tips
        EasyLoading.showSuccess(response.msg.isNotEmpty ? response.msg : '保存成功');
        // 重新获取用户信息以更新本地缓存
        await getUserInfo();
        return true;
      } else {
        EasyLoading.showError(response.msg.isNotEmpty ? response.msg : '保存失败');
        return false;
      }
    } catch (e) {
      debugPrint('保存用户信息失败: $e');
      EasyLoading.showError('保存失败');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}
