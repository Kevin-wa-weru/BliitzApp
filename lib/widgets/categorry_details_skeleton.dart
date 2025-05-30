import 'dart:math' as math;

import 'package:bliitz/Features/HomeScreen/CategoryPages/categroy_details.dart';
import 'package:bliitz/widgets/profile_visit_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CategorryDetailsSkeleton extends StatefulWidget {
  const CategorryDetailsSkeleton({super.key});

  @override
  State<CategorryDetailsSkeleton> createState() =>
      _CategorryDetailsSkeletonState();
}

class _CategorryDetailsSkeletonState extends State<CategorryDetailsSkeleton> {
  ScrollController? _scrollController;
  Color animateColor = Colors.black54;
  double opacity = 1.0;
  double topPadding = 25.0;
  bool isVisible = true;
  int speed = 500;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              stretch: true,
              backgroundColor: const Color(0xFF141312),
              elevation: 0,
              pinned: true,
              automaticallyImplyLeading: false,
              expandedHeight:
                  MediaQuery.of(context).size.height * getRatioHeight(150),
              collapsedHeight: 50,
              toolbarHeight: 30,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                ],
                background: SizedBox(
                  height:
                      MediaQuery.of(context).size.height * getRatioHeight(200),
                  child: Opacity(
                      opacity: .7,
                      child: Container(
                        color: const Color(0xFF141312),
                      )),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: false,
              delegate: _SliverAppBarDelegate(
                minHeight: 80,
                maxHeight: 80,
                child: Container(
                  decoration: BoxDecoration(
                    color: opacity == 1.0
                        ? Colors.transparent
                        : Colors.transparent,
                  ),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 8.0,
                              top: 8,
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    color: const Color(0xFF141312),
                                    width: 120,
                                    height: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 4),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    color: const Color(0xFF141312),
                                    width: 60,
                                    height: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: IntrinsicWidth(
                            child: IntrinsicHeight(
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF141312),
                                      borderRadius:
                                          BorderRadius.circular(200.0),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Center(
                                          child: Icon(
                                        size: 24,
                                        Icons.add,
                                        color: Colors.transparent,
                                      )),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF141312),
                                      borderRadius:
                                          BorderRadius.circular(200.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          'assets/icons/share.svg',
                                          height: 24,
                                          width: 24,
                                          colorFilter: const ColorFilter.mode(
                                            Colors.transparent,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, int index) {
                  return const SingleGroupItemSkeleton(
                    itemCount: [1, 2, 3, 4],
                  );
                },
                childCount: 2,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 24.0,
            left: 8.0,
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: AnimatedContainer(
              curve: Curves.easeIn,
              height: 48,
              width: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF141312),
                borderRadius: BorderRadius.all(
                  Radius.circular(500.0),
                ),
              ),
              duration: const Duration(milliseconds: 250),
              child: const Center(
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white30,
                  size: 25,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
