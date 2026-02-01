import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shuhang_mall_flutter/app/data/models/home_index_model.dart';

/// 通用商品卡片组件 - 适用于首页推荐与商城列表。
class HomeProductCard extends StatelessWidget {
  /// 商品数据。
  final HomeHotProduct product;

  /// 点击回调。
  final VoidCallback? onTap;

  const HomeProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final price = product.price.toStringAsFixed(2);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: CachedNetworkImage(
                imageUrl: product.image,
                width: double.infinity,
                height: 169,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 169,
                  color: Colors.grey[100],
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 169,
                  color: Colors.grey[100],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.storeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    if (product.keyword.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        product.keyword,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: Color(0xFFE9AD00)),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/xiaofeiquan.png',
                          width: 41,
                          height: 15.5,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFA281D),
                            fontFamily: 'DIN Alternate',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
