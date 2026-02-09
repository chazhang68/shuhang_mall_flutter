import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:signals/signals.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/data/models/cart_model.dart';
import 'package:shuhang_mall_flutter/app/data/providers/order_provider.dart';

/// 全局购物车状态
class CartStore {
  CartStore._();

  static final CartStore instance = CartStore._();

  final OrderProvider _orderProvider = OrderProvider();

  /// 同步购物车数量到 AppController（更新 TabBar 角标）
  void _syncCartNum() {
    final controller = Get.find<AppController>();
    final count = items.value.fold(0, (sum, item) => sum + item.cartNum);
    controller.updateCartNum(count);
  }

  /// 是否加载中
  final Signal<bool> isLoading = signal(false);

  /// 是否编辑模式
  final Signal<bool> isEdit = signal(false);

  /// 购物车列表
  final Signal<List<CartItem>> items = signal(<CartItem>[]);

  /// 已选中的购物车 id
  final Signal<Set<int>> selectedIds = signal(<int>{});

  /// 已选数量
  late final ReadonlySignal<int> selectedCount = computed(() => selectedIds.value.length);

  /// 合计金额
  late final ReadonlySignal<double> totalPrice = computed(
    () => items.value
        .where((item) => selectedIds.value.contains(item.id))
        .fold(0.0, (sum, item) => sum + item.unitPrice * item.cartNum),
  );

  /// 购物车总数量
  late final ReadonlySignal<int> cartCount = computed(
    () => items.value.fold(0, (sum, item) => sum + item.cartNum),
  );

  /// 刷新购物车列表
  Future<void> loadCartList() async {
    final controller = Get.find<AppController>();
    if (!controller.isLogin) {
      items.value = <CartItem>[];
      selectedIds.value = <int>{};
      _syncCartNum();
      return;
    }

    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final response = await _orderProvider.getCartList();
      if (response.isSuccess && response.data != null) {
        final list = response.data!.valid;
        items.value = list;
        selectedIds.value = list.map((e) => e.id).toSet();
        _syncCartNum();
      } else {
        FlutterToastPro.showMessage( response.msg);
      }
    } catch (e) {
      FlutterToastPro.showMessage( '获取购物车失败');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleSelectAll(bool selected) {
    if (selected) {
      selectedIds.value = items.value.map((e) => e.id).toSet();
    } else {
      selectedIds.value = <int>{};
    }
  }

  void toggleSelected(int id, bool selected) {
    final updated = Set<int>.from(selectedIds.value);
    if (selected) {
      updated.add(id);
    } else {
      updated.remove(id);
    }
    selectedIds.value = updated;
  }

  Future<void> changeCartNum(CartItem item, int newNum) async {
    if (newNum < 1) return;
    try {
      final response = await _orderProvider.changeCartNum(id: item.id, number: newNum);
      if (response.isSuccess) {
        items.value = items.value
            .map((e) => e.id == item.id ? e.copyWith(cartNum: newNum) : e)
            .toList();
        _syncCartNum();
      } else {
        FlutterToastPro.showMessage( response.msg);
      }
    } catch (e) {
      FlutterToastPro.showMessage( '更新购物车数量失败');
    }
  }

  Future<void> deleteSelected() async {
    if (selectedIds.value.isEmpty) {
      FlutterToastPro.showMessage( '请选择要删除的商品');
      return;
    }

    try {
      final response = await _orderProvider.deleteCart(selectedIds.value.toList());
      if (response.isSuccess) {
        await loadCartList();
      } else {
        FlutterToastPro.showMessage( response.msg);
      }
    } catch (e) {
      FlutterToastPro.showMessage( '删除购物车失败');
    }
  }
}


