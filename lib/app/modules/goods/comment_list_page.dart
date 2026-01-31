import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../theme/theme_colors.dart';
import '../../../widgets/empty_page.dart';
import '../../data/providers/store_provider.dart';

/// 商品评论列表页面
class CommentListPage extends StatefulWidget {
  const CommentListPage({super.key});

  @override
  State<CommentListPage> createState() => _CommentListPageState();
}

class _CommentListPageState extends State<CommentListPage> {
  final StoreProvider _storeProvider = StoreProvider();

  int _productId = 0;
  int _type = 0; // 0-全部 1-好评 2-中评 3-差评

  Map<String, dynamic> _replyData = {};
  List<dynamic> _reply = [];

  int _page = 1;
  final int _limit = 20;

  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _productId = int.tryParse(Get.parameters['productId'] ?? '0') ?? 0;
    if (_productId > 0) {
      _getProductReplyCount();
      _getProductReplyList();
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  /// 获取评论统计
  Future<void> _getProductReplyCount() async {
    try {
      final response = await _storeProvider.getReplyCount(_productId);
      if (response.isSuccess) {
        setState(() {
          _replyData = response.data ?? {};
        });
      }
    } catch (e) {
      debugPrint('获取评论统计失败: $e');
    }
  }

  /// 获取评论列表
  Future<void> _getProductReplyList({bool isLoadMore = false}) async {
    try {
      final response = await _storeProvider.getReplyList(_productId, {
        'page': _page,
        'limit': _limit,
        'type': _type,
      });

      if (response.isSuccess) {
        final List<dynamic> list = response.data ?? [];

        setState(() {
          if (isLoadMore) {
            _reply.addAll(list);
            if (list.length < _limit) {
              _refreshController.loadNoData();
            } else {
              _refreshController.loadComplete();
              _page++;
            }
          } else {
            _reply = list;
            _refreshController.refreshCompleted();
            _page = 2;
            if (list.length < _limit) {
              _refreshController.loadNoData();
            }
          }
        });
      } else {
        if (isLoadMore) {
          _refreshController.loadFailed();
        } else {
          _refreshController.refreshFailed();
        }
      }
    } catch (e) {
      debugPrint('获取评论列表失败: $e');
      if (isLoadMore) {
        _refreshController.loadFailed();
      } else {
        _refreshController.refreshFailed();
      }
    }
  }

  /// 切换评论类型
  void _changeType(int type) {
    if (type == _type) return;

    setState(() {
      _type = type;
      _page = 1;
      _reply = [];
    });

    _getProductReplyList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('商品评价'), elevation: 0),
      body: SafeArea(
        child: Column(
          children: [
            // 评分统计
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('评分', style: TextStyle(fontSize: 14, color: Color(0xFF808080))),
                      const SizedBox(width: 8),
                      _buildStarRating(_replyData['reply_star']?.toString() ?? '0'),
                    ],
                  ),
                  Text(
                    '好评率 ${_replyData['reply_chance'] ?? 0}%',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF808080)),
                  ),
                ],
              ),
            ),

            // 筛选类型
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
              ),
              child: Row(
                children: [
                  _buildTypeItem('全部', 0, _replyData['sum_count'] ?? 0),
                  const SizedBox(width: 10),
                  _buildTypeItem('好评', 1, _replyData['good_count'] ?? 0),
                  const SizedBox(width: 10),
                  _buildTypeItem('中评', 2, _replyData['in_count'] ?? 0),
                  const SizedBox(width: 10),
                  _buildTypeItem('差评', 3, _replyData['poor_count'] ?? 0),
                ],
              ),
            ),

            // 评论列表
            Expanded(
              child: _reply.isEmpty
                  ? const EmptyPage(text: '暂无评论')
                  : SmartRefresher(
                      controller: _refreshController,
                      enablePullDown: true,
                      enablePullUp: true,
                      onRefresh: () => _getProductReplyList(),
                      onLoading: () => _getProductReplyList(isLoadMore: true),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(15),
                        itemCount: _reply.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 15),
                        itemBuilder: (context, index) {
                          final item = _reply[index];
                          return _buildCommentItem(item);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建类型筛选项
  Widget _buildTypeItem(String label, int type, int count) {
    final bool isSelected = _type == type;
    final Color primaryColor = ThemeColors.red.primary;

    return GestureDetector(
      onTap: () => _changeType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          '$label($count)',
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : const Color(0xFF282828),
          ),
        ),
      ),
    );
  }

  /// 构建星级评分
  Widget _buildStarRating(String rating) {
    final int star = int.tryParse(rating) ?? 0;

    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < star ? Icons.star : Icons.star_border,
          size: 16,
          color: const Color(0xFFFFB547),
        );
      }),
    );
  }

  /// 构建评论项
  Widget _buildCommentItem(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息
          Row(
            children: [
              ClipOval(
                child: Image.network(
                  item['avatar'] ?? '',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.person, color: Colors.white),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['nickname'] ?? '',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStarRating(item['star']?.toString() ?? '0'),
                        const SizedBox(width: 10),
                        Text(
                          item['add_time'] ?? '',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 评论内容
          Text(item['comment'] ?? '', style: const TextStyle(fontSize: 14, height: 1.5)),

          // 评论图片
          if (item['pics'] != null && (item['pics'] as List).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (item['pics'] as List).map<Widget>((pic) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(pic, width: 80, height: 80, fit: BoxFit.cover),
                  );
                }).toList(),
              ),
            ),

          // 商品信息
          if (item['product'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        item['product']['image'] ?? '',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['product']['title'] ?? '',
                            style: const TextStyle(fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['product']['sku'] ?? '',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 商家回复
          if (item['merchant_reply_content'] != null &&
              (item['merchant_reply_content'] as String).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9F0),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('商家回复', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    Text(item['merchant_reply_content'], style: const TextStyle(fontSize: 13)),
                    if (item['merchant_reply_time'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item['merchant_reply_time'],
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
