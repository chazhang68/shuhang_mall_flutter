import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:get/get.dart';
import '../../data/providers/store_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme_colors.dart';
import '../../../widgets/empty_page.dart';

class UserCollectionPage extends StatefulWidget {
  const UserCollectionPage({super.key});

  @override
  State<UserCollectionPage> createState() => _UserCollectionPageState();
}

class _UserCollectionPageState extends State<UserCollectionPage> {
  final StoreProvider _storeProvider = StoreProvider();

  List<Map<String, dynamic>> _collectionList = [];
  Set<int> _selectedIds = {};
  int _count = 0;
  int _page = 1;
  bool _loadEnd = false;
  bool _loading = false;
  bool _isManageMode = false;
  bool _isAllSelected = false;

  @override
  void initState() {
    super.initState();
    _getCollectionList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getCollectionList({bool reset = false}) async {
    if (reset) {
      _page = 1;
      _loadEnd = false;
    }

    if (_loadEnd) {
      return;
    }

    if (_loading) return;

    setState(() {
      _loading = true;
    });

    final response = await _storeProvider.getCollectList({'page': _page, 'limit': 15});

    if (response.isSuccess && response.data != null) {
      List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
        response.data['list'] ?? [],
      );
      _count = response.data['count'] ?? list.length;

      setState(() {
        if (reset) {
          _collectionList = list;
        } else {
          _collectionList.addAll(list);
        }

        if (list.length < 15) {
          _loadEnd = true;
        }
        _page++;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  void _toggleManageMode() {
    setState(() {
      _isManageMode = !_isManageMode;
      if (!_isManageMode) {
        _selectedIds.clear();
        _isAllSelected = false;
      }
    });
  }

  void _toggleSelectItem(int pid) {
    setState(() {
      if (_selectedIds.contains(pid)) {
        _selectedIds.remove(pid);
      } else {
        _selectedIds.add(pid);
      }
      _isAllSelected = _selectedIds.length == _collectionList.length;
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_isAllSelected) {
        _selectedIds.clear();
      } else {
        _selectedIds = _collectionList.map((e) => e['pid'] as int).toSet();
      }
      _isAllSelected = !_isAllSelected;
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) {
      FlutterToastPro.showMessage('请选择商品');
      return;
    }

    final response = await _storeProvider.batchUncollect(_selectedIds.toList());
    if (response.isSuccess) {
      FlutterToastPro.showMessage('取消收藏成功');
      setState(() {
        _collectionList.removeWhere((item) => _selectedIds.contains(item['pid']));
        _count = _collectionList.length;
        _selectedIds.clear();
        _isAllSelected = false;
      });
    }
  }

  void _goToDetail(Map<String, dynamic> item) {
    bool isShow = item['is_show'] == 1 || item['is_show'] == true;
    if (!isShow) {
      FlutterToastPro.showMessage('该商品已下架');
      return;
    }
    int pid = item['pid'] ?? 0;
    Get.toNamed(AppRoutes.goodsDetail, parameters: {'id': pid.toString()});
  }

  Widget _buildCollectionItem(Map<String, dynamic> item) {
    int pid = item['pid'] ?? 0;
    String image = item['image'] ?? '';
    String storeName = item['store_name'] ?? '';
    String price = (item['price'] ?? 0).toString();
    bool isShow = item['is_show'] == 1 || item['is_show'] == true;
    bool isSelected = _selectedIds.contains(pid);

    return GestureDetector(
      onTap: () => _isManageMode ? _toggleSelectItem(pid) : _goToDetail(item),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            if (_isManageMode)
              Container(
                margin: const EdgeInsets.only(right: 12),
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? ThemeColors.red.primary : Colors.grey[400],
                  size: 24,
                ),
              ),

            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: image,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) =>
                        Container(color: Colors.grey[200], child: const Icon(Icons.image)),
                  ),
                ),
                if (!isShow)
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Text('已下架', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '¥$price',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.red.primary,
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

  Widget _buildFooter() {
    if (!_isManageMode || _collectionList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _toggleSelectAll,
            child: Row(
              children: [
                Icon(
                  _isAllSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: _isAllSelected ? ThemeColors.red.primary : Colors.grey[400],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text('全选(${_selectedIds.length})'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _deleteSelected,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.red.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('取消关注'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        centerTitle: true,
        actions: [
          if (_collectionList.isNotEmpty)
            TextButton(
              onPressed: _toggleManageMode,
              child: Text(
                _isManageMode ? '取消' : '管理',
                style: const TextStyle(color: Colors.black87),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // 统计
          if (_collectionList.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  const Text('当前共 '),
                  Text(
                    '$_count',
                    style: TextStyle(color: ThemeColors.red.primary, fontWeight: FontWeight.bold),
                  ),
                  const Text(' 件商品'),
                ],
              ),
            ),

          Expanded(
            child: EasyRefresh(
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
              onRefresh: () => _getCollectionList(reset: true),
              onLoad: _loadEnd ? null : () => _getCollectionList(),
              child: _collectionList.isEmpty && !_loading
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [EmptyPage(text: '暂无收藏商品')],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: _collectionList.length,
                      itemBuilder: (context, index) => _buildCollectionItem(_collectionList[index]),
                    ),
            ),
          ),

          _buildFooter(),
        ],
      ),
    );
  }
}
