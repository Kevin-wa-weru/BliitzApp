import 'package:bliitz/Features/HomeScreen/Explore/cubit/get_feed_links_cubit.dart';
import 'package:bliitz/Features/HomeScreen/LinkPages/cubit/get_owners_links.dart';
import 'package:bliitz/Features/HomeScreen/Profile/cubit/get_specific_user_links_cubit.dart';
import 'package:bliitz/utils/misc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class SocialChips extends StatefulWidget {
  const SocialChips({
    super.key,
    required this.isProfilePage,
    this.glowAnimation,
    required this.selectedSocial,
    required this.currentPage,
    this.creatorId,
  });
  final bool isProfilePage;
  final Animation<Color?>? glowAnimation;
  final ValueNotifier<String> selectedSocial;
  final String currentPage;
  final String? creatorId;

  @override
  State<SocialChips> createState() => _SocialChipsState();
}

class _SocialChipsState extends State<SocialChips> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          removeTop: true,
          child: Padding(
            // padding: EdgeInsets.symmetric(horizontal: isProfilePage ? 8 : 16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: MiscImpl()
                      .getSocialNames()
                      .map(
                        (e) => Padding(
                          padding: EdgeInsets.only(
                              right: e['name'] == 'We-chat' ? 14 : 8.0),
                          child: GestureDetector(
                            onTap: () {
                              widget.selectedSocial.value = e['name'];
                              if (widget.currentPage == 'Explore') {
                                context
                                    .read<GetLinksCubit>()
                                    .filtertLinksBySocial(
                                        widget.selectedSocial.value,
                                        widget.currentPage,
                                        false);
                              }
                              if (widget.currentPage == 'Profile') {
                                context
                                    .read<GetOwnersLinksCubit>()
                                    .filtertLinksBySocial(
                                      widget.selectedSocial.value,
                                    );
                              }

                              if (widget.currentPage == 'Profile Visit') {
                                context
                                    .read<GetSpecificUserLinksCubit>()
                                    .filtertLinksBySocial(
                                      widget.selectedSocial.value,
                                      widget.creatorId!,
                                    );
                              }
                            },
                            child: ValueListenableBuilder<String>(
                                valueListenable: widget.selectedSocial,
                                builder: (context, selected, _) {
                                  return widget.glowAnimation != null
                                      ? AnimatedBuilder(
                                          animation: widget.glowAnimation!,
                                          builder: (context, child) {
                                            return Container(
                                              height: 32.0,
                                              decoration: BoxDecoration(
                                                color: selected.isEmpty
                                                    ? widget
                                                        .glowAnimation!.value!
                                                    : selected == e['name']
                                                        ? const Color(
                                                            0xE601DE27)
                                                        : const Color(
                                                            0xFF141312),
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 2,
                                                    right: 9,
                                                    top: 8,
                                                    bottom: 8),
                                                child: Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                      e['iconPath'],
                                                      height: 32,
                                                      width: 32,
                                                      colorFilter:
                                                          ColorFilter.mode(
                                                        selected == e['name']
                                                            ? Colors.black87
                                                            : Colors.white,
                                                        BlendMode.srcIn,
                                                      ),
                                                    ),
                                                    Transform.translate(
                                                      offset: const Offset(
                                                          -2.0, 0.0),
                                                      child: Text(
                                                        e['name'],
                                                        style: TextStyle(
                                                          color: selected ==
                                                                  e['name']
                                                              ? Colors.black87
                                                              : Colors.white
                                                                  .withOpacity(
                                                                      0.8),
                                                          fontFamily:
                                                              'Questrial',
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          fontSize: 12,
                                                          letterSpacing: 0.5,
                                                          height: 1.2,
                                                          decorationColor:
                                                              selected ==
                                                                      e['name']
                                                                  ? Colors
                                                                      .black87
                                                                  : Colors.white
                                                                      .withOpacity(
                                                                          0.75),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          })
                                      : Container(
                                          height: 32.0,
                                          decoration: BoxDecoration(
                                            color: selected == e['name']
                                                ? const Color(0xE601DE27)
                                                : const Color(0xFF141312),
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 2,
                                                right: 9,
                                                top: 8,
                                                bottom: 8),
                                            child: Row(
                                              children: [
                                                SvgPicture.asset(
                                                  e['iconPath'],
                                                  height: 32,
                                                  width: 32,
                                                  colorFilter: ColorFilter.mode(
                                                    selected == e['name']
                                                        ? Colors.black87
                                                        : Colors.white,
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                                Transform.translate(
                                                  offset:
                                                      const Offset(-2.0, 0.0),
                                                  child: Text(
                                                    e['name'],
                                                    style: TextStyle(
                                                      color: selected ==
                                                              e['name']
                                                          ? Colors.black87
                                                          : Colors.white
                                                              .withOpacity(0.8),
                                                      fontFamily: 'Questrial',
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      fontSize: 12,
                                                      letterSpacing: 0.5,
                                                      height: 1.2,
                                                      decorationColor:
                                                          selected == e['name']
                                                              ? Colors.black87
                                                              : Colors.white
                                                                  .withOpacity(
                                                                      0.75),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                }),
                          ),
                        ),
                      )
                      .toList()),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(-4, 0),
          child: Container(
            height: 32.0,
            width: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black,
                  Colors.black.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 32.0,
              width: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Colors.black,
                    Colors.black.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
