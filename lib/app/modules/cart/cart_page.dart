import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/controllers/cart_store.dart';
import 'package:shuhang_mall_flutter/app/data/models/cart_model.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/theme/theme_colors.dart';

/// 购物车页面
/// 对应原 pages/order_addcart/order_addcart.vue
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with AutomaticKeepAliveClientMixin {
  final CartStore _store = CartStore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _store.loadCartList();
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GetBuilder<AppController>(
      builder: (controller) {
        final themeColor = controller.themeColor;

        return Watch.builder(
          builder: (context) {
            final isLoading = _store.isLoading.value;
            final items = _store.items.value;
            final selectedIds = _store.selectedIds.value;
            final isEdit = _store.isEdit.value;
            final selectedCount = _store.selectedCount.value;
            final totalPrice = _store.totalPrice.value;
            final selectAll = items.isNotEmpty && selectedIds.length == items.length;

            return Scaffold(
              appBar: AppBar(
                title: const Text('购物车'),
                actions: [
                  TextButton(
                    onPressed: () {
                      _store.isEdit.value = !isEdit;
                    },
                    child: Text(isEdit ? '完成' : '编辑', style: TextStyle(color: themeColor.primary)),
                  ),
                ],
              ),
              body: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                  ? _CartEmptyView(
                      themeColor: themeColor,
                      onBrowse: () => Get.offAllNamed(AppRoutes.main),
                    )
                  : RefreshIndicator(
                      onRefresh: _store.loadCartList,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _CartItemTile(
                            item: item,
                            selected: selectedIds.contains(item.id),
                            themeColor: themeColor,
                            onSelectedChanged: (value) {
                              _store.toggleSelected(item.id, value == true);
                            },
                            onDecrease: () => _store.changeCartNum(item, item.cartNum - 1),
                            onIncrease: () => _store.changeCartNum(item, item.cartNum + 1),
                          );
                        },
                      ),
                    ),
              bottomNavigationBar: isLoading || items.isEmpty
                  ? null
                  : _CartBottomBar(
                      themeColor: themeColor,
                      selectAll: selectAll,
                      totalPrice: totalPrice,
                      selectedCount: selectedCount,
                      isEdit: isEdit,
                      onSelectAllChanged: (value) {
                        _store.toggleSelectAll(value ?? false);
                      },
                      onDeleteSelected: _store.deleteSelected,
                      onCheckout: () {},
                    ),
            );
          },
        );
      },
    );
  }
}

class _CartEmptyView extends StatelessWidget {
  const _CartEmptyView({required this.themeColor, required this.onBrowse});

  final ThemeColorData themeColor;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('购物车是空的', style: TextStyle(fontSize: 16, color: Color(0xFF999999))),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onBrowse,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor.primary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: const Text('去逛逛'),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.selected,
    required this.themeColor,
    required this.onSelectedChanged,
    required this.onDecrease,
    required this.onIncrease,
  });

  final CartItem item;
  final bool selected;
  final ThemeColorData themeColor;
  final ValueChanged<bool?> onSelectedChanged;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.productInfo?.image ?? item.productInfo?.attrInfo?.image ?? '';
    final name = item.productInfo?.storeName ?? '商品';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: selected,
              onChanged: onSelectedChanged,
              activeColor: themeColor.primary,
            ),
          ),
          SizedBox(width: 8),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: imageUrl.isEmpty
                ? Center(child: Icon(Icons.shopping_bag, size: 24, color: Colors.grey[400]))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.image, size: 24, color: Colors.grey[400]),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((item.productInfo?.attrInfo?.suk ?? '').isNotEmpty)
                  Text(
                    item.productInfo?.attrInfo?.suk ?? '',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                  ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '¥${item.unitPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: themeColor.price,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _QuantitySelector(
                      count: item.cartNum,
                      onDecrease: onDecrease,
                      onIncrease: onIncrease,
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
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.count,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int count;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: count > 1 ? onDecrease : null,
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              child: const Icon(Icons.remove, size: 12),
            ),
          ),
          Container(
            width: 40,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border.symmetric(vertical: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Text('$count', style: const TextStyle(fontSize: 14)),
          ),
          GestureDetector(
            onTap: onIncrease,
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              child: const Icon(Icons.add, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartBottomBar extends StatelessWidget {
  const _CartBottomBar({
    required this.themeColor,
    required this.selectAll,
    required this.totalPrice,
    required this.selectedCount,
    required this.isEdit,
    required this.onSelectAllChanged,
    required this.onDeleteSelected,
    required this.onCheckout,
  });

  final ThemeColorData themeColor;
  final bool selectAll;
  final double totalPrice;
  final int selectedCount;
  final bool isEdit;
  final ValueChanged<bool?> onSelectAllChanged;
  final VoidCallback onDeleteSelected;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: selectAll,
              onChanged: onSelectAllChanged,
              activeColor: themeColor.primary,
            ),
          ),
          const Text('全选', style: TextStyle(fontSize: 14)),
          const Spacer(),
          Text('合计: ', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            '¥${totalPrice.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 16, color: themeColor.price, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            height: 40,
            child: ElevatedButton(
              onPressed: selectedCount > 0 ? (isEdit ? onDeleteSelected : onCheckout) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor.primary,
                padding: EdgeInsets.zero,
              ),
              child: Text(isEdit ? '删除' : '结算($selectedCount)'),
            ),
          ),
        ],
      ),
    );
  }
}
