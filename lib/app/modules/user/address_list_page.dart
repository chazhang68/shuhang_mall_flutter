import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/theme/theme_colors.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/widgets/widgets.dart';

/// 收货地址列表页
/// 对应原 pages/users/user_address_list/index.vue
class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  final List<Map<String, dynamic>> _addressList = [
    {
      'id': 1,
      'real_name': '张三',
      'phone': '13800138000',
      'province': '广东省',
      'city': '深圳市',
      'district': '南山区',
      'detail': '科技园路xxx号',
      'is_default': 1,
    },
    {
      'id': 2,
      'real_name': '李四',
      'phone': '13900139000',
      'province': '北京市',
      'city': '北京市',
      'district': '朝阳区',
      'detail': 'xxx小区x号楼',
      'is_default': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        final themeColor = controller.themeColor;

        return Scaffold(
          appBar: AppBar(title: const Text('收货地址')),
          body: _addressList.isEmpty
              ? EmptyAddress(onPressed: () => Get.toNamed(AppRoutes.addressEdit))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _addressList.length,
                  itemBuilder: (context, index) {
                    return _buildAddressItem(_addressList[index], themeColor);
                  },
                ),
          bottomNavigationBar: _buildAddButton(themeColor),
        );
      },
    );
  }

  Widget _buildAddressItem(Map<String, dynamic> address, themeColor) {
    final isDefault = address['is_default'] == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 收货人信息
          Row(
            children: [
              Text(
                address['real_name'] ?? '',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Text(
                address['phone'] ?? '',
                style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
              if (isDefault) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: themeColor.primary.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text('默认', style: TextStyle(fontSize: 10, color: themeColor.primary)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          // 详细地址
          Text(
            '${address['province']}${address['city']}${address['district']}${address['detail']}',
            style: const TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.4),
          ),
          const SizedBox(height: 12),
          // 操作按钮
          Row(
            children: [
              // 设为默认
              if (!isDefault)
                GestureDetector(
                  onTap: () => _setDefault(address['id']),
                  child: Row(
                    children: [
                      Icon(Icons.radio_button_unchecked, size: 18, color: const Color(0xFF999999)),
                      const SizedBox(width: 4),
                      const Text('设为默认', style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
                    ],
                  ),
                ),
              const Spacer(),
              // 编辑
              GestureDetector(
                onTap: () =>
                    Get.toNamed(AppRoutes.addressEdit, parameters: {'id': '${address['id']}'}),
                child: const Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 16, color: Color(0xFF666666)),
                    SizedBox(width: 4),
                    Text('编辑', style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // 删除
              GestureDetector(
                onTap: () => _deleteAddress(address['id']),
                child: const Row(
                  children: [
                    Icon(Icons.delete_outline, size: 16, color: Color(0xFF666666)),
                    SizedBox(width: 4),
                    Text('删除', style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(ThemeColorData themeColor) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(15),
        child: GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.addressEdit),
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: themeColor.primary,
              borderRadius: BorderRadius.circular(23),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 20, color: Colors.white),
                SizedBox(width: 4),
                Text('新增收货地址', style: TextStyle(fontSize: 15, color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setDefault(int id) {
    setState(() {
      for (var addr in _addressList) {
        addr['is_default'] = addr['id'] == id ? 1 : 0;
      }
    });
    Get.snackbar('成功', '设置默认地址成功');
  }

  void _deleteAddress(int id) {
    Get.dialog(
      AlertDialog(
        title: const Text('提示'),
        content: const Text('确定要删除该地址吗？'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Get.back();
              setState(() {
                _addressList.removeWhere((addr) => addr['id'] == id);
              });
              Get.snackbar('成功', '删除成功');
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
