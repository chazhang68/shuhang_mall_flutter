import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/providers/lottery_provider.dart';
import '../../theme/theme_colors.dart';
import '../../../widgets/empty_page.dart';

class PointsGoodsListPage extends StatefulWidget {
  const PointsGoodsListPage({super.key});

  @override
  State<PointsGoodsListPage> createState() => _PointsGoodsListPageState();
}

class _PointsGoodsListPageState extends State<PointsGoodsListPage> {
  final PointsMallProvider _pointsMallProvider = PointsMallProvider();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _productList = [];
  bool _isSwitch = true; // true: 双列, false: 单列
  int _page = 1;
  bool _loadEnd = false;
  bool _loading = false;

  // 排序状态: 0-默认, 1-升序, 2-降序
  int _priceSort = 0;
  int _salesSort = 0;

  String _storeName = '';

  @override
  void initState() {
    super.initState();
    _storeName = Get.parameters['searchValue'] ?? '';
    _searchController.text = _storeName;
    _getProductList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getProductList({bool reset = false}) async {
    if (reset) {
      _page = 1;
      _loadEnd = false;
    }

    if (_loadEnd) {
      return;
    }

    setState(() {
      _loading = true;
    });

    String priceOrder = '';
    String salesOrder = '';

    if (_priceSort == 1) {
      priceOrder = 'asc';
    } else if (_priceSort == 2) {
      priceOrder = 'desc';
    }

    if (_salesSort == 1) {
      salesOrder = 'asc';
    } else if (_salesSort == 2) {
      salesOrder = 'desc';
    }

    final response = await _pointsMallProvider.getPointsGoodsList({
      'store_name': _storeName,
      'priceOrder': priceOrder,
      'salesOrder': salesOrder,
      'page': _page,
      'limit': 20,
    });

    if (response.isSuccess && response.data != null) {
      List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(response.data);

      setState(() {
        if (reset) {
          _productList = list;
        } else {
          _productList.addAll(list);
        }

        if (list.length < 20) {
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

  Future<void> _onRefresh() async {
    await _getProductList(reset: true);
  }

  Future<void> _onLoading() async {
    await _getProductList();
  }

  void _searchSubmit(String value) {
    setState(() {
      _storeName = value;
    });
    _getProductList(reset: true);
  }

  void _toggleSwitch() {
    setState(() {
      _isSwitch = !_isSwitch;
    });
  }

  void _setSort(int type) {
    setState(() {
      if (type == 1) {
        // 默认排序
        _priceSort = 0;
        _salesSort = 0;
        _storeName = '';
        _searchController.clear();
      } else if (type == 2) {
        // 消费券排序
        if (_priceSort == 0) {
          _priceSort = 1;
        } else if (_priceSort == 1) {
          _priceSort = 2;
        } else {
          _priceSort = 0;
        }
        _salesSort = 0;
      } else if (type == 3) {
        // 销量排序
        if (_salesSort == 0) {
          _salesSort = 1;
        } else if (_salesSort == 1) {
          _salesSort = 2;
        } else {
          _salesSort = 0;
        }
        _priceSort = 0;
      }
    });
    _getProductList(reset: true);
  }

  void _goDetail(Map<String, dynamic> item) {
    Get.toNamed('/points-mall/goods/detail', parameters: {'id': (item['id'] ?? 0).toString()});
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: ThemeColors.red.primary,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: '搜索商品名称',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 14),
                      textInputAction: TextInputAction.search,
                      onSubmitted: _searchSubmit,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _toggleSwitch,
            child: Icon(
              _isSwitch ? Icons.view_module : Icons.view_list,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => _setSort(1),
            child: Text(
              '默认',
              style: TextStyle(
                fontSize: 14,
                color: _priceSort == 0 && _salesSort == 0 ? ThemeColors.red.primary : Colors.black,
                fontWeight: _priceSort == 0 && _salesSort == 0
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _setSort(2),
            child: Row(
              children: [
                Text(
                  '消费券',
                  style: TextStyle(
                    fontSize: 14,
                    color: _priceSort != 0 ? ThemeColors.red.primary : Colors.black,
                    fontWeight: _priceSort != 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Icon(
                  _priceSort == 1
                      ? Icons.arrow_upward
                      : (_priceSort == 2 ? Icons.arrow_downward : Icons.unfold_more),
                  size: 16,
                  color: _priceSort != 0 ? ThemeColors.red.primary : Colors.grey,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _setSort(3),
            child: Row(
              children: [
                Text(
                  '销量',
                  style: TextStyle(
                    fontSize: 14,
                    color: _salesSort != 0 ? ThemeColors.red.primary : Colors.black,
                    fontWeight: _salesSort != 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Icon(
                  _salesSort == 1
                      ? Icons.arrow_upward
                      : (_salesSort == 2 ? Icons.arrow_downward : Icons.unfold_more),
                  size: 16,
                  color: _salesSort != 0 ? ThemeColors.red.primary : Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> item) {
    if (_isSwitch) {
      // 双列模式
      return GestureDetector(
        onTap: () => _goDetail(item),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 4),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: CachedNetworkImage(
                  imageUrl: item['image'] ?? '',
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) =>
                      Container(color: Colors.grey[200], child: const Icon(Icons.image)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${item['price'] ?? 0}消费券',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeColors.red.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item['sales'] ?? 0}人兑换',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: ThemeColors.red.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '兑换',
                            style: TextStyle(fontSize: 11, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // 单列模式
      return GestureDetector(
        onTap: () => _goDetail(item),
        child: Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 1),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: item['image'] ?? '',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) =>
                      Container(color: Colors.grey[200], child: const Icon(Icons.image)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${item['price'] ?? 0}消费券',
                      style: TextStyle(
                        fontSize: 16,
                        color: ThemeColors.red.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item['sales'] ?? 0}人兑换',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: ThemeColors.red.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '兑换',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('积分商品'), centerTitle: true),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildSortBar(),
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
              onRefresh: _onRefresh,
              onLoad: _loadEnd ? null : _onLoading,
              child: _productList.isEmpty && !_loading
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [EmptyPage(text: '暂无商品')],
                    )
                  : _isSwitch
                  ? GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _productList.length,
                      itemBuilder: (context, index) => _buildProductItem(_productList[index]),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _productList.length,
                      itemBuilder: (context, index) => _buildProductItem(_productList[index]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
