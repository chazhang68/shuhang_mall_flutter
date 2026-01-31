import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/store_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme_colors.dart';

class UserMoneyPage extends StatefulWidget {
  const UserMoneyPage({super.key});

  @override
  State<UserMoneyPage> createState() => _UserMoneyPageState();
}

class _UserMoneyPageState extends State<UserMoneyPage> {
  final UserProvider _userProvider = UserProvider();
  final StoreProvider _storeProvider = StoreProvider();
  final RefreshController _refreshController = RefreshController();

  Map<String, dynamic> _userInfo = {};
  List<Map<String, dynamic>> _hostProduct = [];
  int _hotPage = 1;
  bool _hotScrollEnd = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    _getHotProducts();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _getUserInfo() async {
    final response = await _userProvider.getUserInfo();
    if (response.isSuccess && response.data != null) {
      final user = response.data!;
      setState(() {
        _userInfo = {
          'now_money': user.balance,
          'recharge': user.extra?['recharge'] ?? 0,
          'orderStatusSum': user.extra?['orderStatusSum'] ?? 0,
        };
      });
    }
  }

  Future<void> _getHotProducts({bool reset = false}) async {
    if (reset) {
      _hotPage = 1;
      _hotScrollEnd = false;
    }

    if (_hotScrollEnd) {
      _refreshController.loadNoData();
      return;
    }

    if (_loading) return;

    setState(() {
      _loading = true;
    });

    final response = await _storeProvider.getHotProducts({'page': _hotPage, 'limit': 10});
    if (response.isSuccess && response.data != null) {
      List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(response.data);

      setState(() {
        if (reset) {
          _hostProduct = list;
        } else {
          _hostProduct.addAll(list);
        }

        if (list.length < 10) {
          _hotScrollEnd = true;
        }
        _hotPage++;
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
      if (_hotScrollEnd) {
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
    }
  }

  void _onRefresh() {
    _getUserInfo();
    _getHotProducts(reset: true);
  }

  void _onLoading() {
    _getHotProducts();
  }

  Widget _buildHeader() {
    double nowMoney = double.tryParse((_userInfo['now_money'] ?? 0).toString()) ?? 0;
    double recharge = double.tryParse((_userInfo['recharge'] ?? 0).toString()) ?? 0;
    double consume = double.tryParse((_userInfo['orderStatusSum'] ?? 0).toString()) ?? 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEEBE09),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEEBE09).withAlpha((0.3 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('总资产(元)', style: TextStyle(fontSize: 14, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Text(
                    nowMoney.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.userPayment),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('充值', style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('累计充值(元)', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text(
                      recharge.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('累计消费(元)', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text(
                      consume.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItems() {
    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.receipt_long, 'name': '账单记录', 'route': AppRoutes.userBill},
      {
        'icon': Icons.shopping_cart_outlined,
        'name': '消费记录',
        'route': '${AppRoutes.userBill}?type=1',
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'name': '充值记录',
        'route': '${AppRoutes.userBill}?type=2',
      },
      {'icon': Icons.card_giftcard, 'name': '消费券中心', 'route': AppRoutes.userIntegral},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navItems.map((item) {
          return GestureDetector(
            onTap: () => Get.toNamed(item['route']),
            child: Column(
              children: [
                Icon(item['icon'], size: 28, color: ThemeColors.red.primary),
                const SizedBox(height: 8),
                Text(item['name'], style: const TextStyle(fontSize: 12)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的余额'), centerTitle: true),
      backgroundColor: Colors.grey[100],
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: true,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildNavItems(),

              const SizedBox(height: 24),

              // 推荐商品标题
              if (_hostProduct.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('为你推荐', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),

              const SizedBox(height: 12),

              // 推荐商品列表
              ..._hostProduct.map((product) {
                return _buildProductItem(product);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    String image = product['image'] ?? '';
    String storeName = product['store_name'] ?? '';
    String price = (product['price'] ?? 0).toString();
    int id = product['id'] ?? 0;

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.goodsDetail, parameters: {'id': id.toString()}),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¥$price',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.red.primary,
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
}
