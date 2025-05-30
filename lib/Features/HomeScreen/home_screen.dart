import 'package:bliitz/Features/HomeScreen/Explore/cubit/get_feed_links_cubit.dart';
import 'package:bliitz/Features/HomeScreen/LinkPages/cubit/get_owners_links.dart';
import 'package:bliitz/Features/HomeScreen/Profile/cubit/get_pofile_details_cubit.dart';
import 'package:bliitz/Features/HomeScreen/Explore/explore_page.dart';
import 'package:bliitz/Features/HomeScreen/Profile/user_profile_page.dart';
import 'package:bliitz/Features/HomeScreen/Search/search_page.dart';
import 'package:bliitz/services/payment_services.dart';
import 'package:bliitz/widgets/bottom_nav_bar.dart';
import 'package:bliitz/services/link_services.dart';
import 'package:bliitz/utils/_index.dart';
import 'package:bliitz/utils/misc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _pageNotifier = ValueNotifier<int>(0);

  final ValueNotifier<bool> isPopupOpen = ValueNotifier(false);

  final ValueNotifier<List<Map<String, dynamic>>> gridItems = ValueNotifier([]);

  final ValueNotifier<List<bool>> imageLoadedNotifier =
      ValueNotifier<List<bool>>(
    List.generate(16, (index) => false),
  );

  getSearchSuggestions() async {
    var backendSearchSuggestions =
        await LinkServicesImpl().fetchSearchSuggestions();
    MiscImpl().deletedSearchSuggestion();
    for (var i in backendSearchSuggestions) {
      await MiscImpl().saveSearchSuggestions(groupDetails: i);
    }
  }

  getCategories() async {
    var localCategories = await MiscImpl().fetchLocalCategoryCounts();

    gridItems.value = localCategories;
  }

  initStoreInfo() async {
    await PaymentServicesImpl().initStoreInfo();

    await PaymentServicesImpl().getActivePurchases();
  }

  @override
  void initState() {
    super.initState();

    initStoreInfo();

    _pageNotifier.addListener(() {
      _pageController.jumpToPage(_pageNotifier.value);
    });
    context.read<GetLinksCubit>().getLinks('Explore', false);
    final profileCubit = context.read<GetProfileDetailsCubit>();
    final linksCubit = context.read<GetOwnersLinksCubit>();

    profileCubit.stream.listen((state) {
      if (state is GetProfileDetailsStateLoaded) {
        linksCubit.getLinks();
      }
    });

    profileCubit.getProfileDetails(true);
    getSearchSuggestions();
    getCategories();
  }

  @override
  void dispose() {
    imageLoadedNotifier.dispose();
    _pageController.dispose();
    _pageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView(
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              _pageNotifier.value = index;
            },
            controller: _pageController,
            children: [
              ExplorePage(
                socialMedia: MiscImpl().getSocialNames(),
                isPopupOpen: isPopupOpen,
              ),
              ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: gridItems,
                  builder: (context, items, child) {
                    return SearchPage(
                      socialMedia: MiscImpl().getSocialNames(),
                      gridItems: items,
                      isPopupOpen: isPopupOpen,
                    );
                  }),
              ProfilePage(
                isPopupOpen: isPopupOpen,
              )
            ],
          ),
          BottomNavBar(pageNotifier: _pageNotifier),
          ValueListenableBuilder<bool>(
              valueListenable: isPopupOpen,
              builder: (context, popupOpen, child) {
                return !popupOpen
                    ? const SizedBox.shrink()
                    : Positioned.fill(
                        child: GestureDetector(
                        onTap: () {
                          isPopupOpen.value = false;
                        },
                        child: Container(
                          color: Colors.black54,
                        ),
                      ));
              }),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              height: Adapt.padTopH(),
              width: Adapt.screenW(),
              color: const Color(0xFF141312),
            ),
          ),
        ],
      ),
    );
  }
}
