import 'package:flutter/material.dart';

/// 骨架屏组件 - 对应 components/skeleton/index.vue
class SkeletonWidget extends StatefulWidget {
  final bool show;
  final Color? backgroundColor;
  final SkeletonType type;
  final Widget? child;
  final int itemCount;

  const SkeletonWidget({
    super.key,
    this.show = true,
    this.backgroundColor,
    this.type = SkeletonType.list,
    this.child,
    this.itemCount = 5,
  });

  @override
  State<SkeletonWidget> createState() => _SkeletonWidgetState();
}

class _SkeletonWidgetState extends State<SkeletonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show) {
      return widget.child ?? const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: _buildSkeleton(),
        );
      },
    );
  }

  Widget _buildSkeleton() {
    switch (widget.type) {
      case SkeletonType.list:
        return _buildListSkeleton();
      case SkeletonType.grid:
        return _buildGridSkeleton();
      case SkeletonType.detail:
        return _buildDetailSkeleton();
      case SkeletonType.card:
        return _buildCardSkeleton();
      case SkeletonType.profile:
        return _buildProfileSkeleton();
      case SkeletonType.custom:
        return widget.child ?? const SizedBox.shrink();
    }
  }

  Widget _buildListSkeleton() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return _buildListItem();
      },
    );
  }

  Widget _buildListItem() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片占位
          SkeletonBox(
            width: 90,
            height: 90,
            borderRadius: 10,
          ),
          const SizedBox(width: 12),
          // 文字占位
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                SkeletonBox(width: 150, height: 14),
                const SizedBox(height: 16),
                SkeletonBox(width: 80, height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridSkeleton() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return _buildGridItem();
      },
    );
  }

  Widget _buildGridItem() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片占位
          Expanded(
            child: SkeletonBox(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 8,
            ),
          ),
          // 文字占位
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: double.infinity, height: 14),
                const SizedBox(height: 6),
                SkeletonBox(width: 80, height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSkeleton() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 大图占位
          SkeletonBox(
            width: double.infinity,
            height: 375,
          ),
          // 商品信息
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 120, height: 28),
                const SizedBox(height: 10),
                SkeletonBox(width: double.infinity, height: 18),
                const SizedBox(height: 6),
                SkeletonBox(width: 200, height: 18),
                const SizedBox(height: 20),
                Row(
                  children: [
                    SkeletonBox(width: 60, height: 14),
                    const SizedBox(width: 20),
                    SkeletonBox(width: 60, height: 14),
                    const SizedBox(width: 20),
                    SkeletonBox(width: 60, height: 14),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 规格
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                SkeletonBox(width: 60, height: 16),
                const SizedBox(width: 10),
                SkeletonBox(width: 150, height: 16),
              ],
            ),
          ),
          const Divider(height: 1),
          // 评价
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 100, height: 18),
                const SizedBox(height: 15),
                Row(
                  children: [
                    SkeletonCircle(size: 40),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 80, height: 14),
                        const SizedBox(height: 4),
                        SkeletonBox(width: 60, height: 12),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SkeletonBox(width: double.infinity, height: 14),
                const SizedBox(height: 4),
                SkeletonBox(width: 200, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSkeleton() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: double.infinity, height: 150, borderRadius: 8),
          const SizedBox(height: 12),
          SkeletonBox(width: double.infinity, height: 16),
          const SizedBox(height: 8),
          SkeletonBox(width: 150, height: 14),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 80, height: 20),
              SkeletonBox(width: 60, height: 30, borderRadius: 15),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSkeleton() {
    return Column(
      children: [
        // 头部
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              SkeletonCircle(size: 60),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 100, height: 18),
                  const SizedBox(height: 8),
                  SkeletonBox(width: 150, height: 14),
                ],
              ),
            ],
          ),
        ),
        // 资产
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (index) {
              return Column(
                children: [
                  SkeletonBox(width: 50, height: 20),
                  const SizedBox(height: 6),
                  SkeletonBox(width: 40, height: 14),
                ],
              );
            }),
          ),
        ),
        // 订单状态
        Container(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) {
              return Column(
                children: [
                  SkeletonBox(width: 30, height: 30),
                  const SizedBox(height: 8),
                  SkeletonBox(width: 40, height: 12),
                ],
              );
            }),
          ),
        ),
        // 菜单列表
        ...List.generate(4, (index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Row(
              children: [
                SkeletonBox(width: 24, height: 24),
                const SizedBox(width: 12),
                SkeletonBox(width: 100, height: 16),
              ],
            ),
          );
        }),
      ],
    );
  }
}

/// 骨架屏类型
enum SkeletonType {
  list,
  grid,
  detail,
  card,
  profile,
  custom,
}

/// 矩形骨架块
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? color;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 4,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFE3E3E3),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// 圆形骨架块
class SkeletonCircle extends StatelessWidget {
  final double size;
  final Color? color;

  const SkeletonCircle({
    super.key,
    required this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFE3E3E3),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// 闪烁动画骨架块
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 4,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(1.0 + 2.0 * _controller.value, 0),
              colors: const [
                Color(0xFFE3E3E3),
                Color(0xFFF5F5F5),
                Color(0xFFE3E3E3),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

