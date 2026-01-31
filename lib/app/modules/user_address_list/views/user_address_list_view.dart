import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../core/constants/app_icons.dart';
import '../controllers/user_address_list_controller.dart';

class UserAddressListView extends GetView<UserAddressListController> {
  const UserAddressListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地址管理'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 地址列表
            Expanded(
              child: SmartRefresher(
                onRefresh: () => controller.getAddressList(isRefresh: true),
                onLoading: () => controller.loadMore(),
                controller: RefreshController(initialRefresh: true),
                child: Obx(() {
                  if (controller.addressList.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(AppIcons.location, size: 60, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('暂无地址', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.addressList.length,
                    itemBuilder: (context, index) {
                      final address = controller.addressList[index];
                      return _buildAddressItem(address, index);
                    },
                  );
                }),
              ),
            ),

            // 底部操作栏
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha((0.2 * 255).round()),
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.addNewAddress(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text(
                        '添加新地址',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建地址项
  Widget _buildAddressItem(dynamic address, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 收货人信息
            Row(
              children: [
                Expanded(
                  child: Text(
                    '收货人：${address['real_name'] ?? ''}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  address['phone'] ?? '',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 地址信息
            Text(
              '收货地址：${address['province'] ?? ''}${address['city'] ?? ''}${address['district'] ?? ''}${address['detail'] ?? ''}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              softWrap: true,
            ),
            const SizedBox(height: 16),

            // 操作按钮行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 设为默认地址
                Row(
                  children: [
                    Obx(
                      () => Checkbox(
                        value: (address['is_default'] ?? 0) == 1,
                        onChanged: (value) =>
                            controller.setDefaultAddress(address['id'] ?? 0, index),
                      ),
                    ),
                    const Text('设为默认'),
                  ],
                ),

                // 编辑和删除按钮
                Row(
                  children: [
                    TextButton(
                      onPressed: () => controller.editAddress(address['id'] ?? 0),
                      child: const Text('编辑', style: TextStyle(color: Colors.blue)),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () => _showDeleteDialog(address['id'] ?? 0, index),
                      child: const Text('删除', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 显示删除确认对话框
  void _showDeleteDialog(int addressId, int index) {
    Get.defaultDialog(
      title: '确认删除',
      content: const Text('确定要删除这个地址吗？'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('取消')),
        TextButton(
          onPressed: () {
            Get.back();
            controller.deleteAddress(addressId, index);
          },
          child: const Text('删除', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
