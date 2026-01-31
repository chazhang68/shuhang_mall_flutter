import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/providers/lottery_provider.dart';
import '../../theme/theme_colors.dart';
import '../../../widgets/empty_page.dart';

class LotteryRecordPage extends StatefulWidget {
  const LotteryRecordPage({super.key});

  @override
  State<LotteryRecordPage> createState() => _LotteryRecordPageState();
}

class _LotteryRecordPageState extends State<LotteryRecordPage> {
  final LotteryProvider _lotteryProvider = LotteryProvider();
  final RefreshController _refreshController = RefreshController();

  List<Map<String, dynamic>> _recordList = [];
  int _page = 1;
  bool _loadEnd = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _getRecordList();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _getRecordList({bool reset = false}) async {
    if (reset) {
      _page = 1;
      _loadEnd = false;
    }

    if (_loadEnd) {
      _refreshController.loadNoData();
      return;
    }

    if (_loading) return;

    setState(() {
      _loading = true;
    });

    final response = await _lotteryProvider.getLotteryRecord({'page': _page, 'limit': 20});

    if (response.isSuccess && response.data != null) {
      List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
        response.data['list'] ?? response.data,
      );

      setState(() {
        if (reset) {
          _recordList = list;
        } else {
          _recordList.addAll(list);
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

    if (reset) {
      _refreshController.refreshCompleted();
    } else {
      if (_loadEnd) {
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
    }
  }

  void _onRefresh() {
    _getRecordList(reset: true);
  }

  void _onLoading() {
    _getRecordList();
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return '待领取';
      case 1:
        return '已领取';
      case 2:
        return '已过期';
      default:
        return '未知';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      case 2:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Future<void> _receivePrize(Map<String, dynamic> item) async {
    int id = item['id'] ?? 0;

    final response = await _lotteryProvider.exchangePrize({'id': id});

    if (response.isSuccess) {
      Get.snackbar('提示', '领取成功', snackPosition: SnackPosition.BOTTOM);
      _getRecordList(reset: true);
    } else {
      Get.snackbar('提示', response.msg, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Widget _buildRecordItem(Map<String, dynamic> item) {
    int status = item['status'] ?? 0;
    String prizeName = item['prize_name'] ?? '';
    String prizeImage = item['prize_image'] ?? '';
    String createTime = item['create_time'] ?? '';
    int type = item['type'] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 4)],
      ),
      child: Row(
        children: [
          // 奖品图片
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: prizeImage.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: prizeImage,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => Container(
                      width: 64,
                      height: 64,
                      color: Colors.grey[200],
                      child: const Icon(Icons.card_giftcard, color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.card_giftcard, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 16),

          // 奖品信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        prizeName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withAlpha((0.1 * 255).round()),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _getStatusText(status),
                        style: TextStyle(fontSize: 12, color: _getStatusColor(status)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(createTime, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 8),

                // 领取按钮
                if (status == 0 && type != 0) // 未领取且不是谢谢参与
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => _receivePrize(item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.red.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('立即领取', style: TextStyle(fontSize: 13)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的奖品'), centerTitle: true),
      body: _recordList.isEmpty && !_loading
          ? const EmptyPage(text: '暂无中奖记录~')
          : SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              enablePullUp: true,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                itemCount: _recordList.length,
                itemBuilder: (context, index) => _buildRecordItem(_recordList[index]),
              ),
            ),
    );
  }
}
