import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/widgets/empty_page.dart';

/// OTC 订单页面 - 适用于 OTC 交易订单列表与详情入口。
class OtcOrderPage extends StatefulWidget {
  const OtcOrderPage({super.key});

  @override
  State<OtcOrderPage> createState() => _OtcOrderPageState();
}

class _OtcOrderPageState extends State<OtcOrderPage> with TickerProviderStateMixin {
  final UserProvider _userProvider = UserProvider();

  final List<String> _tabs = ['我的换入', '我的换出'];
  final List<String> _leftFilters = ['全部', '发布中', '待支付', '待确认', '已完成'];
  final List<String> _rightFilters = ['全部', '待收款', '待确认', '已完成'];

  final List<Map<String, dynamic>> _records = [];
  int _page = 1;
  final int _limit = 15;
  bool _loading = false;
  bool _loadEnd = false;
  int _currentTab = 0;
  int _statusIndex = 0;

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadList();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _currentTab = _tabController.index;
      _statusIndex = 0;
      _page = 1;
      _loadEnd = false;
      _records.clear();
    });
    _loadList();
  }

  Future<void> _loadList() async {
    if (_loading || _loadEnd) return;

    setState(() {
      _loading = true;
    });

    try {
      final response = await _userProvider.getMyOtcList({
        'page': _page,
        'limit': _limit,
        'current': _currentTab == 0 ? 1 : 2,
        'child': _statusIndex,
      });
      if (response.isSuccess && response.data != null) {
        final data = response.data is List ? response.data as List : <dynamic>[];
        setState(() {
          _loadEnd = data.length < _limit;
          _records.addAll(List<Map<String, dynamic>>.from(data));
          _page++;
        });
      }
    } catch (e) {
      debugPrint('加载 OTC 订单失败: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _page = 1;
      _loadEnd = false;
      _records.clear();
    });
    await _loadList();
  }

  void _changeStatus(int index) {
    setState(() {
      _statusIndex = index;
      _page = 1;
      _loadEnd = false;
      _records.clear();
    });
    _loadList();
  }

  Future<void> _cancel(int id) async {
    await _userProvider.cancelOtc(id);
    await _onRefresh();
  }

  Future<void> _confirm(int id) async {
    await _userProvider.okOver(id);
    await _onRefresh();
  }

  void _goPay(int id) {
    Get.toNamed(AppRoutes.otcPay, arguments: {'id': id});
  }

  @override
  Widget build(BuildContext context) {
    final filters = _currentTab == 0 ? _leftFilters : _rightFilters;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OTC 订单'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((text) => Tab(text: text)).toList(),
        ),
      ),
      body: Column(
        children: [
          _StatusFilterBar(filters: filters, selectedIndex: _statusIndex, onChanged: _changeStatus),
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
                noMoreText: '我也是有底线的',
                failedText: '加载失败',
              ),
              onRefresh: _onRefresh,
              onLoad: _loadEnd ? null : _loadList,
              child: _records.isEmpty && _page > 1
                  ? ListView(children: const [EmptyPage(title: '暂无数据~')])
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _records.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _records[index];
                        return _OtcOrderCard(
                          item: item,
                          isOutgoing: _currentTab == 1,
                          onCancel: _cancel,
                          onConfirm: _confirm,
                          onPay: _goPay,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _StatusFilterBar({
    required this.filters,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: List.generate(filters.length, (index) {
          return ChoiceChip(
            label: Text(filters[index]),
            selected: selectedIndex == index,
            onSelected: (_) => onChanged(index),
          );
        }),
      ),
    );
  }
}

class _OtcOrderCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isOutgoing;
  final ValueChanged<int> onCancel;
  final ValueChanged<int> onConfirm;
  final ValueChanged<int> onPay;

  const _OtcOrderCard({
    required this.item,
    required this.isOutgoing,
    required this.onCancel,
    required this.onConfirm,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final id = int.tryParse('${item['id']}') ?? 0;
    final avatar = item['avatar']?.toString() ?? '';
    final nickname = item['nickname']?.toString() ?? '-';
    final dprice = item['dprice']?.toString() ?? '-';
    final number = item['number']?.toString() ?? '-';
    final type = item['type']?.toString() == '1' ? '消费券' : '福豆';
    final status = int.tryParse('${item['status']}') ?? 0;
    final isBank = item['is_bank'] == true || item['is_bank'] == 1;
    final isAlipay = item['is_alipay'] == true || item['is_alipay'] == 1;
    final isWechat = item['is_wechat'] == true || item['is_wechat'] == 1;
    final time = int.tryParse('${item['time']}') ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: avatar.isEmpty ? null : NetworkImage(avatar),
                child: avatar.isEmpty ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  nickname,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              _StatusBadge(status: status, isOutgoing: isOutgoing),
            ],
          ),
          const SizedBox(height: 8),
          Text(dprice, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('数量：$number'),
          const SizedBox(height: 4),
          Text('类型：$type'),
          const SizedBox(height: 12),
          _OtcPayIcons(isBank: isBank, isAlipay: isAlipay, isWechat: isWechat),
          if (!isOutgoing && status == 2 && time > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('付款倒计时', style: TextStyle(color: Colors.redAccent)),
                const SizedBox(width: 8),
                _OtcCountdown(seconds: time),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isOutgoing && status == 1)
                TextButton(onPressed: () => onCancel(id), child: const Text('取消')),
              if (!isOutgoing && status == 2)
                ElevatedButton(onPressed: () => onPay(id), child: const Text('去结算')),
              if (isOutgoing && status == 3)
                OutlinedButton(onPressed: () => onPay(id), child: const Text('结算详情')),
              if (!isOutgoing && status == 4)
                ElevatedButton(onPressed: () => onConfirm(id), child: const Text('确认完成')),
              if (!isOutgoing && status == 5)
                const Text('互换完成', style: TextStyle(color: Colors.redAccent)),
              if (!isOutgoing && status == 6)
                const Text('互换关闭', style: TextStyle(color: Colors.redAccent)),
              if (isOutgoing && status == 2)
                const Text('待收款', style: TextStyle(color: Colors.blueAccent)),
              if (isOutgoing && status == 5)
                const Text('互换完成', style: TextStyle(color: Colors.redAccent)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final int status;
  final bool isOutgoing;

  const _StatusBadge({required this.status, required this.isOutgoing});

  @override
  Widget build(BuildContext context) {
    final text = isOutgoing
        ? switch (status) {
            2 => '待收款',
            3 => '待确认',
            5 => '互换完成',
            _ => '未知',
          }
        : switch (status) {
            1 => '发布中',
            2 => '待支付',
            3 => '待确认',
            4 => '待确认',
            5 => '互换完成',
            6 => '互换关闭',
            _ => '未知',
          };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}

class _OtcPayIcons extends StatelessWidget {
  final bool isBank;
  final bool isAlipay;
  final bool isWechat;

  const _OtcPayIcons({required this.isBank, required this.isAlipay, required this.isWechat});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isBank)
          Row(
            children: [
              Image.asset('assets/images/bank.png', width: 20, height: 20),
              const SizedBox(width: 4),
              const Text('银行卡'),
              const SizedBox(width: 12),
            ],
          ),
        if (isAlipay)
          Row(
            children: [
              Image.asset('assets/images/zfb.png', width: 20, height: 20),
              const SizedBox(width: 4),
              const Text('支付宝'),
              const SizedBox(width: 12),
            ],
          ),
        if (isWechat)
          Row(
            children: [
              Image.asset('assets/images/wx.png', width: 20, height: 20),
              const SizedBox(width: 4),
              const Text('微信'),
            ],
          ),
      ],
    );
  }
}

class _OtcCountdown extends StatefulWidget {
  final int seconds;

  const _OtcCountdown({required this.seconds});

  @override
  State<_OtcCountdown> createState() => _OtcCountdownState();
}

class _OtcCountdownState extends State<_OtcCountdown> {
  late int _secondsLeft;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.seconds;
    _ticker = Ticker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final remaining = widget.seconds - elapsed.inSeconds;
    if (remaining <= 0) {
      _ticker.stop();
      if (mounted) {
        setState(() {
          _secondsLeft = 0;
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _secondsLeft = remaining;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(4)),
      child: Text('$minutes:$seconds', style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}
