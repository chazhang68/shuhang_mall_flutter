import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:shuhang_mall_flutter/app/controllers/app_controller.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/app/services/ad_manager.dart';
import 'package:shuhang_mall_flutter/app/theme/theme_colors.dart';
import 'package:shuhang_mall_flutter/app/routes/app_routes.dart';

/// 任务页面
/// 对应原 pages/task/task.vue
class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> with AutomaticKeepAliveClientMixin {
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

  // 防重复点击
  bool _isExchanging = false;

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
          _seedList = List<Map<String, dynamic>>.from(response.data as List? ?? []);
        });
      }
    } catch (e) {
      debugPrint('获取任务列表失败: $e');
    }
  }

  Future<void> _getMyTask() async {
    try {
      debugPrint('🌱 开始获取种植任务...');
      debugPrint('📍 API 端点: task/new_my_tasks');

      final response = await _userProvider.getNewMyTask();

      debugPrint('📦 API 响应:');
      debugPrint('  - isSuccess: ${response.isSuccess}');
      debugPrint('  - status: ${response.status}');
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
        debugPrint('   状态码: ${response.status}');

        // 如果是空数据，显示提示
        if (response.isSuccess &&
            (response.data == null || (response.data as List?)?.isEmpty == true)) {
          debugPrint('ℹ️ 用户还没有田地，需要先购买种子并播种');
        }
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
      case 'SWP':
        // 直接切换到"我的" tab（index=4）
        Get.offAllNamed(AppRoutes.main, arguments: {'tab': 4});
        break;
    }
  }

  // 显示广告
  Future<void> _showAd() async {
    // 1. 检查实名认证（与uni-app一致）
    if (_userInfo['is_sign'] != true) {
      FlutterToastPro.showMessage('请先实名认证哦');
      await Future.delayed(const Duration(seconds: 1));
      Get.toNamed(AppRoutes.realName); // 修复：使用正确的路由
      return;
    }

    // 2. 显示加载中
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

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
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

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
    // 防重复点击
    if (_isExchanging) return;

    if (_pwd.isEmpty) {
      FlutterToastPro.showMessage('请输入交易密码');
      return;
    }

    if (_selectedSeed == null) return;

    // 验证数量
    if (_buyNum <= 0) {
      FlutterToastPro.showMessage('最少兑换一个');
      return;
    }

    final dhNum = double.tryParse(_selectedSeed!['dh_num']?.toString() ?? '0') ?? 0;
    final userFudou = double.tryParse(_userInfo['fudou']?.toString() ?? '0') ?? 0;

    if (userFudou < dhNum * _buyNum) {
      FlutterToastPro.showMessage('积分不够哦');
      return;
    }

    _isExchanging = true;

    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      final response = await _userProvider.exchangeTask({
        'task_id': _selectedSeed!['id'],
        'num': _buyNum,
        'pwd': _pwd,
      });

      Get.back(); // 关闭加载对话框

      if (response.isSuccess) {
        FlutterToastPro.showMessage('兑换成功');
        setState(() {
          _showShopPopup = false;
          _pwd = '';
          _buyNum = 1;
          _selectedSeed = null;
        });
        // 刷新数据
        await _loadData();
      } else {
        // 失败时清空密码
        setState(() {
          _pwd = '';
        });
        FlutterToastPro.showMessage(response.msg);
      }
    } catch (e) {
      Get.back(); // 关闭加载对话框
      // 失败时清空密码
      setState(() {
        _pwd = '';
      });
      FlutterToastPro.showMessage('兑换失败: ${e.toString()}');
    } finally {
      _isExchanging = false;
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
                        colors: [themeColor.gradientStart, themeColor.gradientEnd],
                      ),
                    ),
                  ),
                ),
              ),

              // 主内容
              SafeArea(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
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
                      gradient: LinearGradient(colors: [Colors.red[400]!, Colors.red[600]!]),
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
      {'type': 'SWP', 'image': 'xfq.png', 'label': '消费券'},
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
                      child: Text(btn['label'] as String, style: const TextStyle(fontSize: 10)),
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
            Icon(Icons.agriculture, size: 64, color: Colors.white.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text('暂无种植任务', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('点击右侧"播种"按钮购买种子开始种植', style: TextStyle(color: Colors.white60, fontSize: 14)),
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
  Widget _build3DPlotItem(Map<String, dynamic> plot, ThemeColorData themeColor) {
    final plants = plot['plants'] as List? ?? [];
    final fieldType = plot['fieldType'] ?? 1;
    final rightIcon = plot['right'] ?? 0;

    // 计算田块宽度（与uni-app一致：500rpx ≈ 屏幕宽度的 2/3）
    final screenWidth = MediaQuery.of(context).size.width;
    final fieldWidth = screenWidth * 0.67; // 500rpx / 750rpx ≈ 0.67

    // 即使没有植物也显示空田地
    // 田块间距：在原有基础上增加10px
    final plotGap = screenWidth * 0.02 + 10; // 原15rpx + 10px

    return Container(
      margin: EdgeInsets.only(bottom: plotGap), // 田块间距
      // 不设置固定高度，让图片自适应高度，确保所有田块间距一致
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center, // 居中对齐
        children: [
          // 田块容器（居中）
          SizedBox(
            width: fieldWidth,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 田块背景图
                Image.asset(
                  'assets/images/$fieldType.png',
                  width: fieldWidth,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('田块图片加载失败: $fieldType.png');
                    return Container(
                      width: fieldWidth,
                      height: fieldWidth * 0.8,
                      decoration: BoxDecoration(
                        color: Colors.brown.withAlpha((0.5 * 255).round()),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text('田块 $fieldType', style: const TextStyle(color: Colors.white)),
                      ),
                    );
                  },
                ),

                // 植物层 - 使用绝对定位（与uni-app一致）
                // 使用固定尺寸的容器来确保植物定位准确
                if (plants.isNotEmpty)
                  SizedBox(
                    width: fieldWidth,
                    height: fieldWidth, // 使用固定高度确保定位准确
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: plants.asMap().entries.map((entry) {
                        final plantIndex = entry.key;
                        final plant = entry.value;
                        return _build3DPlantWidget(
                          plant,
                          fieldType,
                          plantIndex,
                          fieldWidth, // 传入田块宽度
                          themeColor,
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),

          // 右侧指示牌（与uni-app一致：120rpx ≈ 0.16 * 屏幕宽度）
          // 修复：right 为 0 时也要显示
          Positioned(
            right: fieldWidth * -0.04, // -20rpx / 500rpx ≈ -0.04
            top: fieldWidth * 0.04, // 20rpx / 500rpx ≈ 0.04
            child: Image.asset(
              'assets/images/right_icon$rightIcon.png',
              width: fieldWidth * 0.24, // 120rpx / 500rpx = 0.24
              errorBuilder: (context, error, stackTrace) {
                debugPrint('指示牌图片加载失败: right_icon$rightIcon.png');
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopPopup(ThemeColorData themeColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final popupWidth = screenWidth * 0.8; // 600rpx / 750rpx = 0.8

    return GestureDetector(
      onTap: () => setState(() => _showShopPopup = false),
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // 阻止点击穿透
            child: SizedBox(
              width: popupWidth,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 背景图
                  Image.asset(
                    'assets/images/popup_bg.png',
                    width: popupWidth,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (context, error, stackTrace) {
                      // 如果背景图加载失败，使用纯色背景
                      return Container(
                        width: popupWidth,
                        height: popupWidth * 1.4,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFF8C42), Color(0xFFFF6B35)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    },
                  ),

                  // 关闭按钮
                  Positioned(
                    right: -5,
                    top: -5,
                    child: GestureDetector(
                      onTap: () => setState(() => _showShopPopup = false),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '×',
                            style: TextStyle(fontSize: 28, color: Color(0xFF999999), height: 1),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 内容区域（覆盖在背景图上）
                  // 参考uni-app: top: 27%, left/right: 5%, bottom: 7%
                  Positioned(
                    top: popupWidth * 0.38, // 顶部位置
                    left: popupWidth * 0.05, // 5%
                    right: popupWidth * 0.05, // 5%
                    bottom: popupWidth * 0.1, // 底部留白
                    child: _seedList.isEmpty
                        ? const Center(
                            child: Text('暂无种子', style: TextStyle(color: Colors.white70)),
                          )
                        : GridView.builder(
                            padding: EdgeInsets.zero,
                            physics: const BouncingScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.85, // 调整宽高比，减少间距
                              crossAxisSpacing: 8, // 16rpx
                              mainAxisSpacing: 8, // 16rpx
                            ),
                            itemCount: _seedList.length,
                            itemBuilder: (context, index) {
                              return _buildSeedItem(_seedList[index]);
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

  Widget _buildSeedItem(Map<String, dynamic> seed) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFEF8), Color(0xFFFFF9E6)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 种子名称
          Text(
            seed['name']?.toString() ?? '',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // 种子图片
          Image.network(
            seed['image']?.toString() ?? '',
            width: 45,
            height: 45,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(color: Colors.green[100], shape: BoxShape.circle),
                child: Icon(Icons.eco, color: Colors.green[600], size: 25),
              );
            },
          ),

          const SizedBox(height: 4),

          // 种子信息
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '预计获得${seed['output_num'] ?? 0}积分',
                style: const TextStyle(fontSize: 10, color: Color(0xFF666666), height: 1.2),
              ),
              Text(
                '活跃度：${seed['activity'] ?? 0}',
                style: const TextStyle(fontSize: 10, color: Color(0xFF666666), height: 1.2),
              ),
              Text(
                '种子数量：${seed['count'] ?? 0}/${seed['limit'] ?? 0}个',
                style: const TextStyle(fontSize: 10, color: Color(0xFF666666), height: 1.2),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // 购买按钮
          GestureDetector(
            onTap: () {
              setState(() => _selectedSeed = seed);
              _showBuyDialog();
            },
            child: Container(
              width: double.infinity,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF7DD87D), Color(0xFF4EB84E)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF44AA44).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${seed['dh_num'] ?? 0}积分',
                  style: const TextStyle(
                    fontSize: 11,
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
              decoration: const InputDecoration(hintText: '请输入交易密码', border: OutlineInputBorder()),
              onChanged: (value) => _pwd = value,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
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
    double fieldWidth, // 添加田块宽度参数
    ThemeColorData themeColor,
  ) {
    final plantType = plant['type'] ?? 0;
    final progress = double.tryParse(plant['progress']?.toString() ?? '0') ?? 0;
    final dkDay = plant['dk_day'] ?? 0;
    final totalDay = plant['day'] ?? 1;
    final score = plant['score'] ?? 0;

    // 植物宽度：80rpx / 500rpx = 0.16
    final plantWidth = fieldWidth * 0.16;

    // 获取植物位置（与uni-app的getPlantPosition一致）
    final position = _getPlantPosition(fieldType, plantIndex);
    if (position == null) return const SizedBox.shrink();

    return Positioned(
      left: position['left']! * fieldWidth, // 转换百分比为像素
      top: position['top']! * fieldWidth,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.85), // 从-1.0调整到-0.85，让植物往下移一点
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 植物图标
            Image.asset(
              'assets/images/plant$plantType.png',
              width: plantWidth,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: plantWidth,
                  height: plantWidth,
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
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 进度条（100rpx / 500rpx = 0.2）
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: fieldWidth * 0.2, // 100rpx / 500rpx = 0.2
                        height: fieldWidth * 0.024, // 12rpx / 500rpx ≈ 0.024
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(fieldWidth * 0.012),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7dd87d), Color(0xFF4eb84e)],
                              ),
                              borderRadius: BorderRadius.circular(fieldWidth * 0.012),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: fieldWidth * 0.008),
                      Text(
                        '$dkDay/$totalDay天',
                        style: TextStyle(
                          fontSize: fieldWidth * 0.02, // 10rpx / 500rpx = 0.02（放大文字）
                          color: const Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: fieldWidth * 0.004),
                  Text(
                    '已领取$score',
                    style: TextStyle(
                      fontSize: fieldWidth * 0.032, // 16rpx / 500rpx = 0.032
                      color: const Color(0xFF666666),
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
