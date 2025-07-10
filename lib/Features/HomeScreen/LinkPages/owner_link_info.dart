// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:bliitz/Features/HomeScreen/LinkPages/edit_link_profile.dart';
import 'package:bliitz/Features/HomeScreen/LinkPages/cubit/get_link_details.dart';
import 'package:bliitz/Features/HomeScreen/LinkPages/cubit/get_owners_links.dart';
import 'package:bliitz/Features/Payments/payment_plans_screen.dart';
import 'package:bliitz/services/actions_services.dart';
import 'package:bliitz/services/link_services.dart';
import 'package:bliitz/utils/_index.dart';
import 'package:bliitz/utils/misc.dart';
import 'package:bliitz/utils/sound_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:octo_image/octo_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OwnerGroupInfo extends StatefulWidget {
  const OwnerGroupInfo(
      {super.key, required this.groupDetails, required this.isFromDeepLink});
  final Map<String, dynamic> groupDetails;
  final bool isFromDeepLink;
  @override
  State<OwnerGroupInfo> createState() => _OwnerGroupInfoState();
}

class _OwnerGroupInfoState extends State<OwnerGroupInfo> {
  final ValueNotifier<bool> isPopupOpen = ValueNotifier(false);
  final ValueNotifier<bool> isFavoriteNotifier = ValueNotifier(false);
  final ValueNotifier<bool> isLikedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> isDisLikedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> isDeletingGroup = ValueNotifier(false);
  final ValueNotifier<bool> _isPromoted = ValueNotifier<bool>(false);

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
    if (widget.groupDetails['promoted']) {
      _isPromoted.value = true;
    }
    _checkIfFavorite();
    _checkIfLiked();
    _checkIfDisLiked();
    favoriteCountNotifier.value = widget.groupDetails['favourites'];
    likeCountNotifier.value = widget.groupDetails['likes'];
    dislikeCountNotifier.value = widget.groupDetails['dislikes'];
    context.read<GetLinkDetailsCubit>().updateLinkDetails(
        widget.groupDetails['Profile Image'],
        widget.groupDetails['Name'],
        widget.groupDetails['Description']);
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
    void showCustomCupertinoDialog(
        BuildContext context, String title, String message) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoTheme(
          data: const CupertinoThemeData(
              brightness: Brightness.dark), // Ensures a dark theme
          child: Container(
            color: Colors.black.withOpacity(0.8), // Background color
            child: CupertinoAlertDialog(
              title: Text(
                title,
                style: const TextStyle(
                  color: Color(0xCC01DE27), // Green shade used in the UI
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Questrial',
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                        fontFamily: 'Questrial',
                        color: Colors.white70), // Softer white
                  ),
                ),
                ValueListenableBuilder<bool>(
                    valueListenable: isDeletingGroup,
                    builder: (context, loading, child) {
                      return CupertinoDialogAction(
                        onPressed: () async {
                          isDeletingGroup.value = true;
                          Future<bool> actionCompleted = LinkServicesImpl()
                              .deleteLink(widget.groupDetails['id']);
                          if (await actionCompleted) {
                            isDeletingGroup.value = false;
                            Navigator.pop(context);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Link has been deleted.')));
                            context
                                .read<GetOwnersLinksCubit>()
                                .getLinks('Facebook');
                          } else {
                            isDeletingGroup.value = false;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('An Error Ocurred')));
                          }
                        },
                        child: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xCC01DE27),
                                ),
                              )
                            : const Text(
                                "OK",
                                style: TextStyle(
                                    fontFamily: 'Questrial',
                                    color: Color(0xCC01DE27)), // Green accent
                              ),
                      );
                    }),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: Adapt.screenH() * .45,
                  child: Stack(
                    children: [
                      widget.groupDetails['Profile Image'] == null
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
                          : BlocBuilder<GetLinkDetailsCubit,
                              GetLinkDetailsState>(
                              builder: (context, state) {
                                if (state is GetLinkDetailsStateLoaded) {
                                  if (state.imageUrl != null &&
                                      state.imageUrl!.isNotEmpty) {
                                    return OctoImage(
                                      width: Adapt.screenW(),
                                      height: Adapt.screenH() * .5,
                                      fit: BoxFit.cover,
                                      image: CachedNetworkImageProvider(
                                          state.imageUrl!),
                                      progressIndicatorBuilder: (context, p) {
                                        double? value;
                                        final expectedBytes =
                                            p?.expectedTotalBytes;
                                        if (p != null &&
                                            expectedBytes != null) {
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
                                      errorBuilder:
                                          (context, error, stacktrace) =>
                                              const Icon(Icons.error),
                                    );
                                  } else {
                                    return Container(
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
                                    );
                                  }
                                } else {
                                  return Container(
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
                                  );
                                }
                              },
                            ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 8.0, top: Adapt.padTopH()),
                        child: Stack(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (!widget.isFromDeepLink) {
                                      Navigator.pop(context);
                                    } else {
                                      context.pushReplacement('/');
                                    }
                                  },
                                  child: Container(
                                    height: Adapt.px(80),
                                    width: Adapt.px(80),
                                    decoration: const BoxDecoration(
                                      color: Color(0x80141312),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(100.0),
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.arrow_back,
                                        color: Colors.white.withOpacity(0.8),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
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
                  height: 24,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1D1C),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 16.0, left: 16, top: 4, bottom: 4),
                          child: Column(
                            children: [
                              Container(
                                color: Colors.transparent,
                                height: 39,
                                child: Row(
                                  children: [
                                    Opacity(
                                      opacity: .9,
                                      child: SvgPicture.asset(
                                        'assets/icons/world.svg',
                                        height: 16,
                                        width: 16,
                                        colorFilter: ColorFilter.mode(
                                          Colors.white.withOpacity(0.8),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Transform.translate(
                                        offset: const Offset(0.0, 2),
                                        child: Text(
                                          'Impressions',
                                          style: TextStyle(
                                            fontFamily: 'Questrial',
                                            color:
                                                Colors.white.withOpacity(0.5),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            letterSpacing: 0.25,
                                            height: 1.5,
                                            decorationColor:
                                                Colors.white.withOpacity(0.75),
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                              Container(
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    Text(
                                      widget.groupDetails['totalImpressions']
                                          .toString(),
                                      style: TextStyle(
                                        fontFamily: 'Questrial',
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        letterSpacing: 0.25,
                                        height: 1.5,
                                        decorationColor:
                                            Colors.white.withOpacity(0.75),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Transform.translate(
                                        offset: const Offset(0.0, -2),
                                        child: Text(
                                          'Impressions',
                                          style: TextStyle(
                                            fontFamily: 'Questrial',
                                            color: Colors.transparent,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            letterSpacing: 0.25,
                                            height: 1.5,
                                            decorationColor:
                                                Colors.white.withOpacity(0.75),
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1D1C),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 16.0, left: 16, top: 4, bottom: 4),
                          child: Column(
                            children: [
                              Container(
                                color: Colors.transparent,
                                height: 39,
                                child: Row(
                                  children: [
                                    Opacity(
                                      opacity: .9,
                                      child: SvgPicture.asset(
                                        'assets/icons/user.svg',
                                        height: 16,
                                        width: 16,
                                        colorFilter: ColorFilter.mode(
                                          Colors.white.withOpacity(0.8),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Transform.translate(
                                        offset: const Offset(0.0, 2),
                                        child: Text(
                                          'Favorites',
                                          style: TextStyle(
                                            fontFamily: 'Questrial',
                                            color:
                                                Colors.white.withOpacity(0.5),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            letterSpacing: 0.25,
                                            height: 1.5,
                                            decorationColor:
                                                Colors.white.withOpacity(0.75),
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                              Container(
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    ValueListenableBuilder<int>(
                                        valueListenable: favoriteCountNotifier,
                                        builder: (context, favCount, child) {
                                          return Text(
                                            favCount.toString(),
                                            style: TextStyle(
                                              fontFamily: 'Questrial',
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              letterSpacing: 0.25,
                                              height: 1.5,
                                              decorationColor: Colors.white
                                                  .withOpacity(0.75),
                                            ),
                                          );
                                        }),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Transform.translate(
                                        offset: const Offset(0.0, -2),
                                        child: Text(
                                          'Favorites',
                                          style: TextStyle(
                                            fontFamily: 'Questrial',
                                            color: Colors.transparent,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            letterSpacing: 0.25,
                                            height: 1.5,
                                            decorationColor:
                                                Colors.white.withOpacity(0.75),
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ValueListenableBuilder<bool>(
                          valueListenable: _isPromoted,
                          builder: (context, promoted, child) {
                            if (!promoted) {
                              return GestureDetector(
                                onTap: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  var paymentPlanId =
                                      prefs.getString('paymentPlanId');
                                  if (paymentPlanId != null &&
                                      paymentPlanId.isNotEmpty) {
                                    await LinkServicesImpl().alterLinkScore(
                                        linkId: widget.groupDetails['id'],
                                        isIncrement: true,
                                        planId: paymentPlanId);
                                    _isPromoted.value = true;
                                  } else {
                                    final updatedItem =
                                        await Navigator.of(context).push(
                                      PageRouteBuilder(
                                        transitionDuration:
                                            const Duration(milliseconds: 300),
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            PromoteScreen(
                                          linkId: widget.groupDetails['id'],
                                          fromPage: 'LinkDetailsPage',
                                        ),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                        },
                                        opaque: true,
                                        barrierColor: Colors.black,
                                      ),
                                    );

                                    if (updatedItem['hasPaid']) {
                                      _isPromoted.value = true;
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xE601DE27),
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  child: const Text(
                                    'Promote',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontFamily: 'Questrial',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                      height: 1.2,
                                      decorationColor: Colors.black54,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: const Color(
                                      0xFF1E1D1C), // Green to show success/promoted
                                  borderRadius: BorderRadius.circular(25.0),
                                  // border: Border.all(
                                  //     color: const Color(0xE601DE27), width: .0),
                                ),
                                child: const Text(
                                  'Promoted',
                                  style: TextStyle(
                                    color: Color(0xE601DE27),
                                    fontFamily: 'Questrial',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                    height: 1.2,
                                    decorationColor: Colors.black54,
                                  ),
                                ),
                              );
                            }
                          }),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BlocBuilder<GetLinkDetailsCubit, GetLinkDetailsState>(
                        builder: (context, state) {
                          if (state is GetLinkDetailsStateLoaded) {
                            return InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    transitionDuration:
                                        const Duration(milliseconds: 300),
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        EditGroupInfo(
                                      groupName: state.linkName!,
                                      imageUrl: state.imageUrl,
                                      groupBio: state.aboutLink,
                                      groupId: widget.groupDetails['id'],
                                    ),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                    opaque: true,
                                    barrierColor: Colors.black,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xE601DE27),
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                child: const Text(
                                  'Edit profile',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontFamily: 'Questrial',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                    height: 1.2,
                                    decorationColor: Colors.black54,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditGroupInfo(
                                            groupName:
                                                widget.groupDetails['Name'],
                                            imageUrl: widget
                                                .groupDetails['Profile Image'],
                                            groupBio: widget
                                                .groupDetails['Description'],
                                            groupId: widget.groupDetails['id'],
                                          )),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xE601DE27),
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                child: const Text(
                                  'Edit profile',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontFamily: 'Questrial',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                    height: 1.2,
                                    decorationColor: Colors.black54,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
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
                                                var totalActvity =
                                                    likeCount.abs() +
                                                        dislikeCount.abs();
                                                var likeRatio =
                                                    likeCount.abs() * 100;
                                                return Text(
                                                  likeRatio == 0
                                                      ? '0 %'
                                                      : '${(likeRatio / totalActvity).round()}%',
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
                                                var totalActvity =
                                                    likeCount.abs() +
                                                        dislikeCount.abs();
                                                var dislikeRatio =
                                                    dislikeCount.abs() * 100;
                                                return Text(
                                                  dislikeRatio == 0
                                                      ? '0 %'
                                                      : '${(dislikeRatio / totalActvity).round()}%',
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
                  padding: const EdgeInsets.only(left: 18.0),
                  child: Row(
                    children: [
                      BlocBuilder<GetLinkDetailsCubit, GetLinkDetailsState>(
                        builder: (context, state) {
                          if (state is GetLinkDetailsStateLoaded) {
                            return Row(
                              children: [
                                Text(
                                  state.linkName!,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0,
                                    height: 1.4,
                                  ),
                                ),
                                widget.groupDetails['promoted']
                                    ? const SizedBox(
                                        width: 8,
                                      )
                                    : const SizedBox.shrink(),
                                widget.groupDetails['promoted']
                                    ? const Icon(
                                        Icons.verified,
                                        size: 24,
                                        color: Color(0xE601DE27),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            );
                          } else {
                            return Row(
                              children: [
                                Text(
                                  widget.groupDetails['Name'],
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0,
                                    height: 1.4,
                                  ),
                                ),
                                widget.groupDetails['promoted']
                                    ? const SizedBox(
                                        width: 8,
                                      )
                                    : const SizedBox.shrink(),
                                widget.groupDetails['promoted']
                                    ? const Icon(
                                        Icons.verified,
                                        size: 24,
                                        color: Color(0xE601DE27),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: BlocBuilder<GetLinkDetailsCubit,
                            GetLinkDetailsState>(
                          builder: (context, state) {
                            if (state is GetLinkDetailsStateLoaded) {
                              return Text(
                                state.aboutLink!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontFamily: 'Questrial',
                                  fontWeight: FontWeight.w300,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                  height: 1.2,
                                  decorationColor:
                                      Colors.white.withOpacity(0.75),
                                ),
                              );
                            } else {
                              return Text(
                                widget.groupDetails['Description'],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontFamily: 'Questrial',
                                  fontWeight: FontWeight.w300,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                  height: 1.2,
                                  decorationColor:
                                      Colors.white.withOpacity(0.75),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                GestureDetector(
                  onTap: () {
                    showCustomCupertinoDialog(context, 'Delete Link?',
                        'Are you sure you want to delete this link?');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1D1C),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: 'Questrial',
                        fontWeight: FontWeight.w300,
                        fontSize: 12,
                        letterSpacing: 0.5,
                        height: 1.2,
                        decorationColor: Colors.white.withOpacity(0.75),
                      ),
                    ),
                  ),
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
