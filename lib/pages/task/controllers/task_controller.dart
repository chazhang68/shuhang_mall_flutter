import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:shuhang_mall_flutter/app/data/providers/user_provider.dart';
import 'package:shuhang_mall_flutter/app/data/models/user_model.dart';
import 'package:shuhang_mall_flutter/app/services/ad_manager.dart';
import '../models/task_seed_model.dart';
import '../models/task_plot_model.dart';

/// 任务页面控制器
/// 对应原 pages/task/task.vue
class TaskController extends GetxController {
  final UserProvider _userProvider = UserProvider();
  final AdManager _adManager = AdManager.instance;

  // ==================== 响应式状态 ====================

  // 加载状态
  final RxBool _isLoading = true.obs;
  bool get isLoading => _isLoading.value;

  // 水壶进度 (0-8)
  final RxInt _taskDoneCount = 0.obs;
  int get taskDoneCount => _taskDoneCount.value;

  // 种子列表
  final RxList<TaskSeedModel> _seedList = <TaskSeedModel>[].obs;
  List<TaskSeedModel> get seedList => _seedList;

  // 地块列表
  final RxList<TaskPlotModel> _plotList = <TaskPlotModel>[].obs;
  List<TaskPlotModel> get plotList => _plotList;

  // 用户信息
  final Rx<UserModel?> _userInfo = Rx<UserModel?>(null);
  UserModel? get userInfo => _userInfo.value;

  // 弹窗状态
  final RxBool _showShopPopup = false.obs;
  bool get showShopPopup => _showShopPopup.value;

  // 当前选中的种子
  final Rx<TaskSeedModel?> _selectedSeed = Rx<TaskSeedModel?>(null);
  TaskSeedModel? get selectedSeed => _selectedSeed.value;

  // 购买数量
  final RxInt _buyNum = 1.obs;
  int get buyNum => _buyNum.value;

  // 密码输入
  final RxString _pwd = ''.obs;
  String get pwd => _pwd.value;

  // 广告加载状态
  final RxBool _adLoading = false.obs;
  bool get adLoading => _adLoading.value;

  @override
  void onInit() {
    super.onInit();
    _initAd();
    loadData();
  }

  // ==================== 初始化 ====================

  /// 初始化广告
  Future<void> _initAd() async {
    try {
      await _adManager.start();
      _adManager.preloadRewardedVideoAd();
    } catch (e) {
      debugPrint('初始化广告失败: $e');
    }
  }

  // ==================== 数据加载 ====================

  /// 加载所有数据
  Future<void> loadData() async {
    _isLoading.value = true;

    await Future.wait([getUserInfo(), getTaskList(), getMyTask()]);

    _isLoading.value = false;
  }

  /// 获取用户信息
  Future<void> getUserInfo() async {
    try {
      final response = await _userProvider.getUserInfo();
      if (response.isSuccess && response.data != null) {
        _userInfo.value = response.data;
        _taskDoneCount.value = response.data!.task;
      }
    } catch (e) {
      debugPrint('获取用户信息失败: $e');
    }
  }

  /// 获取任务列表（种子列表）
  Future<void> getTaskList() async {
    try {
      final response = await _userProvider.getUserTask();
      if (response.isSuccess && response.data != null) {
        final List<dynamic> dataList = response.data as List? ?? [];
        _seedList.assignAll(
          dataList
              .map(
                (item) => TaskSeedModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
        );
      }
    } catch (e) {
      debugPrint('获取任务列表失败: $e');
    }
  }

  /// 获取我的任务（地块列表）
  Future<void> getMyTask() async {
    try {
      final response = await _userProvider.getNewMyTask();
      if (response.isSuccess && response.data != null) {
        final List<dynamic> dataList = response.data as List? ?? [];
        _plotList.assignAll(
          dataList
              .map(
                (item) => TaskPlotModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
        );
      }
    } catch (e) {
      debugPrint('获取我的任务失败: $e');
    }
  }

  // ==================== 按钮操作 ====================

  /// 处理按钮点击
  void handleButtonClick(String type) {
    switch (type) {
      case 'seed':
        _showShopPopup.value = true;
        break;
      case 'water':
        if (_taskDoneCount.value >= 8) {
          lingqu();
        } else {
          showAd();
        }
        break;
      case 'points':
        // 跳转到可用积分页面
        Get.toNamed('/task/ryz', arguments: {'index': 1});
        break;
      case 'SWP':
        // 跳转到SWP页面
        Get.toNamed('/task/ryz', arguments: {'index': 2});
        break;
    }
  }

  // ==================== 广告相关 ====================

  /// 显示广告
  Future<void> showAd() async {
    // 检查实名认证
    if (_userInfo.value?.isSign != true) {
      FlutterToastPro.showMessage('请先实名认证哦');
      await Future.delayed(const Duration(seconds: 1));
      Get.toNamed('/real-name');
      return;
    }

    _adLoading.value = true;

    // 调用广告SDK显示激励视频
    final success = await _adManager.showRewardedVideoAd(
      onReward: () {
        // 广告观看完成，发放奖励
        onAdComplete();
      },
      onClose: () {
        _adLoading.value = false;
        debugPrint('广告已关闭');
      },
      onError: (error) {
        _adLoading.value = false;
        FlutterToastPro.showMessage('广告加载失败: $error');
      },
    );

    if (!success) {
      _adLoading.value = false;
      FlutterToastPro.showMessage('暂无可用广告，请稍后重试');
    }
  }

  /// 广告观看完成回调
  Future<void> onAdComplete() async {
    try {
      final response = await _userProvider.watchOver(null);
      if (response.isSuccess) {
        await getUserInfo();
        if (_taskDoneCount.value >= 8) {
          lingqu();
        }
        // 预加载下一个广告
        _adManager.preloadRewardedVideoAd();
      }
    } catch (e) {
      FlutterToastPro.showMessage('领取奖励失败');
    }
  }

  // ==================== 领取奖励 ====================

  /// 领取奖励
  Future<void> lingqu() async {
    if (_taskDoneCount.value < 8) {
      FlutterToastPro.showMessage('请先完成所有任务');
      return;
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response = await _userProvider.lingqu();
      Get.back();

      if (response.isSuccess) {
        FlutterToastPro.showMessage('今日任务已完成，请查看您的奖励！');
        await loadData();
      } else {
        FlutterToastPro.showMessage(response.msg);
      }
    } catch (e) {
      Get.back();
      FlutterToastPro.showMessage('领取奖励失败');
    }
  }

  // ==================== 种子商店 ====================

  /// 打开种子商店
  void openShopPopup() {
    _showShopPopup.value = true;
  }

  /// 关闭种子商店
  void closeShopPopup() {
    _showShopPopup.value = false;
    _selectedSeed.value = null;
    _pwd.value = '';
    _buyNum.value = 1;
  }

  /// 选择种子
  void selectSeed(TaskSeedModel seed) {
    _selectedSeed.value = seed;
  }

  /// 设置密码
  void setPwd(String value) {
    _pwd.value = value;
  }

  /// 设置购买数量
  void setBuyNum(int value) {
    _buyNum.value = value;
  }

  /// 购买种子
  Future<void> buySeed() async {
    if (_pwd.value.isEmpty) {
      FlutterToastPro.showMessage('请输入交易密码');
      return;
    }

    if (_selectedSeed.value == null) return;

    final dhNum = _selectedSeed.value!.dhNum;
    final userFudou = _userInfo.value?.fudou ?? 0;

    if (userFudou < dhNum * _buyNum.value) {
      FlutterToastPro.showMessage('积分不够哦');
      return;
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response = await _userProvider.exchangeTask({
        'task_id': _selectedSeed.value!.id,
        'num': _buyNum.value,
        'pwd': _pwd.value,
      });

      Get.back();

      if (response.isSuccess) {
        FlutterToastPro.showMessage('兑换成功');
        closeShopPopup();
        await loadData();
      } else {
        FlutterToastPro.showMessage(response.msg);
      }
    } catch (e) {
      Get.back();
      FlutterToastPro.showMessage('兑换失败: $e');
    }
  }

  // ==================== 工具方法 ====================

  /// 计算进度条宽度百分比
  double getProgressBarWidthPercent() {
    if (_taskDoneCount.value <= 0) return 0;
    if (_taskDoneCount.value >= 8) return 1.0;
    return _taskDoneCount.value / 8;
  }
}
