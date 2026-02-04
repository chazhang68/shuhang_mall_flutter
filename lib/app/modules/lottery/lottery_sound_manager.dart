import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class LotterySoundManager {
  static final LotterySoundManager _instance = LotterySoundManager._internal();
  factory LotterySoundManager() => _instance;
  LotterySoundManager._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 这里可以加载本地音效文件
      // await _player.setAsset('assets/sounds/lottery_spin.mp3');
      _isInitialized = true;
    } catch (e) {
      // 音效加载失败时静默处理
      debugPrint('音效初始化失败: $e');
    }
  }

  Future<void> playSpinSound() async {
    if (!_isInitialized) return;

    try {
      // 播放抽奖旋转音效
      await _player.play();
    } catch (e) {
      // 音效播放失败时静默处理
    }
  }

  Future<void> playWinSound() async {
    if (!_isInitialized) return;

    try {
      // 播放中奖音效
      // 可以使用不同的音效文件
      await _player.play();
    } catch (e) {
      // 音效播放失败时静默处理
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
