// ignore_for_file: use_build_context_synchronously

import 'package:bliitz/Features/HomeScreen/Explore/cubit/get_feed_links_cubit.dart';
import 'package:bliitz/Features/Favorites/favourites_page.dart'
    show LikedGroups;
import 'package:bliitz/Features/Notifications/notifications.dart';
import 'package:bliitz/utils/check_internet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

class CustomAppBar extends StatefulWidget {
  const CustomAppBar(
      {super.key,
      required this.title,
      required this.isPopupOpen,
      required this.currentPage});
  final String title;
  final ValueNotifier<bool> isPopupOpen;
  final String currentPage;
  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final ValueNotifier<String> selectedOption = ValueNotifier<String>('All');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 32,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Opacity(
                    opacity: .9,
                    child: SvgPicture.asset(
                      'assets/images/logo.svg',
                      height: 32,
                      width: 32,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 300),
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    LikedGroups(
                              userId: FirebaseAuth.instance.currentUser!.uid,
                              isFromDeepLink: false,
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
                      child: SvgPicture.asset(
                        'assets/icons/heart.svg',
                        height: 24,
                        width: 24,
                        colorFilter: ColorFilter.mode(
                          Colors.white.withOpacity(0.7),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        popupMenuTheme: PopupMenuThemeData(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(
                              color:
                                  Colors.white.withOpacity(0.5), // Border color
                              width: 1.2, // Border width
                            ),
                          ),
                          color: Colors.black, // Background color of the popup
                        ),
                      ),
                      child: PopupMenuButton<String>(
                        offset: const Offset(150, -20),
                        icon: Transform.rotate(
                          angle: -math.pi / 2,
                          child: SvgPicture.asset(
                            'assets/icons/filter.svg',
                            height: 24,
                            width: 24,
                            colorFilter: ColorFilter.mode(
                              Colors.white.withOpacity(0.7),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        onSelected: (value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Selected: $value')),
                          );
                        },
                        onOpened: () {
                          widget.isPopupOpen.value = true;
                        },
                        onCanceled: () {
                          widget.isPopupOpen.value = false;
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            height: 16,
                            child: Center(
                              child: Container(
                                color: Colors.transparent,
                                width: 120,
                                child: Center(
                                  child: Text(
                                    'Filters',
                                    style: TextStyle(
                                      fontFamily: 'Questrial',
                                      color: Colors.white.withOpacity(0.8),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      height: 1.5,
                                      decorationColor:
                                          Colors.white.withOpacity(0.75),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            height: 24,
                            child: ValueListenableBuilder<String>(
                                valueListenable: selectedOption,
                                builder: (context, value, child) {
                                  return Container(
                                    color: Colors.transparent,
                                    height: 32,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'All',
                                            style: TextStyle(
                                              fontFamily: 'Questrial',
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              letterSpacing: 0.25,
                                              height: 1.5,
                                              decorationColor: Colors.white
                                                  .withOpacity(0.75),
                                            ),
                                          ),
                                          Transform.scale(
                                            scale: 0.9,
                                            child: Radio<String>(
                                              value: 'All',
                                              groupValue: value,
                                              onChanged: (newValue) {
                                                selectedOption.value =
                                                    newValue!;
                                              },
                                              activeColor:
                                                  const Color(0xE601DE27),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          PopupMenuItem(
                            height: 24,
                            child: ValueListenableBuilder<String>(
                                valueListenable: selectedOption,
                                builder: (context, value, child) {
                                  return Container(
                                    color: Colors.transparent,
                                    height: 32,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Channels',
                                            style: TextStyle(
                                              fontFamily: 'Questrial',
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              letterSpacing: 0.25,
                                              height: 1.5,
                                              decorationColor: Colors.white
                                                  .withOpacity(0.75),
                                            ),
                                          ),
                                          Transform.scale(
                                            scale: 0.9,
                                            child: Radio<String>(
                                              value: 'Channels',
                                              groupValue: value,
                                              onChanged: (newValue) {
                                                selectedOption.value =
                                                    newValue!;
                                              },
                                              activeColor:
                                                  const Color(0xE601DE27),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          PopupMenuItem(
                            height: 24,
                            child: ValueListenableBuilder<String>(
                                valueListenable: selectedOption,
                                builder: (context, value, child) {
                                  return Container(
                                    color: Colors.transparent,
                                    height: 32,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Groups',
                                            style: TextStyle(
                                              fontFamily: 'Questrial',
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              letterSpacing: 0.25,
                                              height: 1.5,
                                              decorationColor: Colors.white
                                                  .withOpacity(0.75),
                                            ),
                                          ),
                                          Transform.scale(
                                            scale: 0.9,
                                            child: Radio<String>(
                                              value: 'Groups',
                                              groupValue: value,
                                              onChanged: (newValue) {
                                                selectedOption.value =
                                                    newValue!;
                                              },
                                              activeColor:
                                                  const Color(0xE601DE27),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          PopupMenuItem(
                            height: 24,
                            child: ValueListenableBuilder<String>(
                                valueListenable: selectedOption,
                                builder: (context, value, child) {
                                  return Container(
                                    color: Colors.transparent,
                                    height: 32,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Pages',
                                            style: TextStyle(
                                              fontFamily: 'Questrial',
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              letterSpacing: 0.25,
                                              height: 1.5,
                                              decorationColor: Colors.white
                                                  .withOpacity(0.75),
                                            ),
                                          ),
                                          Transform.scale(
                                            scale: 0.9,
                                            child: Radio<String>(
                                              value: 'Pages',
                                              groupValue: value,
                                              onChanged: (newValue) {
                                                selectedOption.value =
                                                    newValue!;
                                              },
                                              activeColor:
                                                  const Color(0xE601DE27),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          PopupMenuItem(
                            height: 56,
                            child: Center(
                              child: SizedBox(
                                height: 32,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xE601DE27),
                                  ),
                                  onPressed: () async {
                                    bool isConnected =
                                        await ConnectivityHelper.isConnected();
                                    if (!isConnected) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              backgroundColor:
                                                  const Color(0xE601DE27)
                                                      .withOpacity(.5),
                                              content: const Text(
                                                  'No internet connection')));
                                      Navigator.pop(context);
                                      return;
                                    }

                                    if (widget.currentPage == 'Explore') {
                                      Navigator.pop(context);
                                      widget.isPopupOpen.value = false;
                                      context
                                          .read<GetLinksCubit>()
                                          .filtertLinksByType(
                                              selectedOption.value,
                                              widget.currentPage,
                                              false);
                                    }
                                    if (widget.currentPage == 'Profile') {
                                      Navigator.pop(context);
                                      widget.isPopupOpen.value = false;
                                      context
                                          .read<GetLinksCubit>()
                                          .filtertLinksByType(
                                              selectedOption.value,
                                              widget.currentPage,
                                              false);
                                    }
                                  },
                                  child: const Text(
                                    'Apply',
                                    style: TextStyle(
                                      fontFamily: 'Questrial',
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                      height: 1.2,
                                      decorationColor: Colors.black,
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
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 300),
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const NotificationScreen(),
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
                      child: SvgPicture.asset(
                        'assets/icons/notifications.svg',
                        height: 24,
                        width: 24,
                        colorFilter: ColorFilter.mode(
                          Colors.white.withOpacity(0.7),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
