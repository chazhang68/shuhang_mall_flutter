import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';
import 'package:shuhang_mall_flutter/widgets/empty_page.dart';

/// OTC 商城页面 - 适用于 OTC 交易入口与商品展示。
class OtcShopPage extends StatefulWidget {
  const OtcShopPage({super.key});

  @override
  State<OtcShopPage> createState() => _OtcShopPageState();
}

class _OtcShopPageState extends State<OtcShopPage> with TickerProviderStateMixin {
  final UserProvider _userProvider = UserProvider();

  final List<String> _tabs = ['消费券互换区', '福豆互换区', '结算方式'];
  final List<Map<String, dynamic>> _records = [];
  int _page = 1;
  final int _limit = 15;
  bool _loading = false;
  bool _loadEnd = false;
  int _currentTab = 0;
  bool _canPublish = false;
  double _userIntegral = 0;
  double _userFudou = 0;

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map && args['id'] != null) {
      final index = int.tryParse('${args['id']}') ?? 0;
      if (index >= 0 && index < 2) {
        _currentTab = index;
      }
    }
    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: _currentTab);
    _tabController.addListener(_onTabChanged);
    _loadUserInfo();
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
    if (_tabController.index == 2) {
      Future<void>(() async {
        await Get.toNamed(AppRoutes.otcPayType);
        if (!mounted) return;
        setState(() {
          _currentTab = 0;
          _page = 1;
          _loadEnd = false;
          _records.clear();
        });
        _tabController.animateTo(0);
        _loadList();
      });
      return;
    }
    setState(() {
      _currentTab = _tabController.index;
      _page = 1;
      _loadEnd = false;
      _records.clear();
    });
    _loadList();
  }

  Future<void> _loadUserInfo() async {
    try {
      final response = await _userProvider.userInfos();
      if (response.isSuccess && response.data != null) {
        final data = response.data!.extra ?? <String, dynamic>{};
        setState(() {
          _canPublish = data['is_shop'] == true || data['is_shop'] == 1;
          _userIntegral = response.data!.integral;
          _userFudou = response.data!.fudou;
        });
      }
    } catch (e) {
      debugPrint('获取用户信息失败: $e');
    }
  }

  Future<void> _loadList() async {
    if (_loading || _loadEnd) return;

    setState(() {
      _loading = true;
    });

    try {
      final response = await _userProvider.getOtcList({
        'page': _page,
        'limit': _limit,
        'type': _currentTab == 0 ? 1 : 2,
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
      debugPrint('加载 OTC 列表失败: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTC 商城'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((text) => Tab(text: text)).toList(),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.otcOrder),
            icon: const Icon(Icons.receipt_long),
          ),
        ],
      ),
      body: EasyRefresh(
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
                  return _OtcMarketCard(item: item, onExchange: _openExchange);
                },
              ),
      ),
      bottomNavigationBar: _canPublish
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton(
                  onPressed: () => Get.toNamed(AppRoutes.otcSend),
                  child: const Text('发布互换'),
                ),
              ),
            )
          : null,
    );
  }

  Future<void> _openExchange(int id) async {
    try {
      final response = await _userProvider.otcOrderInfo(id);
      if (!response.isSuccess || response.data == null) return;

      final raw = response.data as Map;
      final info = raw['data'] is Map
          ? Map<String, dynamic>.from(raw['data'] as Map)
          : Map<String, dynamic>.from(raw);

      final sxfResponse = await _userProvider.getSxf();
      final sxfData = sxfResponse.data is Map
          ? Map<String, dynamic>.from(sxfResponse.data as Map)
          : <String, dynamic>{};
      final sxfList = sxfData['sxf'] is List
          ? List<Map<String, dynamic>>.from(sxfData['sxf'] as List)
          : <Map<String, dynamic>>[];
      final bz = sxfData['bz']?.toString() ?? '';

      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return _OtcExchangeSheet(
            info: info,
            sxfList: sxfList,
            bz: bz,
            userIntegral: _userIntegral,
            userFudou: _userFudou,
            onConfirm: _submitExchange,
          );
        },
      );
    } catch (e) {
      debugPrint('加载互换信息失败: $e');
    }
  }

  Future<void> _submitExchange(
    Map<String, dynamic> info,
    int number,
    List<int> payTypes,
    int? sxfIndex,
  ) async {
    final id = int.tryParse('${info['id']}') ?? 0;
    if (id == 0) return;

    final extra = sxfIndex == null ? null : {'sxf_index': sxfIndex};
    final data = <String, dynamic>{'id': id, 'number': number, 'pay_type': payTypes, ...?extra};

    final response = await _userProvider.saleOtc(data);
    if (!mounted) return;
    if (response.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('数据提交成功，等待买方打款')));
      Navigator.of(context).pop();
      await _onRefresh();
    } else {
      final message = response.msg.isEmpty ? '提交失败' : response.msg;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _OtcMarketCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final ValueChanged<int> onExchange;

  const _OtcMarketCard({required this.item, required this.onExchange});

  @override
  Widget build(BuildContext context) {
    final avatar = item['avatar']?.toString() ?? '';
    final nickname = item['nickname']?.toString() ?? '-';
    final dprice = item['dprice']?.toString() ?? '-';
    final number = item['number']?.toString() ?? '-';
    final type = item['type']?.toString() == '1' ? '消费券' : '福豆';
    final id = int.tryParse('${item['id']}') ?? 0;
    final isBank = item['is_bank'] == true || item['is_bank'] == 1;
    final isAlipay = item['is_alipay'] == true || item['is_alipay'] == 1;
    final isWechat = item['is_wechat'] == true || item['is_wechat'] == 1;

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
            ],
          ),
          const SizedBox(height: 8),
          Text(dprice, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text('数量：$number'), const SizedBox(height: 4), Text('类型：$type')],
              ),
              ElevatedButton(
                onPressed: id == 0 ? null : () => onExchange(id),
                child: const Text('互换'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _OtcPayIcons(isBank: isBank, isAlipay: isAlipay, isWechat: isWechat),
        ],
      ),
    );
  }
}

class _OtcExchangeSheet extends StatefulWidget {
  final Map<String, dynamic> info;
  final List<Map<String, dynamic>> sxfList;
  final String bz;
  final double userIntegral;
  final double userFudou;
  final Future<void> Function(
    Map<String, dynamic> info,
    int number,
    List<int> payTypes,
    int? sxfIndex,
  )
  onConfirm;

  const _OtcExchangeSheet({
    required this.info,
    required this.sxfList,
    required this.bz,
    required this.userIntegral,
    required this.userFudou,
    required this.onConfirm,
  });

  @override
  State<_OtcExchangeSheet> createState() => _OtcExchangeSheetState();
}

class _OtcExchangeSheetState extends State<_OtcExchangeSheet> {
  late final TextEditingController _numberController;
  final Set<int> _payTypes = {};
  int _sxfIndex = 0;
  int _sxfType = 1029;
  bool _submitting = false;
  double _fdRate = 0;
  double _xfqRate = 0;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(text: '${widget.info['number'] ?? ''}');
    _syncSxfIndex();
    _updateRate();
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.info['type']?.toString() == '1' ? 1 : 2;
    final nickname = widget.info['nickname']?.toString() ?? '-';
    final dprice = widget.info['dprice']?.toString() ?? '-';
    final number = int.tryParse(_numberController.text.trim()) ?? 0;
    final allPrice = number > 0
        ? (number * (double.tryParse(dprice) ?? 0)).toStringAsFixed(3)
        : '0';
    final fdSxf = (number * _fdRate / 100).toStringAsFixed(3);
    final xfqSxf = (number * _xfqRate / 100).toStringAsFixed(3);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: widget.info['avatar'] == null
                      ? null
                      : NetworkImage(widget.info['avatar'].toString()),
                  child: widget.info['avatar'] == null ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$nickname 提醒您：',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('互换${type == 1 ? '消费券' : '福豆'}', style: const TextStyle(fontSize: 16)),
            Text('单价 $dprice', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            _OtcNumberField(
              controller: _numberController,
              onFillAll: () => setState(() {
                _numberController.text = '${widget.info['number'] ?? ''}';
              }),
            ),
            const SizedBox(height: 8),
            _OtcInfoRow(label: '当前可用', value: _currentBalance(type)),
            _OtcInfoRow(label: '互换数量', value: '$number${type == 1 ? '消费券' : '福豆'}'),
            _OtcInfoRow(label: type == 1 ? '换入金额' : '换入消费券数量', value: allPrice),
            const SizedBox(height: 12),
            if (type == 1) ...[
              const Text('换入方式', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _OtcPayTypeSelector(selected: _payTypes, onChanged: _onPayTypeChanged),
            ],
            if (type == 2)
              _OtcSxfSelector(
                sxfList: widget.sxfList,
                selected: _sxfIndex,
                onChanged: (value) => setState(() {
                  _sxfIndex = value;
                  _syncSxfType();
                  _updateRate();
                }),
              ),
            if (type == 2 && widget.bz.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  widget.bz,
                  style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                ),
              ),
            if (type == 2)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    if (_fdRate > 0) Text('福豆手续费：$fdSxf'),
                    if (_xfqRate > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text('消费券手续费：$xfqSxf'),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: Text(_submitting ? '提交中...' : '确认互换'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onPayTypeChanged(Set<int> value) {
    setState(() {
      _payTypes
        ..clear()
        ..addAll(value);
    });
  }

  void _updateRate() {
    if (widget.sxfList.isEmpty) {
      _fdRate = 0;
      _xfqRate = 0;
      return;
    }
    final item = widget.sxfList[_sxfIndex.clamp(0, widget.sxfList.length - 1)];
    _fdRate = double.tryParse('${item['sxf'] ?? 0}') ?? 0;
    _xfqRate = double.tryParse('${item['xfq'] ?? 0}') ?? 0;
  }

  void _syncSxfIndex() {
    if (widget.sxfList.isEmpty) return;
    final index = widget.sxfList.indexWhere((item) => int.tryParse('${item['id']}') == _sxfType);
    _sxfIndex = index >= 0 ? index : 0;
  }

  void _syncSxfType() {
    if (widget.sxfList.isEmpty) return;
    _sxfType = int.tryParse('${widget.sxfList[_sxfIndex]['id']}') ?? _sxfType;
  }

  String _currentBalance(int type) {
    if (type == 1) {
      return '${widget.userIntegral.toStringAsFixed(3)}消费券';
    }
    return '${widget.userFudou.toStringAsFixed(3)}福豆';
  }

  Future<void> _submit() async {
    final number = int.tryParse(_numberController.text.trim()) ?? 0;
    if (number <= 0) {
      _showMessage('请输入互换数量');
      return;
    }
    if (widget.info['type']?.toString() == '1' && _payTypes.isEmpty) {
      _showMessage('请选择支付方式');
      return;
    }

    if (widget.info['type']?.toString() == '1') {
      if (number > widget.userIntegral) {
        _showMessage('消费券余额不足');
        return;
      }
    }

    if (widget.info['type']?.toString() == '2') {
      final fdSxf = number * _fdRate / 100;
      final xfqSxf = number * _xfqRate / 100;
      final allFd = number + fdSxf + 10;
      if (xfqSxf > widget.userIntegral) {
        _showMessage('消费券余额不足');
        return;
      }
      if (allFd > widget.userFudou) {
        _showMessage('福豆余额不足');
        return;
      }
    }

    setState(() {
      _submitting = true;
    });

    try {
      await widget.onConfirm(widget.info, number, _payTypes.toList(), _sxfIndex);
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _OtcNumberField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onFillAll;

  const _OtcNumberField({required this.controller, required this.onFillAll});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: '互换数量',
        border: const OutlineInputBorder(),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('个', style: TextStyle(color: Color(0xFF53586E))),
            const SizedBox(width: 6),
            Container(width: 1, height: 20, color: const Color(0xFFDCDDE1)),
            TextButton(onPressed: onFillAll, child: const Text('全部互换')),
          ],
        ),
      ),
    );
  }
}

class _OtcInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _OtcInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF7D7D7D))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
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

class _OtcPayTypeSelector extends StatelessWidget {
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  const _OtcPayTypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const items = [(1, '银行卡'), (2, '支付宝'), (3, '微信')];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selected.contains(item.$1);
        return FilterChip(
          label: Text(item.$2),
          selected: isSelected,
          onSelected: (value) {
            final next = Set<int>.from(selected);
            if (value) {
              next.add(item.$1);
            } else {
              next.remove(item.$1);
            }
            onChanged(next);
          },
        );
      }).toList(),
    );
  }
}

class _OtcSxfSelector extends StatelessWidget {
  final List<Map<String, dynamic>> sxfList;
  final int selected;
  final ValueChanged<int> onChanged;

  const _OtcSxfSelector({required this.sxfList, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    if (sxfList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('结算方式', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...List.generate(sxfList.length, (index) {
          final item = sxfList[index];
          final name = item['name']?.toString() ?? '-';
          return RadioListTile<int>(
            value: index,
            // ignore: deprecated_member_use
            groupValue: selected,
            // ignore: deprecated_member_use
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
            title: Text(name),
            dense: true,
          );
        }),
      ],
    );
  }
}
