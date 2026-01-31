import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/providers/store_provider.dart';
import '../../theme/theme_colors.dart';
import '../../../widgets/empty_page.dart';

/// 收藏商品页面
/// 对应原 pages/users/user_goods_collection/index.vue
class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final StoreProvider _storeProvider = StoreProvider();
  final RefreshController _refreshController = RefreshController();

  // 数据
  List<Map<String, dynamic>> _collectList = [];
  int _count = 0;

  // 管理模式
  bool _isManageMode = false;
  Set<String> _selectedIds = {};

  // 分页
  int _page = 1;
  final int _limit = 15;
  bool _isLoading = false;
  bool _hasMore = true;

  Color get _primaryColor => ThemeColors.red.primary;

  @override
  void initState() {
    super.initState();
    _loadCollectList();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadCollectList({bool isRefresh = false}) async {
    if (_isLoading) return;
    if (!isRefresh && !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    if (isRefresh) {
      _page = 1;
      _hasMore = true;
      _selectedIds.clear();
    }

    try {
      final response = await _storeProvider.getCollectList({'page': _page, 'limit': _limit});

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final list =
            (data['list'] as List<dynamic>?)?.map((e) => e as Map<String, dynamic>).toList() ?? [];

        setState(() {
          _count = data['count'] ?? 0;
          if (isRefresh) {
            _collectList = list;
          } else {
            _collectList.addAll(list);
          }
          _hasMore = list.length >= _limit;
          _page++;
        });
      }
    } catch (e) {
      debugPrint('获取收藏列表失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      if (isRefresh) {
        _refreshController.refreshCompleted();
      } else {
        if (_hasMore) {
          _refreshController.loadComplete();
        } else {
          _refreshController.loadNoData();
        }
      }
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

  void _toggleSelect(String pid) {
    setState(() {
      if (_selectedIds.contains(pid)) {
        _selectedIds.remove(pid);
      } else {
        _selectedIds.add(pid);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedIds.length == _collectList.length) {
        _selectedIds.clear();
      } else {
        _selectedIds = _collectList.map((e) => e['pid'].toString()).toSet();
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) {
      Get.snackbar('提示', '请选择商品');
      return;
    }

    try {
      final response = await _storeProvider.batchUncollect(
        _selectedIds.map((e) => int.tryParse(e) ?? 0).toList(),
      );
      if (response.isSuccess) {
        Get.snackbar('提示', response.msg);
        _loadCollectList(isRefresh: true);
      } else {
        Get.snackbar('提示', response.msg);
      }
    } catch (e) {
      Get.snackbar('提示', '操作失败');
    }
  }

  void _goDetail(Map<String, dynamic> item) {
    if (item['is_show'] == true || item['is_show'] == 1) {
      Get.toNamed('/goods/detail', arguments: {'id': item['pid']});
    } else {
      Get.snackbar('提示', '该商品已下架');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '我的收藏',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: _collectList.isNotEmpty ? _toggleManageMode : null,
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
          if (_isManageMode && _collectList.isNotEmpty) _buildFooter(),
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
          const Text('当前共 ', style: TextStyle(fontSize: 14, color: Color(0xFF333333))),
          Text(
            '$_count',
            style: TextStyle(fontSize: 14, color: _primaryColor, fontWeight: FontWeight.w500),
          ),
          const Text(' 件商品', style: TextStyle(fontSize: 14, color: Color(0xFF333333))),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_collectList.isEmpty && !_isLoading) {
      return const EmptyPage(text: '暂无收藏商品');
    }

    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: true,
      onRefresh: () => _loadCollectList(isRefresh: true),
      onLoading: () => _loadCollectList(),
      child: ListView.builder(
        itemCount: _collectList.length,
        itemBuilder: (context, index) {
          return _buildItem(_collectList[index]);
        },
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> item) {
    final pid = item['pid'].toString();
    final isSelected = _selectedIds.contains(pid);
    final isShow = item['is_show'] == true || item['is_show'] == 1;

    return InkWell(
      onTap: () => _isManageMode ? _toggleSelect(pid) : _goDetail(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: Row(
          children: [
            // 选择框
            if (_isManageMode) ...[
              Checkbox(
                value: isSelected,
                onChanged: (v) => _toggleSelect(pid),
                activeColor: _primaryColor,
              ),
            ],
            // 图片
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: item['image'] ?? '',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: const Color(0xFFF5F5F5)),
                    errorWidget: (context, url, error) => Container(color: const Color(0xFFF5F5F5)),
                  ),
                ),
                // 下架遮罩
                if (!isShow)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha((0.4 * 255).round()),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: const Text('已下架', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // 商品信息
            Expanded(
              child: SizedBox(
                height: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['store_name'] ?? '',
                      style: const TextStyle(fontSize: 14, color: Color(0xFF282828)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '¥${item['price'] ?? 0}',
                      style: TextStyle(
                        fontSize: 14,
                        color: _primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildFooter() {
    final isAllSelected = _selectedIds.length == _collectList.length && _collectList.isNotEmpty;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
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
                Text(
                  '全选(${_selectedIds.length})',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF282828)),
                ),
              ],
            ),
          ),
          // 取关按钮
          GestureDetector(
            onTap: _deleteSelected,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFBBBBBB)),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Text('取关', style: TextStyle(fontSize: 14, color: Color(0xFF999999))),
            ),
          ),
        ],
      ),
    );
  }
}
