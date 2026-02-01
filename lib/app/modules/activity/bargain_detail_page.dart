import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:get/get.dart';
import '../../data/providers/activity_provider.dart';
import '../../theme/theme_colors.dart';
import '../../../widgets/countdown_widget.dart';

class BargainDetailPage extends StatefulWidget {
  const BargainDetailPage({super.key});

  @override
  State<BargainDetailPage> createState() => _BargainDetailPageState();
}

class _BargainDetailPageState extends State<BargainDetailPage> {
  final ActivityProvider _activityProvider = ActivityProvider();

  int _id = 0;
  int _bargainUid = 0;
  final int _userUid = 0;

  Map<String, dynamic> _bargainInfo = {};
  Map<String, dynamic> _bargainUserInfo = {};
  Map<String, dynamic> _userBargainInfo = {};
  Map<String, dynamic> _peopleCount = {};
  List<dynamic> _bargainUserHelpList = [];
  String _description = '';
  String _rule = '';
  int _datatime = 0;
  bool _couponsHidden = true;

  @override
  void initState() {
    super.initState();
    _id = int.tryParse(Get.parameters['id'] ?? '0') ?? 0;
    _bargainUid = int.tryParse(Get.parameters['bargain'] ?? '0') ?? 0;
    if (_id > 0) {
      _getBargainDetail();
      _getBargainUserHelp();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getBargainDetail() async {
    final response = await _activityProvider.getBargainDetail(_id);
    if (response.isSuccess && response.data != null) {
      setState(() {
        _bargainInfo = response.data['bargainInfo'] ?? {};
        _bargainUserInfo = response.data['bargainUserInfo'] ?? {};
        _userBargainInfo = response.data['userBargainInfo'] ?? {};
        _peopleCount = response.data['peopleCount'] ?? {};
        _description = _bargainInfo['description'] ?? '';
        _rule = _bargainInfo['rule'] ?? '';
        _datatime = _bargainInfo['datatime'] ?? 0;
      });
    }
  }

  Future<void> _getBargainUserHelp() async {
    final response = await _activityProvider.getBargainUserList(_id, {
      'bargain_user_id': _bargainUid,
      'page': 1,
      'limit': 100,
    });
    if (response.isSuccess && response.data != null) {
      setState(() {
        _bargainUserHelpList = response.data ?? [];
      });
    }
  }

  void _setBargainHelp() {
    // TODO: 实现帮砍一刀逻辑
    FlutterToastPro.showMessage('帮砍一刀功能待实现');
  }

  void _goBargainList() {
    Get.offNamed('/activity/bargain');
  }

  void _goPay() {
    // TODO: 跳转到支付页面
    Get.toNamed('/order/confirm');
  }

  void _goProduct() {
    Get.toNamed('/goods/detail', parameters: {'id': _bargainInfo['product_id']?.toString() ?? '0'});
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ThemeColors.red.primary, ThemeColors.red.primary.withAlpha((0.8 * 255).round())],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    '${_peopleCount['lookCount'] ?? 0}人查看',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Container(width: 1, height: 12, color: Colors.white),
                  Text(
                    '${_peopleCount['shareCount'] ?? 0}人分享',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Container(width: 1, height: 12, color: Colors.white),
                  Text(
                    '${_peopleCount['userCount'] ?? 0}人参与',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            if (_bargainUid == _userUid)
              CountdownWidget(endTime: _datatime, textColor: Colors.white)
            else
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: _bargainUserInfo['avatar'] ?? '',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey[300]),
                        errorWidget: (context, url, error) =>
                            Container(color: Colors.grey[300], child: const Icon(Icons.person)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_bargainUserInfo['nickname'] ?? ''}邀请您帮忙砍价',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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

  Widget _buildProductInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: _bargainInfo['image'] ?? '',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[300]),
                  errorWidget: (context, url, error) =>
                      Container(color: Colors.grey[300], child: const Icon(Icons.image)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _bargainInfo['title'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('当前: ', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        Text(
                          '¥${_bargainInfo['price'] ?? 0}',
                          style: TextStyle(
                            fontSize: 18,
                            color: ThemeColors.red.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '最低: ¥${_bargainInfo['min_price'] ?? 0}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: _goProduct,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: ThemeColors.red.primary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('查看商品', style: TextStyle(fontSize: 14, color: ThemeColors.red.primary)),
                      Icon(Icons.arrow_forward_ios, size: 12, color: ThemeColors.red.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if ((_userBargainInfo['price'] ?? 0) > 0) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_userBargainInfo['pricePercent'] ?? 0) / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(ThemeColors.red.primary),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '已砍${_userBargainInfo['alreadyPrice'] ?? 0}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(
                  '还剩${_userBargainInfo['price'] ?? 0}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          _buildBargainButton(),
        ],
      ),
    );
  }

  Widget _buildBargainButton() {
    int bargainType = _userBargainInfo['bargainType'] ?? 0;

    switch (bargainType) {
      case 1:
        return ElevatedButton(
          onPressed: () {
            // TODO: 立即参与砍价
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColors.red.primary,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          child: const Text('立即参与砍价'),
        );
      case 2:
        return Column(
          children: [
            ElevatedButton(
              onPressed: () {
                // TODO: 邀请好友帮砍价
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.red.primary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('邀请好友帮砍价'),
            ),
            const SizedBox(height: 8),
            Text(
              '已有${_userBargainInfo['count'] ?? 0}位好友成功砍价',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        );
      case 3:
        return ElevatedButton(
          onPressed: _setBargainHelp,
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColors.red.primary,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          child: const Text('帮好友砍一刀'),
        );
      case 4:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sentiment_satisfied, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Text(
                    '好友已砍价成功',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // TODO: 我也要参与
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.red.primary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('我也要参与'),
            ),
          ],
        );
      case 5:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sentiment_satisfied, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Text(
                    '已成功帮助好友砍价',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // TODO: 我也要参与
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.red.primary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('我也要参与'),
            ),
          ],
        );
      case 6:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sentiment_very_satisfied, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Text(
                    '恭喜您砍价成功，快去支付',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _goPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.red.primary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('立即支付'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _goBargainList,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: ThemeColors.red.primary),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: Text('抢更多商品', style: TextStyle(color: ThemeColors.red.primary)),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBargainHelp() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
          const Text('砍价帮', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_bargainUserHelpList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('暂无砍价记录', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _couponsHidden
                  ? (_bargainUserHelpList.length > 3 ? 3 : _bargainUserHelpList.length)
                  : _bargainUserHelpList.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final item = _bargainUserHelpList[index];
                return Row(
                  children: [
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: item['avatar'] ?? '',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey[300]),
                        errorWidget: (context, url, error) =>
                            Container(color: Colors.grey[300], child: const Icon(Icons.person)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['nickname'] ?? '',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['add_time'] ?? '',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '砍掉¥${item['price'] ?? 0}',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeColors.red.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          if (_bargainUserHelpList.length > 3)
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _couponsHidden = !_couponsHidden;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_couponsHidden ? '更多' : '收起'),
                    Icon(
                      _couponsHidden ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('砍价详情'), elevation: 0),
      body: EasyRefresh(
        header: const ClassicHeader(
          dragText: '下拉刷新',
          armedText: '松手刷新',
          processingText: '刷新中...',
          processedText: '刷新完成',
          failedText: '刷新失败',
        ),
        onRefresh: () async {
          await _getBargainDetail();
          await _getBargainUserHelp();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _buildHeader(),
            _buildProductInfo(),
            _buildBargainHelp(),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
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
                  const Text('商品详情', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text(_description),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
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
                  const Text('砍价规则', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text(_rule),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
