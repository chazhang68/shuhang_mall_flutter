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
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
              ),
              body: Column(
                children: [
                  // 顶部标签栏（与 uni-app 一致）
                  _buildTopLabels(),
                  // 购物数量和管理按钮
                  _buildCartHeader(items.length, isEdit, themeColor),
                  // 主内容区域
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : items.isEmpty
                            ? _CartEmptyView(
                                themeColor: themeColor,
                                onBrowse: () => Get.offAllNamed(AppRoutes.main),
                              )
                            : RefreshIndicator(
                                onRefresh: _store.loadCartList,
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 120),
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
                                      onTap: () {
                                        // 跳转到商品详情
                                        Get.toNamed(
                                          AppRoutes.goodsDetail,
                                          arguments: {'id': item.productId},
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                  ),
                ],
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
                      onCheckout: () {
                        // 跳转到订单确认页
                        if (selectedIds.isNotEmpty) {
                          Get.toNamed(
                            AppRoutes.orderConfirm,
                            arguments: {'cartId': selectedIds.join(',')},
                          );
                        }
                      },
                    ),
            );
          },
        );
      },
    );
  }

  /// 顶部标签栏（与 uni-app 一致）
  Widget _buildTopLabels() {
    return Container(
      height: 38,
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, size: 12, color: Color(0xFF8C8C8C)),
              SizedBox(width: 5),
              Text('100%正品保证', style: TextStyle(fontSize: 11, color: Color(0xFF8C8C8C))),
            ],
          ),
          Row(
            children: [
              Icon(Icons.check_circle, size: 12, color: Color(0xFF8C8C8C)),
              SizedBox(width: 5),
              Text('所有商品精挑细选', style: TextStyle(fontSize: 11, color: Color(0xFF8C8C8C))),
            ],
          ),
          Row(
            children: [
              Icon(Icons.check_circle, size: 12, color: Color(0xFF8C8C8C)),
              SizedBox(width: 5),
              Text('售后无忧', style: TextStyle(fontSize: 11, color: Color(0xFF8C8C8C))),
            ],
          ),
        ],
      ),
    );
  }

  /// 购物数量和管理按钮
  Widget _buildCartHeader(int count, bool isEdit, ThemeColorData themeColor) {
    return Container(
      height: 40,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              text: '购物数量 ',
              style: const TextStyle(fontSize: 14, color: Color(0xFF282828)),
              children: [
                TextSpan(
                  text: '$count',
                  style: TextStyle(fontSize: 14, color: themeColor.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (count > 0)
            GestureDetector(
              onTap: () {
                _store.isEdit.value = !isEdit;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFA4A4A4)),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  isEdit ? '取消' : '管理',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF282828)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CartEmptyView extends StatelessWidget {
  const _CartEmptyView({required this.themeColor, required this.onBrowse});

  final ThemeColorData themeColor;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          // 空状态图片（与 uni-app 一致）
          Image.asset(
            'assets/images/no-thing.png',
            width: 207,
            height: 168,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.shopping_cart_outlined, size: 120, color: Colors.grey[300]);
            },
          ),
          const SizedBox(height: 28),
          const Text('暂无商品', style: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA))),
          const SizedBox(height: 40),
          // 热门推荐区域
          _buildHotRecommend(themeColor),
        ],
      ),
    );
  }

  /// 热门推荐区域（与 uni-app 一致）
  Widget _buildHotRecommend(ThemeColorData themeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          // 分隔线和标题
          Row(
            children: [
              Expanded(child: Container(height: 1, color: const Color(0xFFEEEEEE))),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text('热门推荐', style: TextStyle(fontSize: 15, color: Color(0xFF333333))),
              ),
              Expanded(child: Container(height: 1, color: const Color(0xFFEEEEEE))),
            ],
          ),
          const SizedBox(height: 20),
          // 这里可以添加热门商品列表
          const Text('暂无推荐商品', style: TextStyle(fontSize: 12, color: Color(0xFF999999))),
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
    required this.onTap,
  });

  final CartItem item;
  final bool selected;
  final ThemeColorData themeColor;
  final ValueChanged<bool?> onSelectedChanged;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.productInfo?.attrInfo?.image ?? item.productInfo?.image ?? '';
    final name = item.productInfo?.storeName ?? '商品';
    final suk = item.productInfo?.attrInfo?.suk ?? '';
    // 使用 unitPrice 而不是 truePrice，与总价计算保持一致
    final price = item.unitPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 复选框
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: selected,
                onChanged: onSelectedChanged,
                activeColor: themeColor.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 商品信息（可点击）
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 商品图片
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: imageUrl.isEmpty
                        ? Center(child: Icon(Icons.shopping_bag, size: 30, color: Colors.grey[400]))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.image, size: 30, color: Colors.grey[400]),
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),
                  // 商品详情
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 商品名称
                        Text(
                          name,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF282828)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // 规格信息
                        if (suk.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '属性：$suk',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF868686)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 14),
                        // 价格和数量选择器
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // 价格（使用消费券图片）
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Image.asset(
                                  'assets/images/xiaofeiquan.png',
                                  height: 12,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Text(
                                      '消费券',
                                      style: TextStyle(fontSize: 10, color: Color(0xFFFA281D)),
                                    );
                                  },
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  _formatPrice(price),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFFA281D),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            // 数量选择器
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
    final canDecrease = count > 1;

    return Container(
      height: 24,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFA4A4A4)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 减号按钮
          GestureDetector(
            onTap: canDecrease ? onDecrease : null,
            child: Container(
              width: 33,
              height: 24,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: Color(0xFFA4A4A4))),
              ),
              child: Text(
                '-',
                style: TextStyle(
                  fontSize: 14,
                  color: canDecrease ? const Color(0xFFA4A4A4) : const Color(0xFFDEDEDE),
                ),
              ),
            ),
          ),
          // 数量显示
          Container(
            width: 33,
            height: 24,
            alignment: Alignment.center,
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 14, color: Color(0xFF282828)),
            ),
          ),
          // 加号按钮
          GestureDetector(
            onTap: onIncrease,
            child: Container(
              width: 33,
              height: 24,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: Color(0xFFA4A4A4))),
              ),
              child: const Text(
                '+',
                style: TextStyle(fontSize: 14, color: Color(0xFFA4A4A4)),
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // 全选复选框
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: selectAll,
                onChanged: onSelectAllChanged,
                activeColor: themeColor.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '全选($selectedCount)',
              style: const TextStyle(fontSize: 14, color: Color(0xFF282828)),
            ),
            const Spacer(),
            // 编辑模式：显示收藏和删除按钮
            if (isEdit) ...[
              // 收藏按钮（暂时隐藏，uni-app 中有但功能未实现）
              // GestureDetector(
              //   onTap: selectedCount > 0 ? () {} : null,
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              //     decoration: BoxDecoration(
              //       border: Border.all(color: const Color(0xFF999999)),
              //       borderRadius: BorderRadius.circular(25),
              //     ),
              //     child: const Text(
              //       '收藏',
              //       style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
              //     ),
              //   ),
              // ),
              // const SizedBox(width: 8),
              // 删除按钮
              GestureDetector(
                onTap: selectedCount > 0 ? onDeleteSelected : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF999999)),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    '删除',
                    style: TextStyle(
                      fontSize: 14,
                      color: selectedCount > 0 ? const Color(0xFF999999) : const Color(0xFFCCCCCC),
                    ),
                  ),
                ),
              ),
            ]
            // 非编辑模式：显示价格和结算按钮
            else ...[
              // 合计价格
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/images/xiaofeiquan.png',
                    height: 12,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        '消费券',
                        style: TextStyle(fontSize: 10, color: Color(0xFFFA281D)),
                      );
                    },
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _formatPrice(totalPrice),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFFFA281D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 11),
              // 立即下单按钮
              GestureDetector(
                onTap: selectedCount > 0 ? onCheckout : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  decoration: BoxDecoration(
                    color: selectedCount > 0 ? themeColor.primary : const Color(0xFFCCCCCC),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text(
                    '立即下单',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 格式化价格显示（与uni-app一致，整数不显示小数点）
String _formatPrice(double price) {
  if (price == price.truncateToDouble()) {
    return price.toInt().toString();
  }
  return price.toStringAsFixed(2);
}
