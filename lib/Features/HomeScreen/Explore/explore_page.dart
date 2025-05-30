import 'package:bliitz/Features/HomeScreen/Explore/cubit/get_feed_links_cubit.dart';
import 'package:bliitz/widgets/custom_app_bar.dart';
import 'package:bliitz/widgets/group_item.dart';
import 'package:bliitz/utils/_index.dart';
import 'package:bliitz/widgets/custom_loader.dart' show EqualizerLoader;
import 'package:bliitz/widgets/empty_data_widget.dart';
import 'package:bliitz/widgets/social_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({
    super.key,
    required this.socialMedia,
    required this.isPopupOpen,
  });

  final List<Map<String, dynamic>> socialMedia;

  final ValueNotifier<bool> isPopupOpen;

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _isTitleVisible = ValueNotifier<bool>(true);
  final ValueNotifier<String> selectedSocial = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        // Scrolling up
        if (_isTitleVisible.value) {
          _isTitleVisible.value = false;
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        // Scrolling down
        if (!_isTitleVisible.value) {
          _isTitleVisible.value = true;
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _isTitleVisible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return Column(
      children: [
        CustomAppBar(
          title: 'Home',
          isPopupOpen: widget.isPopupOpen,
          currentPage: 'Explore',
        ),
        const SizedBox(
          height: 4,
        ),
        SocialChips(
          isProfilePage: false,
          selectedSocial: selectedSocial,
          currentPage: 'Explore',
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isTitleVisible,
                  builder: (context, isVisible, child) {
                    return AnimatedSize(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeInOut,
                      child: isVisible
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Suggested',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Explore our suggested picks curated just for you',
                                          style: TextStyle(
                                            fontFamily: 'Questrial',
                                            color:
                                                Colors.white.withOpacity(0.4),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            letterSpacing: 0.5,
                                            height: 1.5,
                                          ),
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    );
                  },
                ),
              ),
              BlocConsumer<GetLinksCubit, GetLinksState>(
                buildWhen: (previous, current) {
                  return current is GetLinksStateLoaded &&
                          current.currentPage == 'Explore' ||
                      current is GetLinksStateLoading;

                  // 👈 only rebuild if it matches!
                },
                listener: (context, state) {},
                builder: (context, state) {
                  if (state is GetLinksStateInitial) {
                    return ValueListenableBuilder<bool>(
                      valueListenable: _isTitleVisible,
                      builder: (context, isVisible, child) {
                        return AnimatedPositioned(
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeInOut,
                            top: isVisible ? 70 : 10,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Column(
                              children: [
                                SizedBox(height: Adapt.screenH() * .27),
                                const EqualizerLoader(
                                  color: Color(0xCC01DE27),
                                ),
                              ],
                            ));
                      },
                    );
                  }
                  if (state is GetLinksStateLoading) {
                    return ValueListenableBuilder<bool>(
                      valueListenable: _isTitleVisible,
                      builder: (context, isVisible, child) {
                        return AnimatedPositioned(
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeInOut,
                            top: isVisible ? 70 : 10,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Column(
                              children: [
                                SizedBox(height: Adapt.screenH() * .27),
                                const EqualizerLoader(
                                  color: Color(0xCC01DE27),
                                ),
                              ],
                            ));
                      },
                    );
                  }
                  if (state is GetLinksStateLoaded) {
                    if (state.links.isEmpty) {
                      return const EmptyDataWidget();
                    } else {
                      return ValueListenableBuilder<bool>(
                        valueListenable: _isTitleVisible,
                        builder: (context, isVisible, child) {
                          return AnimatedPositioned(
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeInOut,
                            top: isVisible
                                ? textScaleFactor > 1.0
                                    ? 70
                                    : 70
                                : 10,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: MediaQuery.removePadding(
                              context: context,
                              removeBottom: true,
                              removeTop: true,
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.only(bottom: 60.0),
                                itemBuilder: (BuildContext context, int index) {
                                  return SingleGroupItem(
                                    groupDetails: state.links[index],
                                    isOwnersGroups: false,
                                    isViewinginGroupInfo: false,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }
                  } else {
                    return const Center(
                      child: Text('Error getting links'),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
