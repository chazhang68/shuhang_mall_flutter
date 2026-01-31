import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/app/data/models/user_model.dart';
import 'package:shuhang_mall_flutter/app/core/constants/app_images.dart';

/// 用户信息编辑页面
/// 对应原 pages/users/user_info/index.vue
class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final UserProvider _userProvider = Get.find<UserProvider>();
  final TextEditingController _nicknameController = TextEditingController();

  UserModel? _userInfo;
  bool _isLoading = true;
  int _genderIndex = 0;
  final List<String> _genderList = ['男', '女'];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final response = await _userProvider.getUserInfo();
    if (response.isSuccess && response.data != null) {
      setState(() {
        _userInfo = response.data;
        _nicknameController.text = _userInfo?.nickname ?? '';
        _genderIndex = _userInfo?.sex == '女' ? 1 : 0;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('个人信息'), centerTitle: true, elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // 头像
                  _buildAvatarSection(),
                  const SizedBox(height: 12),
                  // 昵称
                  _buildNicknameSection(),
                  const SizedBox(height: 1),
                  // 性别
                  _buildGenderSection(),
                  const SizedBox(height: 50),
                  // 保存按钮
                  _buildSaveButton(),
                ],
              ),
            ),
    );
  }

  /// 头像区域
  Widget _buildAvatarSection() {
    String avatar = _userInfo?.avatar ?? '';
    return GestureDetector(
      onTap: _pickAvatar,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Text('头像', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const Spacer(),
            ClipOval(
              child: avatar.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: avatar,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        AppImages.defaultAvatar,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(AppImages.defaultAvatar, width: 50, height: 50, fit: BoxFit.cover),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// 昵称区域
  Widget _buildNicknameSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '昵称',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey[800]),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _nicknameController,
              textAlign: TextAlign.right,
              maxLength: 12,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '请输入昵称',
                counterText: '',
              ),
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  /// 性别区域
  Widget _buildGenderSection() {
    return GestureDetector(
      onTap: _showGenderPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Text(
              '性别',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey[800]),
            ),
            const Spacer(),
            Text(_genderList[_genderIndex], style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// 保存按钮
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _saveUserInfo,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: const Text(
          '保存',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ),
    );
  }

  /// 选择头像
  Future<void> _pickAvatar() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('提示'),
        content: const Text('需要获取相册的读取权限和摄像头的权限进行更换头像'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('取消')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('确定')),
        ],
      ),
    );

    if (confirm != true) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // TODO: 上传图片并更新头像
      FlutterToastPro.showMessage( '头像上传功能待实现');
    }
  }

  /// 显示性别选择器
  void _showGenderPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Center(child: Text('男')),
                onTap: () {
                  setState(() => _genderIndex = 0);
                  Navigator.pop(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Center(child: Text('女')),
                onTap: () {
                  setState(() => _genderIndex = 1);
                  Navigator.pop(context);
                },
              ),
              const Divider(height: 8, color: Color(0xFFF5F5F5)),
              ListTile(
                title: const Center(child: Text('取消')),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 保存用户信息
  Future<void> _saveUserInfo() async {
    String nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      FlutterToastPro.showMessage( '请输入昵称');
      return;
    }

    final response = await _userProvider.updateUserInfo({
      'nickname': nickname,
      'avatar': _userInfo?.avatar ?? '',
      'sex': _genderList[_genderIndex],
    });

    if (response.isSuccess) {
      FlutterToastPro.showMessage( response.msg);
      Get.back();
    } else {
      FlutterToastPro.showMessage( response.msg);
    }
  }
}


