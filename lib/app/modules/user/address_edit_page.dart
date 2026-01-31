import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/theme/theme_colors.dart';

/// 地址编辑页
/// 对应原 pages/users/user_address/index.vue
class AddressEditPage extends StatefulWidget {
  const AddressEditPage({super.key});

  @override
  State<AddressEditPage> createState() => _AddressEditPageState();
}

class _AddressEditPageState extends State<AddressEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _detailController = TextEditingController();

  String? _addressId;
  String _province = '';
  String _city = '';
  String _district = '';
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addressId = Get.parameters['id'];
    if (_addressId != null) {
      _loadAddressData();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  void _loadAddressData() {
    // 模拟加载地址数据
    setState(() {
      _nameController.text = '张三';
      _phoneController.text = '13800138000';
      _province = '广东省';
      _city = '深圳市';
      _district = '南山区';
      _detailController.text = '科技园路xxx号';
      _isDefault = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        final themeColor = controller.themeColor;

        return Scaffold(
          appBar: AppBar(title: Text(_addressId != null ? '编辑地址' : '新增地址')),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                // 收货人
                _buildInputField(
                  label: '收货人',
                  controller: _nameController,
                  hintText: '请输入收货人姓名',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入收货人姓名';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                // 手机号
                _buildInputField(
                  label: '手机号',
                  controller: _phoneController,
                  hintText: '请输入手机号',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入手机号';
                    }
                    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                      return '请输入正确的手机号';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                // 选择地区
                _buildRegionPicker(themeColor),
                const SizedBox(height: 15),
                // 详细地址
                _buildInputField(
                  label: '详细地址',
                  controller: _detailController,
                  hintText: '请输入详细地址',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入详细地址';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // 设为默认
                _buildDefaultSwitch(themeColor),
                const SizedBox(height: 30),
                // 保存按钮
                _buildSaveButton(themeColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            style: const TextStyle(fontSize: 14),
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildRegionPicker(ThemeColorData themeColor) {
    return GestureDetector(
      onTap: _selectRegion,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '所在地区',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _province.isEmpty ? '请选择省市区' : '$_province $_city $_district',
                    style: TextStyle(
                      fontSize: 14,
                      color: _province.isEmpty ? const Color(0xFF999999) : const Color(0xFF333333),
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF999999), size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultSwitch(ThemeColorData themeColor) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('设为默认地址', style: TextStyle(fontSize: 14, color: Color(0xFF333333))),
          Switch(
            value: _isDefault,
            onChanged: (value) {
              setState(() {
                _isDefault = value;
              });
            },
            activeThumbColor: themeColor.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(ThemeColorData themeColor) {
    return GestureDetector(
      onTap: _isLoading ? null : _saveAddress,
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: themeColor.primary,
          borderRadius: BorderRadius.circular(23),
        ),
        alignment: Alignment.center,
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('保存', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  void _selectRegion() async {
    // 显示地区选择器
    // 这里简化处理，直接设置默认值
    setState(() {
      _province = '广东省';
      _city = '深圳市';
      _district = '南山区';
    });
  }

  void _saveAddress() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    if (_province.isEmpty) {
      FlutterToastPro.showMessage( '请选择所在地区');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 模拟保存
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
      Get.back();
      FlutterToastPro.showMessage( '保存成功');
    });
  }
}


