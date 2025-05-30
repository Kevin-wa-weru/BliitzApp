import 'package:flutter/material.dart';

class ProfileVisitSkeleton extends StatefulWidget {
  const ProfileVisitSkeleton({super.key});

  @override
  State<ProfileVisitSkeleton> createState() => _ProfileVisitSkeletonState();
}

class _ProfileVisitSkeletonState extends State<ProfileVisitSkeleton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 24,
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Container(
            color: const Color(0xFF141312),
            width: 156,
            height: 156,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: const Color(0xFF141312),
                width: 70,
                height: 20,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32.0, right: 32),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: const Color(0xFF141312),
                width: 1400,
                height: 60,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 14,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: const Color(0xFF141312),
                width: 60,
                height: 20,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF141312),
                borderRadius: BorderRadius.circular(200.0),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 6,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 20,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF141312),
                        borderRadius: BorderRadius.circular(200.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 60,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF141312),
                        borderRadius: BorderRadius.circular(200.0),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 16,
              ),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 20,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF141312),
                        borderRadius: BorderRadius.circular(200.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 60,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF141312),
                        borderRadius: BorderRadius.circular(200.0),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 16,
              ),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 20,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF141312),
                        borderRadius: BorderRadius.circular(200.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 60,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF141312),
                        borderRadius: BorderRadius.circular(200.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  1,
                  2,
                  3,
                  4,
                ]
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            height: 30.0,
                            width: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFF141312),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
        const SingleGroupItemSkeleton(),
      ],
    );
  }
}

class SingleGroupItemSkeleton extends StatefulWidget {
  const SingleGroupItemSkeleton({super.key, this.itemCount});
  final List<int>? itemCount;
  @override
  State<SingleGroupItemSkeleton> createState() =>
      _SingleGroupItemSkeletonState();
}

class _SingleGroupItemSkeletonState extends State<SingleGroupItemSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shimmerGradient = LinearGradient(
      colors: [
        Colors.grey.shade900,
        Colors.grey.shade800,
        Colors.grey.shade900,
      ],
      stops: const [0.1, 0.5, 0.9],
      begin: const Alignment(-1.0, -0.3),
      end: const Alignment(1.0, 0.3),
      transform:
          _SlidingGradientTransform(slidePercent: _shimmerController.value),
    );

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        List<int>? items = widget.itemCount ?? [1, 2];
        return Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 24),
              child: Column(
                children: items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: ShaderMask(
                      shaderCallback: (bounds) =>
                          shimmerGradient.createShader(bounds),
                      blendMode: BlendMode.srcATop,
                      child: Container(
                        width: MediaQuery.of(context).size.width * .9,
                        height: 125,
                        decoration: BoxDecoration(
                          color: const Color(0xFF141312),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
