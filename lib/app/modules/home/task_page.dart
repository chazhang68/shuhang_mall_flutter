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
      debugPrint('🌱 开始获取种植任务...');
      final response = await _userProvider.getNewMyTask();

      debugPrint('📦 API 响应:');
      debugPrint('  - isSuccess: ${response.isSuccess}');
      debugPrint('  - msg: ${response.msg}');
      debugPrint('  - data type: ${response.data.runtimeType}');
      debugPrint('  - data: ${response.data}');

      if (response.isSuccess && response.data != null) {
        final dataList = response.data as List? ?? [];
        debugPrint('✅ 获取到 ${dataList.length} 个地块');

        // 打印每个地块的详细信息
        for (var i = 0; i < dataList.length; i++) {
          final plot = dataList[i];
          debugPrint('  地块 $i:');
          debugPrint('    - fieldType: ${plot['fieldType']}');
          debugPrint('    - right: ${plot['right']}');
          debugPrint('    - plants: ${plot['plants']}');
        }

        setState(() {
          _plotList = List<Map<String, dynamic>>.from(dataList);
        });

        debugPrint('🎉 地块列表更新完成，当前有 ${_plotList.length} 个地块');
      } else {
        debugPrint('❌ 获取失败: ${response.msg}');
      }
    } catch (e, stackTrace) {
      debugPrint('💥 获取我的任务失败: $e');
      debugPrint('堆栈: $stackTrace');
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
              return Image.asset(
                isActive
                    ? 'assets/images/pot_progress_active.png'
                    : 'assets/images/pot_progress_default.png',
                width: 30,
                height: 30,
                fit: BoxFit.contain,
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
      {'type': 'water', 'image': 'jiaoshui.png', 'label': '浇水'},
      {'type': 'seed', 'image': 'bozhong.png', 'label': '播种'},
      {'type': 'points', 'image': 'jifen.png', 'label': '积分'},
      {'type': 'SWP', 'image': 'swp.png', 'label': 'SWP'},
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
              child: Image.asset(
                'assets/images/${btn['image']}',
                width: 50,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
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
                    child: Center(
                      child: Text(
                        btn['label'] as String,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFarmArea(ThemeColorData themeColor) {
    if (_plotList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.agriculture,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              '暂无种植任务',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '点击右侧"播种"按钮购买种子开始种植',
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _plotList.length,
      itemBuilder: (context, index) {
        final plot = _plotList[index];
        return _build3DPlotItem(plot, themeColor);
      },
    );
  }

  // 3D田块渲染（与uni-app一致）
  Widget _build3DPlotItem(
    Map<String, dynamic> plot,
    ThemeColorData themeColor,
  ) {
    final plants = plot['plants'] as List? ?? [];
    final fieldType = plot['fieldType'] ?? 1;
    final rightIcon = plot['right'] ?? 0;

    if (plants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      height: 250, // 固定高度以容纳田块
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 田块容器（居中）
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                children: [
                  // 田块背景图
                  Image.asset(
                    'assets/images/$fieldType.png',
                    width: 250,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('田块图片加载失败: $fieldType.png');
                      return Container(
                        width: 250,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.brown.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '田块 $fieldType',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),

                  // 植物层 - 使用绝对定位（与uni-app一致）
                  Positioned.fill(
                    child: Stack(
                      children: plants.asMap().entries.map((entry) {
                        final plantIndex = entry.key;
                        final plant = entry.value;
                        return _build3DPlantWidget(
                          plant,
                          fieldType,
                          plantIndex,
                          themeColor,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 右侧指示牌（与uni-app一致）
          Positioned(
            right: -10,
            top: 20,
            child: Image.asset(
              'assets/images/right_icon$rightIcon.png',
              width: 60,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
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

  // 3D植物组件（与uni-app一致）
  Widget _build3DPlantWidget(
    Map<String, dynamic> plant,
    int fieldType,
    int plantIndex,
    ThemeColorData themeColor,
  ) {
    final plantType = plant['type'] ?? 0;
    final progress = double.tryParse(plant['progress']?.toString() ?? '0') ?? 0;
    final dkDay = plant['dk_day'] ?? 0;
    final totalDay = plant['day'] ?? 1;
    final score = plant['score'] ?? 0;

    // 获取植物位置（与uni-app的getPlantPosition一致）
    final position = _getPlantPosition(fieldType, plantIndex);
    if (position == null) return const SizedBox.shrink();

    return Positioned(
      left: position['left']! * 250, // 转换百分比为像素
      top: position['top']! * 250,
      child: Transform.translate(
        offset: const Offset(-20, -40), // 居中偏移（植物宽40，向上偏移40）
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 植物图标
            Image.asset(
              'assets/images/plant$plantType.png',
              width: 40,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.eco, color: Colors.white, size: 24),
                );
              },
            ),

            const SizedBox(height: 4),

            // 进度信息卡片（与uni-app一致）
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 进度条
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7dd87d), Color(0xFF4eb84e)],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$dkDay/$totalDay天',
                        style: const TextStyle(
                          fontSize: 8,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '已领取$score',
                    style: const TextStyle(
                      fontSize: 8,
                      color: Color(0xFF666666),
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

  // 获取植物位置（与uni-app的fieldCenters配置一致）
  Map<String, double>? _getPlantPosition(int fieldType, int plantIndex) {
    // 田块中心位置配置（与uni-app完全一致）
    final fieldCenters = <int, List<List<Map<String, double>?>>>{
      1: [
        [
          {'x': 0.5, 'y': 0.5},
        ],
      ],
      2: [
        [
          {'x': 0.33, 'y': 0.33},
          {'x': 0.66, 'y': 0.66},
        ],
      ],
      3: [
        [
          {'x': 0.33, 'y': 0.25},
          {'x': 0.66, 'y': 0.5},
        ],
        [
          null,
          {'x': 0.33, 'y': 0.75},
        ],
      ],
      4: [
        [
          {'x': 0.5, 'y': 0.25},
          {'x': 0.75, 'y': 0.5},
        ],
        [
          {'x': 0.25, 'y': 0.5},
          {'x': 0.5, 'y': 0.75},
        ],
      ],
      5: [
        [
          {'x': 0.4, 'y': 0.25},
          {'x': 0.6, 'y': 0.5},
          {'x': 0.8, 'y': 0.75},
        ],
        [
          {'x': 0.2, 'y': 0.5},
          {'x': 0.4, 'y': 0.75},
          null,
        ],
      ],
      6: [
        [
          {'x': 0.4, 'y': 0.2},
          {'x': 0.6, 'y': 0.4},
          {'x': 0.8, 'y': 0.6},
        ],
        [
          {'x': 0.2, 'y': 0.4},
          {'x': 0.4, 'y': 0.6},
          {'x': 0.6, 'y': 0.8},
        ],
      ],
      7: [
        [
          {'x': 0.4, 'y': 0.2},
          {'x': 0.6, 'y': 0.4},
          {'x': 0.8, 'y': 0.6},
        ],
        [
          {'x': 0.2, 'y': 0.4},
          {'x': 0.4, 'y': 0.6},
          {'x': 0.6, 'y': 0.8},
        ],
        [
          null,
          {'x': 0.2, 'y': 0.8},
          null,
        ],
      ],
      8: [
        [
          {'x': 0.5, 'y': 0.2},
          {'x': 0.667, 'y': 0.4},
          {'x': 0.833, 'y': 0.6},
        ],
        [
          {'x': 0.333, 'y': 0.4},
          {'x': 0.5, 'y': 0.6},
          {'x': 0.667, 'y': 0.8},
        ],
        [
          {'x': 0.167, 'y': 0.6},
          {'x': 0.333, 'y': 0.8},
          null,
        ],
      ],
      9: [
        [
          {'x': 0.5, 'y': 0.167},
          {'x': 0.667, 'y': 0.333},
          {'x': 0.833, 'y': 0.5},
        ],
        [
          {'x': 0.333, 'y': 0.333},
          {'x': 0.5, 'y': 0.5},
          {'x': 0.667, 'y': 0.667},
        ],
        [
          {'x': 0.167, 'y': 0.5},
          {'x': 0.333, 'y': 0.667},
          {'x': 0.5, 'y': 0.833},
        ],
      ],
      10: [
        [
          {'x': 0.5, 'y': 0.143},
          {'x': 0.667, 'y': 0.286},
          {'x': 0.833, 'y': 0.429},
        ],
        [
          {'x': 0.333, 'y': 0.286},
          {'x': 0.5, 'y': 0.429},
          {'x': 0.667, 'y': 0.571},
        ],
        [
          {'x': 0.167, 'y': 0.429},
          {'x': 0.333, 'y': 0.571},
          {'x': 0.5, 'y': 0.714},
          {'x': 0.667, 'y': 0.857},
        ],
      ],
      11: [
        [
          {'x': 0.5, 'y': 0.143},
          {'x': 0.667, 'y': 0.286},
          {'x': 0.833, 'y': 0.429},
        ],
        [
          {'x': 0.333, 'y': 0.286},
          {'x': 0.5, 'y': 0.429},
          {'x': 0.667, 'y': 0.571},
        ],
        [
          {'x': 0.167, 'y': 0.429},
          {'x': 0.333, 'y': 0.571},
          {'x': 0.5, 'y': 0.714},
          {'x': 0.667, 'y': 0.857},
        ],
        [
          null,
          null,
          {'x': 0.333, 'y': 0.857},
          null,
        ],
      ],
      12: [
        [
          {'x': 0.5, 'y': 0.125},
          {'x': 0.667, 'y': 0.25},
          {'x': 0.833, 'y': 0.375},
        ],
        [
          {'x': 0.333, 'y': 0.25},
          {'x': 0.5, 'y': 0.375},
          {'x': 0.667, 'y': 0.5},
        ],
        [
          {'x': 0.167, 'y': 0.375},
          {'x': 0.333, 'y': 0.5},
          {'x': 0.5, 'y': 0.625},
          {'x': 0.667, 'y': 0.75},
        ],
        [
          null,
          null,
          {'x': 0.333, 'y': 0.75},
          {'x': 0.5, 'y': 0.875},
        ],
      ],
    };

    final centers = fieldCenters[fieldType];
    if (centers == null) return null;

    // 遍历找到第plantIndex个有效位置
    int count = 0;
    for (final row in centers) {
      for (final pos in row) {
        if (pos != null) {
          if (count == plantIndex) {
            return {'left': pos['x']!, 'top': pos['y']!};
          }
          count++;
        }
      }
    }

    return null;
  }
}
