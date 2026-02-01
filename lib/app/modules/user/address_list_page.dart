import 'package:flutter/material.dart';
import 'package:shuhang_mall_flutter/app/modules/user_address_list/bindings/user_address_list_binding.dart';
import 'package:shuhang_mall_flutter/app/modules/user_address_list/views/user_address_list_view.dart';

/// 收货地址列表页
/// 对应原 pages/users/user_address_list/index.vue
class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  @override
  void initState() {
    super.initState();
    UserAddressListBinding().dependencies();
  }

  @override
  Widget build(BuildContext context) {
    return const UserAddressListView();
  }
}
