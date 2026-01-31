import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/providers/activity_provider.dart';
import '../../theme/theme_colors.dart';
import '../../../widgets/countdown_widget.dart';

class GroupbuyStatusPage extends StatefulWidget {
  const GroupbuyStatusPage({super.key});

  @override
  State<GroupbuyStatusPage> createState() => _GroupbuyStatusPageState();
}

class _GroupbuyStatusPageState extends State<GroupbuyStatusPage> {
  final ActivityProvider _activityProvider = ActivityProvider();
  final RefreshController _refreshController = RefreshController();

  int _pinkId = 0;
  int _pinkBool = 0; // 0进行中, 1成功, -1失败
  int _userBool = 0; // 0未在团内, 1在团内
  int _isOk = 0;
  int _count = 0;
  int _orderPid = 0;
  Map<String, dynamic> _pinkT = {}; // 团长信息
  List<dynamic> _pinkAll = []; // 团员
  Map<String, dynamic> _storeCombination = {}; // 拼团产品
  List<dynamic> _storeCombinationHost = []; // 推荐产品
  final bool _isHidden = false;
  bool _posters = false;

  @override
  void initState() {
    super.initState();
    _pinkId = int.tryParse(Get.parameters['id'] ?? '0') ?? 0;
    if (_pinkId > 0) {
      _getCombinationPink();
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _getCombinationPink() async {
    final response = await _activityProvider.getCombinationPink(_pinkId);
    if (response.isSuccess && response.data != null) {
      setState(() {
        _pinkBool = response.data['pinkBool'] ?? 0;
        _userBool = response.data['userBool'] ?? 0;
        _isOk = response.data['isOk'] ?? 0;
        _count = response.data['count'] ?? 0;
        _orderPid = response.data['orderPid'] ?? 0;
        _pinkT = response.data['pinkT'] ?? {};
        _pinkAll = response.data['pinkAll'] ?? [];
        _storeCombination = response.data['storeCombination'] ?? {};
        _storeCombinationHost = response.data['storeCombinationHost'] ?? [];
      });
    }
    _refreshController.refreshCompleted();
  }

  void _goDetail(int id) {
    Get.toNamed('/activity/groupbuy/detail', parameters: {'id': id.toString()});
  }

  void _goList() {
    Get.toNamed('/activity/groupbuy');
  }

  void _goOrder() {
    Get.toNamed('/order/detail', parameters: {'id': (_pinkT['order_id'] ?? '').toString()});
  }

  void _inviteFriend() {
    setState(() {
      _posters = true;
    });
  }

  void _closePosters() {
    setState(() {
      _posters = false;
    });
  }

  void _pay() {
    Get.toNamed(
      '/activity/groupbuy/detail',
      parameters: {'id': (_storeCombination['id'] ?? 0).toString(), 'pinkId': _pinkId.toString()},
    );
  }

  Future<void> _getCombinationRemove() async {
    bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('提示'),
        content: const Text('确定取消开团吗？'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('取消')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('确定')),
        ],
      ),
    );

    if (confirm == true) {
      final response = await _activityProvider.cancelCombination(_pinkId);
      if (response.isSuccess) {
        Get.snackbar('提示', '取消成功', snackPosition: SnackPosition.BOTTOM);
        _getCombinationPink();
      } else {
        Get.snackbar('提示', response.msg, snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Widget _buildHeader() {
    if (_storeCombination.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: _storeCombination['image'] ?? '',
              width: 80,
              height: 80,
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
                  _storeCombination['title'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '¥${_storeCombination['price'] ?? 0}',
                      style: TextStyle(
                        fontSize: 18,
                        color: ThemeColors.red.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: ThemeColors.red.primary.withAlpha((0.1 * 255).round()),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${_storeCombination['people'] ?? 0}人拼',
                        style: TextStyle(fontSize: 12, color: ThemeColors.red.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_pinkBool == -1)
            Icon(Icons.cancel, size: 48, color: Colors.grey[400])
          else if (_pinkBool == 1)
            Icon(Icons.check_circle, size: 48, color: Colors.green[400]),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // 状态标题
          if (_pinkBool == 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 40, height: 1, color: Colors.grey[300]),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text('剩余 ', style: TextStyle(fontSize: 14)),
                      if (_pinkT['stop_time'] != null)
                        CountdownWidget(
                          endTime: _pinkT['stop_time'],
                          textColor: ThemeColors.red.primary,
                          backgroundColor: Colors.transparent,
                        ),
                      const Text(' 结束', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                Container(width: 40, height: 1, color: Colors.grey[300]),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // 状态提示
          Text(
            _pinkBool == 1
                ? '恭喜您拼团成功'
                : (_pinkBool == -1 ? '还差$_count人，拼团失败' : '拼团中，还差$_count人拼团成功'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _pinkBool == 1
                  ? Colors.green
                  : (_pinkBool == -1 ? Colors.grey : ThemeColors.red.primary),
            ),
          ),

          const SizedBox(height: 16),

          // 团员头像列表
          _buildMemberList(),

          const SizedBox(height: 16),

          // 按钮区域
          _buildActionButtons(),

          // 查看订单
          if (_pinkBool == 1 && _orderPid == 0)
            TextButton(
              onPressed: _goOrder,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [const Text('查看订单信息'), const Icon(Icons.arrow_forward_ios, size: 14)],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMemberList() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        // 团长
        Stack(
          children: [
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: _pinkT['avatar'] ?? '',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[300]),
                errorWidget: (context, url, error) =>
                    Container(color: Colors.grey[300], child: const Icon(Icons.person, size: 24)),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: ThemeColors.red.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '团长',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          ],
        ),

        // 已参团成员
        ..._pinkAll.take(_isHidden ? _pinkAll.length : 8).map((item) {
          return ClipOval(
            child: CachedNetworkImage(
              imageUrl: item['avatar'] ?? '',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[300]),
              errorWidget: (context, url, error) =>
                  Container(color: Colors.grey[300], child: const Icon(Icons.person, size: 24)),
            ),
          );
        }),

        // 空位
        ...List.generate(
          _count.clamp(0, _isHidden ? _count : 8 - _pinkAll.length.clamp(0, 8)),
          (index) => Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
            child: const Icon(Icons.person_outline, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_userBool == 1 && _isOk == 0 && _pinkBool == 0) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _inviteFriend,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.red.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              child: const Text(
                '邀请好友参团',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _getCombinationRemove,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.close, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('取消开团', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      );
    }

    if (_userBool == 0 && _pinkBool == 0 && _count > 0) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _pay,
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColors.red.primary,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          ),
          child: const Text('我要参团', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      );
    }

    if (_pinkBool == 1 || _pinkBool == -1) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _goDetail(_storeCombination['id'] ?? 0),
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColors.red.primary,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          ),
          child: const Text('再次开团', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildRecommendSection() {
    if (_storeCombinationHost.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('大家都在拼', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              InkWell(
                onTap: _goList,
                child: Row(
                  children: [
                    Text('更多拼团', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[600]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _storeCombinationHost.length,
              itemBuilder: (context, index) {
                final item = _storeCombinationHost[index];
                return GestureDetector(
                  onTap: () => _goDetail(item['id'] ?? 0),
                  child: Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: item['image'] ?? '',
                                width: 140,
                                height: 140,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(color: Colors.grey[200]),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: ThemeColors.red.primary,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  '${item['people'] ?? 0}人团',
                                  style: const TextStyle(fontSize: 10, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['title'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '¥${item['price'] ?? 0}',
                          style: TextStyle(
                            fontSize: 14,
                            color: ThemeColors.red.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharePopup() {
    if (!_posters) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _closePosters,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('分享给好友', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // 分享到微信好友
                        _closePosters();
                        Get.snackbar('提示', '分享功能开发中', snackPosition: SnackPosition.BOTTOM);
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.green[400],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.chat, color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 8),
                          const Text('发送给朋友', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // 生成海报
                        _closePosters();
                        Get.snackbar('提示', '海报生成中...', snackPosition: SnackPosition.BOTTOM);
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.orange[400],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.image, color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 8),
                          const Text('生成海报', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextButton(onPressed: _closePosters, child: const Text('取消')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('拼团状态'), centerTitle: true),
      body: Stack(
        children: [
          SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            onRefresh: _getCombinationPink,
            child: ListView(
              children: [_buildHeader(), _buildStatusSection(), _buildRecommendSection()],
            ),
          ),
          _buildSharePopup(),
        ],
      ),
    );
  }
}
