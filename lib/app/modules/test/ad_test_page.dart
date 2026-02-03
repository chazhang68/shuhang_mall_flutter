import 'package:flutter/material.dart';
import 'package:shuhang_mall_flutter/app/services/ad_manager.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';

/// 广告测试页面
class AdTestPage extends StatefulWidget {
  const AdTestPage({super.key});

  @override
  State<AdTestPage> createState() => _AdTestPageState();
}

class _AdTestPageState extends State<AdTestPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('广告测试')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // SDK 状态
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SDK 状态',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('已初始化: ${AdManager.instance.isInitialized}'),
                  Text('已启动: ${AdManager.instance.isStarted}'),
                  Text('加载中: ${AdManager.instance.isAdLoading}'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 初始化按钮
          ElevatedButton(
            onPressed: _isLoading ? null : _initSdk,
            child: const Text('初始化 SDK'),
          ),

          const SizedBox(height: 8),

          // 启动按钮
          ElevatedButton(
            onPressed: _isLoading ? null : _startSdk,
            child: const Text('启动 SDK'),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // 激励视频
          ElevatedButton(
            onPressed: _isLoading ? null : _showRewardVideo,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('显示激励视频'),
          ),

          const SizedBox(height: 8),

          // 插全屏
          ElevatedButton(
            onPressed: _isLoading ? null : _showInterstitial,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('显示插全屏广告'),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // 说明
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '使用说明',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('1. 首先点击"初始化 SDK"'),
                  Text('2. 然后点击"启动 SDK"'),
                  Text('3. 最后可以测试各种广告'),
                  SizedBox(height: 8),
                  Text(
                    '注意：测试广告需要使用正确的广告位ID和包名',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 初始化 SDK
  Future<void> _initSdk() async {
    setState(() => _isLoading = true);

    try {
      await AdManager.instance.initWithoutStart();
      FlutterToastPro.showMessage('SDK 初始化成功');
      setState(() {});
    } catch (e) {
      FlutterToastPro.showMessage('SDK 初始化失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 启动 SDK
  Future<void> _startSdk() async {
    setState(() => _isLoading = true);

    try {
      final success = await AdManager.instance.start();
      if (success) {
        FlutterToastPro.showMessage('SDK 启动成功');
        setState(() {});
      } else {
        FlutterToastPro.showMessage('SDK 启动失败');
      }
    } catch (e) {
      FlutterToastPro.showMessage('SDK 启动失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 显示激励视频
  Future<void> _showRewardVideo() async {
    setState(() => _isLoading = true);

    try {
      await AdManager.instance.showRewardedVideoAd(
        onShow: () {
          FlutterToastPro.showMessage('激励视频展示');
        },
        onClick: () {
          FlutterToastPro.showMessage('激励视频点击');
        },
        onReward: () {
          FlutterToastPro.showMessage('获得奖励！');
        },
        onClose: () {
          FlutterToastPro.showMessage('激励视频关闭');
          setState(() => _isLoading = false);
        },
        onError: (error) {
          FlutterToastPro.showMessage('激励视频错误: $error');
          setState(() => _isLoading = false);
        },
      );
    } catch (e) {
      FlutterToastPro.showMessage('激励视频失败: $e');
      setState(() => _isLoading = false);
    }
  }

  /// 显示插全屏广告
  Future<void> _showInterstitial() async {
    setState(() => _isLoading = true);

    try {
      await AdManager.instance.showInterstitialAd(
        onShow: () {
          FlutterToastPro.showMessage('插全屏广告展示');
        },
        onClick: () {
          FlutterToastPro.showMessage('插全屏广告点击');
        },
        onClose: () {
          FlutterToastPro.showMessage('插全屏广告关闭');
          setState(() => _isLoading = false);
        },
        onError: (error) {
          FlutterToastPro.showMessage('插全屏广告错误: $error');
          setState(() => _isLoading = false);
        },
      );
    } catch (e) {
      FlutterToastPro.showMessage('插全屏广告失败: $e');
      setState(() => _isLoading = false);
    }
  }
}
