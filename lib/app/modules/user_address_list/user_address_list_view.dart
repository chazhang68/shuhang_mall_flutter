import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import '../../core/constants/app_icons.dart';
import '../../data/models/address_model.dart';
import 'user_address_list_controller.dart';

class UserAddressListView extends GetView<UserAddressListController> {
  const UserAddressListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('地址管理'),
        centerTitle: true,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1.5), child: _buildTopLine()),
      ),
      body: SafeArea(
        child: Obx(() {
          final list = controller.addressList;
          final defaultIndex = list.indexWhere((element) => element.isDefault == 1);

          final Widget listView = list.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 80, bottom: 80),
                  children: [_buildEmpty()],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final address = list[index];
                    return _buildAddressItem(address, index, defaultIndex, theme);
                  },
                );

          return EasyRefresh(
            header: const ClassicHeader(
              dragText: '下拉刷新',
              armedText: '松手刷新',
              readyText: '正在刷新',
              processingText: '刷新中...',
              processedText: '刷新完成',
              noMoreText: '我也是有底线的',
              failedText: '刷新失败',
              messageText: '最后更新于 %T',
            ),
            footer: const ClassicFooter(
              dragText: '上拉加载',
              armedText: '松手加载',
              readyText: '正在加载',
              processingText: '加载中...',
              processedText: '加载完成',
              noMoreText: '我也是有底线的',
              failedText: '加载失败',
              messageText: '最后更新于 %T',
            ),
            onRefresh: () async => controller.getAddressList(isRefresh: true),
            onLoad: controller.loadEnd
                ? null
                : () async {
                    await controller.getAddressList();
                  },
            child: listView,
          );
        }),
      ),
      bottomNavigationBar: _buildFooter(theme),
    );
  }

  // 构建地址项
  Widget _buildAddressItem(AddressItem address, int index, int defaultIndex, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        if (controller.cartId != null && controller.cartId!.isNotEmpty) {
          controller.selectAddress(address.id);
        }
      },
      child: Container(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '收货人：${address.realName}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF282828),
                          ),
                        ),
                      ),
                      Text(
                        address.phone,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF282828)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '收货地址：${address.province}${address.city}'
                    '${address.district}${address.detail}',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF282828)),
                    softWrap: true,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 42,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Radio<int>(
                        value: index,
                        // ignore: deprecated_member_use
                        groupValue: defaultIndex,
                        // ignore: deprecated_member_use
                        onChanged: (_) => controller.setDefaultAddress(address.id, index),
                        activeColor: theme.primaryColor,
                        visualDensity: VisualDensity.compact,
                      ),
                      const Text('设为默认', style: TextStyle(fontSize: 14, color: Color(0xFF282828))),
                    ],
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => controller.editAddress(address.id),
                        child: Row(
                          children: const [
                            Icon(AppIcons.edit, size: 18, color: Color(0xFF2C2C2C)),
                            SizedBox(width: 4),
                            Text('编辑', style: TextStyle(fontSize: 14, color: Color(0xFF282828))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () => _showDeleteDialog(address.id, index),
                        child: Row(
                          children: const [
                            Icon(AppIcons.delete, size: 18, color: Color(0xFF2C2C2C)),
                            SizedBox(width: 4),
                            Text('删除', style: TextStyle(fontSize: 14, color: Color(0xFF282828))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopLine() {
    return SizedBox(
      height: 1.5,
      width: double.infinity,
      child: Image.asset('assets/images/line.jpg', fit: BoxFit.cover),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/address.png', width: 120, fit: BoxFit.contain),
          const SizedBox(height: 12),
          const Text('暂无地址', style: TextStyle(fontSize: 14, color: Color(0xFF999999))),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return SafeArea(
      top: false,
      child: Container(
        height: 53,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        color: Colors.white,
        child: SizedBox(
          height: 38,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => controller.addNewAddress(),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              padding: EdgeInsets.zero,
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(AppIcons.add, size: 18, color: Colors.white),
                SizedBox(width: 6),
                Text('添加新地址', style: TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 显示删除确认对话框
  void _showDeleteDialog(int addressId, int index) {
    final theme = Get.theme;
    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Color(0x22000000), blurRadius: 16, offset: Offset(0, 6)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCECEC),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.delete_outline, color: Color(0xFFE64A4A), size: 26),
                ),
                const SizedBox(height: 12),
                const Text('确认删除', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text(
                  '确定要删除这个地址吗？',
                  style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF666666),
                          side: const BorderSide(color: Color(0xFFDDDDDD)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('取消', style: TextStyle(fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          controller.deleteAddress(addressId, index);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: const Text('确认删除', style: TextStyle(fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
