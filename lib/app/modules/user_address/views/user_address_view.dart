import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_icons.dart';
import '../controllers/user_address_controller.dart';

class UserAddressView extends GetView<UserAddressController> {
  const UserAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.addressId != null ? '修改地址' : '添加地址')),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Form(
          child: Column(
            children: [
              // 地址表单
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 姓名输入
                      _buildInputField(
                        label: '姓名',
                        hint: '请输入姓名',
                        initialValue: controller.addressInfo['real_name'] ?? '',
                        keyboardType: TextInputType.text,
                        onChanged: controller.updateRealName,
                      ),

                      // 电话输入
                      _buildInputField(
                        label: '联系电话',
                        hint: '请输入联系电话',
                        initialValue: controller.addressInfo['phone'] ?? '',
                        keyboardType: TextInputType.phone,
                        onChanged: controller.updatePhone,
                      ),

                      // 地区选择
                      _buildRegionSelector(),

                      // 详细地址
                      _buildInputField(
                        label: '详细地址',
                        hint: '请填写具体地址',
                        initialValue: controller.addressInfo['detail'] ?? '',
                        keyboardType: TextInputType.text,
                        maxLines: 3,
                        onChanged: controller.updateDetailAddress,
                      ),
                    ],
                  ),
                ),
              ),

              // 设置为默认地址
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Obx(
                  () => CheckboxListTile(
                    title: const Text('设置为默认地址'),
                    value: controller.isDefault,
                    onChanged: (_) => controller.toggleDefaultAddress(),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ),

              // 保存按钮
              Container(
                margin: const EdgeInsets.all(20),
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _saveAddress(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text(
                    '立即保存',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // 导入微信地址按钮（暂时隐藏，因为需要微信插件）
              /*
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => _importWechatAddress(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    '导入微信地址',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              */
            ],
          ),
        ),
      ),
    );
  }

  // 构建输入字段
  Widget _buildInputField({
    required String label,
    required String hint,
    required String initialValue,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: initialValue,
                onChanged: onChanged,
                keyboardType: keyboardType,
                maxLines: maxLines,
                decoration: InputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建地区选择器
  Widget _buildRegionSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('所在地区', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Obx(
                () => InkWell(
                  onTap: () => _showRegionPicker(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${controller.region[0]} ${controller.region[1]} ${controller.region[2]}',
                            style: TextStyle(
                              color: controller.region[0] == '省' ? Colors.grey : Colors.black,
                            ),
                          ),
                        ),
                        const Icon(AppIcons.forward, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 显示地区选择器
  void _showRegionPicker() {
    // 这里需要实现省市区选择器，可以使用第三方库如 flutter_picker 或者自定义
    // 暂时使用简单的对话框
    Get.defaultDialog(
      title: '选择地区',
      content: Column(
        children: [
          Obx(() {
            TextEditingController provinceController = TextEditingController(
              text: controller.region[0],
            );
            return TextField(
              controller: provinceController,
              decoration: const InputDecoration(labelText: '省份'),
              onChanged: (value) {
                List<String> region = [...controller.region];
                region[0] = value;
                controller.updateRegion(region);
              },
            );
          }),
          Obx(() {
            TextEditingController cityController = TextEditingController(
              text: controller.region[1],
            );
            return TextField(
              controller: cityController,
              decoration: const InputDecoration(labelText: '城市'),
              onChanged: (value) {
                List<String> region = [...controller.region];
                region[1] = value;
                controller.updateRegion(region);
              },
            );
          }),
          Obx(() {
            TextEditingController areaController = TextEditingController(
              text: controller.region[2],
            );
            return TextField(
              controller: areaController,
              decoration: const InputDecoration(labelText: '区域'),
              onChanged: (value) {
                List<String> region = [...controller.region];
                region[2] = value;
                controller.updateRegion(region);
              },
            );
          }),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('取消')),
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('确定'),
        ),
      ],
    );
  }

  // 保存地址
  void _saveAddress() async {
    bool success = await controller.saveAddress();
    if (success) {
      Get.back(); // 返回上一页
    }
  }
}
