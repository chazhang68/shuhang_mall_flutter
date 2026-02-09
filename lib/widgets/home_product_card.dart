import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shuhang_mall_flutter/app/data/models/home_index_model.dart';
import 'package:shuhang_mall_flutter/widgets/coupon_tag.dart';

/// 通用商品卡片组件 - 适用于首页推荐与商城列表。
/// 对应uni-app的首页商品列表样式
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // 商品图片 - 高度169px，与uni-app一致
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: CachedNetworkImage(
                imageUrl: product.image,
                width: 1.sw / 2,
                height: 170.h,
                memCacheWidth: (1.sw / 2).toInt(),
                memCacheHeight: 170.h.toInt(),
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(height: 170.h, color: Colors.grey[100]),
                errorWidget: (context, url, error) =>
                    Container(height: 170.h, color: Colors.grey[100]),
              ),
            ),
            // 商品信息区域 - 对应uni-app的p-1样式（约10px）
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 商品名称 - font-size: 30rpx ≈ 15px
                  Text(
                    product.storeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  // 商品关键词
                  if (product.keyword.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Text(
                        product.keyword,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10.sp, color: Color(0xFFE9AD00)),
                      ),
                    ),
                  ],
                  Visibility(
                    visible: product.keyword.isEmpty,
                    child: SizedBox(height: 10.h),
                  ),
                  // 价格区域 - margin-top: 15rpx ≈ 7.5px, padding: 10rpx ≈ 5px
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Row(
                      spacing: 12.w,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 消费券票券样式标签
                        const CouponTag(),
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFA281D),
                          ),
                        ),
                      ],
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
}
