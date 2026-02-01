import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:get/get.dart';
import '../../data/providers/user_provider.dart';
import '../../theme/theme_colors.dart';
import '../../../widgets/empty_page.dart';

class UserAddressListPage extends StatefulWidget {
  const UserAddressListPage({super.key});

  @override
  State<UserAddressListPage> createState() => _UserAddressListPageState();
}

class _UserAddressListPageState extends State<UserAddressListPage> {
  final UserProvider _userProvider = UserProvider();

  List<Map<String, dynamic>> _addressList = [];
  int _page = 1;
  bool _loadEnd = false;
  bool _loading = false;
  String? _cartId;

  @override
  void initState() {
    super.initState();
    _cartId = Get.parameters['cartId'];
    _getAddressList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getAddressList({bool reset = false}) async {
    if (reset) {
      _page = 1;
      _loadEnd = false;
    }

    if (_loadEnd) {
      return;
    }

    if (_loading) return;

    setState(() {
      _loading = true;
    });

    final response = await _userProvider.getAddressList({'page': _page, 'limit': 20});

    if (response.isSuccess && response.data != null) {
      List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(response.data);

      setState(() {
        if (reset) {
          _addressList = list;
        } else {
          _addressList.addAll(list);
        }

        if (list.length < 20) {
          _loadEnd = true;
        }
        _page++;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _setDefault(int id) async {
    final response = await _userProvider.setAddressDefault(id);
    if (response.isSuccess) {
      _getAddressList(reset: true);
    }
  }

  Future<void> _deleteAddress(int index) async {
    int id = _addressList[index]['id'] ?? 0;

    bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个地址吗？'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('取消')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('删除', style: TextStyle(color: ThemeColors.red.primary)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final response = await _userProvider.delAddress(id);
    if (response.isSuccess) {
      setState(() {
        _addressList.removeAt(index);
      });
      FlutterToastPro.showMessage('删除成功');
    }
  }

  void _editAddress(int id) {
    Get.toNamed('/user/address-edit', parameters: {'id': id.toString()})?.then((_) {
      _getAddressList(reset: true);
    });
  }

  void _addAddress() {
    Get.toNamed('/user/address-edit')?.then((_) {
      _getAddressList(reset: true);
    });
  }

  void _selectAddress(int id) {
    if (_cartId != null) {
      Get.back(result: id);
    }
  }

  Widget _buildAddressItem(Map<String, dynamic> item, int index) {
    String realName = item['real_name'] ?? '';
    String phone = item['phone'] ?? '';
    String province = item['province'] ?? '';
    String city = item['city'] ?? '';
    String district = item['district'] ?? '';
    String detail = item['detail'] ?? '';
    bool isDefault = item['is_default'] == 1 || item['is_default'] == true;
    int id = item['id'] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // 地址信息
          GestureDetector(
            onTap: () => _selectAddress(id),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('收货人：', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(
                        realName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      Text(phone, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '收货地址：$province$city$district$detail',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // 操作栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 设为默认
                GestureDetector(
                  onTap: () => isDefault ? null : _setDefault(id),
                  child: Row(
                    children: [
                      Icon(
                        isDefault ? Icons.check_circle : Icons.radio_button_unchecked,
                        size: 20,
                        color: isDefault ? ThemeColors.red.primary : Colors.grey[400],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '设为默认',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDefault ? ThemeColors.red.primary : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // 编辑和删除
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _editAddress(id),
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('编辑', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () => _deleteAddress(index),
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('删除', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('地址管理'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: EasyRefresh(
              header: const ClassicHeader(
                dragText: '下拉刷新',
                armedText: '松手刷新',
                processingText: '刷新中...',
                processedText: '刷新完成',
                failedText: '刷新失败',
              ),
              footer: const ClassicFooter(
                dragText: '上拉加载',
                armedText: '松手加载',
                processingText: '加载中...',
                processedText: '加载完成',
                failedText: '加载失败',
                noMoreText: '我也是有底线的',
              ),
              onRefresh: () => _getAddressList(reset: true),
              onLoad: _loadEnd ? null : () => _getAddressList(),
              child: _addressList.isEmpty && !_loading
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [EmptyPage(text: '暂无收货地址')],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 8, bottom: 100),
                      itemCount: _addressList.length,
                      itemBuilder: (context, index) =>
                          _buildAddressItem(_addressList[index], index),
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addAddress,
              icon: const Icon(Icons.add_location_alt),
              label: const Text('添加新地址'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.red.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
