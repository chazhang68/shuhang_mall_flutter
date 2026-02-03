import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_icons.dart';
import '../controllers/user_address_controller.dart';

class UserAddressView extends GetView<UserAddressController> {
  const UserAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.addressId != null ? '修改地址' : '添加地址'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F5F5),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Form(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      _buildInputRow(
                        label: '姓名',
                        hint: '请输入姓名',
                        controller: controller.realNameController,
                        keyboardType: TextInputType.text,
                      ),
                      _buildInputRow(
                        label: '联系电话',
                        hint: '请输入联系电话',
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      _buildRegionRow(theme),
                      _buildInputRow(
                        label: '详细地址',
                        hint: '请填写具体地址',
                        controller: controller.detailController,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  color: Colors.white,
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: InkWell(
                    onTap: controller.toggleDefaultAddress,
                    child: Row(
                      children: [
                        Obx(
                          () => Checkbox(
                            value: controller.isDefault,
                            onChanged: (_) => controller.toggleDefaultAddress(),
                            shape: CircleBorder(),
                          ),
                        ),
                        const Text(
                          '设置为默认地址',
                          style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: 345,
                  height: 43,
                  child: ElevatedButton(
                    onPressed: _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    child: const Text('立即保存', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputRow({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 98,
            child: Text(label, style: const TextStyle(fontSize: 15, color: Color(0xFF333333))),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 15, color: Color(0xFFCCCCCC)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                isDense: true,
                filled: true,
                fillColor: Colors.transparent,
                focusedBorder: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionRow(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 98,
            child: Text('所在地区', style: TextStyle(fontSize: 15, color: Color(0xFF333333))),
          ),
          Expanded(
            child: InkWell(
              onTap: _showRegionPicker,
              child: Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => Text(
                        '${controller.region[0]}，${controller.region[1]}，${controller.region[2]}',
                        style: TextStyle(
                          fontSize: 15,
                          color: controller.region[0] == '省'
                              ? const Color(0xFFCCCCCC)
                              : const Color(0xFF333333),
                        ),
                      ),
                    ),
                  ),
                  Icon(CupertinoIcons.location_solid, size: 20, color: theme.primaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 显示地区选择器
  void _showRegionPicker() {
    if (controller.districtData.isEmpty) {
      Get.snackbar('提示', '地区数据加载中');
      return;
    }

    showModalBottomSheet<void>(
      context: Get.context!,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              if (controller.multiArray.length < 3) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              int safeIndex(int length, int index) {
                if (length <= 0) return 0;
                return index.clamp(0, length - 1);
              }

              final provinceIndex = safeIndex(
                controller.multiArray[0].length,
                controller.multiIndex[0],
              );
              final cityIndex = safeIndex(
                controller.multiArray[1].length,
                controller.multiIndex[1],
              );
              final districtIndex = safeIndex(
                controller.multiArray[2].length,
                controller.multiIndex[2],
              );

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(onPressed: () => Get.back(), child: const Text('取消')),
                      const Text(
                        '选择地区',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.applyRegionSelection();
                          Get.back();
                        },
                        child: const Text('确定'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: provinceIndex,
                            ),
                            backgroundColor: Colors.white,
                            itemExtent: 36,
                            onSelectedItemChanged: controller.updateProvinceIndex,
                            children: controller.multiArray[0]
                                .map(
                                  (item) => Center(
                                    child: Text(item, style: const TextStyle(fontSize: 13)),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(initialItem: cityIndex),
                            backgroundColor: Colors.white,
                            itemExtent: 36,
                            onSelectedItemChanged: controller.updateCityIndex,
                            children: controller.multiArray[1]
                                .map(
                                  (item) => Center(
                                    child: Text(item, style: const TextStyle(fontSize: 13)),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: districtIndex,
                            ),
                            backgroundColor: Colors.white,
                            itemExtent: 36,
                            onSelectedItemChanged: controller.updateDistrictIndex,
                            children: controller.multiArray[2]
                                .map(
                                  (item) => Center(
                                    child: Text(item, style: const TextStyle(fontSize: 13)),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  // 保存地址
  void _saveAddress() async {
    await controller.saveAddress();
  }
}
