import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'cached_image.dart';

/// 轮播图组件 - 对应 components/swipers/index.vue
class BannerSwiper extends StatefulWidget {
  final List<Map<String, dynamic>> banners;
  final double height;
  final double borderRadius;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final Function(Map<String, dynamic> banner)? onTap;
  final bool showIndicator;
  final IndicatorStyle indicatorStyle;

  const BannerSwiper({
    super.key,
    required this.banners,
    this.height = 180,
    this.borderRadius = 8,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.onTap,
    this.showIndicator = true,
    this.indicatorStyle = IndicatorStyle.dot,
  });

  @override
  State<BannerSwiper> createState() => _BannerSwiperState();
}

class _BannerSwiperState extends State<BannerSwiper> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return SizedBox(height: widget.height);
    }

    return Stack(
      children: [
        carousel.CarouselSlider.builder(
          itemCount: widget.banners.length,
          options: carousel.CarouselOptions(
            height: widget.height,
            viewportFraction: 1.0,
            autoPlay: widget.autoPlay && widget.banners.length > 1,
            autoPlayInterval: widget.autoPlayInterval,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            final banner = widget.banners[index];
            return GestureDetector(
              onTap: () => widget.onTap?.call(banner),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: CachedImage(
                    imageUrl: banner['pic'] ?? banner['image'] ?? '',
                    width: double.infinity,
                    height: widget.height,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
        // 指示器
        if (widget.showIndicator && widget.banners.length > 1)
          Positioned(bottom: 10, left: 0, right: 0, child: _buildIndicator()),
      ],
    );
  }

  Widget _buildIndicator() {
    switch (widget.indicatorStyle) {
      case IndicatorStyle.dot:
        return _buildDotIndicator();
      case IndicatorStyle.number:
        return _buildNumberIndicator();
      case IndicatorStyle.line:
        return _buildLineIndicator();
    }
  }

  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.banners.asMap().entries.map((entry) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentIndex == entry.key
                ? Colors.white
                : Colors.white.withAlpha((0.4 * 255).round()),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumberIndicator() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha((0.5 * 255).round()),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '${_currentIndex + 1}/${widget.banners.length}',
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLineIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.banners.asMap().entries.map((entry) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _currentIndex == entry.key ? 20 : 8,
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: _currentIndex == entry.key
                ? Colors.white
                : Colors.white.withAlpha((0.4 * 255).round()),
          ),
        );
      }).toList(),
    );
  }
}

/// 指示器样式
enum IndicatorStyle { dot, number, line }

/// 商品轮播图组件 - 用于商品详情页
class ProductSwiper extends StatefulWidget {
  final List<String> images;
  final double height;
  final bool showIndicator;
  final Function(int index)? onTap;

  const ProductSwiper({
    super.key,
    required this.images,
    this.height = 375,
    this.showIndicator = true,
    this.onTap,
  });

  @override
  State<ProductSwiper> createState() => _ProductSwiperState();
}

class _ProductSwiperState extends State<ProductSwiper> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        height: widget.height,
        color: const Color(0xFFF5F5F5),
        child: const Center(child: Icon(Icons.image_outlined, size: 60, color: Colors.grey)),
      );
    }

    return Stack(
      children: [
        carousel.CarouselSlider.builder(
          itemCount: widget.images.length,
          options: carousel.CarouselOptions(
            height: widget.height,
            viewportFraction: 1.0,
            autoPlay: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            return GestureDetector(
              onTap: () => widget.onTap?.call(index),
              child: CachedImage(
                imageUrl: widget.images[index],
                width: double.infinity,
                height: widget.height,
                fit: BoxFit.cover,
              ),
            );
          },
        ),
        // 页码指示器
        if (widget.showIndicator && widget.images.length > 1)
          Positioned(
            bottom: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha((0.5 * 255).round()),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_currentIndex + 1}/${widget.images.length}',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

/// 功能菜单网格组件 - 用于首页功能入口
class MenuGrid extends StatelessWidget {
  final List<Map<String, dynamic>> menus;
  final int crossAxisCount;
  final double spacing;
  final double iconSize;
  final Function(Map<String, dynamic> menu)? onTap;

  const MenuGrid({
    super.key,
    required this.menus,
    this.crossAxisCount = 5,
    this.spacing = 10,
    this.iconSize = 44,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (menus.isEmpty) {
      return const SizedBox.shrink();
    }

    // 分页处理，每页显示10个
    final pageCount = (menus.length / 10).ceil();

    if (pageCount <= 1) {
      return _buildMenuPage(menus);
    }

    return SizedBox(
      height: _calculateHeight(),
      child: PageView.builder(
        itemCount: pageCount,
        itemBuilder: (context, pageIndex) {
          final start = pageIndex * 10;
          final end = (start + 10).clamp(0, menus.length);
          final pageMenus = menus.sublist(start, end);
          return _buildMenuPage(pageMenus);
        },
      ),
    );
  }

  double _calculateHeight() {
    final rowCount = (menus.length > crossAxisCount ? 2 : 1);
    return rowCount * (iconSize + 30 + spacing) + spacing;
  }

  Widget _buildMenuPage(List<Map<String, dynamic>> pageMenus) {
    return Container(
      padding: EdgeInsets.all(spacing),
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: pageMenus.map((menu) {
          return SizedBox(
            width:
                (MediaQuery.of(Get.context!).size.width -
                    spacing * 2 -
                    spacing * (crossAxisCount - 1)) /
                crossAxisCount,
            child: _buildMenuItem(menu),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> menu) {
    return GestureDetector(
      onTap: () => onTap?.call(menu),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图标
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(iconSize / 4)),
            child: CachedImage(
              imageUrl: menu['pic'] ?? menu['icon'] ?? '',
              width: iconSize,
              height: iconSize,
              borderRadius: iconSize / 4,
            ),
          ),
          const SizedBox(height: 6),
          // 文字
          Text(
            menu['name'] ?? menu['title'] ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
          ),
        ],
      ),
    );
  }
}

/// 公告滚动组件
class NoticeBar extends StatefulWidget {
  final List<Map<String, dynamic>> notices;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final Function(Map<String, dynamic> notice)? onTap;

  const NoticeBar({
    super.key,
    required this.notices,
    this.height = 36,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.onTap,
  });

  @override
  State<NoticeBar> createState() => _NoticeBarState();
}

class _NoticeBarState extends State<NoticeBar> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.notices.length > 1) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && widget.notices.isNotEmpty) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.notices.length;
        });
        _startAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notices.isEmpty) {
      return const SizedBox.shrink();
    }

    final notice = widget.notices[_currentIndex];

    return GestureDetector(
      onTap: () => widget.onTap?.call(notice),
      child: Container(
        height: widget.height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? const Color(0xFFFFF9E6),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(
              widget.icon ?? Icons.campaign_outlined,
              size: 18,
              color: widget.textColor ?? const Color(0xFFFF9900),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                child: Text(
                  notice['title'] ?? notice['content'] ?? '',
                  key: ValueKey(_currentIndex),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.textColor ?? const Color(0xFF666666),
                  ),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFF999999)),
          ],
        ),
      ),
    );
  }
}
