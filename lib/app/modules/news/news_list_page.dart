import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../data/providers/public_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme_colors.dart';
import '../../../widgets/empty_page.dart';

class NewsListPage extends StatefulWidget {
  const NewsListPage({super.key});

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  final PublicProvider _publicProvider = PublicProvider();

  List<Map<String, dynamic>> _bannerList = [];
  List<Map<String, dynamic>> _categoryList = [];
  List<Map<String, dynamic>> _articleList = [];
  int _activeCategory = 0;
  int _page = 1;
  bool _loadEnd = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initData() {
    _getArticleBanner();
    _getArticleCategory();
    _getArticleList();
  }

  Future<void> _getArticleBanner() async {
    final response = await _publicProvider.getArticleBannerList();
    if (response.isSuccess && response.data != null) {
      setState(() {
        _bannerList = List<Map<String, dynamic>>.from(response.data);
      });
    }
  }

  Future<void> _getArticleCategory() async {
    final response = await _publicProvider.getArticleCategoryList();
    if (response.isSuccess && response.data != null) {
      setState(() {
        _categoryList = List<Map<String, dynamic>>.from(response.data);
      });
    }
  }

  Future<void> _getArticleList({bool reset = false}) async {
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

    final response = await _publicProvider.getArticleListByCid(_activeCategory, {
      'page': _page,
      'limit': 8,
    });

    if (response.isSuccess && response.data != null) {
      List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(response.data);

      setState(() {
        if (reset) {
          _articleList = list;
        } else {
          _articleList.addAll(list);
        }

        if (list.length < 8) {
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

  void _selectCategory(int id) {
    if (_activeCategory == id) return;
    setState(() {
      _activeCategory = id;
      _articleList = [];
    });
    _getArticleList(reset: true);
  }

  void _goToDetail(int id) {
    Get.toNamed(AppRoutes.newsDetail, parameters: {'id': id.toString()});
  }

  Future<void> _onRefresh() async {
    _getArticleBanner();
    _getArticleCategory();
    await _getArticleList(reset: true);
  }

  Future<void> _onLoading() async {
    await _getArticleList();
  }

  Widget _buildBanner() {
    if (_bannerList.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      height: 160,
      child: CarouselSlider.builder(
        itemCount: _bannerList.length,
        itemBuilder: (context, index, realIndex) {
          Map<String, dynamic> item = _bannerList[index];
          List<dynamic> images = item['image_input'] ?? [];
          String image = images.isNotEmpty ? images[0] : '';
          int id = item['id'] ?? 0;

          return GestureDetector(
            onTap: () => _goToDetail(id),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: image,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) =>
                    Container(color: Colors.grey[200], child: const Icon(Icons.image)),
              ),
            ),
          );
        },
        options: CarouselOptions(
          height: 160,
          autoPlay: true,
          viewportFraction: 1,
          enlargeCenterPage: false,
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    if (_categoryList.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 48,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _categoryList.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> category = _categoryList[index];
          int id = category['id'] ?? 0;
          String title = category['title'] ?? '';
          bool isActive = _activeCategory == id;

          return GestureDetector(
            onTap: () => _selectCategory(id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? ThemeColors.red.primary : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 20,
                    height: 3,
                    decoration: BoxDecoration(
                      color: isActive ? ThemeColors.red.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArticleItem(Map<String, dynamic> item) {
    int id = item['id'] ?? 0;
    String title = item['title'] ?? '';
    String addTime = item['add_time'] ?? '';
    List<dynamic> images = item['image_input'] ?? [];

    if (images.length == 1) {
      // 单图布局
      return GestureDetector(
        onTap: () => _goToDetail(id),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(addTime, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: images[0],
                  width: 100,
                  height: 70,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) =>
                      Container(color: Colors.grey[200], child: const Icon(Icons.image)),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (images.length >= 2) {
      // 多图布局
      return GestureDetector(
        onTap: () => _goToDetail(id),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: images.take(3).map<Widget>((img) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: images.indexOf(img) < 2 ? 8 : 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: img,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[200]),
                          errorWidget: (context, url, error) =>
                              Container(color: Colors.grey[200], child: const Icon(Icons.image)),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text(addTime, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
        ),
      );
    }

    // 无图布局
    return GestureDetector(
      onTap: () => _goToDetail(id),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(addTime, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('资讯'), centerTitle: true),
      body: Column(
        children: [
          _buildCategoryTabs(),

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
              child: _articleList.isEmpty && !_loading
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [EmptyPage(text: '暂无资讯')],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _articleList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildBanner();
                        }
                        return _buildArticleItem(_articleList[index - 1]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
