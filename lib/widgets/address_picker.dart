import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 地址选择弹窗组件 - 对应 components/addressWindow/index.vue
class AddressPickerDialog extends StatefulWidget {
  final List<Map<String, dynamic>> addressList;
  final int? selectedId;
  final VoidCallback? onAddAddress;
  final Function(Map<String, dynamic>)? onSelect;

  const AddressPickerDialog({
    super.key,
    required this.addressList,
    this.selectedId,
    this.onAddAddress,
    this.onSelect,
  });

  /// 显示地址选择弹窗
  static Future<Map<String, dynamic>?> show({
    required List<Map<String, dynamic>> addressList,
    int? selectedId,
    VoidCallback? onAddAddress,
  }) async {
    return await Get.bottomSheet<Map<String, dynamic>>(
      AddressPickerDialog(
        addressList: addressList,
        selectedId: selectedId,
        onAddAddress: onAddAddress,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<AddressPickerDialog> createState() => _AddressPickerDialogState();
}

class _AddressPickerDialogState extends State<AddressPickerDialog> {
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedId;
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.7;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          _buildTitle(),
          // 地址列表
          Flexible(
            child: widget.addressList.isEmpty
                ? _buildEmptyView()
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.addressList.length,
                    itemBuilder: (context, index) {
                      return _buildAddressItem(widget.addressList[index]);
                    },
                  ),
          ),
          // 添加地址按钮
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '选择收货地址'.tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF282828),
            ),
          ),
          Positioned(
            right: 0,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: const Icon(Icons.close, size: 22, color: Color(0xFF8A8A8A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('暂无收货地址'.tr, style: const TextStyle(fontSize: 14, color: Color(0xFF999999))),
        ],
      ),
    );
  }

  Widget _buildAddressItem(Map<String, dynamic> address) {
    final id = address['id'];
    final isSelected = _selectedId == id;
    final isDefault = address['is_default'] == 1 || address['is_default'] == true;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedId = id;
        });
        widget.onSelect?.call(address);
        Get.back(result: address);
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 选中状态
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 20,
                color: isSelected ? Theme.of(context).primaryColor : const Color(0xFFCCCCCC),
              ),
            ),
            const SizedBox(width: 12),
            // 地址信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 收货人和电话
                  Row(
                    children: [
                      Text(
                        address['real_name'] ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        address['phone'] ?? '',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
                      ),
                      if (isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).round()),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            '默认'.tr,
                            style: TextStyle(fontSize: 10, color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 详细地址
                  Text(
                    _getFullAddress(address),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFullAddress(Map<String, dynamic> address) {
    final province = address['province'] ?? '';
    final city = address['city'] ?? '';
    final district = address['district'] ?? '';
    final detail = address['detail'] ?? '';
    return '$province$city$district$detail';
  }

  Widget _buildAddButton() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(15),
        child: GestureDetector(
          onTap: () {
            Get.back();
            widget.onAddAddress?.call();
          },
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(23),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, size: 20, color: Colors.white),
                const SizedBox(width: 4),
                Text('新增收货地址'.tr, style: const TextStyle(fontSize: 15, color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 地区选择器组件
class AreaPickerDialog extends StatefulWidget {
  final String? initialProvince;
  final String? initialCity;
  final String? initialDistrict;
  final List<Map<String, dynamic>>? areaData;

  const AreaPickerDialog({
    super.key,
    this.initialProvince,
    this.initialCity,
    this.initialDistrict,
    this.areaData,
  });

  /// 显示地区选择弹窗
  static Future<Map<String, String>?> show({
    String? initialProvince,
    String? initialCity,
    String? initialDistrict,
    List<Map<String, dynamic>>? areaData,
  }) async {
    return await Get.bottomSheet<Map<String, String>>(
      AreaPickerDialog(
        initialProvince: initialProvince,
        initialCity: initialCity,
        initialDistrict: initialDistrict,
        areaData: areaData,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<AreaPickerDialog> createState() => _AreaPickerDialogState();
}

class _AreaPickerDialogState extends State<AreaPickerDialog> {
  int _currentLevel = 0; // 0: 省, 1: 市, 2: 区
  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedDistrict;
  int? _selectedProvinceId;
  int? _selectedCityId;

  List<Map<String, dynamic>> _currentList = [];
  final List<Map<String, dynamic>> _provinces = [];
  final List<Map<String, dynamic>> _cities = [];
  final List<Map<String, dynamic>> _districts = [];

  @override
  void initState() {
    super.initState();
    _selectedProvince = widget.initialProvince;
    _selectedCity = widget.initialCity;
    _selectedDistrict = widget.initialDistrict;
    _initData();
  }

  void _initData() {
    // 这里需要从API获取地区数据
    // 暂时使用示例数据
    if (widget.areaData != null) {
      _provinces.addAll(widget.areaData!);
      _currentList = _provinces;
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.6;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          _buildTitle(),
          // 已选择的面包屑
          _buildBreadcrumb(),
          // 地区列表
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _currentList.length,
              itemBuilder: (context, index) {
                return _buildAreaItem(_currentList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '选择地区'.tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF282828),
            ),
          ),
          Positioned(
            right: 0,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: const Icon(Icons.close, size: 22, color: Color(0xFF8A8A8A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          _buildBreadcrumbItem(_selectedProvince ?? '请选择'.tr, 0, isActive: _currentLevel == 0),
          if (_selectedProvince != null) ...[
            const Icon(Icons.chevron_right, size: 16, color: Color(0xFF999999)),
            _buildBreadcrumbItem(_selectedCity ?? '请选择'.tr, 1, isActive: _currentLevel == 1),
          ],
          if (_selectedCity != null) ...[
            const Icon(Icons.chevron_right, size: 16, color: Color(0xFF999999)),
            _buildBreadcrumbItem(_selectedDistrict ?? '请选择'.tr, 2, isActive: _currentLevel == 2),
          ],
        ],
      ),
    );
  }

  Widget _buildBreadcrumbItem(String text, int level, {bool isActive = false}) {
    return GestureDetector(
      onTap: () {
        if (level < _currentLevel) {
          setState(() {
            _currentLevel = level;
            if (level == 0) {
              _currentList = _provinces;
              _selectedCity = null;
              _selectedDistrict = null;
            } else if (level == 1) {
              _currentList = _cities;
              _selectedDistrict = null;
            }
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isActive ? Theme.of(context).primaryColor : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }

  Widget _buildAreaItem(Map<String, dynamic> area) {
    final name = area['name'] ?? '';
    bool isSelected = false;

    if (_currentLevel == 0) {
      isSelected = _selectedProvince == name;
    } else if (_currentLevel == 1) {
      isSelected = _selectedCity == name;
    } else {
      isSelected = _selectedDistrict == name;
    }

    return GestureDetector(
      onTap: () => _onSelectArea(area),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Theme.of(context).primaryColor : const Color(0xFF333333),
              ),
            ),
            if (isSelected) Icon(Icons.check, size: 18, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }

  void _onSelectArea(Map<String, dynamic> area) {
    final name = area['name'] ?? '';
    final id = area['id'];
    final children = area['children'] as List<Map<String, dynamic>>? ?? [];

    setState(() {
      if (_currentLevel == 0) {
        _selectedProvince = name;
        _selectedProvinceId = id;
        _selectedCity = null;
        _selectedDistrict = null;
        if (children.isNotEmpty) {
          _cities.clear();
          _cities.addAll(children);
          _currentList = _cities;
          _currentLevel = 1;
        } else {
          _confirmSelection();
        }
      } else if (_currentLevel == 1) {
        _selectedCity = name;
        _selectedCityId = id;
        _selectedDistrict = null;
        if (children.isNotEmpty) {
          _districts.clear();
          _districts.addAll(children);
          _currentList = _districts;
          _currentLevel = 2;
        } else {
          _confirmSelection();
        }
      } else {
        _selectedDistrict = name;
        _confirmSelection();
      }
    });
  }

  void _confirmSelection() {
    final result = {
      'province': _selectedProvince ?? '',
      'city': _selectedCity ?? '',
      'district': _selectedDistrict ?? '',
      'province_id': _selectedProvinceId,
      'city_id': _selectedCityId,
    };
    Get.back(result: result);
  }
}
