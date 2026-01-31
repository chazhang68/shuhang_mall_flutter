import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../theme/theme_colors.dart';
import '../../../widgets/countdown_widget.dart';
import '../../data/providers/activity_provider.dart';

/// 拼团详情页面
class GroupBuyDetailPage extends StatefulWidget {
  const GroupBuyDetailPage({super.key});

  @override
  State<GroupBuyDetailPage> createState() => _GroupBuyDetailPageState();
}

class _GroupBuyDetailPageState extends State<GroupBuyDetailPage> {
  final ActivityProvider _activityProvider = ActivityProvider();

  int _id = 0;
  Map<String, dynamic> _storeInfo = {};
  List<dynamic> _images = [];
  List<dynamic> _pink = []; // 拼团列表
  int _pinkOkSum = 0; // 已拼件数
  int _replyCount = 0;

  bool _isLoading = true;
  bool _showAll = false;
  final int _defaultShowCount = 2;

  @override
  void initState() {
    super.initState();
    _id = int.tryParse(Get.parameters['id'] ?? '0') ?? 0;
    if (_id > 0) {
      _getCombinationDetail();
    }
  }

  /// 获取拼团详情
  Future<void> _getCombinationDetail() async {
    try {
      final response = await _activityProvider.getCombinationDetail(_id);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _storeInfo = response.data['storeInfo'] ?? {};
          _images = _storeInfo['images'] ?? [];
          _pink = response.data['pink'] ?? [];
          _pinkOkSum = response.data['pink_ok_sum'] ?? 0;
          _replyCount = response.data['replyCount'] ?? 0;
          _isLoading = false;
        });
      } else {
        FlutterToastPro.showMessage( response.msg);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('获取拼团详情失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 收藏/取消收藏
  Future<void> _toggleCollect() async {
    // 实现收藏逻辑
  }

  /// 立即开团
  void _startGroup() {
    // 跳转到订单确认页
    Get.toNamed(
      '/order/confirm',
      parameters: {
        'productId': _storeInfo['product_id']?.toString() ?? '',
        'type': 'combination',
        'combinationId': _id.toString(),
      },
    );
  }

  /// 单独购买
  void _buyAlone() {
    // 跳转到商品详情
    Get.toNamed('/goods/detail', parameters: {'id': _storeInfo['product_id']?.toString() ?? ''});
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = ThemeColors.red.primary;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('拼团详情')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('拼团详情'), elevation: 0),
      body: SafeArea(
        child: Stack(
          children: [
            // 内容区域
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 70),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 商品图片轮播
                  if (_images.isNotEmpty)
                    CarouselSlider(
                      options: CarouselOptions(height: 375, viewportFraction: 1.0, autoPlay: true),
                      items: _images.map<Widget>((item) {
                        return CachedNetworkImage(
                          imageUrl: item,
                          width: double.infinity,
                          height: 375,
                          fit: BoxFit.cover,
                        );
                      }).toList(),
                    ),

                  // 商品信息
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 价格和分享
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '￥',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${_storeInfo['price'] ?? 0}',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '￥${_storeInfo['product_price'] ?? 0}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF999999),
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Icon(Icons.share, color: Colors.grey.shade600, size: 24),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // 商品标题
                        Text(
                          _storeInfo['title'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 商品标签
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '类型：${_storeInfo['people'] ?? 0}人团',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                            ),
                            Text(
                              '累计销量：${_storeInfo['total'] ?? 0} ${_storeInfo['unit_name'] ?? ''}',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                            ),
                            Text(
                              '限购：${_storeInfo['quota'] ?? 0} ${_storeInfo['unit_name'] ?? ''}',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 拼团进度通知
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.campaign, color: primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '已拼$_pinkOkSum件',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 拼团列表
                  if (_pink.isNotEmpty)
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          ..._pink
                              .asMap()
                              .entries
                              .where((entry) {
                                return _showAll || entry.key < _defaultShowCount;
                              })
                              .map((entry) {
                                final item = entry.value;
                                return _buildPinkItem(item);
                              }),

                          if (_pink.length > _defaultShowCount)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showAll = !_showAll;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _showAll ? '收起' : '查看更多',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                    Icon(
                                      _showAll
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: const Color(0xFF666666),
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),

                  // 拼团玩法
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '拼团玩法',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildPlayWayItem('①', '开团/参团'),
                            const Icon(Icons.arrow_forward, size: 16),
                            _buildPlayWayItem('②', '邀请好友'),
                            const Icon(Icons.arrow_forward, size: 16),
                            _buildPlayWayItem('③', '满员发货'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 用户评价
                  if (_replyCount > 0)
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '用户评价($_replyCount)',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.toNamed(
                                    '/goods/commentList',
                                    parameters: {
                                      'productId': _storeInfo['product_id']?.toString() ?? '',
                                    },
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Text(
                                      '查看全部',
                                      style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
                                    ),
                                    Icon(Icons.chevron_right, color: Color(0xFF999999), size: 18),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // 这里可以添加评价列表
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),

                  // 产品介绍
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '产品介绍',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),
                        Text(_storeInfo['description'] ?? ''),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 底部操作栏
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.05 * 255).round()),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // 首页
                    GestureDetector(
                      onTap: () => Get.offAllNamed('/'),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.home_outlined, size: 24),
                          SizedBox(height: 2),
                          Text('首页', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // 收藏
                    GestureDetector(
                      onTap: _toggleCollect,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _storeInfo['userCollect'] == true
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 24,
                            color: _storeInfo['userCollect'] == true ? primaryColor : null,
                          ),
                          const SizedBox(height: 2),
                          const Text('收藏', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),

                    // 操作按钮
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _buyAlone,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6F29),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                '单独购买',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _startGroup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                '立即开团',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ],
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

  /// 构建拼团项
  Widget _buildPinkItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          // 用户头像
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: item['avatar'] ?? '',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey.shade300),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // 用户昵称
          Expanded(
            child: Text(
              item['nickname'] ?? '',
              style: const TextStyle(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 拼团信息
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '还差${item['count'] ?? 0}人成团',
                style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 4),
              CountdownWidget(
                endTime: item['stop_time'] ?? 0,
                textColor: const Color(0xFF666666),
                backgroundColor: Colors.transparent,
              ),
            ],
          ),

          const SizedBox(width: 10),

          // 去拼单按钮
          GestureDetector(
            onTap: () {
              Get.toNamed(
                '/activity/groupStatus',
                parameters: {'id': item['id']?.toString() ?? ''},
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              decoration: BoxDecoration(
                color: ThemeColors.red.primary,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text('去拼单', style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建拼团玩法项
  Widget _buildPlayWayItem(String num, String text) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ThemeColors.red.primary.withAlpha((0.1 * 255).round()),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              num,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeColors.red.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
      ],
    );
  }
}


