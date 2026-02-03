import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/app/services/ad_manager.dart';
import 'package:shuhang_mall_flutter/app/theme/theme_colors.dart';

/// 任务页面
/// 对应原 pages/task/task.vue
class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage>
    with AutomaticKeepAliveClientMixin {
  final UserProvider _userProvider = UserProvider();
  final AdManager _adManager = AdManager.instance;

  // 水壶进度 (0-8)
  int _taskDoneCount = 0;

  // 种子列表
  List<Map<String, dynamic>> _seedList = [];

  // 地块列表
  List<Map<String, dynamic>> _plotList = [];

  // 用户信息
  Map<String, dynamic> _userInfo = {};

  // 加载状态
  bool _isLoading = true;

  // 弹窗状态
  bool _showShopPopup = false;

  // 密码输入
  String _pwd = '';

  // 当前选中的种子
  Map<String, dynamic>? _selectedSeed;

  // 购买数量
  int _buyNum = 1;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initAd();
    _loadData();
  }

  Future<void> _initAd() async {
    // 启动广告SDK
    await AdManager.instance.start();
    // 预加载激励视频广告（实现秒开）
    await AdManager.instance.preloadRewardedVideoAd();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    await Future.wait([_getUserInfo(), _getTaskList(), _getMyTask()]);

    setState(() => _isLoading = false);
  }

  Future<void> _getUserInfo() async {
    try {
      final response = await _userProvider.getUserInfo();
      if (response.isSuccess && response.data != null) {
        setState(() {
          _userInfo = {
            'is_sign': response.data!.isSign,
            'task': response.data!.task,
            'fudou': response.data!.fudou,
            'integral': response.data!.integral,
          };
          _taskDoneCount = response.data!.task;
        });
      }
    } catch (e) {
      debugPrint('获取用户信息失败: $e');
    }
  }

  Future<void> _getTaskList() async {
    try {
      final response = await _userProvider.getUserTask();
      if (response.isSuccess && response.data != null) {
        setState(() {
          _seedList = List<Map<String, dynamic>>.from(
            response.data as List? ?? [],
          );
        });
      }
    } catch (e) {
      debugPrint('获取任务列表失败: $e');
    }
  }

  Future<void> _getMyTask() async {
    try {
      final response = await _userProvider.getNewMyTask();
      if (response.isSuccess && response.data != null) {
        setState(() {
          _plotList = List<Map<String, dynamic>>.from(
            response.data as List? ?? [],
          );
        });
      }
    } catch (e) {
      debugPrint('获取我的任务失败: $e');
    }
  }

  // 处理按钮点击（与uni-app的handleButtonClick一致）
  void _handleButtonClick(String type) {
    switch (type) {
      case 'seed':
        // 打开种子商店
        setState(() => _showShopPopup = true);
        break;
      case 'water':
        // 浇水按钮：如果已完成8次则领取奖励，否则看广告
        if (_taskDoneCount >= 8) {
          _lingqu();
        } else {
          _showAd();
        }
        break;
      case 'points':
        // 跳转到积分页面
        Get.toNamed('/user/ryz', arguments: {'index': 1});
        break;
      case 'SWP':
        // 跳转到SWP页面
        Get.toNamed('/user/ryz', arguments: {'index': 0});
        break;
    }
  }

  // 显示广告
  Future<void> _showAd() async {
    // 1. 检查实名认证（与uni-app一致）
    if (_userInfo['is_sign'] != true) {
      FlutterToastPro.showMessage('请先实名认证哦');
      await Future.delayed(const Duration(seconds: 1));
      Get.toNamed('/pages/sign/sign');
      return;
    }

    // 2. 显示加载中
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    // 3. 显示激励视频广告
    final success = await _adManager.showRewardedVideoAd(
      onShow: () {
        debugPrint('✅ 激励视频展示');
        Get.back(); // 关闭loading
      },
      onReward: () {
        // 广告观看完成，发放奖励（与uni-app的giveReward一致）
        debugPrint('🎁 广告观看完成，发放奖励');
        _giveReward();
      },
      onClose: () {
        debugPrint('广告已关闭');
        // 预加载下一个广告
        _adManager.preloadRewardedVideoAd();
      },
      onError: (error) {
        Get.back(); // 关闭loading
        FlutterToastPro.showMessage('广告加载失败: $error');
        debugPrint('❌ 广告错误: $error');
      },
    );

    // 4. 如果广告未就绪，关闭loading并提示
    if (!success) {
      Get.back();
      FlutterToastPro.showMessage('暂无可用广告，请稍后重试');
    }
  }

  // 发放奖励（对应uni-app的giveReward方法）
  Future<void> _giveReward() async {
    try {
      // 调用watchOver接口更新任务进度
      final response = await _userProvider.watchOver(null);

      if (response.isSuccess) {
        // 延迟500ms后刷新用户信息
        await Future.delayed(const Duration(milliseconds: 500));
        await _getUserInfo();

        // 再延迟1秒检查是否完成8次任务
        await Future.delayed(const Duration(seconds: 1));
        if (_taskDoneCount >= 8) {
          // 自动领取奖励
          _lingqu();
        }
      }
    } catch (e) {
      debugPrint('发放奖励失败: $e');
      FlutterToastPro.showMessage('领取奖励失败');
    }
  }

  // 领取奖励（与uni-app的lingqu方法一致）
  Future<void> _lingqu() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final response = await _userProvider.lingqu();
      Get.back();

      if (response.isSuccess) {
        FlutterToastPro.showMessage('今日任务已完成，请查看您的奖励！');
        // 刷新所有数据
        await _loadData();
      } else {
        FlutterToastPro.showMessage(response.msg);
      }
    } catch (e) {
      Get.back();
      FlutterToastPro.showMessage('领取奖励失败');
      debugPrint('领取奖励失败: $e');
    }
  }

  // 购买种子
  Future<void> _buySeed() async {
    if (_pwd.isEmpty) {
      FlutterToastPro.showMessage('请输入交易密码');
      return;
    }

    if (_selectedSeed == null) return;

    final dhNum =
        double.tryParse(_selectedSeed!['dh_num']?.toString() ?? '0') ?? 0;
    final userFudou =
        double.tryParse(_userInfo['fudou']?.toString() ?? '0') ?? 0;

    if (userFudou < dhNum * _buyNum) {
      FlutterToastPro.showMessage('积分不够哦');
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final response = await _userProvider.exchangeTask({
        'task_id': _selectedSeed!['id'],
        'num': _buyNum,
        'pwd': _pwd,
      });

      Get.back();

      if (response.isSuccess) {
        FlutterToastPro.showMessage('兑换成功');
        setState(() {
          _showShopPopup = false;
          _pwd = '';
          _buyNum = 1;
          _selectedSeed = null;
        });
        await _loadData();
      } else {
        FlutterToastPro.showMessage(response.msg);
      }
    } catch (e) {
      Get.back();
      FlutterToastPro.showMessage('兑换失败');
    }
  }

  // 计算进度条宽度
  double _getProgressBarWidth(double totalWidth) {
    if (_taskDoneCount <= 0) return 0;
    if (_taskDoneCount >= 8) return totalWidth;
    return totalWidth * _taskDoneCount / 8;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GetBuilder<AppController>(
      builder: (controller) {
        final themeColor = controller.themeColor;

        return Scaffold(
          body: Stack(
            children: [
              // 背景图
              Positioned.fill(
                child: Image.asset(
                  'assets/images/bg.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          themeColor.gradientStart,
                          themeColor.gradientEnd,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 主内容
              SafeArea(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Column(
                        children: [
                          // 水壶进度条
                          _buildWaterProgress(themeColor),

                          // 地块区域
                          Expanded(child: _buildFarmArea(themeColor)),
                        ],
                      ),
              ),

              // 右侧按钮
              _buildRightButtons(themeColor),

              // 种子商店弹窗
              if (_showShopPopup) _buildShopPopup(themeColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWaterProgress(ThemeColorData themeColor) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.7 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha((0.9 * 255).round())),
      ),
      child: Column(
        children: [
          // 水壶图标行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(8, (index) {
              final isActive = index < _taskDoneCount;
              return Icon(
                Icons.water_drop,
                size: 30,
                color: isActive ? themeColor.primary : Colors.grey[300],
              );
            }),
          ),

          const SizedBox(height: 8),

          // 进度槽
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // 灰色背景
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // 红色进度
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    width: _getProgressBarWidth(constraints.maxWidth),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[400]!, Colors.red[600]!],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 8),

          // 状态文字行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(8, (index) {
              final isActive = index < _taskDoneCount;
              return Text(
                isActive ? '已完成' : '未完成',
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? themeColor.primary : Colors.grey,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRightButtons(ThemeColorData themeColor) {
    final buttons = [
      {'type': 'water', 'icon': Icons.water_drop, 'label': '浇水'},
      {'type': 'seed', 'icon': Icons.grass, 'label': '播种'},
      {'type': 'points', 'icon': Icons.stars, 'label': '积分'},
      {'type': 'SWP', 'icon': Icons.account_balance_wallet, 'label': 'SWP'},
    ];

    return Positioned(
      right: 20,
      top: MediaQuery.of(context).size.height * 0.35,
      child: Column(
        children: buttons.map((btn) {
          return GestureDetector(
            onTap: () => _handleButtonClick(btn['type'] as String),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.1 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    btn['icon'] as IconData,
                    size: 24,
                    color: themeColor.primary,
                  ),
                  Text(
                    btn['label'] as String,
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFarmArea(ThemeColorData themeColor) {
    if (_plotList.isEmpty) {
      return const Center(
        child: Text(
          '暂无种植任务',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _plotList.length,
      itemBuilder: (context, index) {
        final plot = _plotList[index];
        return _buildPlotItem(plot, themeColor);
      },
    );
  }

  Widget _buildPlotItem(Map<String, dynamic> plot, ThemeColorData themeColor) {
    final progress = double.tryParse(plot['progress']?.toString() ?? '0') ?? 0;
    final dkDay = plot['dk_day'] ?? 0;
    final totalDay = plot['day'] ?? 1;
    final score = plot['score'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.9 * 255).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plot['name']?.toString() ?? '种植任务',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // 进度条
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      themeColor.primary,
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$dkDay/$totalDay天',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            '已领取 $score 积分',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildShopPopup(ThemeColorData themeColor) {
    return GestureDetector(
      onTap: () => setState(() => _showShopPopup = false),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              constraints: const BoxConstraints(maxHeight: 500),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题栏
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '种子商店',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _showShopPopup = false),
                          child: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // 种子列表
                  Flexible(
                    child: _seedList.isEmpty
                        ? const Center(child: Text('暂无种子'))
                        : GridView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: _seedList.length,
                            itemBuilder: (context, index) {
                              return _buildSeedItem(
                                _seedList[index],
                                themeColor,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeedItem(Map<String, dynamic> seed, ThemeColorData themeColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFEF8), Color(0xFFFFF9E6)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            seed['name']?.toString() ?? '',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // 种子图片
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.green[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.eco, color: Colors.green[600], size: 30),
          ),

          const SizedBox(height: 8),

          Text(
            '预计获得${seed['output_num'] ?? 0}积分',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          Text(
            '活跃度：${seed['activity'] ?? 0}',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          Text(
            '种子数量：${seed['count'] ?? 0}/${seed['limit'] ?? 0}个',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),

          const Spacer(),

          // 购买按钮
          GestureDetector(
            onTap: () {
              setState(() => _selectedSeed = seed);
              _showBuyDialog();
            },
            child: Container(
              width: double.infinity,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.green[600]!],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '${seed['dh_num'] ?? 0}积分',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBuyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认购买'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: '请输入交易密码',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _pwd = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _buySeed();
            },
            child: const Text('确认购买'),
          ),
        ],
      ),
    );
  }
}
