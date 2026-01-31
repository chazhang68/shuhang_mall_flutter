import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import '../../data/providers/lottery_provider.dart';
import '../../theme/theme_colors.dart';
import '../../../widgets/empty_page.dart';

class LotteryPage extends StatefulWidget {
  const LotteryPage({super.key});

  @override
  State<LotteryPage> createState() => _LotteryPageState();
}

class _LotteryPageState extends State<LotteryPage> with SingleTickerProviderStateMixin {
  final LotteryProvider _lotteryProvider = LotteryProvider();

  bool _loading = true;
  bool _lotteryShow = false;
  int _lotteryNum = 0;
  String _image = '';
  List<Map<String, dynamic>> _prize = [];
  List<Map<String, dynamic>> _userList = [];
  int _id = 0;

  // 抽奖动画相关
  late AnimationController _animationController;
  int _currentIndex = 0;
  bool _isAnimating = false;
  int _winIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _getLotteryData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getLotteryData() async {
    final response = await _lotteryProvider.getLotteryConfig();
    if (response.isSuccess && response.data != null) {
      setState(() {
        _loading = false;
        _lotteryShow = true;
        _id = response.data['id'] ?? 0;
        _lotteryNum = response.data['lottery_num'] ?? 0;
        _image = response.data['image'] ?? '';
        _prize = List<Map<String, dynamic>>.from(response.data['prize'] ?? []);
        _userList = List<Map<String, dynamic>>.from(response.data['user_list'] ?? []);
      });
    } else {
      setState(() {
        _loading = false;
        _lotteryShow = false;
      });
    }
  }

  Future<void> _startLottery() async {
    if (_isAnimating) return;
    if (_lotteryNum <= 0) {
      FlutterToastPro.showMessage( '抽奖次数不足');
      return;
    }

    setState(() {
      _isAnimating = true;
    });

    // 调用抽奖接口
    final response = await _lotteryProvider.lottery(_id);
    if (response.isSuccess && response.data != null) {
      _winIndex = response.data['index'] ?? 0;
      Map<String, dynamic> prizeInfo = response.data['prize'] ?? {};

      // 开始抽奖动画
      _runAnimation(() {
        setState(() {
          _isAnimating = false;
          _lotteryNum--;
        });

        // 显示中奖结果
        _showPrizeDialog(prizeInfo);
      });
    } else {
      setState(() {
        _isAnimating = false;
      });
      FlutterToastPro.showMessage( response.msg);
    }
  }

  void _runAnimation(VoidCallback onComplete) {
    int totalSteps = 24 + _winIndex; // 转3圈再停到中奖位置
    int currentStep = 0;

    void animate() {
      if (currentStep >= totalSteps) {
        onComplete();
        return;
      }

      int delay = 50 + (currentStep * 10).clamp(0, 200);

      Future.delayed(Duration(milliseconds: delay), () {
        setState(() {
          _currentIndex = currentStep % 8;
        });
        currentStep++;
        animate();
      });
    }

    animate();
  }

  void _showPrizeDialog(Map<String, dynamic> prizeInfo) {
    int type = prizeInfo['type'] ?? 0;
    String name = prizeInfo['name'] ?? '';
    String image = prizeInfo['image'] ?? '';

    Get.dialog(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('恭喜您', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (image.isNotEmpty)
              Image.network(
                image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.card_giftcard, size: 40),
                  );
                },
              ),
            const SizedBox(height: 12),
            Text(
              type == 1 ? '获得$name' : (type == 0 ? '谢谢参与' : name),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.red.primary),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void _goRecord() {
    Get.toNamed('/lottery/record');
  }

  Widget _buildLotteryGrid() {
    // 8个奖品位置(3x3九宫格，中间是按钮)
    // 0 1 2
    // 7 X 3
    // 6 5 4
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.red.primary.withAlpha((0.3 * 255).round()),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          // 中间位置是抽奖按钮
          if (index == 4) {
            return GestureDetector(
              onTap: _startLottery,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ThemeColors.red.primary,
                      ThemeColors.red.primary.withAlpha((0.8 * 255).round()),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '点击抽奖',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '剩余$_lotteryNum次',
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            );
          }

          // 计算奖品位置
          int prizeIndex;
          switch (index) {
            case 0:
              prizeIndex = 0;
              break;
            case 1:
              prizeIndex = 1;
              break;
            case 2:
              prizeIndex = 2;
              break;
            case 5:
              prizeIndex = 3;
              break;
            case 8:
              prizeIndex = 4;
              break;
            case 7:
              prizeIndex = 5;
              break;
            case 6:
              prizeIndex = 6;
              break;
            case 3:
              prizeIndex = 7;
              break;
            default:
              prizeIndex = 0;
          }

          bool isHighlight = _currentIndex == prizeIndex && _isAnimating;
          Map<String, dynamic> prize = prizeIndex < _prize.length ? _prize[prizeIndex] : {};

          return Container(
            decoration: BoxDecoration(
              color: isHighlight
                  ? ThemeColors.red.primary.withAlpha((0.3 * 255).round())
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isHighlight ? ThemeColors.red.primary : Colors.grey[300]!,
                width: isHighlight ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (prize['image'] != null && prize['image'].toString().isNotEmpty)
                  Image.network(
                    prize['image'],
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.card_giftcard, size: 32, color: Colors.grey[400]);
                    },
                  )
                else
                  Icon(Icons.card_giftcard, size: 32, color: Colors.grey[400]),
                const SizedBox(height: 4),
                Text(
                  prize['name'] ?? '奖品',
                  style: const TextStyle(fontSize: 11, overflow: TextOverflow.ellipsis),
                  maxLines: 1,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWinnerList() {
    if (_userList.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.9 * 255).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text('中奖名单', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ..._userList.take(5).map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(item['nickname'] ?? '用户', style: const TextStyle(fontSize: 14)),
                  const Text(' 获得 '),
                  Text(
                    item['prize_name'] ?? '',
                    style: TextStyle(fontSize: 14, color: ThemeColors.red.primary),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('幸运抽奖'), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_lotteryShow) {
      return Scaffold(
        appBar: AppBar(title: const Text('幸运抽奖'), centerTitle: true),
        body: const EmptyPage(text: '商家暂未上架活动哦~'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('幸运抽奖'),
        centerTitle: true,
        actions: [TextButton(onPressed: _goRecord, child: const Text('我的奖品'))],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ThemeColors.red.primary,
              ThemeColors.red.primary.withAlpha((0.7 * 255).round()),
              Colors.orange[100]!,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 顶部图片
              if (_image.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _image,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox.shrink();
                    },
                  ),
                ),

              const SizedBox(height: 24),

              // 剩余次数提示
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '恭喜您，获得 $_lotteryNum 次抽奖机会',
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeColors.red.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 九宫格抽奖
              _buildLotteryGrid(),

              // 中奖名单
              _buildWinnerList(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}


