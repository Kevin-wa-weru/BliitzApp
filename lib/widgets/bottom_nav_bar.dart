import 'package:bliitz/Features/HomeScreen/Profile/cubit/get_pofile_details_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_svg/svg.dart';
import 'package:octo_image/octo_image.dart';

class BottomNavBar extends StatelessWidget {
  final ValueNotifier<int> pageNotifier;
  const BottomNavBar({
    super.key,
    required this.pageNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF141312),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32.0),
            topRight: Radius.circular(32.0),
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 56, right: 56, top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ValueListenableBuilder<int>(
                      valueListenable: pageNotifier,
                      builder: (context, selectedIndex, child) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/home.svg',
                              height: 24,
                              width: 24,
                              colorFilter: selectedIndex == 0
                                  ? const ColorFilter.mode(
                                      Colors.green,
                                      BlendMode.srcIn,
                                    )
                                  : ColorFilter.mode(
                                      Colors.white.withOpacity(0.7),
                                      BlendMode.srcIn,
                                    ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              'Home',
                              style: TextStyle(
                                color: selectedIndex == 0
                                    ? Colors.green
                                    : Colors.white.withOpacity(0.7),
                                fontFamily: 'Questrial',
                                fontWeight: FontWeight.w300,
                                fontSize: 10,
                                letterSpacing: 0.5,
                                height: 1.2,
                                decorationColor: Colors.white.withOpacity(0.75),
                              ),
                            )
                          ],
                        );
                      }),
                  ValueListenableBuilder<int>(
                      valueListenable: pageNotifier,
                      builder: (context, selectedIndex, child) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/search.svg',
                              height: 24,
                              width: 24,
                              colorFilter: selectedIndex == 1
                                  ? const ColorFilter.mode(
                                      Colors.green,
                                      BlendMode.srcIn,
                                    )
                                  : ColorFilter.mode(
                                      Colors.white.withOpacity(0.7),
                                      BlendMode.srcIn,
                                    ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              'Search',
                              style: TextStyle(
                                color: selectedIndex == 1
                                    ? Colors.green
                                    : Colors.white.withOpacity(0.8),
                                fontFamily: 'Questrial',
                                fontWeight: FontWeight.w300,
                                fontSize: 10,
                                letterSpacing: 0.5,
                                height: 1.2,
                                decorationColor: Colors.white.withOpacity(0.75),
                              ),
                            )
                          ],
                        );
                      }),
                  ValueListenableBuilder<int>(
                      valueListenable: pageNotifier,
                      builder: (context, selectedIndex, child) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BlocBuilder<GetProfileDetailsCubit,
                                GetProfileDetailsState>(
                              builder: (context, state) {
                                if (state is GetProfileDetailsStateLoaded) {
                                  if (state.imageUrl == null) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        color: const Color(0xFF333333),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            'assets/icons/person.svg',
                                            height: 12,
                                            width: 12,
                                            colorFilter: ColorFilter.mode(
                                              Colors.white.withOpacity(.3),
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: OctoImage(
                                        width: 24,
                                        height: 24,
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
                                              color: const Color(0xFF01de27),
                                              backgroundColor: Colors.grey,
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stacktrace) =>
                                                const Icon(Icons.error),
                                      ),
                                    );
                                  }
                                } else {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      color: const Color(0xFF333333),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          'assets/icons/person.svg',
                                          height: 12,
                                          width: 12,
                                          colorFilter: ColorFilter.mode(
                                            Colors.white.withOpacity(.3),
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              'Profile',
                              style: TextStyle(
                                color: selectedIndex == 2
                                    ? Colors.green
                                    : Colors.white.withOpacity(0.8),
                                fontFamily: 'Questrial',
                                fontWeight: FontWeight.w300,
                                fontSize: 10,
                                letterSpacing: 0.5,
                                height: 1.2,
                                decorationColor: Colors.white.withOpacity(0.75),
                              ),
                            )
                          ],
                        );
                      }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 44, right: 44, top: 4),
              child: Container(
                height: 56,
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        pageNotifier.value = 0;
                      },
                      child: Container(
                        height: 56,
                        width: 56,
                        color: Colors.transparent,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        pageNotifier.value = 1;
                      },
                      child: Container(
                          height: 56, width: 56, color: Colors.transparent),
                    ),
                    GestureDetector(
                      onTap: () {
                        pageNotifier.value = 2;
                      },
                      child: Container(
                          height: 56, width: 56, color: Colors.transparent),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
