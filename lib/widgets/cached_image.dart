import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 缓存图片组件 - 对应 components/easy-loadimage/easy-loadimage.vue
class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Color? placeholderColor;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.placeholderColor,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorWidget();
    }

    // 处理相对路径
    String url = imageUrl;
    if (!imageUrl.startsWith('http')) {
      // 如果是相对路径，可以加上基础URL
      // url = '${AppConfig.baseUrl}$imageUrl';
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) {
      return placeholder!;
    }

    return Container(
      width: width,
      height: height,
      color: placeholderColor ?? const Color(0xFFE3E3E3),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (errorWidget != null) {
      return errorWidget!;
    }

    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE3E3E3),
      child: const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 32)),
    );
  }
}

/// 头像组件
class CachedAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  final Color? borderColor;
  final double borderWidth;
  final Widget? placeholder;

  const CachedAvatar({
    super.key,
    required this.imageUrl,
    this.size = 40,
    this.borderColor,
    this.borderWidth = 0,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor != null ? Border.all(color: borderColor!, width: borderWidth) : null,
      ),
      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildPlaceholder(),
                errorWidget: (context, url, error) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) {
      return placeholder!;
    }

    return Container(
      width: size,
      height: size,
      color: const Color(0xFFE3E3E3),
      child: Icon(Icons.person, size: size * 0.6, color: Colors.grey),
    );
  }
}

/// 商品图片组件
class ProductImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final String? tag; // 活动标签: 秒杀、拼团、砍价等
  final bool showSoldOut; // 是否售罄

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.tag,
    this.showSoldOut = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CachedImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          borderRadius: borderRadius,
          fit: BoxFit.cover,
        ),
        // 活动标签
        if (tag != null && tag!.isNotEmpty)
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getTagColor(tag!),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(tag!, style: const TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ),
        // 售罄遮罩
        if (showSoldOut)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha((0.5 * 255).round()),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: const Center(
                child: Text(
                  '已售罄',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _getTagColor(String tag) {
    switch (tag) {
      case '秒杀':
        return const Color(0xFFFF5722);
      case '拼团':
        return const Color(0xFFE91E63);
      case '砍价':
        return const Color(0xFF4CAF50);
      case '预售':
        return const Color(0xFF2196F3);
      case '新品':
        return const Color(0xFF9C27B0);
      case '热卖':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFFE93323);
    }
  }
}

/// 轮播图片组件
class BannerImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final VoidCallback? onTap;

  const BannerImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CachedImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        borderRadius: borderRadius,
        fit: BoxFit.cover,
      ),
    );
  }
}

/// 可预览的图片组件
class PreviewableImage extends StatelessWidget {
  final String imageUrl;
  final List<String>? imageList;
  final int? initialIndex;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  const PreviewableImage({
    super.key,
    required this.imageUrl,
    this.imageList,
    this.initialIndex,
    this.width,
    this.height,
    this.borderRadius = 0,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPreview(context),
      child: CachedImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        borderRadius: borderRadius,
        fit: fit,
      ),
    );
  }

  void _showPreview(BuildContext context) {
    final images = imageList ?? [imageUrl];
    final index = initialIndex ?? 0;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return ImagePreviewPage(images: images, initialIndex: index);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

/// 图片预览页面
class ImagePreviewPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImagePreviewPage({super.key, required this.images, this.initialIndex = 0});

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 图片
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: InteractiveViewer(
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: widget.images[index],
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.broken_image_outlined, color: Colors.white, size: 48),
                    ),
                  ),
                ),
              );
            },
          ),
          // 关闭按钮
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 15,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((0.5 * 255).round()),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),
          // 页码指示器
          if (widget.images.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((0.5 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.images.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
