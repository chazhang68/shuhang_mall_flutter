import 'dart:async';
import 'package:flutter/material.dart';

/// 倒计时组件 - 对应 components/countDown/index.vue
class CountdownWidget extends StatefulWidget {
  /// 目标时间戳（秒）
  final int? targetTime;

  /// 结束时间戳（秒）- 为了兼容旧代码
  final int? endTime;

  /// 是否显示天数
  final bool showDays;

  /// 提示文字
  final String? tipText;

  /// 天文字
  final String dayText;

  /// 时文字
  final String hourText;

  /// 分文字
  final String minuteText;

  /// 秒文字
  final String secondText;

  /// 数字背景色
  final Color? backgroundColor;

  /// 数字文字颜色
  final Color? textColor;

  /// 分隔符颜色
  final Color? separatorColor;

  /// 倒计时结束回调
  final VoidCallback? onFinish;

  /// 样式类型
  final CountdownStyle style;

  const CountdownWidget({
    super.key,
    this.targetTime,
    this.endTime,
    this.showDays = true,
    this.tipText,
    this.dayText = '天',
    this.hourText = '时',
    this.minuteText = '分',
    this.secondText = '秒',
    this.backgroundColor,
    this.textColor,
    this.separatorColor,
    this.onFinish,
    this.style = CountdownStyle.normal,
  });

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  Timer? _timer;
  int _days = 0;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _calculateTime();
    _startTimer();
  }

  @override
  void didUpdateWidget(CountdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetTime != widget.targetTime) {
      _calculateTime();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTime();
    });
  }

  void _calculateTime() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final target = widget.targetTime ?? widget.endTime ?? now;
    int diff = target - now;

    if (diff <= 0) {
      setState(() {
        _days = 0;
        _hours = 0;
        _minutes = 0;
        _seconds = 0;
      });
      _timer?.cancel();
      widget.onFinish?.call();
      return;
    }

    int days = 0;
    if (widget.showDays) {
      days = diff ~/ (24 * 60 * 60);
      diff = diff % (24 * 60 * 60);
    }

    final hours = diff ~/ (60 * 60);
    diff = diff % (60 * 60);
    final minutes = diff ~/ 60;
    final seconds = diff % 60;

    setState(() {
      _days = days;
      _hours = hours;
      _minutes = minutes;
      _seconds = seconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.style) {
      case CountdownStyle.normal:
        return _buildNormalStyle();
      case CountdownStyle.box:
        return _buildBoxStyle();
      case CountdownStyle.simple:
        return _buildSimpleStyle();
      case CountdownStyle.seckill:
        return _buildSeckillStyle();
    }
  }

  /// 普通样式
  Widget _buildNormalStyle() {
    final primaryColor =
        widget.separatorColor ?? Theme.of(context).primaryColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.tipText != null) ...[
          Text(
            widget.tipText!,
            style: TextStyle(
              color: primaryColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
        ],
        if (widget.showDays) ...[
          _buildTimeBox('$_days'.padLeft(2, '0')),
          _buildSeparator(widget.dayText),
        ],
        _buildTimeBox('$_hours'.padLeft(2, '0')),
        _buildSeparator(widget.hourText),
        _buildTimeBox('$_minutes'.padLeft(2, '0')),
        _buildSeparator(widget.minuteText),
        _buildTimeBox('$_seconds'.padLeft(2, '0')),
        if (widget.secondText.isNotEmpty) _buildSeparator(widget.secondText),
      ],
    );
  }

  /// 盒子样式
  Widget _buildBoxStyle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.tipText != null) ...[
          Text(
            widget.tipText!,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (widget.showDays) ...[
          _buildBoxTimeItem('$_days'.padLeft(2, '0')),
          _buildBoxSeparator(widget.dayText),
        ],
        _buildBoxTimeItem('$_hours'.padLeft(2, '0')),
        _buildBoxSeparator(widget.hourText),
        _buildBoxTimeItem('$_minutes'.padLeft(2, '0')),
        _buildBoxSeparator(widget.minuteText),
        _buildBoxTimeItem('$_seconds'.padLeft(2, '0')),
        if (widget.secondText.isNotEmpty) _buildBoxSeparator(widget.secondText),
      ],
    );
  }

  /// 简单样式
  Widget _buildSimpleStyle() {
    String timeStr = '';
    if (widget.showDays && _days > 0) {
      timeStr += '$_days${widget.dayText}';
    }
    timeStr += '${_hours.toString().padLeft(2, '0')}:';
    timeStr += '${_minutes.toString().padLeft(2, '0')}:';
    timeStr += _seconds.toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.tipText != null) ...[
          Text(
            widget.tipText!,
            style: TextStyle(
              color: widget.textColor ?? Theme.of(context).primaryColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
        ],
        Text(
          timeStr,
          style: TextStyle(
            color: widget.textColor ?? Theme.of(context).primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 秒杀样式
  Widget _buildSeckillStyle() {
    final bgColor = widget.backgroundColor ?? const Color(0xFF222222);
    final txtColor = widget.textColor ?? Colors.white;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.tipText != null) ...[
          Text(
            widget.tipText!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (widget.showDays && _days > 0) ...[
          _buildSeckillTimeItem('$_days'.padLeft(2, '0'), bgColor, txtColor),
          _buildSeckillSeparator(widget.dayText),
        ],
        _buildSeckillTimeItem('$_hours'.padLeft(2, '0'), bgColor, txtColor),
        _buildSeckillSeparator(':'),
        _buildSeckillTimeItem('$_minutes'.padLeft(2, '0'), bgColor, txtColor),
        _buildSeckillSeparator(':'),
        _buildSeckillTimeItem('$_seconds'.padLeft(2, '0'), bgColor, txtColor),
      ],
    );
  }

  Widget _buildTimeBox(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: widget.textColor ?? Theme.of(context).primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSeparator(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        text,
        style: TextStyle(
          color: widget.separatorColor ?? Theme.of(context).primaryColor,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildBoxTimeItem(String value) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? const Color(0xFF333333),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: widget.textColor ?? Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBoxSeparator(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          color: widget.separatorColor ?? const Color(0xFF666666),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSeckillTimeItem(String value, Color bgColor, Color txtColor) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: txtColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSeckillSeparator(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        text,
        style: TextStyle(
          color: widget.separatorColor ?? Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// 倒计时样式
enum CountdownStyle {
  normal, // 普通样式
  box, // 盒子样式
  simple, // 简单样式
  seckill, // 秒杀样式
}

/// 时间倒计时控制器
class CountdownController {
  _CountdownTimerState? _state;

  void _bindState(_CountdownTimerState state) {
    _state = state;
  }

  void start() {
    _state?._start();
  }

  void pause() {
    _state?._pause();
  }

  void reset(int seconds) {
    _state?._reset(seconds);
  }

  int get remainingSeconds => _state?._remainingSeconds ?? 0;

  bool get isRunning => _state?._isRunning ?? false;
}

/// 可控倒计时组件
class CountdownTimer extends StatefulWidget {
  final int seconds;
  final CountdownController? controller;
  final bool autoStart;
  final VoidCallback? onFinish;
  final Widget Function(int seconds)? builder;
  final CountdownStyle style;
  final String? tipText;

  const CountdownTimer({
    super.key,
    required this.seconds,
    this.controller,
    this.autoStart = true,
    this.onFinish,
    this.builder,
    this.style = CountdownStyle.simple,
    this.tipText,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.seconds;
    widget.controller?._bindState(this);
    if (widget.autoStart) {
      _start();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        _pause();
        widget.onFinish?.call();
        return;
      }
      setState(() {
        _remainingSeconds--;
      });
    });
  }

  void _pause() {
    _isRunning = false;
    _timer?.cancel();
  }

  void _reset(int seconds) {
    _pause();
    setState(() {
      _remainingSeconds = seconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.builder != null) {
      return widget.builder!(_remainingSeconds);
    }

    // 转换为目标时间戳
    final targetTime =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 + _remainingSeconds;

    return CountdownWidget(
      targetTime: targetTime,
      showDays: _remainingSeconds >= 86400,
      tipText: widget.tipText,
      style: widget.style,
      onFinish: widget.onFinish,
    );
  }
}

/// 验证码倒计时按钮
class CountdownButton extends StatefulWidget {
  final Future<bool> Function()? onSend;
  final int seconds;
  final String sendText;
  final String countdownText;
  final TextStyle? textStyle;
  final TextStyle? countdownTextStyle;
  final bool enabled;

  const CountdownButton({
    super.key,
    this.onSend,
    this.seconds = 60,
    this.sendText = '获取验证码',
    this.countdownText = '秒后重试',
    this.textStyle,
    this.countdownTextStyle,
    this.enabled = true,
  });

  @override
  State<CountdownButton> createState() => _CountdownButtonState();
}

class _CountdownButtonState extends State<CountdownButton> {
  Timer? _timer;
  int _countdown = 0;
  bool _isSending = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (_countdown > 0 || _isSending || !widget.enabled) return;

    setState(() {
      _isSending = true;
    });

    try {
      final success = await widget.onSend?.call() ?? true;
      if (success) {
        _startCountdown();
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _startCountdown() {
    setState(() {
      _countdown = widget.seconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 0) {
        timer.cancel();
        return;
      }
      setState(() {
        _countdown--;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = _countdown > 0 || _isSending || !widget.enabled;

    return GestureDetector(
      onTap: isDisabled ? null : _handleSend,
      child: Text(
        _countdown > 0 ? '$_countdown${widget.countdownText}' : widget.sendText,
        style: _countdown > 0
            ? (widget.countdownTextStyle ??
                const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                ))
            : (widget.textStyle ??
                TextStyle(
                  fontSize: 14,
                  color: isDisabled
                      ? const Color(0xFF999999)
                      : Theme.of(context).primaryColor,
                )),
      ),
    );
  }
}

