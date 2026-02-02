import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/app/theme/theme_colors.dart';
import 'package:shuhang_mall_flutter/app/utils/config.dart';

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
  final UserProvider _userProvider = UserProvider();

  List<Map<String, dynamic>> _searchHistory = [];
  bool _isLoading = false;

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

  /// 加载搜索历史 - 对应uni-app的searchList
  Future<void> _loadSearchHistory() async {
    setState(() => _isLoading = true);
    try {
      final response = await _userProvider.getSearchHistory({'page': 1, 'limit': 10});
      if (response.isSuccess && response.data != null) {
        setState(() {
          _searchHistory = List<Map<String, dynamic>>.from(
            (response.data as List).map((item) => Map<String, dynamic>.from(item)),
          );
        });
      }
    } catch (e) {
      debugPrint('加载搜索历史失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 清空搜索历史 - 对应uni-app的clear
  void _clearHistory() {
    Get.dialog(
      AlertDialog(
        title: const Text('提示'),
        content: const Text('确定要清空搜索历史吗？'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              Get.back();
              final response = await _userProvider.clearSearchHistory();
              if (response.isSuccess) {
                FlutterToastPro.showMessage(response.msg);
                setState(() {
                  _searchHistory.clear();
                });
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 搜索 - 对应uni-app的setHotSearchValue
  void _doSearch(String keyword) {
    if (keyword.isEmpty) return;
    Get.toNamed(AppRoutes.goodsList, parameters: {'keyword': keyword});
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        final themeColor = controller.themeColor;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildSearchBar(themeColor),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(15),
                  children: [
                    // 搜索历史
                    if (_searchHistory.isNotEmpty) _buildHistorySection(themeColor),
                    // 空搜索提示
                    _buildEmptySearch(),
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
          decoration: const InputDecoration(
            hintText: '搜索商品名称',
            hintStyle: TextStyle(fontSize: 14, color: Color(0xFF999999)),
            prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFF999999)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
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

  /// 搜索历史区域 - 对应uni-app的history区域
  Widget _buildHistorySection(ThemeColorData themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '搜索历史',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            GestureDetector(
              onTap: _clearHistory,
              child: const Icon(Icons.delete_outline, size: 20, color: Color(0xFF999999)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 历史记录列表
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _searchHistory.map((item) {
            final keyword = item['keyword']?.toString() ?? '';
            if (keyword.isEmpty) return const SizedBox.shrink();
            return GestureDetector(
              onTap: () => _doSearch(keyword),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  keyword,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 空搜索提示 - 对应uni-app的空状态图
  Widget _buildEmptySearch() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 空搜索图片 - 使用网络图片
          CachedNetworkImage(
            imageUrl: '${AppConfig.httpRequestUrl}/statics/images/noSearch.png',
            width: 200,
            height: 150,
            fit: BoxFit.contain,
            placeholder: (context, url) => const SizedBox(
              width: 200,
              height: 150,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (context, url, error) => Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.search,
                size: 80,
                color: Color(0xFFCCCCCC),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
