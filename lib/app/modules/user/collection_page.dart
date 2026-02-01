import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
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
      FlutterToastPro.showMessage('请选择商品');
      return;
    }

    try {
      final response = await _storeProvider.batchUncollect(
        _selectedIds.map((e) => int.tryParse(e) ?? 0).toList(),
      );
      if (response.isSuccess) {
        FlutterToastPro.showMessage(response.msg);
        _loadCollectList(isRefresh: true);
      } else {
        FlutterToastPro.showMessage(response.msg);
      }
    } catch (e) {
      FlutterToastPro.showMessage('操作失败');
    }
  }

  void _goDetail(Map<String, dynamic> item) {
    if (item['is_show'] == true || item['is_show'] == 1) {
      Get.toNamed('/goods/detail', arguments: {'id': item['pid']});
    } else {
      FlutterToastPro.showMessage('该商品已下架');
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
    final listView = _collectList.isEmpty && !_isLoading
        ? ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [EmptyPage(text: '暂无收藏商品')],
          )
        : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _collectList.length,
            itemBuilder: (context, index) {
              return _buildItem(_collectList[index]);
            },
          );

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
      onRefresh: () => _loadCollectList(isRefresh: true),
      onLoad: _hasMore ? () => _loadCollectList() : null,
      child: listView,
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
