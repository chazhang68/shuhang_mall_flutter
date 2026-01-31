import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import '../../../data/providers/user_provider.dart';

class UserAddressController extends GetxController {
  final UserProvider _userProvider = UserProvider();

  // 地址信息
  final RxMap<String, dynamic> _addressInfo = <String, dynamic>{}.obs;
  Map<String, dynamic> get addressInfo => _addressInfo;

  // 地区选择
  final RxList<String> _region = <String>['省', '市', '区'].obs;
  List<String> get region => _region;

  // 是否为默认地址
  final RxBool _isDefault = false.obs;
  bool get isDefault => _isDefault.value;

  // 城市ID
  final RxInt _cityId = 0.obs;
  int get cityId => _cityId.value;

  // 地区数据
  final RxList<dynamic> _districtData = <dynamic>[].obs;
  List<dynamic> get districtData => _districtData;

  // 多级选择数组
  final RxList<List<String>> _multiArray = <List<String>>[].obs;
  List<List<String>> get multiArray => _multiArray;

  // 当前选择的索引
  final RxList<int> _multiIndex = <int>[0, 0, 0].obs;
  List<int> get multiIndex => _multiIndex;

  // 加载状态
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // 地址ID（用于编辑）
  String? addressId;

  @override
  void onInit() {
    super.onInit();
    // 初始化地区数据
    _initializeRegionData();
  }

  // 初始化地区数据
  void _initializeRegionData() {
    // 默认显示省市区
    _region.assignAll(['省', '市', '区']);
  }

  // 获取城市列表
  Future<void> getCityList() async {
    try {
      _isLoading.value = true;
      await _userProvider.getAddressList(null);
      // 注意：这里需要调用实际的获取城市列表API
      // 由于现有API中没有专门的城市列表接口，我们暂时模拟数据
      // 在实际应用中，需要调用特定的地区API
    } catch (e) {
      debugPrint('获取城市列表失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // 获取地址详情（用于编辑）
  Future<void> getAddressDetail(String id) async {
    try {
      _isLoading.value = true;
      final response = await _userProvider.getAddressDetail(int.parse(id));
      if (response.isSuccess && response.data != null) {
        _addressInfo.assignAll(response.data!);

        // 设置地区信息
        final province = response.data!['province'] ?? '';
        final city = response.data!['city'] ?? '';
        final district = response.data!['district'] ?? '';
        _region.assignAll([province, city, district]);

        // 设置是否为默认地址
        _isDefault.value = (response.data!['is_default'] == 1);

        // 设置城市ID
        _cityId.value = response.data!['city_id'] ?? 0;
      }
    } catch (e) {
      debugPrint('获取地址详情失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // 更新收货人姓名
  void updateRealName(String name) {
    _addressInfo['real_name'] = name;
  }

  // 更新联系电话
  void updatePhone(String phone) {
    _addressInfo['phone'] = phone;
  }

  // 更新详细地址
  void updateDetailAddress(String detail) {
    _addressInfo['detail'] = detail;
  }

  // 更新地区信息
  void updateRegion(List<String> regionList) {
    _region.assignAll(regionList);
  }

  // 切换默认地址状态
  void toggleDefaultAddress() {
    _isDefault.value = !_isDefault.value;
  }

  // 保存地址信息
  Future<bool> saveAddress() async {
    try {
      _isLoading.value = true;

      // 验证输入
      if ((_addressInfo['real_name'] ?? '').toString().trim().isEmpty) {
        FlutterToastPro.showMessage( '请填写收货人姓名');
        return false;
      }

      if ((_addressInfo['phone'] ?? '').toString().trim().isEmpty) {
        FlutterToastPro.showMessage( '请填写联系电话');
        return false;
      }

      if (!RegExp(r'^1(3|4|5|7|8|9|6)\d{9}$').hasMatch(_addressInfo['phone'])) {
        FlutterToastPro.showMessage( '请输入正确的手机号码');
        return false;
      }

      if (_region[0] == '省') {
        FlutterToastPro.showMessage( '请选择所在地区');
        return false;
      }

      if ((_addressInfo['detail'] ?? '').toString().trim().isEmpty) {
        FlutterToastPro.showMessage( '请填写详细地址');
        return false;
      }

      // 准备提交数据
      Map<String, dynamic> submitData = {
        'id': addressId != null ? int.parse(addressId!) : 0, // 如果是编辑则传入ID
        'real_name': _addressInfo['real_name'] ?? '',
        'phone': _addressInfo['phone'] ?? '',
        'province': _region[0],
        'city': _region[1],
        'district': _region[2],
        'detail': _addressInfo['detail'] ?? '',
        'is_default': _isDefault.value ? 1 : 0,
        'city_id': _cityId.value,
      };

      // 调用API保存地址
      final response = await _userProvider.editAddress(submitData);
      if (response.isSuccess) {
        FlutterToastPro.showMessage( addressId != null ? '修改成功' : '添加成功');
        return true;
      } else {
        FlutterToastPro.showMessage( response.msg);
        return false;
      }
    } catch (e) {
      debugPrint('保存地址失败: $e');
      FlutterToastPro.showMessage( '保存失败: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}


