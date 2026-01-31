import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/theme/theme_colors.dart';
import 'package:shuhang_mall_flutter/app/utils/cache.dart';

/// 商品搜索页
/// 对应原 pages/goods/goods_search/index.vue
class GoodsSearchPage extends StatefulWidget {
  const GoodsSearchPage({super.key});

  @override
  State<GoodsSearchPage> createState() => _GoodsSearchPageState();
}

class _GoodsSearchPageState extends State<GoodsSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<String> _hotWords = ['新品上市', '热卖推荐', '限时特惠', '品牌精选', '爆款', '好物推荐'];

  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadSearchHistory() {
    final history = Cache.getStringList('search_history');
    if (history != null) {
      setState(() {
        _searchHistory = history;
      });
    }
  }

  void _saveSearchHistory(String keyword) {
    if (keyword.isEmpty) return;
    _searchHistory.remove(keyword);
    _searchHistory.insert(0, keyword);
    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.sublist(0, 10);
    }
    Cache.setStringList('search_history', _searchHistory);
    setState(() {});
  }

  void _clearHistory() {
    Get.dialog(
      AlertDialog(
        title: const Text('提示'),
        content: const Text('确定要清空搜索历史吗？'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Get.back();
              setState(() {
                _searchHistory.clear();
              });
              Cache.remove('search_history');
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        final themeColor = controller.themeColor;

        return Scaffold(
          appBar: _buildSearchBar(themeColor),
          body: ListView(
            padding: const EdgeInsets.all(15),
            children: [
              // 热门搜索
              _buildSection('热门搜索', null, _hotWords, themeColor),
              const SizedBox(height: 20),
              // 搜索历史
              if (_searchHistory.isNotEmpty)
                _buildSection('搜索历史', _clearHistory, _searchHistory, themeColor),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildSearchBar(ThemeColorData themeColor) {
    return AppBar(
      titleSpacing: 0,
      title: Container(
        height: 36,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: '搜索商品',
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
            prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF999999)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _doSearch(value);
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            final keyword = _searchController.text.trim();
            if (keyword.isNotEmpty) {
              _doSearch(keyword);
            }
          },
          child: Text('搜索', style: TextStyle(color: themeColor.primary)),
        ),
      ],
    );
  }

  Widget _buildSection(
    String title,
    VoidCallback? onClear,
    List<String> words,
    ThemeColorData themeColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Row(
                  children: [
                    Icon(Icons.delete_outline, size: 16, color: Color(0xFF999999)),
                    SizedBox(width: 4),
                    Text('清空', style: TextStyle(fontSize: 12, color: Color(0xFF999999))),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: words.map((word) {
            return GestureDetector(
              onTap: () => _doSearch(word),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(word, style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _doSearch(String keyword) {
    _saveSearchHistory(keyword);
    Get.toNamed(AppRoutes.goodsList, parameters: {'keyword': keyword});
  }
}
