import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import '../../data/models/address_model.dart';
import '../../data/models/city_model.dart';
import '../../data/providers/public_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../routes/app_routes.dart';

class UserAddressController extends GetxController {
  final UserProvider _userProvider = UserProvider();
  final PublicProvider _publicProvider = PublicProvider();

  final TextEditingController realNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController detailController = TextEditingController();

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
  final RxList<CityNode> _districtData = <CityNode>[].obs;
  List<CityNode> get districtData => _districtData;

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

  // 订单相关参数
  String? cartId;
  int pinkId = 0;
  int couponId = 0;
  String news = '0';
  int noCoupon = 0;

  @override
  void onInit() {
    super.onInit();
    _bindParams();
    _initializeRegionData();
    _loadInitialData();
  }

  @override
  void onClose() {
    realNameController.dispose();
    phoneController.dispose();
    detailController.dispose();
    super.onClose();
  }

  void _bindParams() {
    final params = Get.parameters;
    final args = Get.arguments;

    final argId = args is Map ? args['id']?.toString() : null;
    addressId = params['id'] ?? argId;

    cartId = params['cartId'];
    pinkId = _toInt(params['pinkId']);
    couponId = _toInt(params['couponId']);
    news = params['new'] ?? params['news'] ?? '0';
    noCoupon = _toInt(params['noCoupon']);
  }

  Future<void> _loadInitialData() async {
    await getCityList();
    if (addressId != null && addressId!.isNotEmpty) {
      await getAddressDetail(addressId!);
    }
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
      final response = await _publicProvider.getCityList();
      if (response.isSuccess && response.data != null) {
        final rawList = response.data as List<dynamic>;
        final list = rawList
            .map((item) => CityNode.fromJson(item as Map<String, dynamic>))
            .toList();
        _districtData.assignAll(list);
        _syncIndicesFromRegion();
        _buildMultiArray();
        _applyRegionFromIndices();
      }
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
        final detail = AddressDetail.fromJson(response.data as Map<String, dynamic>);

        realNameController.text = detail.realName;
        phoneController.text = detail.phone;
        detailController.text = detail.detail;

        _region.assignAll([detail.province, detail.city, detail.district]);
        _isDefault.value = detail.isDefault == 1;
        _cityId.value = detail.cityId;

        _syncIndicesFromRegion();
        _buildMultiArray();
      }
    } catch (e) {
      debugPrint('获取地址详情失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void updateRegion(List<String> regionList) {
    _region.assignAll(regionList);
  }

  // 切换默认地址状态
  void toggleDefaultAddress() {
    _isDefault.value = !_isDefault.value;
  }

  // 保存地址信息
  Future<void> saveAddress() async {
    try {
      _isLoading.value = true;

      // 验证输入
      if (realNameController.text.trim().isEmpty) {
        FlutterToastPro.showMessage('请填写收货人姓名');
        return;
      }

      if (phoneController.text.trim().isEmpty) {
        FlutterToastPro.showMessage('请填写联系电话');
        return;
      }

      if (!RegExp(r'^1(3|4|5|7|8|9|6)\d{9}$').hasMatch(phoneController.text)) {
        FlutterToastPro.showMessage('请输入正确的手机号码');
        return;
      }

      if (_region[0] == '省') {
        FlutterToastPro.showMessage('请选择所在地区');
        return;
      }

      if (detailController.text.trim().isEmpty) {
        FlutterToastPro.showMessage('请填写详细地址');
        return;
      }

      // 准备提交数据
      Map<String, dynamic> submitData = {
        'id': addressId != null ? int.parse(addressId!) : 0, // 如果是编辑则传入ID
        'real_name': realNameController.text,
        'phone': phoneController.text,
        'detail': detailController.text,
        'is_default': _isDefault.value ? 1 : 0,
        'address': {
          'province': _region[0],
          'city': _region[1],
          'district': _region[2],
          'city_id': _cityId.value,
        },
      };

      // 调用API保存地址
      final response = await _userProvider.editAddress(submitData);
      if (response.isSuccess) {
        FlutterToastPro.showMessage(addressId != null ? '修改成功' : '添加成功');
        final id = _resolveSavedId(response.data);
        _handleAfterSave(id);
        return;
      } else {
        FlutterToastPro.showMessage(response.msg);
        return;
      }
    } catch (e) {
      debugPrint('保存地址失败: $e');
      FlutterToastPro.showMessage('保存失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  int _resolveSavedId(dynamic data) {
    if (data is Map<String, dynamic>) {
      return _toInt(data['id']);
    }
    return _toInt(addressId);
  }

  void _handleAfterSave(int savedId) {
    if (cartId != null && cartId!.isNotEmpty) {
      Get.offNamed(
        AppRoutes.orderConfirm,
        parameters: {
          'cartId': cartId!,
          'addressId': savedId.toString(),
          'pinkId': pinkId.toString(),
          'couponId': couponId.toString(),
          'new': news,
          'noCoupon': noCoupon.toString(),
          'is_address': '1',
        },
      );
      return;
    }

    Get.back(result: true);
  }

  void updateProvinceIndex(int index) {
    _multiIndex[0] = index;
    _multiIndex[1] = 0;
    _multiIndex[2] = 0;
    _buildMultiArray();
  }

  void updateCityIndex(int index) {
    _multiIndex[1] = index;
    _multiIndex[2] = 0;
    _buildMultiArray();
  }

  void updateDistrictIndex(int index) {
    _multiIndex[2] = index;
    _buildMultiArray();
  }

  void applyRegionSelection() {
    _applyRegionFromIndices();
  }

  void _buildMultiArray() {
    if (_districtData.isEmpty) return;

    final province = _districtData[_multiIndex[0]];
    final cityList = province.children;
    final city = cityList.isNotEmpty
        ? cityList[_multiIndex[1].clamp(0, cityList.length - 1)]
        : null;
    final areaList = city?.children ?? <CityNode>[];

    _multiArray.assignAll([
      _districtData.map((item) => item.name).toList(),
      cityList.map((item) => item.name).toList(),
      areaList.map((item) => item.name).toList(),
    ]);
  }

  void _applyRegionFromIndices() {
    if (_districtData.isEmpty) return;

    final province = _districtData[_multiIndex[0]];
    final cityList = province.children;
    final city = cityList.isNotEmpty
        ? cityList[_multiIndex[1].clamp(0, cityList.length - 1)]
        : null;
    final areaList = city?.children ?? <CityNode>[];
    final district = areaList.isNotEmpty
        ? areaList[_multiIndex[2].clamp(0, areaList.length - 1)]
        : null;

    final provinceName = province.name;
    final cityName = city?.name ?? '市';
    final districtName = district?.name ?? '区';

    _region.assignAll([provinceName, cityName, districtName]);
    _cityId.value = city?.value ?? 0;
  }

  void _syncIndicesFromRegion() {
    if (_districtData.isEmpty) return;

    final provinceIndex = _districtData.indexWhere((item) => item.name == _region[0]);
    final pIndex = provinceIndex >= 0 ? provinceIndex : 0;

    final cityList = _districtData[pIndex].children;
    final cityIndex = cityList.indexWhere((item) => item.name == _region[1]);
    final cIndex = cityIndex >= 0 ? cityIndex : 0;

    final areaList = cityList.isNotEmpty ? cityList[cIndex].children : <CityNode>[];
    final districtIndex = areaList.indexWhere((item) => item.name == _region[2]);
    final dIndex = districtIndex >= 0 ? districtIndex : 0;

    _multiIndex.assignAll([pIndex, cIndex, dIndex]);
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
