import 'package:bliitz/Features/HomeScreen/CategoryPages/cubit/get_links_category_page.dart';
import 'package:bliitz/Features/HomeScreen/LinkPages/create_link_page.dart';
import 'package:bliitz/widgets/group_item.dart';
import 'package:bliitz/utils/_index.dart';
import 'package:bliitz/widgets/categorry_details_skeleton.dart';
import 'package:bliitz/widgets/custom_loader.dart';
import 'package:bliitz/widgets/empty_data_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:octo_image/octo_image.dart';
import 'package:share_plus/share_plus.dart';

class CategroyDetails extends StatefulWidget {
  const CategroyDetails(
      {super.key,
      required this.categoryImageUrl,
      required this.category,
      required this.socialType,
      required this.isFromDeepLink});
  final String categoryImageUrl;
  final String category;
  final String socialType;
  final bool isFromDeepLink;
  @override
  State<CategroyDetails> createState() => _CategroyDetailsState();
}

class _CategroyDetailsState extends State<CategroyDetails> {
  Color animateColor = Colors.black54;
  double opacity = 1.0;
  double topPadding = 25.0;
  bool isVisible = true;
  int speed = 500;
  // double stickyHieght = 20;

  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() {
        if (_isAppBarExpandedOne) {
          topPadding != 0.0
              ? setState(
                  () {
                    topPadding = 0.0;
                  },
                )
              : {};
        } else {
          topPadding != 25.0
              ? setState(
                  () {
                    topPadding = 25.0;
                  },
                )
              : {};
        }
        if (_isAppBarExpandedTwo) {
          animateColor != Colors.transparent
              ? setState(
                  () {
                    animateColor = Colors.transparent;
                  },
                )
              : {};

          opacity != 0.0
              ? setState(
                  () {
                    opacity = 0.0;
                  },
                )
              : {};

          speed != 10
              ? setState(
                  () {
                    speed = 10;
                  },
                )
              : {};
        } else {
          animateColor != Colors.black54
              ? setState(() {
                  animateColor = Colors.black54;
                })
              : {};

          opacity != 1.0
              ? setState(
                  () {
                    opacity = 1.0;
                  },
                )
              : {};

          speed != 500
              ? setState(
                  () {
                    speed = 500;
                  },
                )
              : {};
        }
      });

    context
        .read<GetLinksInCategoriesPageCubit>()
        .filtertLinksBySocialAndCatgory(widget.socialType, widget.category);
  }

  bool get _isAppBarExpandedTwo {
    return _scrollController!.hasClients &&
        _scrollController!.offset > (150 - 100);
  }

  bool get _isAppBarExpandedOne {
    return _scrollController!.hasClients &&
        _scrollController!.offset > (150 - 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<GetLinksInCategoriesPageCubit,
          GetLinksInCategoriesPageState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is GetLinksInCategoriesPageStateInitial) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: Adapt.screenH() * .27),
                const EqualizerLoader(
                  color: Color(0xCC01DE27),
                ),
              ],
            );
          }

          if (state is GetLinksInCategoriesPageStateLoading) {
            return const CategorryDetailsSkeleton();
          }

          if (state is GetLinksInCategoriesPageStateLoaded) {
            if (state.links.isEmpty) {
              return Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            if (widget.isFromDeepLink) {
                              context.pushReplacement('/home_screen');
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            height: Adapt.px(80),
                            width: Adapt.px(80),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.08),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(100.0),
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white60,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                  const EmptyDataWidget(),
                ],
              );
            } else {
              return Stack(
                children: [
                  CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: <Widget>[
                      SliverAppBar(
                        stretch: true,
                        backgroundColor: Colors.black,
                        elevation: 0,
                        pinned: true,
                        automaticallyImplyLeading: false,
                        expandedHeight: MediaQuery.of(context).size.height *
                            getRatioHeight(150),
                        collapsedHeight: 50,
                        toolbarHeight: 30,
                        flexibleSpace: FlexibleSpaceBar(
                          stretchModes: const [
                            StretchMode.zoomBackground,
                          ],
                          background: SizedBox(
                            height: MediaQuery.of(context).size.height *
                                getRatioHeight(200),
                            child: Opacity(
                              opacity: .7,
                              child: OctoImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(
                                    state.links.first['Profile Image']),
                                progressIndicatorBuilder: (context, p) {
                                  double? value;
                                  final expectedBytes = p?.expectedTotalBytes;
                                  if (p != null && expectedBytes != null) {
                                    value =
                                        p.cumulativeBytesLoaded / expectedBytes;
                                  }
                                  return Align(
                                    child: CircularProgressIndicator(
                                      value: value,
                                      strokeWidth: 2,
                                      backgroundColor:
                                          Colors.white.withOpacity(0.12),
                                      color: const Color(0xFF141312),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stacktrace) =>
                                    const Icon(Icons.error),
                              ),
                            ),
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
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            widget.category,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color:
                                                  Colors.white.withOpacity(0.7),
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, top: 4),
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              '${state.links.length} Communites',
                                              style: TextStyle(
                                                fontFamily: 'Questrial',
                                                color: Colors.white
                                                    .withOpacity(0.4),
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                letterSpacing: 0.5,
                                                decorationColor: Colors.white
                                                    .withOpacity(0.75),
                                              ),
                                              overflow: TextOverflow.visible,
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
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          CreateGroupPage(
                                                            isFromProfilePage:
                                                                false,
                                                            preselectedCategory:
                                                                widget.category,
                                                            preselectedSocialType:
                                                                widget
                                                                    .socialType,
                                                          )),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFF1E1D1C),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          200.0),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Center(
                                                      child: Icon(
                                                    size: 24,
                                                    Icons.add,
                                                    color: Colors.white
                                                        .withOpacity(0.7),
                                                  )),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 12,
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                const String screen =
                                                    'CATEGORY';
                                                final data = {
                                                  "category": widget.category,
                                                  "categoryImageUrl":
                                                      widget.categoryImageUrl,
                                                  "socialType":
                                                      widget.socialType,
                                                };

                                                final uri = Uri(
                                                  scheme: 'https',
                                                  host: 'bliitz-655ea.web.app',
                                                  path: 'profile/$screen',
                                                  queryParameters: data,
                                                );

                                                await Share.share(
                                                    'Check out these ${widget.category} Links in Bliitz App: $uri');
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFF1E1D1C),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          200.0),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Center(
                                                    child: SvgPicture.asset(
                                                      'assets/icons/share.svg',
                                                      height: 24,
                                                      width: 24,
                                                      colorFilter:
                                                          ColorFilter.mode(
                                                        Colors.white
                                                            .withOpacity(0.7),
                                                        BlendMode.srcIn,
                                                      ),
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
                            final items = state.links;
                            return SingleGroupItem(
                              groupDetails: items[index],
                              isOwnersGroups: false,
                              isViewinginGroupInfo: false,
                            );
                          },
                          childCount: state.links.length,
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
                        if (widget.isFromDeepLink) {
                          context.pushReplacement('/home_screen');
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: AnimatedContainer(
                        curve: Curves.easeIn,
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: animateColor,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(500.0),
                          ),
                        ),
                        duration: const Duration(milliseconds: 250),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white54,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          } else {
            return const EmptyDataWidget();
          }
        },
      ),
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

const backgroundColor = Color(0xFF000000);
const fadedbackgroundColor = Color(0x80000000);
const primaryColor = Color(0xFFE4C145);
const fadedprimaryColor = Color(0xCCE4C145);
const semifadeprimaryColor = Color(0x80E4C145);
const extremefadeprimaryColor = Color(0x33E4C145);
const secondaryColor = Color(0xFF38E449);
const warningColor = Color(0xFFFF0000);
const fadedTextColor = Color(0xFF6B6363);
const fadedButtonColor = Color(0xFF717D72);
const extrafadedButtonColor = Color(0x33717D72);
const fadedCardColor = Color(0xFF161616);
const semifadedCardColor = Color(0xFF161616);
const extrafadedCardColor = Color(0xB3161616);

const ratioheight = 699;
const ratioWidth = 237;

getRatioHeight(input) {
  num heightRatio = input / ratioheight;
  return heightRatio;
}

getRatioWidth(input) {
  num widthRatio = input / ratioWidth;
  return widthRatio;
}

var titleOne = (
  fontSize: 25,
  fontWeight: FontWeight.w700,
  fontStyle: FontStyle.normal,
  color: Colors.white
);

var subtitleOne = (
  fontSize: 12,
  fontWeight: FontWeight.w400,
  fontStyle: FontStyle.normal,
  color: const Color(0xFF6B6363)
);

var subtitleTwo = (
  fontSize: 12,
  fontWeight: FontWeight.w400,
  fontStyle: FontStyle.normal,
  color: primaryColor
);

var subtitleThree = (
  fontSize: 12,
  fontWeight: FontWeight.w400,
  fontStyle: FontStyle.normal,
  color: Colors.white
);

class DrawSvg extends StatelessWidget {
  const DrawSvg(
      {super.key,
      required this.svgPath,
      required this.height,
      required this.width,
      this.color});
  final String svgPath;
  final num height;
  final num width;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * getRatioHeight(height),
      width: MediaQuery.of(context).size.width * getRatioWidth(width),
      child: SvgPicture.asset('assets/$svgPath.svg',
          color: color, fit: BoxFit.contain),
    );
  }
}

class SpacingBox extends StatelessWidget {
  const SpacingBox({super.key, required this.height});
  final num height;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * getRatioHeight(height),
    );
  }
}

void showSnackBarWithoutButton(BuildContext context, message, textColor) {
  final snackBar = SnackBar(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    duration: const Duration(seconds: 3),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(message,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
                color: textColor)),
      ],
    ),
    // backgroundColor: const Color(0xFF070606),
    behavior: SnackBarBehavior.floating,
    elevation: 0,
    margin: const EdgeInsets.only(
      left: 20,
      right: 20,
      bottom: 5,
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
