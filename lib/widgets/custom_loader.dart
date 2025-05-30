import 'dart:async';
import 'package:flutter/material.dart';

class EqualizerLoader extends StatefulWidget {
  const EqualizerLoader({super.key, required this.color});
  final Color color;
  @override
  State<EqualizerLoader> createState() => _EqualizerLoaderState();
}

class _EqualizerLoaderState extends State<EqualizerLoader> {
  List<double> barHeights = List.generate(5, (index) => 10.0); // Initial height
  // List<double> barHeights = [5.0, 25.0, 45.0, 25.0, 5.0];
  int currentAnimatingBar = 0;
  final Duration animationDuration = const Duration(milliseconds: 150);
  final Duration delayBetweenBars = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    startEqualizerAnimation();
  }

  void startEqualizerAnimation() async {
    while (mounted) {
      for (int i = 0; i < barHeights.length; i++) {
        if (!mounted) return;

        setState(() {
          barHeights[i] = 30.0; // Expand
        });

        await Future.delayed(animationDuration);

        if (!mounted) return;

        setState(() {
          barHeights[i] = 10.0; // Collapse
        });

        if (i == 4) {
          await Future.delayed(delayBetweenBars);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(barHeights.length, (index) {
          return AnimatedContainer(
            duration: animationDuration,
            curve: Curves.easeIn,
            width: 6,
            height: barHeights[index],
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}
