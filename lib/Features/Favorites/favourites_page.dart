import 'package:bliitz/Features/Favorites/cubit/get_favorites_links_cubit.dart';
import 'package:bliitz/widgets/group_item.dart';
import 'package:bliitz/utils/_index.dart';
import 'package:bliitz/utils/misc.dart';
import 'package:bliitz/widgets/custom_loader.dart';
import 'package:bliitz/widgets/empty_data_widget.dart';
import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImageProvider;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:octo_image/octo_image.dart';
import 'package:share_plus/share_plus.dart';

class LikedGroups extends StatefulWidget {
  const LikedGroups({
    super.key,
    required this.userId,
    required this.isFromDeepLink,
  });
  final String userId;
  final bool isFromDeepLink;
  @override
  State<LikedGroups> createState() => _LikedGroupsState();
}

class _LikedGroupsState extends State<LikedGroups> {
  final ValueNotifier<bool> isPopupOpen = ValueNotifier<bool>(false);
  final ValueNotifier<String> selectedOption = ValueNotifier<String>('All');

  @override
  void initState() {
    super.initState();

    context.read<GetFovoritedLinksCubit>().getFavourites(
        social: 'All Socials', isFilter: false, userId: widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (!widget.isFromDeepLink) {
                            Navigator.pop(context);
                          } else {
                            context.pushReplacement('/home_screen');
                          }
                        },
                        child: Container(
                          height: Adapt.px(80),
                          width: Adapt.px(80),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(100.0),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white.withOpacity(0.5),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
            BlocConsumer<GetFovoritedLinksCubit, GetFovoritedLinksState>(
              buildWhen: (previous, current) {
                return current is GetFovoritedLinksStateLoaded &&
                        !current.isFilter! ||
                    current is GetFovoritedLinksStateLoading &&
                        !current.isFilter!;

                // 👈 only rebuild if it matches!
              },
              listener: (context, state) {},
              builder: (context, state) {
                if (state is GetFovoritedLinksStateInitial) {
                  return Column(
                    children: [
                      SizedBox(height: Adapt.screenH() * .33),
                      const EqualizerLoader(
                        color: Color(0xCC01DE27),
                      ),
                    ],
                  );
                }
                if (state is GetFovoritedLinksStateLoading) {
                  return Column(
                    children: [
                      SizedBox(height: Adapt.screenH() * .33),
                      const EqualizerLoader(
                        color: Color(0xCC01DE27),
                      ),
                    ],
                  );
                }

                if (state is GetFovoritedLinksStateLoaded) {
                  if (state.links.isEmpty) {
                    return Column(
                      children: [
                        SizedBox(height: Adapt.screenH() * .33),
                        const EmptyDataWidget(),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: OctoImage(
                                  width: 172,
                                  height: 172,
                                  fit: BoxFit.cover,
                                  image: CachedNetworkImageProvider(
                                      state.links.first['Profile Image']),
                                  progressIndicatorBuilder: (context, p) {
                                    double? value;
                                    final expectedBytes = p?.expectedTotalBytes;
                                    if (p != null && expectedBytes != null) {
                                      value = p.cumulativeBytesLoaded /
                                          expectedBytes;
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
                              const SizedBox(
                                height: 16,
                              ),
                              const Center(
                                child: Text(
                                  'Favourites',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Color(0xE601DE27),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  '${state.links.length} Communities',
                                  style: TextStyle(
                                    fontFamily: 'Questrial',
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    letterSpacing: 0.25,
                                    height: 1.5,
                                    decorationColor:
                                        Colors.white.withOpacity(0.75),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  PopupMenuButton<String>(
                                    offset: const Offset(0, -20),
                                    icon: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E1D1C),
                                        borderRadius:
                                            BorderRadius.circular(200.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 16),
                                        child: Center(
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/icons/filter_list.svg',
                                                height: 24,
                                                width: 24,
                                                colorFilter: ColorFilter.mode(
                                                  Colors.white.withOpacity(0.7),
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Socials',
                                                style: TextStyle(
                                                  fontFamily: 'Questrial',
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                  letterSpacing: 0.5,
                                                  height: 1.2,
                                                  decorationColor: Colors.white
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    onSelected: (value) {
                                      selectedOption.value = value;

                                      context
                                          .read<GetFovoritedLinksCubit>()
                                          .getFavourites(
                                              social: value,
                                              isFilter: true,
                                              userId: widget.userId);
                                    },
                                    onOpened: () {
                                      isPopupOpen.value = true;
                                    },
                                    onCanceled: () {
                                      isPopupOpen.value = false;
                                    },
                                    itemBuilder: (context) {
                                      final socialList = [
                                        {'name': 'All Socials'},
                                        ...MiscImpl().getSocialNames(),
                                      ];

                                      return [
                                        const PopupMenuItem<String>(
                                          value: 'Socials',
                                          height: 24,
                                          child: Center(
                                            child: Text(
                                              'Socials',
                                              style: TextStyle(
                                                fontFamily: 'Questrial',
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                height: 1.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                        ...socialList.map((social) {
                                          return PopupMenuItem<String>(
                                            value: social['name'],
                                            height: 24,
                                            child: ValueListenableBuilder<
                                                    String>(
                                                valueListenable: selectedOption,
                                                builder:
                                                    (context, valuee, child) {
                                                  return Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        social['name'],
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Questrial',
                                                          color: Colors.white
                                                              .withOpacity(0.8),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                          letterSpacing: 0.25,
                                                          height: 1.5,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      CustomRadioButton(
                                                        isSelected: valuee ==
                                                                social['name']
                                                            ? true
                                                            : false,
                                                      ),
                                                    ],
                                                  );
                                                }),
                                          );
                                        }),
                                      ];
                                    },
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      const String screen = 'FAVORITE';
                                      final data = {
                                        "userId": widget.userId,
                                      };

                                      final uri = Uri(
                                        scheme: 'https',
                                        host: 'bliitz-655ea.web.app',
                                        path: 'profile/$screen',
                                        queryParameters: data,
                                      );
                                      await Share.share(
                                          'Check out these ${FirebaseAuth.instance.currentUser!.displayName ?? 'This user\'s'} Favorited Links in Bliitz: $uri');
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E1D1C),
                                        borderRadius:
                                            BorderRadius.circular(200.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 16),
                                        child: Center(
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/icons/share.svg',
                                                height: 24,
                                                width: 24,
                                                colorFilter: ColorFilter.mode(
                                                  Colors.white.withOpacity(0.7),
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                'Share',
                                                style: TextStyle(
                                                  fontFamily: 'Questrial',
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                  letterSpacing: 0.5,
                                                  height: 1.2,
                                                  decorationColor: Colors.white
                                                      .withOpacity(0.7),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                            ],
                          ),
                        ),
                        BlocConsumer<GetFovoritedLinksCubit,
                            GetFovoritedLinksState>(
                          buildWhen: (previous, current) {
                            return current is GetFovoritedLinksStateLoaded &&
                                    current.isFilter! ||
                                current is GetFovoritedLinksStateLoading &&
                                    current.isFilter!;

                            // 👈 only rebuild if it matches!
                          },
                          listener: (context, state) {},
                          builder: (context, state) {
                            if (state is GetFovoritedLinksStateLoaded) {
                              if (state.links.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.only(top: 40.0),
                                  child: EmptyDataWidget(),
                                );
                              }

                              return Column(
                                  children: state.links.reversed
                                      .map((e) => SingleGroupItem(
                                            groupDetails: e,
                                            isOwnersGroups: false,
                                            isViewinginGroupInfo: false,
                                            index: state.links.indexOf(e),
                                            navigationCount: 1,
                                          ))
                                      .toList());
                            }

                            if (state is GetFovoritedLinksStateLoading) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 40.0),
                                child: EqualizerLoader(
                                  color: Color(0xCC01DE27),
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ],
                    );
                  }
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CustomRadioButton extends StatelessWidget {
  final bool isSelected;
  final double size;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback? onTap;

  const CustomRadioButton({
    super.key,
    required this.isSelected,
    this.size = 15.0,
    this.selectedColor = const Color(0xE601DE27),
    this.unselectedColor = Colors.grey,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: isSelected ? selectedColor : unselectedColor, width: 2),
          color: Colors.transparent,
        ),
        child: isSelected
            ? Center(
                child: Container(
                  width: size * 0.4,
                  height: size * 0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedColor,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
