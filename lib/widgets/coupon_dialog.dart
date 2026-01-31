import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 优惠券弹窗组件 - 对应 components/couponWindow/index.vue
class CouponDialog extends StatefulWidget {
  final List<Map<String, dynamic>> couponList;
  final int? selectedId;
  final bool multiple;
  final Function(Map<String, dynamic>)? onSelect;
  final Function(List<Map<String, dynamic>>)? onMultipleSelect;

  const CouponDialog({
    super.key,
    required this.couponList,
    this.selectedId,
    this.multiple = false,
    this.onSelect,
    this.onMultipleSelect,
  });

  /// 显示优惠券选择弹窗
  static Future<Map<String, dynamic>?> show({
    required List<Map<String, dynamic>> couponList,
    int? selectedId,
  }) async {
    return await Get.bottomSheet<Map<String, dynamic>>(
      CouponDialog(couponList: couponList, selectedId: selectedId),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<CouponDialog> createState() => _CouponDialogState();
}

class _CouponDialogState extends State<CouponDialog> {
  int? _selectedId;
  final Set<int> _selectedIds = {};

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
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          _buildTitle(),
          // 优惠券列表
          Flexible(
            child: widget.couponList.isEmpty
                ? _buildEmptyView()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    shrinkWrap: true,
                    itemCount: widget.couponList.length,
                    itemBuilder: (context, index) {
                      return _buildCouponItem(widget.couponList[index]);
                    },
                  ),
          ),
          // 不使用优惠券
          _buildNoCouponButton(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '选择优惠券'.tr,
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
          Icon(Icons.confirmation_number_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('暂无可用优惠券'.tr, style: const TextStyle(fontSize: 14, color: Color(0xFF999999))),
        ],
      ),
    );
  }

  Widget _buildCouponItem(Map<String, dynamic> coupon) {
    final id = coupon['id'];
    final isSelected = widget.multiple ? _selectedIds.contains(id) : _selectedId == id;
    final isDisabled = coupon['is_fail'] == 1 || coupon['status'] == 2;

    // 优惠券类型: 1=满减, 2=折扣
    final couponType = coupon['coupon_type'] ?? 1;
    final couponPrice = coupon['coupon_price'] ?? 0;
    final useMinPrice = coupon['use_min_price'] ?? 0;

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              if (widget.multiple) {
                setState(() {
                  if (_selectedIds.contains(id)) {
                    _selectedIds.remove(id);
                  } else {
                    _selectedIds.add(id);
                  }
                });
              } else {
                setState(() {
                  _selectedId = id;
                });
                widget.onSelect?.call(coupon);
                Get.back(result: coupon);
              }
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 100,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            // 左侧金额
            Container(
              width: 100,
              decoration: BoxDecoration(
                color: isDisabled ? const Color(0xFFCCCCCC) : Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (couponType == 2)
                    Text(
                      '${(couponPrice as num).toStringAsFixed(1)}折',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            '￥',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          '$couponPrice',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Text(
                    useMinPrice > 0 ? '满$useMinPrice可用' : '无门槛',
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
            // 中间信息
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      coupon['coupon_title'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDisabled ? const Color(0xFF999999) : const Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _getUseTimeText(coupon),
                      style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getCouponTypeText(coupon),
                      style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
                    ),
                  ],
                ),
              ),
            ),
            // 右侧选中状态
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 22,
                color: isSelected && !isDisabled
                    ? Theme.of(context).primaryColor
                    : const Color(0xFFCCCCCC),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getUseTimeText(Map<String, dynamic> coupon) {
    final startTime = coupon['start_time'] ?? '';
    final endTime = coupon['end_time'] ?? '';
    if (startTime.isEmpty || endTime.isEmpty) {
      return '有效期: 永久有效';
    }
    return '有效期: $startTime - $endTime';
  }

  String _getCouponTypeText(Map<String, dynamic> coupon) {
    final type = coupon['type'] ?? 0;
    switch (type) {
      case 0:
        return '通用券';
      case 1:
        return '商品券';
      case 2:
        return '品类券';
      default:
        return '';
    }
  }

  Widget _buildNoCouponButton() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(15),
        color: Colors.white,
        child: GestureDetector(
          onTap: () {
            Get.back(result: {'id': 0, 'coupon_price': 0});
          },
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(23),
            ),
            alignment: Alignment.center,
            child: Text(
              '不使用优惠券'.tr,
              style: const TextStyle(fontSize: 15, color: Color(0xFF666666)),
            ),
          ),
        ),
      ),
    );
  }
}

/// 优惠券卡片组件
class CouponCard extends StatelessWidget {
  final Map<String, dynamic> coupon;
  final bool isReceived;
  final VoidCallback? onReceive;
  final VoidCallback? onUse;

  const CouponCard({
    super.key,
    required this.coupon,
    this.isReceived = false,
    this.onReceive,
    this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    final couponType = coupon['coupon_type'] ?? 1;
    final couponPrice = coupon['coupon_price'] ?? 0;
    final useMinPrice = coupon['use_min_price'] ?? 0;
    final isDisabled = coupon['is_fail'] == 1 || coupon['status'] == 2;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 左侧金额
          Container(
            width: 100,
            decoration: BoxDecoration(
              gradient: isDisabled
                  ? null
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withAlpha((0.8 * 255).round()),
                      ],
                    ),
              color: isDisabled ? const Color(0xFFCCCCCC) : null,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (couponType == 2)
                  Text(
                    '${(couponPrice as num).toStringAsFixed(1)}折',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          '￥',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        '$couponPrice',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                Text(
                  useMinPrice > 0 ? '满$useMinPrice可用' : '无门槛',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
          // 中间信息
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    coupon['coupon_title'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDisabled ? const Color(0xFF999999) : const Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getUseTimeText(),
                    style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
                  ),
                ],
              ),
            ),
          ),
          // 右侧按钮
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildActionButton(context, isDisabled),
          ),
        ],
      ),
    );
  }

  String _getUseTimeText() {
    final startTime = coupon['start_time'] ?? '';
    final endTime = coupon['end_time'] ?? '';
    if (startTime.isEmpty || endTime.isEmpty) {
      return '永久有效';
    }
    return '$startTime - $endTime';
  }

  Widget _buildActionButton(BuildContext context, bool isDisabled) {
    if (isReceived) {
      return GestureDetector(
        onTap: isDisabled ? null : onUse,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDisabled ? const Color(0xFFCCCCCC) : Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            isDisabled ? '已失效'.tr : '去使用'.tr,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onReceive,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          '立即领取'.tr,
          style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}
