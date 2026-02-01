import 'package:flutter/material.dart';
import 'package:shuhang_mall_flutter/app/modules/user_address/bindings/user_address_binding.dart';
import 'package:shuhang_mall_flutter/app/modules/user_address/views/user_address_view.dart';

/// 地址编辑页
/// 对应原 pages/users/user_address/index.vue
class AddressEditPage extends StatefulWidget {
  const AddressEditPage({super.key});

  @override
  State<AddressEditPage> createState() => _AddressEditPageState();
}

class _AddressEditPageState extends State<AddressEditPage> {
  @override
  void initState() {
    super.initState();
    UserAddressBinding().dependencies();
  }

  @override
  Widget build(BuildContext context) {
    return const UserAddressView();
  }
}
