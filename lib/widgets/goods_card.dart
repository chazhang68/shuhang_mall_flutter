import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'cached_image.dart';

/// 商品卡片组件 - 对应 components/goodList/index.vue
class GoodsCard extends StatelessWidget {
  final Map<String, dynamic> goods;
  final VoidCallback? onTap;
  final GoodsCardStyle style;

  const GoodsCard({super.key, required this.goods, this.onTap, this.style = GoodsCardStyle.list});

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case GoodsCardStyle.list:
        return _buildListCard(context);
      case GoodsCardStyle.grid:
        return _buildGridCard(context);
      case GoodsCardStyle.horizontal:
        return _buildHorizontalCard(context);
    }
  }

  /// 列表样式卡片
  Widget _buildListCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 15),
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图片
            ProductImage(
              imageUrl: goods['image'] ?? '',
              width: 90,
              height: 90,
              borderRadius: 10,
              tag: _getActivityTag(),
            ),
            const SizedBox(width: 12),
            // 商品信息
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 商品名称
                    Text(
                      goods['store_name'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, color: Color(0xFF222222)),
                    ),
                    const SizedBox(height: 25),
                    // 价格
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '￥',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          TextSpan(
                            text: '${goods['price'] ?? '0'}',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // VIP价格和销量
                    _buildVipPriceAndSales(context),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 15),
          ],
        ),
      ),
    );
  }

  /// 网格样式卡片
  Widget _buildGridCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图片
            AspectRatio(
              aspectRatio: 1,
              child: ProductImage(
                imageUrl: goods['image'] ?? '',
                borderRadius: 8,
                tag: _getActivityTag(),
              ),
            ),
            // 商品信息
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 商品名称
                  Text(
                    goods['store_name'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF222222), height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  // 价格行
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '￥',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text(
                        '${goods['price'] ?? '0'}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (goods['ot_price'] != null &&
                          double.tryParse('${goods['ot_price']}') != null &&
                          double.parse('${goods['ot_price']}') >
                              double.parse('${goods['price'] ?? '0'}'))
                        Text(
                          '￥${goods['ot_price']}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF999999),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // 销量
                  Text(
                    '已售${goods['sales'] ?? 0}${goods['unit_name'] ?? '件'}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 横向滚动样式卡片
  Widget _buildHorizontalCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图片
            ProductImage(
              imageUrl: goods['image'] ?? '',
              width: 120,
              height: 120,
              borderRadius: 8,
              tag: _getActivityTag(),
            ),
            const SizedBox(height: 8),
            // 商品名称
            Text(
              goods['store_name'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Color(0xFF222222)),
            ),
            const SizedBox(height: 4),
            // 价格
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '￥',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  TextSpan(
                    text: '${goods['price'] ?? '0'}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取活动标签
  String? _getActivityTag() {
    final activity = goods['activity'];
    if (activity == null) return null;

    final type = activity['type']?.toString();
    switch (type) {
      case '1':
        return '秒杀';
      case '2':
        return '砍价';
      case '3':
        return '拼团';
      default:
        return null;
    }
  }

  /// 构建VIP价格和销量
  Widget _buildVipPriceAndSales(BuildContext context) {
    final isVip = goods['is_vip'] == true || goods['is_vip'] == 1;
    final vipPrice = goods['vip_price'];
    final hasVipPrice =
        vipPrice != null && double.tryParse('$vipPrice') != null && double.parse('$vipPrice') > 0;

    return Row(
      children: [
        if (isVip && hasVipPrice) ...[
          Text(
            '￥$vipPrice',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF282828),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Image.asset(
            'assets/images/vip.png',
            width: 32,
            height: 13,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text(
                  'VIP',
                  style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        Text(
          '${'已售'.tr}${goods['sales'] ?? 0}${(goods['unit_name'] ?? '件').toString().tr}',
          style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
        ),
      ],
    );
  }
}

/// 商品卡片样式
enum GoodsCardStyle {
  list, // 列表样式
  grid, // 网格样式
  horizontal, // 横向滚动样式
}

/// 商品列表组件
class GoodsList extends StatelessWidget {
  final List<Map<String, dynamic>> goods;
  final GoodsCardStyle style;
  final Function(Map<String, dynamic>)? onItemTap;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const GoodsList({
    super.key,
    required this.goods,
    this.style = GoodsCardStyle.list,
    this.onItemTap,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    if (goods.isEmpty) {
      return const SizedBox.shrink();
    }

    switch (style) {
      case GoodsCardStyle.list:
        return _buildListView();
      case GoodsCardStyle.grid:
        return _buildGridView();
      case GoodsCardStyle.horizontal:
        return _buildHorizontalView();
    }
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: goods.length,
      itemBuilder: (context, index) {
        return GoodsCard(
          goods: goods[index],
          style: GoodsCardStyle.list,
          onTap: () => onItemTap?.call(goods[index]),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: padding ?? const EdgeInsets.all(10),
      physics: physics,
      shrinkWrap: shrinkWrap,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.65,
      ),
      itemCount: goods.length,
      itemBuilder: (context, index) {
        return GoodsCard(
          goods: goods[index],
          style: GoodsCardStyle.grid,
          onTap: () => onItemTap?.call(goods[index]),
        );
      },
    );
  }

  Widget _buildHorizontalView() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 15),
        scrollDirection: Axis.horizontal,
        itemCount: goods.length,
        itemBuilder: (context, index) {
          return GoodsCard(
            goods: goods[index],
            style: GoodsCardStyle.horizontal,
            onTap: () => onItemTap?.call(goods[index]),
          );
        },
      ),
    );
  }
}

/// 推荐商品区块
class RecommendGoodsSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> goods;
  final VoidCallback? onViewMore;
  final Function(Map<String, dynamic>)? onItemTap;

  const RecommendGoodsSection({
    super.key,
    required this.title,
    required this.goods,
    this.onViewMore,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (goods.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // 标题栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
                if (onViewMore != null)
                  GestureDetector(
                    onTap: onViewMore,
                    child: Row(
                      children: [
                        Text(
                          '查看更多'.tr,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                        ),
                        const Icon(Icons.chevron_right, size: 16, color: Color(0xFF999999)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // 商品列表
          GoodsList(goods: goods, style: GoodsCardStyle.horizontal, onItemTap: onItemTap),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
