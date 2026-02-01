import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:get/get.dart';
import '../../data/providers/store_provider.dart';
import '../../theme/theme_colors.dart';
import '../../../widgets/empty_page.dart';

/// 浏览足迹页面
/// 对应原 pages/users/visit_list/index.vue
class VisitListPage extends StatefulWidget {
  const VisitListPage({super.key});

  @override
  State<VisitListPage> createState() => _VisitListPageState();
}

class _VisitListPageState extends State<VisitListPage> {
  final StoreProvider _storeProvider = StoreProvider();

  // 数据 - 按日期分组
  final List<VisitGroup> _visitGroups = [];
  int _count = 0;

  // 管理模式
  bool _isManageMode = false;
  Set<int> _selectedIds = {};

  // 分页
  int _page = 1;
  final int _limit = 21;
  bool _isLoading = false;
  bool _hasMore = true;

  Color get _primaryColor => ThemeColors.red.primary;

  @override
  void initState() {
    super.initState();
    _loadVisitList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadVisitList({bool isRefresh = false}) async {
    if (_isLoading) return;
    if (!isRefresh && !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    if (isRefresh) {
      _page = 1;
      _hasMore = true;
      _visitGroups.clear();
      _selectedIds.clear();
    }

    try {
      final response = await _storeProvider.getVisitList({'page': _page, 'limit': _limit});

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        _count = data['count'] ?? 0;

        final times = (data['time'] as List<dynamic>?)?.cast<String>() ?? [];
        final list =
            (data['list'] as List<dynamic>?)?.map((e) => e as Map<String, dynamic>).toList() ?? [];

        // 按时间分组
        for (final time in times) {
          final existingIndex = _visitGroups.indexWhere((g) => g.time == time);
          if (existingIndex == -1) {
            _visitGroups.add(VisitGroup(time: time, products: []));
          }
        }

        for (final item in list) {
          final timeKey = item['time_key'] as String?;
          if (timeKey != null) {
            final groupIndex = _visitGroups.indexWhere((g) => g.time == timeKey);
            if (groupIndex >= 0) {
              _visitGroups[groupIndex].products.add(
                VisitProduct(
                  id: item['id'] ?? 0,
                  productId: item['product_id'] ?? 0,
                  image: item['image'] ?? '',
                  price: (item['product_price'] ?? 0).toString(),
                  isShow: item['is_show'] == true || item['is_show'] == 1,
                  stock: item['stock'] ?? 0,
                ),
              );
            }
          }
        }

        setState(() {
          _hasMore = list.length >= _limit;
          _page++;
        });
      }
    } catch (e) {
      debugPrint('获取足迹列表失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleManageMode() {
    setState(() {
      _isManageMode = !_isManageMode;
      if (!_isManageMode) {
        _selectedIds.clear();
      }
    });
  }

  void _toggleSelect(int productId) {
    setState(() {
      if (_selectedIds.contains(productId)) {
        _selectedIds.remove(productId);
      } else {
        _selectedIds.add(productId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      final allIds = _visitGroups.expand((g) => g.products).map((p) => p.productId).toSet();

      if (_selectedIds.length == allIds.length) {
        _selectedIds.clear();
      } else {
        _selectedIds = allIds;
      }
    });
  }

  int get _totalProductCount {
    return _visitGroups.fold(0, (sum, g) => sum + g.products.length);
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) {
      FlutterToastPro.showMessage('请选择删除商品');
      return;
    }

    try {
      final response = await _storeProvider.deleteVisit(_selectedIds.toList());
      if (response.isSuccess) {
        FlutterToastPro.showMessage(response.msg);
        _loadVisitList(isRefresh: true);
      } else {
        FlutterToastPro.showMessage(response.msg);
      }
    } catch (e) {
      FlutterToastPro.showMessage('操作失败');
    }
  }

  Future<void> _collectSelected() async {
    if (_selectedIds.isEmpty) {
      FlutterToastPro.showMessage('请选择收藏商品');
      return;
    }

    // TODO: 实现批量收藏
    FlutterToastPro.showMessage('收藏成功');
  }

  void _goDetail(VisitProduct product) {
    if (_isManageMode) return;
    if (!product.isShow) {
      FlutterToastPro.showMessage('该商品已下架');
      return;
    }
    Get.toNamed('/goods/detail', arguments: {'id': product.productId});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '我的足迹',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (_totalProductCount > 0)
            TextButton(
              onPressed: _toggleManageMode,
              child: Text(_isManageMode ? '取消' : '管理', style: const TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Column(
        children: [
          // 统计栏
          _buildStatBar(),
          // 列表
          Expanded(child: _buildList()),
          // 底部操作栏
          if (_isManageMode && _totalProductCount > 0) _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildStatBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          const Text('共 ', style: TextStyle(fontSize: 14, color: Color(0xFF333333))),
          Text(
            '$_count',
            style: TextStyle(fontSize: 14, color: _primaryColor, fontWeight: FontWeight.w500),
          ),
          const Text('件商品', style: TextStyle(fontSize: 14, color: Color(0xFF333333))),
        ],
      ),
    );
  }

  Widget _buildList() {
    return EasyRefresh(
      header: const ClassicHeader(
        dragText: '下拉刷新',
        armedText: '松手刷新',
        processingText: '刷新中...',
        processedText: '刷新完成',
        failedText: '刷新失败',
      ),
      footer: const ClassicFooter(
        dragText: '上拉加载',
        armedText: '松手加载',
        processingText: '加载中...',
        processedText: '加载完成',
        failedText: '加载失败',
        noMoreText: '我也是有底线的',
      ),
      onRefresh: () => _loadVisitList(isRefresh: true),
      onLoad: _hasMore ? () => _loadVisitList() : null,
      child: _visitGroups.isEmpty && !_isLoading
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [EmptyPage(text: '暂无浏览记录')],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 16, bottom: 100),
              itemCount: _visitGroups.length,
              itemBuilder: (context, index) {
                return _buildGroup(_visitGroups[index]);
              },
            ),
    );
  }

  Widget _buildGroup(VisitGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 日期标题
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (_isManageMode)
                Checkbox(
                  value: group.products.every((p) => _selectedIds.contains(p.productId)),
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selectedIds.addAll(group.products.map((p) => p.productId));
                      } else {
                        _selectedIds.removeAll(group.products.map((p) => p.productId));
                      }
                    });
                  },
                  activeColor: _primaryColor,
                ),
              Text(
                group.time,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
        // 商品网格
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 16,
            children: group.products.map((p) => _buildProductItem(p)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProductItem(VisitProduct product) {
    final isSelected = _selectedIds.contains(product.productId);
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - 24 - 16) / 3; // 3列

    return GestureDetector(
      onTap: () => _isManageMode ? _toggleSelect(product.productId) : _goDetail(product),
      child: SizedBox(
        width: itemWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: product.image,
                    width: itemWidth,
                    height: itemWidth,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: const Color(0xFFF5F5F5)),
                    errorWidget: (context, url, error) => Container(color: const Color(0xFFF5F5F5)),
                  ),
                ),
                // 选择框
                if (_isManageMode)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _primaryColor
                            : Colors.black.withAlpha((0.16 * 255).round()),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                  ),
                // 售罄/下架遮罩
                if (!_isManageMode && (product.stock <= 0 || !product.isShow))
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha((0.2 * 255).round()),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha((0.6 * 255).round()),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          product.isShow ? '已售罄' : '已下架',
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // 价格
            Text(
              'SWP ${product.price}',
              style: TextStyle(fontSize: 12, color: _primaryColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final isAllSelected = _selectedIds.length == _totalProductCount && _totalProductCount > 0;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.06 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 全选
          GestureDetector(
            onTap: _selectAll,
            child: Row(
              children: [
                Checkbox(
                  value: isAllSelected,
                  onChanged: (v) => _selectAll(),
                  activeColor: _primaryColor,
                ),
                const Text('全选', style: TextStyle(fontSize: 14, color: Color(0xFF282828))),
              ],
            ),
          ),
          // 操作按钮
          Row(
            children: [
              GestureDetector(
                onTap: _collectSelected,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFCCCCCC)),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text('收藏', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _deleteSelected,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: _primaryColor),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text('删除', style: TextStyle(fontSize: 14, color: _primaryColor)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 数据模型
class VisitGroup {
  final String time;
  final List<VisitProduct> products;

  VisitGroup({required this.time, required this.products});
}

class VisitProduct {
  final int id;
  final int productId;
  final String image;
  final String price;
  final bool isShow;
  final int stock;

  VisitProduct({
    required this.id,
    required this.productId,
    required this.image,
    required this.price,
    required this.isShow,
    required this.stock,
  });
}
