import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'user_info_controller.dart';

/// 个人信息页面
/// 对应原 pages/users/user_info/index.vue
class UserInfoView extends GetView<UserInfoController> {
  const UserInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人资料'), centerTitle: true, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // 头像部分
            _buildAvatarItem(context),
            const SizedBox(height: 10),
            // 昵称和性别
            _buildInfoList(context),
            const SizedBox(height: 53), // 105rpx
            // 保存按钮
            _buildSaveButton(context),
          ],
        ),
      ),
    );
  }

  /// 头像项
  Widget _buildAvatarItem(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => _showUploadDialog(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '头像',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
              ),
              Row(
                children: [
                  Obx(
                    () => ClipOval(
                      child:
                          controller.userInfo?.avatar != null &&
                              controller.userInfo!.avatar.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: controller.userInfo!.avatar,
                              width: 36, // 100rpx
                              height: 36,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 36,
                                height: 36,
                                color: Colors.grey[300],
                                child: const Icon(Icons.person, size: 25),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 36,
                                height: 36,
                                color: Colors.grey[300],
                                child: const Icon(Icons.person, size: 25),
                              ),
                            )
                          : Container(
                              width: 36,
                              height: 36,
                              color: Colors.grey[300],
                              child: const Icon(Icons.person, size: 25),
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 信息列表（昵称、性别）
  Widget _buildInfoList(BuildContext context) {
    return Column(
      spacing: 1,
      children: [
        // 昵称
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              SizedBox(
                width: 60, // 约20%
                child: const Text(
                  '昵称',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
                ),
              ),
              Expanded(
                child: Obx(
                  () => TextFormField(
                    maxLength: 12,
                    controller: TextEditingController(text: controller.userInfo?.nickname),
                    textAlign: TextAlign.right,
                    onChanged: (value) => controller.updateNickname(value),
                    decoration: InputDecoration(
                      hintText: '请输入昵称',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      counter: SizedBox.shrink(),
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 6),
                    ),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ],
          ),
        ),
        // 分隔线（实际上uni-app没有分隔线，但视觉上有）
        // 性别选择
        InkWell(
          onTap: () => _showGenderPicker(context),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '性别',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
                ),
                Row(
                  children: [
                    Obx(
                      () => Text(
                        controller.genderOptions[controller.genderIndex],
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 保存按钮
  /// 对应 uni-app 的 type="warn" 红色按钮
  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: () => _saveUserInfo(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE64340), // 红色警告色
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 0,
        ),
        child: const Text('保存', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ),
    );
  }

  /// 显示头像上传确认弹框
  /// 对应 uni-app 的 uni.showModal 先确认权限
  void _showUploadDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          '提示',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          '需要获取相册的读取权限和摄像头的权限进行更换头像',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Get.back();
              _selectAvatar();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 选择头像
  void _selectAvatar() {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照'),
                onTap: () {
                  Get.back();
                  controller.pickImageFromCamera();
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () {
                  Get.back();
                  controller.pickImageFromGallery();
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('取消', textAlign: TextAlign.center),
                onTap: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示性别选择器
  /// 对应 uni-app 的 picker
  void _showGenderPicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  '选择性别',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const Divider(height: 1),
              ...controller.genderOptions.asMap().entries.map((entry) {
                int index = entry.key;
                String gender = entry.value;
                return ListTile(
                  title: Text(
                    gender,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: controller.genderIndex == index
                          ? Theme.of(context).primaryColor
                          : Colors.black,
                    ),
                  ),
                  onTap: () {
                    controller.updateGenderIndex(index);
                    Get.back();
                  },
                );
              }),
              const Divider(height: 1),
              ListTile(
                title: const Text('取消', textAlign: TextAlign.center),
                onTap: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 保存用户信息
  void _saveUserInfo() async {
    // 验证昵称
    if (controller.userInfo?.nickname == null || controller.userInfo!.nickname.isEmpty) {
      EasyLoading.showToast('请输入姓名');
      return;
    }

    bool success = await controller.saveUserInfo();
    if (success) {
      Get.back(); // 返回上一页
    }
  }
}
