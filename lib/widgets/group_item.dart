// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks

import 'dart:math';
import 'dart:ui';

import 'package:bliitz/Features/HomeScreen/LinkPages/owner_link_info.dart';
import 'package:bliitz/Features/HomeScreen/LinkPages/link_info_page.dart';
import 'package:bliitz/Features/Payments/payment_plans_screen.dart';
import 'package:bliitz/services/actions_services.dart';
import 'package:bliitz/services/link_services.dart';
import 'package:bliitz/utils/check_internet.dart';
import 'package:bliitz/utils/misc.dart';
import 'package:bliitz/utils/smooth_transitions.dart' show CustomPageRoute;
import 'package:bliitz/utils/sound_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:octo_image/octo_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';

class SingleGroupItem extends StatefulWidget {
  const SingleGroupItem({
    super.key,
    required this.groupDetails,
    required this.isOwnersGroups,
    required this.isViewinginGroupInfo,
    required this.index,
    required this.navigationCount,
  });

  final Map<String, dynamic> groupDetails;
  final bool isOwnersGroups;
  final bool isViewinginGroupInfo;
  final int index;
  final int navigationCount;
  @override
  State<SingleGroupItem> createState() => _SingleGroupItemState();
}

class _SingleGroupItemState extends State<SingleGroupItem> {
  final ValueNotifier<bool> isFavoriteNotifier = ValueNotifier(false);
  final ValueNotifier<int> favoriteCountNotifier = ValueNotifier(0);
  final ValueNotifier<bool> _isPromoted = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _hasTrackedImpression = ValueNotifier(false);
  int subtractAndClampToZero(int original, int amountToSubtract) {
    return max(0, original - amountToSubtract);
  }

  void _checkIfFavorite() async {
    bool alreadyFavorite =
        await MiscImpl().isFavorite(widget.groupDetails['id']);
    isFavoriteNotifier.value = alreadyFavorite;
  }

  void onFavouriteTap() async {
    bool isConnected = await ConnectivityHelper.isConnected();
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: const Color(0xE601DE27).withOpacity(.5),
          content: const Text('No internet connection')));

      return;
    }
    if (ConnectivityHelper.isConnected() == true) {}
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

  @override
  void initState() {
    super.initState();

    if (widget.groupDetails['promoted']) {
      _isPromoted.value = true;
    }
    _checkIfFavorite();
    favoriteCountNotifier.value = widget.groupDetails['favourites'];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 24),
      child: VisibilityDetector(
        key: Key(widget.groupDetails['id']),
        onVisibilityChanged: (info) {
          if (!_hasTrackedImpression.value && info.visibleFraction > 0.5) {
            _hasTrackedImpression.value = true; // prevent duplicate tracking
            MiscImpl().trackLinkImpression(
                linkId: widget.groupDetails['id'],
                linkCreatorId: widget.groupDetails['createdBy']);
          }
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF141312),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: () {
                    // showGeneralDialog(
                    //   context: context,
                    //   barrierLabel: "ImageDialog",
                    //   barrierDismissible: true,
                    //   barrierColor: Colors.black.withOpacity(0.8),
                    //   transitionDuration: const Duration(milliseconds: 300),
                    //   pageBuilder: (_, __, ___) {
                    //     return HeroImageDialog(
                    //       imageUrl: widget.groupDetails['Profile Image'],
                    //       groupName: widget.groupDetails['Name'],
                    //       isOwnersGroups: widget.isOwnersGroups,
                    //       groupId: widget.groupDetails['id'],
                    //       isFavoriteNotifier: isFavoriteNotifier,
                    //       groupDetails: widget.groupDetails,
                    //       isViewinginGroupInfo: widget.isOwnersGroups,
                    //       index: widget.index,
                    //     );
                    //   },
                    //   transitionBuilder: (_, anim, __, child) {
                    //     return FadeTransition(
                    //       opacity: CurvedAnimation(
                    //           parent: anim, curve: Curves.easeInOut),
                    //       child: child,
                    //     );
                    //   },
                    // );

                    Navigator.push(
                      context,
                      PageRouteBuilder(
                          opaque: false,
                          barrierDismissible: true,
                          barrierColor: Colors.black.withOpacity(0.85),
                          transitionDuration: const Duration(milliseconds: 300),
                          pageBuilder: (_, __, ___) => HeroImageDialog(
                                imageUrl: widget.groupDetails['Profile Image'],
                                groupName: widget.groupDetails['Name'],
                                isOwnersGroups: widget.isOwnersGroups,
                                groupId: widget.groupDetails['id'],
                                isFavoriteNotifier: isFavoriteNotifier,
                                groupDetails: widget.groupDetails,
                                isViewinginGroupInfo:
                                    widget.isViewinginGroupInfo,
                                index: widget.index,
                                navigationCount: widget.navigationCount,
                              )),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: Hero(
                      tag: widget.navigationCount > 1
                          ? '1${widget.index}${widget.groupDetails['id']}'
                          : '${widget.index}${widget.groupDetails['id']}',
                      child: widget.groupDetails['Profile Image'] == ''
                          ? Container(
                              color: Colors.transparent,
                              width: 116,
                              height: 116,
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/icons/person.svg',
                                  height: 24,
                                  width: 24,
                                  colorFilter: ColorFilter.mode(
                                    Colors.white.withOpacity(.3),
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            )
                          : OctoImage(
                              width: 116,
                              height: 116,
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  widget.groupDetails['Profile Image']),
                              progressIndicatorBuilder: (context, p) {
                                double? value;
                                final expectedBytes = p?.expectedTotalBytes;
                                if (p != null && expectedBytes != null) {
                                  value =
                                      p.cumulativeBytesLoaded / expectedBytes;
                                }
                                return SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: Align(
                                    child: CircularProgressIndicator(
                                      value: value,
                                      strokeWidth: 2,
                                      backgroundColor:
                                          Colors.white.withOpacity(0.12),
                                      color: const Color(0xFF141312),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stacktrace) =>
                                  const Icon(Icons.error),
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 4,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.3),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            widget.groupDetails['Name'],
                                            style: TextStyle(
                                              fontFamily: 'Questrial',
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              letterSpacing: 0.25,
                                              height: 1.5,
                                              decorationColor:
                                                  Colors.transparent,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (widget
                                            .groupDetails['promoted']) ...[
                                          const SizedBox(
                                            width: 4,
                                          ),
                                          const Icon(
                                            Icons.verified,
                                            size: 18,
                                            color: Color(0xE601DE27),
                                          )
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Builder(builder: (context) {
                                return ValueListenableBuilder<int>(
                                    valueListenable: favoriteCountNotifier,
                                    builder: (context, favCount, child) {
                                      return Flexible(
                                        child: Text(
                                          '${favCount.toString()} favorites',
                                          style: TextStyle(
                                            fontFamily: 'Questrial',
                                            color:
                                                Colors.white.withOpacity(0.5),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            letterSpacing: 0.25,
                                            decorationColor:
                                                Colors.white.withOpacity(0.4),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    });
                              }),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 4),
                          child: Text(
                            widget.groupDetails['Description'],
                            style: TextStyle(
                              fontFamily: 'Questrial',
                              color: Colors.white.withOpacity(0.5),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              letterSpacing: 0.25,
                              decorationColor: Colors.white.withOpacity(0.4),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          height: 4,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, right: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              widget.isOwnersGroups
                                  ? const SizedBox.shrink()
                                  : ValueListenableBuilder<bool>(
                                      valueListenable: isFavoriteNotifier,
                                      builder: (context, isFavorite, _) {
                                        return GestureDetector(
                                          onTap: onFavouriteTap,
                                          child: Card(
                                            color: const Color(0xFF1E1D1C),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(200.0),
                                            ),
                                            elevation: 2,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Center(
                                                child: SvgPicture.asset(
                                                  isFavorite
                                                      ? 'assets/icons/hearty.svg'
                                                      : 'assets/icons/heart.svg',
                                                  height: 20,
                                                  width: 20,
                                                  colorFilter: isFavorite
                                                      ? const ColorFilter.mode(
                                                          Color(0xE601DE27),
                                                          BlendMode.srcIn,
                                                        )
                                                      : ColorFilter.mode(
                                                          Colors.white
                                                              .withOpacity(0.7),
                                                          BlendMode.srcIn,
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                              GestureDetector(
                                onTap: () async {
                                  const String screen = 'LINKINFO';
                                  final data = {
                                    "linkId": widget.groupDetails['id'],
                                    "userId": widget.groupDetails['createdBy'],
                                  };

                                  final uri = Uri(
                                    scheme: 'https',
                                    host: 'bliitz-655ea.web.app',
                                    path: 'profile/$screen',
                                    queryParameters: data,
                                  );

                                  await Share.share(
                                      'Check out this ${widget.groupDetails['Social']} ${widget.groupDetails['Link Type']} in Bliitz: $uri');
                                },
                                child: Card(
                                  color: const Color(0xFF1E1D1C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(200.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/icons/share.svg',
                                        height: 20,
                                        width: 20,
                                        colorFilter: ColorFilter.mode(
                                          Colors.white.withOpacity(0.7),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              ValueListenableBuilder<int>(
                                  valueListenable: favoriteCountNotifier,
                                  builder: (context, favCount, child) {
                                    return ValueListenableBuilder<bool>(
                                        valueListenable: isFavoriteNotifier,
                                        builder: (context, isFavorite, _) {
                                          return GestureDetector(
                                            onTap: () async {
                                              final updatedDetails =
                                                  widget.groupDetails;

                                              updatedDetails['favourites'] =
                                                  favCount;
                                              if (widget.isOwnersGroups) {
                                                Navigator.of(context)
                                                    .push(CustomPageRoute(
                                                        page: OwnerGroupInfo(
                                                  groupDetails: updatedDetails,
                                                  isFromDeepLink: false,
                                                )));
                                              } else {
                                                final updatedItem =
                                                    await Navigator.of(context)
                                                        .push(CustomPageRoute(
                                                            page:
                                                                GroupInfoScreen(
                                                  isFromDeepLink: false,
                                                  groupDetails: updatedDetails,
                                                  navigationCount: widget
                                                          .isViewinginGroupInfo
                                                      ? 2
                                                      : 1,
                                                )));
                                                if (updatedItem['linkId'] ==
                                                    widget.groupDetails['id']) {
                                                  favoriteCountNotifier.value =
                                                      updatedItem['favCount'];
                                                  isFavoriteNotifier.value =
                                                      updatedItem[
                                                          'isFavorited'];
                                                }
                                              }
                                            },
                                            child: Card(
                                              color: const Color(0xFF1E1D1C),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              ),
                                              elevation: 2,
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                                  child: Text(
                                                    'Open',
                                                    style: TextStyle(
                                                      fontFamily: 'Questrial',
                                                      color: Colors.white
                                                          .withOpacity(0.7),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12,
                                                      letterSpacing: 0.5,
                                                      height: 1.2,
                                                      decorationColor: Colors
                                                          .white
                                                          .withOpacity(0.75),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                  }),
                              ValueListenableBuilder<bool>(
                                  valueListenable: _isPromoted,
                                  builder: (context, promoted, child) {
                                    return GestureDetector(
                                      onTap: () async {
                                        if (widget.isOwnersGroups) {
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          var paymentPlanId =
                                              prefs.getString('paymentPlanId');
                                          if (paymentPlanId != null &&
                                              paymentPlanId.isNotEmpty) {
                                            await LinkServicesImpl()
                                                .alterLinkScore(
                                                    linkId: widget
                                                        .groupDetails['id'],
                                                    isIncrement: true,
                                                    planId: paymentPlanId);
                                            _isPromoted.value = true;
                                          } else {
                                            final updatedItem =
                                                await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PromoteScreen(
                                                        linkId: widget
                                                            .groupDetails['id'],
                                                        fromPage:
                                                            'LinkDetailsPage',
                                                      )),
                                            );

                                            if (updatedItem['hasPaid']) {
                                              _isPromoted.value = true;
                                            }
                                          }
                                        } else {
                                          MiscImpl().openLink(
                                            widget.groupDetails['Link'],
                                          );
                                        }
                                      },
                                      child: Card(
                                        color: widget.isOwnersGroups && promoted
                                            ? const Color(0xFF1E1D1C)
                                            : const Color(0xE601DE27),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                        ),
                                        elevation: 2,
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            child: Text(
                                              !widget.isOwnersGroups
                                                  ? 'Join'
                                                  : widget.isOwnersGroups &&
                                                          promoted
                                                      ? 'Promoted'
                                                      : 'Promote',
                                              style: TextStyle(
                                                  fontFamily: 'Questrial',
                                                  color: widget
                                                              .isOwnersGroups &&
                                                          promoted
                                                      ? const Color(0xE601DE27)
                                                      : Colors.black87,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                  letterSpacing: 0.5,
                                                  height: 1.2,
                                                  decorationColor:
                                                      Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ],
                          ),
                        ),
                        Container(
                          height: 4,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HeroImageDialog extends StatefulWidget {
  const HeroImageDialog(
      {super.key,
      required this.imageUrl,
      required this.groupName,
      required this.isOwnersGroups,
      required this.groupId,
      required this.isFavoriteNotifier,
      required this.groupDetails,
      required this.isViewinginGroupInfo,
      required this.index,
      required this.navigationCount});
  final String imageUrl;
  final String groupId;
  final String groupName;
  final bool isOwnersGroups;
  final bool isViewinginGroupInfo;
  final Map<String, dynamic> groupDetails;
  final ValueNotifier<bool> isFavoriteNotifier;
  final int index;
  final int navigationCount;
  @override
  // ignore: library_private_types_in_public_api
  _HeroImageDialogState createState() => _HeroImageDialogState();
}

class _HeroImageDialogState extends State<HeroImageDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Scaffold(
          backgroundColor: Colors.black.withOpacity(0.5),
          body: Center(
            child: GestureDetector(
              onTap: () async {
                await _controller.forward();
                await _controller.reverse();
              },
              child: Hero(
                tag: widget.navigationCount > 1
                    ? '1${widget.index}${widget.groupId}'
                    : '${widget.index}${widget.groupId}',
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 288,
                        height: 288,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.white.withOpacity(0.12), width: 0),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: widget.imageUrl == ''
                                  ? Container(
                                      color: const Color(0xFF141312),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          'assets/icons/person.svg',
                                          height: 56,
                                          width: 56,
                                          colorFilter: ColorFilter.mode(
                                            Colors.white.withOpacity(.3),
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(0),
                                      child: OctoImage(
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                            widget.imageUrl),
                                        progressIndicatorBuilder: (context, p) {
                                          double? value;
                                          final expectedBytes =
                                              p?.expectedTotalBytes;
                                          if (p != null &&
                                              expectedBytes != null) {
                                            value = p.cumulativeBytesLoaded /
                                                expectedBytes;
                                          }
                                          return SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: Align(
                                              child: CircularProgressIndicator(
                                                value: value,
                                                strokeWidth: 2,
                                                backgroundColor: Colors.white
                                                    .withOpacity(0.12),
                                                color: const Color(0xFF141312),
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stacktrace) =>
                                                const Icon(Icons.error),
                                      ),
                                    ),
                            ),
                            Container(
                              width: 288,
                              height: 40,
                              color: Colors.black54,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, right: 8),
                                child: Row(
                                  children: [
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              widget.groupName,
                                              style: TextStyle(
                                                fontFamily: 'Questrial',
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                letterSpacing: 0.25,
                                                height: 1.5,
                                                decorationColor:
                                                    Colors.transparent,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (widget
                                              .groupDetails['promoted']) ...[
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            const Icon(
                                              Icons.verified,
                                              size: 18,
                                              color: Color(0xE601DE27),
                                            )
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: 288,
                                height: 45,
                                color: Colors.black54,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    IntrinsicHeight(
                                      child: ValueListenableBuilder<bool>(
                                          valueListenable:
                                              widget.isFavoriteNotifier,
                                          builder: (context, isFavorite, _) {
                                            return GestureDetector(
                                              onTap: () {
                                                if (widget.isOwnersGroups) {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            OwnerGroupInfo(
                                                              groupDetails: widget
                                                                  .groupDetails,
                                                              isFromDeepLink:
                                                                  false,
                                                            )),
                                                  );
                                                } else {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            GroupInfoScreen(
                                                              isFromDeepLink:
                                                                  false,
                                                              groupDetails: widget
                                                                  .groupDetails,
                                                              navigationCount:
                                                                  widget.isViewinginGroupInfo
                                                                      ? 2
                                                                      : 1,
                                                            )),
                                                  );
                                                }
                                              },
                                              child: Card(
                                                color: const Color(0xE601DE27),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.0),
                                                ),
                                                elevation: 2,
                                                child: const Center(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 16,
                                                            vertical: 8),
                                                    child: Text(
                                                      'Open',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Questrial',
                                                          color: Colors.black87,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 12,
                                                          letterSpacing: 0.5,
                                                          height: 1.2,
                                                          decorationColor:
                                                              Colors.black),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
