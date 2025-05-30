import 'dart:async';
import 'package:flutter/material.dart';

class TypewriterText extends StatefulWidget {
  final String message;
  final TextStyle? style;
  final ValueNotifier<bool> trigger;

  const TypewriterText({
    super.key,
    required this.message,
    this.style,
    required this.trigger,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _visibleText = "";
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    widget.trigger.addListener(() {
      if (widget.trigger.value) {
        _startTyping();
        widget.trigger.value = false; // reset
      }
    });
  }

  void _startTyping() {
    _visibleText = "";
    _index = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (_index < widget.message.length) {
        setState(() {
          _visibleText += widget.message[_index];
          _index++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _visibleText,
      style: widget.style ??
          TextStyle(
            color: Colors.red.withOpacity(.6),
            fontWeight: FontWeight.w400,
            fontFamily: 'Questrial',
            letterSpacing: 0.3,
            height: 1.5,
          ),
    );
  }
}
