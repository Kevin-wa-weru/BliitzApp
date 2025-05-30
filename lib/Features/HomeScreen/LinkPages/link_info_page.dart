import 'dart:math';

import 'package:bliitz/Features/HomeScreen/LinkPages/cubit/get_might_like_links_cubit.dart';
import 'package:bliitz/Features/HomeScreen/Profile/pofile_visit_page.dart';
import 'package:bliitz/widgets/group_item.dart';
import 'package:bliitz/services/actions_services.dart';
import 'package:bliitz/utils/_index.dart';
import 'package:bliitz/utils/misc.dart';
import 'package:bliitz/utils/sound_player.dart';
import 'package:bliitz/widgets/empty_data_widget.dart';
import 'package:bliitz/widgets/profile_visit_skeleton.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:octo_image/octo_image.dart';
import 'package:share_plus/share_plus.dart';

class GroupInfoScreen extends StatefulWidget {
  const GroupInfoScreen(
      {super.key, required this.groupDetails, required this.isFromDeepLink});

  final Map<String, dynamic> groupDetails;
  final bool isFromDeepLink;
  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final ValueNotifier<bool> isPopupOpen = ValueNotifier(false);
  final ValueNotifier<bool> isFavoriteNotifier = ValueNotifier(false);
  final ValueNotifier<bool> isLikedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> isDisLikedNotifier = ValueNotifier(false);

  final ValueNotifier<int> favoriteCountNotifier = ValueNotifier(0);

  final ValueNotifier<int> likeCountNotifier = ValueNotifier(0);
  final ValueNotifier<int> dislikeCountNotifier = ValueNotifier(0);

  void _checkIfFavorite() async {
    bool alreadyFavorite =
        await MiscImpl().isFavorite(widget.groupDetails['id']);
    isFavoriteNotifier.value = alreadyFavorite;
  }

  void _checkIfLiked() async {
    bool alreadyLiked = await MiscImpl().isLikedLink(widget.groupDetails['id']);
    isLikedNotifier.value = alreadyLiked;
  }

  void _checkIfDisLiked() async {
    bool alreadyDisLiked =
        await MiscImpl().isDisLikedLink(widget.groupDetails['id']);
    isDisLikedNotifier.value = alreadyDisLiked;
  }

  int subtractAndClampToZero(int original, int amountToSubtract) {
    return max(0, original - amountToSubtract);
  }

  @override
  void initState() {
    super.initState();

    _checkIfFavorite();
    _checkIfLiked();
    _checkIfDisLiked();
    favoriteCountNotifier.value = widget.groupDetails['favourites'];
    likeCountNotifier.value = widget.groupDetails['likes'];
    dislikeCountNotifier.value = widget.groupDetails['dislikes'];

    context.read<GetMighLikeLinksCubit>().getLinks(widget.groupDetails);
  }

  void onFavouriteTap() async {
    bool alreadyFavorite =
        await MiscImpl().isFavorite(widget.groupDetails['id']);

    if (alreadyFavorite) {
      favoriteCountNotifier.value =
          subtractAndClampToZero(favoriteCountNotifier.value, 1);
      await MiscImpl().removeFavorite(widget.groupDetails['id']);
      bool isFavourite = await MiscImpl().isFavorite(widget.groupDetails['id']);
      isFavoriteNotifier.value = isFavourite;
      await ActionServicesImpl().removeFavorite(
        creatorId: widget.groupDetails['createdBy'],
        linkId: widget.groupDetails['id'],
      );
    } else {
      SoundPlayer.playClickSound();
      favoriteCountNotifier.value = favoriteCountNotifier.value + 1;
      await MiscImpl().addFavorite(widget.groupDetails['id']);
      bool isFavourite = await MiscImpl().isFavorite(widget.groupDetails['id']);
      isFavoriteNotifier.value = isFavourite;
      await ActionServicesImpl().addFavorite(
        creatorId: widget.groupDetails['createdBy'],
        linkId: widget.groupDetails['id'],
      );
    }
  }

  void onLikeTap() async {
    bool alreadyLiked = await MiscImpl().isLikedLink(widget.groupDetails['id']);
    bool alreadyDisLiked =
        await MiscImpl().isDisLikedLink(widget.groupDetails['id']);

    if (alreadyLiked) {
      likeCountNotifier.value =
          subtractAndClampToZero(likeCountNotifier.value, 1);
      await MiscImpl().removeLikedLink(widget.groupDetails['id']);
      bool isLiked = await MiscImpl().isLikedLink(widget.groupDetails['id']);
      isLikedNotifier.value = isLiked;
      await ActionServicesImpl().removeLikedLinks(widget.groupDetails['id']);
    }
    if (!alreadyLiked) {
      SoundPlayer.playClickSound();
      likeCountNotifier.value = likeCountNotifier.value + 1;
      await MiscImpl().addLikedLinks(widget.groupDetails['id']);
      bool isLiked = await MiscImpl().isLikedLink(widget.groupDetails['id']);
      isLikedNotifier.value = isLiked;
      if (alreadyDisLiked) {
        dislikeCountNotifier.value =
            subtractAndClampToZero(dislikeCountNotifier.value, 1);
        await MiscImpl().removeDisLikedLink(widget.groupDetails['id']);
        isDisLikedNotifier.value = false;
        await ActionServicesImpl()
            .removeDisLikedLinks(widget.groupDetails['id']);
      }
      await ActionServicesImpl().addLikedLinks(widget.groupDetails['id']);
    }
  }

  void onDisLikeTap() async {
    bool alreadyDisLiked =
        await MiscImpl().isDisLikedLink(widget.groupDetails['id']);
    bool alreadyLiked = await MiscImpl().isLikedLink(widget.groupDetails['id']);
    if (alreadyDisLiked) {
      dislikeCountNotifier.value =
          subtractAndClampToZero(dislikeCountNotifier.value, 1);
      await MiscImpl().removeDisLikedLink(widget.groupDetails['id']);
      bool isDisLiked =
          await MiscImpl().isDisLikedLink(widget.groupDetails['id']);
      isDisLikedNotifier.value = isDisLiked;
      await ActionServicesImpl().removeDisLikedLinks(widget.groupDetails['id']);
    } else {
      SoundPlayer.playClickSound();
      dislikeCountNotifier.value = dislikeCountNotifier.value + 1;
      await MiscImpl().addDisLikedLinks(widget.groupDetails['id']);
      bool isDisLiked =
          await MiscImpl().isDisLikedLink(widget.groupDetails['id']);
      isDisLikedNotifier.value = isDisLiked;

      if (alreadyLiked) {
        likeCountNotifier.value =
            subtractAndClampToZero(likeCountNotifier.value, 1);
        await MiscImpl().removeLikedLink(widget.groupDetails['id']);
        isLikedNotifier.value = false;
        await ActionServicesImpl().removeLikedLinks(widget.groupDetails['id']);
      }

      await ActionServicesImpl().addDisLikedLinks(widget.groupDetails['id']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Color(0xFF1E1D1C),
      // backgroundColor: const Color(0xFF141312),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Colors.transparent,
                  height: Adapt.screenH() * .45,
                  child: Stack(
                    children: [
                      Stack(
                        children: [
                          widget.groupDetails['Profile Image'] == ''
                              ? Container(
                                  width: Adapt.screenW(),
                                  height: Adapt.screenH() * .45,
                                  color: const Color(0xFF1E1D1C),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/icons/person.svg',
                                      height: 48,
                                      width: 48,
                                      colorFilter: ColorFilter.mode(
                                        Colors.white.withOpacity(0.5),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                )
                              : OctoImage(
                                  width: Adapt.screenW(),
                                  height: Adapt.screenH() * .45,
                                  fit: BoxFit.cover,
                                  image: CachedNetworkImageProvider(
                                      widget.groupDetails['Profile Image']),
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
                        ],
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 8.0, top: Adapt.padTopH()),
                        child: Stack(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ValueListenableBuilder<bool>(
                                    valueListenable: isFavoriteNotifier,
                                    builder: (context, isFavorited, _) {
                                      return ValueListenableBuilder<int>(
                                          valueListenable:
                                              favoriteCountNotifier,
                                          builder: (context, favCount, child) {
                                            return GestureDetector(
                                              onTap: () {
                                                if (widget.isFromDeepLink) {
                                                  context.pushReplacement('/');
                                                } else {
                                                  Navigator.pop(
                                                    context,
                                                    {
                                                      'linkId': widget
                                                          .groupDetails['id'],
                                                      'favCount': favCount,
                                                      'isFavorited': isFavorited
                                                    },
                                                  );
                                                }
                                              },
                                              child: Container(
                                                height: Adapt.px(80),
                                                width: Adapt.px(80),
                                                decoration: const BoxDecoration(
                                                  color: Color(0x80141312),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(100.0),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.arrow_back,
                                                    color: Colors.white
                                                        .withOpacity(0.8),
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            );
                                          });
                                    }),
                                Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: Text(
                                    widget.groupDetails['Link Type'],
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.5,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Row(
                        children: [
                          // This makes sure the text can shrink if needed
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.5),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.groupDetails['Name'],
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                if (widget.groupDetails['promoted']) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified,
                                    size: 24,
                                    color: Color(0xE601DE27),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 18.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileVisitPage(
                                isPopupOpen: isPopupOpen,
                                creatorId: widget.groupDetails['createdBy'],
                                isFromDeepLink: false,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: const Color(0xCC01DE27),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Visit',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Questrial',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                  height: 1.2,
                                  decorationColor:
                                      Colors.white.withOpacity(0.75),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 10, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          ValueListenableBuilder<bool>(
                              valueListenable: isFavoriteNotifier,
                              builder: (context, isFavorited, _) {
                                return Container(
                                  color: Colors.transparent,
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: onFavouriteTap,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1E1D1C),
                                            borderRadius:
                                                BorderRadius.circular(200.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Center(
                                              child: SvgPicture.asset(
                                                isFavorited
                                                    ? 'assets/icons/hearty.svg'
                                                    : 'assets/icons/heart.svg',
                                                height: 24,
                                                width: 24,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                  Color(0xCC01DE27),
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      ValueListenableBuilder<int>(
                                          valueListenable:
                                              favoriteCountNotifier,
                                          builder: (context, favCount, child) {
                                            return Text(
                                              favCount.toString(),
                                              style: TextStyle(
                                                fontFamily: 'Questrial',
                                                color: Colors.white
                                                    .withOpacity(0.6),
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                letterSpacing: 0.25,
                                                height: 1.5,
                                                decorationColor: Colors.white
                                                    .withOpacity(0.75),
                                              ),
                                            );
                                          })
                                    ],
                                  ),
                                );
                              }),
                        ],
                      ),
                      Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    ValueListenableBuilder<bool>(
                                        valueListenable: isLikedNotifier,
                                        builder: (context, isLiked, _) {
                                          return GestureDetector(
                                            onTap: onLikeTap,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1E1D1C),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        200.0),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    isLiked ? 9.0 : 8),
                                                child: Center(
                                                  child: SvgPicture.asset(
                                                    isLiked
                                                        ? 'assets/icons/like_filled.svg'
                                                        : 'assets/icons/like.svg',
                                                    height: isLiked ? 22 : 24,
                                                    width: isLiked ? 22 : 24,
                                                    colorFilter: isLiked
                                                        ? const ColorFilter
                                                            .mode(
                                                            Color(0xE601DE27),
                                                            BlendMode.srcIn,
                                                          )
                                                        : ColorFilter.mode(
                                                            Colors.white
                                                                .withOpacity(
                                                                    0.7),
                                                            BlendMode.srcIn,
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    ValueListenableBuilder<int>(
                                        valueListenable: dislikeCountNotifier,
                                        builder:
                                            (context, dislikeCount, child) {
                                          return ValueListenableBuilder<int>(
                                              valueListenable:
                                                  likeCountNotifier,
                                              builder:
                                                  (context, likeCount, child) {
                                                return Text(
                                                  likeCount <= 0
                                                      ? '0 %'
                                                      : '${(likeCount / (likeCount + dislikeCount) * 100).round()}%',
                                                  style: TextStyle(
                                                    fontFamily: 'Questrial',
                                                    color: Colors.white
                                                        .withOpacity(0.6),
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14,
                                                    letterSpacing: 0.25,
                                                    height: 1.5,
                                                    decorationColor: Colors
                                                        .white
                                                        .withOpacity(0.75),
                                                  ),
                                                );
                                              });
                                        })
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Column(
                            children: [
                              Container(
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    ValueListenableBuilder<bool>(
                                        valueListenable: isDisLikedNotifier,
                                        builder: (context, isDisLiked, _) {
                                          return GestureDetector(
                                            onTap: onDisLikeTap,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1E1D1C),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        200.0),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    isDisLiked ? 9.0 : 8),
                                                child: Center(
                                                  child: SvgPicture.asset(
                                                    isDisLiked
                                                        ? 'assets/icons/dislike_filled.svg'
                                                        : 'assets/icons/dislike.svg',
                                                    height:
                                                        isDisLiked ? 22 : 24,
                                                    width: isDisLiked ? 22 : 24,
                                                    colorFilter: isDisLiked
                                                        ? const ColorFilter
                                                            .mode(
                                                            Color(0xE601DE27),
                                                            BlendMode.srcIn,
                                                          )
                                                        : ColorFilter.mode(
                                                            Colors.white
                                                                .withOpacity(
                                                                    0.7),
                                                            BlendMode.srcIn,
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    ValueListenableBuilder<int>(
                                        valueListenable: likeCountNotifier,
                                        builder: (context, likeCount, child) {
                                          return ValueListenableBuilder<int>(
                                              valueListenable:
                                                  dislikeCountNotifier,
                                              builder: (context, dislikeCount,
                                                  child) {
                                                return Text(
                                                  dislikeCount <= 0
                                                      ? '0 %'
                                                      : '${(dislikeCount / (likeCount + dislikeCount) * 100).round()}%',
                                                  style: TextStyle(
                                                    fontFamily: 'Questrial',
                                                    color: Colors.white
                                                        .withOpacity(0.6),
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14,
                                                    letterSpacing: 0.25,
                                                    height: 1.5,
                                                    decorationColor: Colors
                                                        .white
                                                        .withOpacity(0.75),
                                                  ),
                                                );
                                              });
                                        })
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          GestureDetector(
                            onTap: () async {
                              await Share.share(
                                  'Check out this ${widget.groupDetails['Link Type']}: ${widget.groupDetails['Link']}');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1D1C),
                                borderRadius: BorderRadius.circular(200.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icons/share.svg',
                                    height: 24,
                                    width: 24,
                                    colorFilter: ColorFilter.mode(
                                      Colors.white.withOpacity(0.7),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Row(
                    children: [
                      Text(
                        'About',
                        style: TextStyle(
                          fontFamily: 'Questrial',
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: 0.25,
                          height: 1.5,
                          decorationColor: Colors.white.withOpacity(0.75),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.groupDetails['Description'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontFamily: 'Questrial',
                            fontWeight: FontWeight.w300,
                            fontSize: 12,
                            letterSpacing: 0.5,
                            height: 1.2,
                            decorationColor: Colors.white.withOpacity(0.75),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                IntrinsicWidth(
                  child: GestureDetector(
                    onTap: () {
                      MiscImpl().openLink(
                        widget.groupDetails['Link'],
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 26.0, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xCC01DE27),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Join',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Questrial',
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              letterSpacing: 0.5,
                              height: 1.2,
                              decorationColor: Colors.white.withOpacity(0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: Row(
                    children: [
                      Text(
                        'You may also like',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                BlocConsumer<GetMighLikeLinksCubit, GetMighLikeLinksState>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    if (state is GetMighLikeLinksStateLoaded) {
                      if (state.links.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 0.0),
                          child: EmptyDataWidget(),
                        );
                      }
                      return Column(
                          children: state.links
                              .map((e) => SingleGroupItem(
                                    groupDetails: e,
                                    isOwnersGroups: false,
                                    isViewinginGroupInfo: true,
                                  ))
                              .toList());
                    }

                    if (state is GetMighLikeLinksStateLoading) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 0.0),
                        child: SingleGroupItemSkeleton(
                          itemCount: [1, 2, 3, 4],
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              height: Adapt.padTopH(),
              width: Adapt.screenW(),
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
