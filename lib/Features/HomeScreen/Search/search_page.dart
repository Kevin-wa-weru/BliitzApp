import 'package:bliitz/Features/HomeScreen/Search/detailed_search_page.dart';
import 'package:bliitz/Features/HomeScreen/CategoryPages/categroy_details.dart';
import 'package:bliitz/utils/_index.dart';
import 'package:bliitz/widgets/custom_app_bar.dart';
import 'package:bliitz/widgets/custom_loader.dart' show EqualizerLoader;
import 'package:bliitz/widgets/social_chips.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:octo_image/octo_image.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    required this.socialMedia,
    required this.gridItems,
    required this.isPopupOpen,
  });

  final List<Map<String, dynamic>> socialMedia;
  final List<Map<String, dynamic>> gridItems;
  final ValueNotifier<bool> isPopupOpen;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ValueNotifier<bool> _isLoaded = ValueNotifier<bool>(true);
  final ValueNotifier<String> selectedSocial =
      ValueNotifier<String>('Facebook');
  // Future<void> delayProcess() async {
  //   await Future.delayed(const Duration(seconds: 2));
  //   _isLoaded.value = true;
  // }

  @override
  void initState() {
    super.initState();
    // delayProcess();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppBar(
          title: 'Search',
          isPopupOpen: widget.isPopupOpen,
          currentPage: 'Explore',
        ),
        const SizedBox(
          height: 4,
        ),
        SocialChips(
          isProfilePage: false,
          selectedSocial: selectedSocial,
          currentPage: 'Search',
        ),
        const SizedBox(
          height: 8,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Row(
                        children: [
                          Text(
                            'Explore',
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
                    const SizedBox(
                      height: 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Quickly search for communities that match your interests',
                              style: TextStyle(
                                fontFamily: 'Questrial',
                                color: Colors.white.withOpacity(0.4),
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                letterSpacing: 0.5,
                                decorationColor: Colors.white.withOpacity(0.75),
                              ),
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 300),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const SearchCommunityScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
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
                    child: SizedBox(
                      height: 45,
                      child: TextField(
                        enabled: false,
                        cursorColor: const Color(0xCC01DE27),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search  communities...',
                          hintStyle: TextStyle(
                            fontFamily: 'Questrial',
                            color: Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            letterSpacing: 0.4,
                            height: 1.5,
                            decorationColor: Colors.white.withOpacity(0.75),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF141312),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: .2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(
                                top: 13.0, bottom: 13, right: 8, left: 16),
                            child: SvgPicture.asset(
                              'assets/icons/search.svg',
                              colorFilter: ColorFilter.mode(
                                Colors.white.withOpacity(0.5),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Row(
                        children: [
                          Text(
                            'Categories',
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
                    const SizedBox(
                      height: 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Find and join social media communities that match your interests',
                              style: TextStyle(
                                fontFamily: 'Questrial',
                                color: Colors.white.withOpacity(0.4),
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                letterSpacing: 0.5,
                                decorationColor: Colors.white.withOpacity(0.75),
                              ),
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                ValueListenableBuilder<bool>(
                    valueListenable: _isLoaded,
                    builder: (context, isloaded, child) {
                      if (!isloaded) {
                        return Column(
                          children: [
                            SizedBox(
                              height: Adapt.screenH() * .12,
                            ),
                            const EqualizerLoader(
                              color: Color(0xCC01DE27),
                            ),
                          ],
                        );
                      } else {
                        return MediaQuery.removePadding(
                          context: context,
                          removeBottom: true,
                          removeTop: true,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(bottom: 64.0),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 8.0,
                                // mainAxisSpacing: 4.0,
                                childAspectRatio: 2 / 3.4,
                              ),
                              itemCount: widget.gridItems.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      PageRouteBuilder(
                                        transitionDuration:
                                            const Duration(milliseconds: 300),
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            CategroyDetails(
                                          categoryImageUrl: widget
                                              .gridItems[index]['imageUrl'],
                                          category: widget.gridItems[index]
                                              ['name'],
                                          socialType: selectedSocial.value,
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
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 72,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF242322),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(16.0),
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Opacity(
                                            opacity: 1,
                                            child: OctoImage(
                                              fit: BoxFit.cover,
                                              image: CachedNetworkImageProvider(
                                                widget.gridItems[index]
                                                    ['imageUrl'],
                                              ),
                                              progressIndicatorBuilder:
                                                  (context, p) {
                                                double? value;
                                                final expectedBytes =
                                                    p?.expectedTotalBytes;
                                                if (p != null &&
                                                    expectedBytes != null) {
                                                  value =
                                                      p.cumulativeBytesLoaded /
                                                          expectedBytes;
                                                }
                                                return Align(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: value,
                                                    strokeWidth: 2,
                                                    backgroundColor: Colors
                                                        .white
                                                        .withOpacity(0.12),
                                                    color:
                                                        const Color(0xFF141312),
                                                  ),
                                                );
                                              },
                                              errorBuilder: (context, error,
                                                      stacktrace) =>
                                                  const Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    widget.gridItems[index]
                                                        ['name'],
                                                    style: TextStyle(
                                                      fontFamily: 'Questrial',
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                      letterSpacing: 0.25,
                                                      height: 1.5,
                                                      decorationColor: Colors
                                                          .white
                                                          .withOpacity(0.75),
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    '${widget.gridItems[index]['linkCount']} Communities',
                                                    style: TextStyle(
                                                      fontFamily: 'Questrial',
                                                      color: Colors.white
                                                          .withOpacity(0.5),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12,
                                                      letterSpacing: 0.25,
                                                      height: 1.5,
                                                      decorationColor: Colors
                                                          .white
                                                          .withOpacity(0.75),
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }
                    }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
