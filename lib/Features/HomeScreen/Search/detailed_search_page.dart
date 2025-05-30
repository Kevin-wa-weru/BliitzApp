import 'package:bliitz/Features/HomeScreen/LinkPages/link_info_page.dart';
import 'package:bliitz/Features/HomeScreen/Search/cubit/get_search_results.dart';
import 'package:bliitz/Features/HomeScreen/LinkPages/owner_link_info.dart';
import 'package:bliitz/utils/misc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class SearchCommunityScreen extends StatefulWidget {
  const SearchCommunityScreen({super.key});

  @override
  State<SearchCommunityScreen> createState() => _SearchCommunityScreenState();
}

class _SearchCommunityScreenState extends State<SearchCommunityScreen> {
  final ValueNotifier<List<Map<String, dynamic>>> _recentSearches =
      ValueNotifier<List<Map<String, dynamic>>>([]);
  final ValueNotifier<List<Map<String, dynamic>>> _suggestedSearches =
      ValueNotifier<List<Map<String, dynamic>>>([]);
  final TextEditingController _searchController = TextEditingController();

  fetchSearchSuggestions() async {
    var suggestesSearches = await MiscImpl().fetchSearchSuggestions();
    var recentSearches = await MiscImpl().fetchSearchedLinks();

    _recentSearches.value = recentSearches;
    _suggestedSearches.value = suggestesSearches;
  }

  @override
  void initState() {
    super.initState();

    fetchSearchSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white.withOpacity(0.9),
          ),
          onPressed: () {
            Navigator.pop(context);
            context.read<GetSearchResultsCubit>().resetState();
          },
        ),
        title: Text(
          'Search for a Community',
          style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white.withOpacity(0.9),
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Flexible(
                  child: Text(
                    'Find and join the perfect community with just a search',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Questrial',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 45,
              child: TextField(
                autofocus: true,
                controller: _searchController,
                cursorColor: const Color(0xCC01DE27),
                onTap: () {},
                onChanged: (value) {
                  if (_searchController.text.isEmpty) {
                    context.read<GetSearchResultsCubit>().resetState();
                  } else {
                    context
                        .read<GetSearchResultsCubit>()
                        .getSearchResults(value);
                  }
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search communities...',
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
                    borderSide: const BorderSide(color: Colors.grey, width: .2),
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
            BlocBuilder<GetSearchResultsCubit, GetSearchResultsState>(
              builder: (context, state) {
                if (state is GetSearchResultsStateInitial) {
                  return Expanded(
                    child: ListView(
                      children: [
                        const SizedBox(height: 24),
                        ValueListenableBuilder<List<Map<String, dynamic>>>(
                            valueListenable: _recentSearches,
                            builder: (context, recents, child) {
                              if (recents.isEmpty) {
                                return const SizedBox.shrink();
                              } else {
                                return Column(
                                  children: [
                                    _buildSectionTitle('Recent Searches'),
                                    Column(
                                      children: recents
                                          .take(2)
                                          .map(
                                            (e) => _buildCommunityItem(
                                                verified: false,
                                                groupDetails: e),
                                          )
                                          .toList(),
                                    )
                                  ],
                                );
                              }
                            }),
                        const SizedBox(height: 24),
                        ValueListenableBuilder<List<Map<String, dynamic>>>(
                            valueListenable: _suggestedSearches,
                            builder: (context, suggested, child) {
                              if (suggested.isEmpty) {
                                return const SizedBox.shrink();
                              } else {
                                return Column(
                                  children: [
                                    _buildSectionTitle('Suggestions'),
                                    Column(
                                      children: suggested
                                          .take(10)
                                          .map(
                                            (e) => _buildCommunityItem(
                                                verified: false,
                                                groupDetails: e),
                                          )
                                          .toList(),
                                    )
                                  ],
                                );
                              }
                            }),
                      ],
                    ),
                  );
                }

                if (state is GetSearchResultsStateLoading) {
                  return Expanded(
                    child: ListView(
                      children: [
                        const SizedBox(height: 24),
                        _buildSectionTitleSkeleton(),
                        Column(
                            children: MiscImpl()
                                .getCategoryItems()
                                .map((e) => _buildCommunityItemSkeleton())
                                .toList())
                      ],
                    ),
                  );
                }

                if (state is GetSearchResultsStateLoaded) {
                  if (state.links.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Column(
                        children: [
                          Center(
                            child: SvgPicture.asset(
                              'assets/icons/sad.svg',
                              height: 24,
                              width: 24,
                              colorFilter: ColorFilter.mode(
                                Colors.white.withOpacity(0.4),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'No links found',
                                style: TextStyle(
                                  fontFamily: 'Questrial',
                                  color: Colors.white.withOpacity(0.5),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Expanded(
                      child: ListView(
                        children: [
                          const SizedBox(height: 24),
                          _buildSectionTitle('Search Results'),
                          Column(
                              children: state.links
                                  .map(
                                    (e) => _buildCommunityItem(
                                        verified: false, groupDetails: e),
                                  )
                                  .toList())
                        ],
                      ),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitleSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: const Color(0xFF141312),
              width: 160,
              height: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityItem(
      {required bool verified, required Map<String, dynamic> groupDetails}) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () {
          MiscImpl().saveRecentSearches(groupDetails: groupDetails);
          if (userId == groupDetails['createdBy']) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OwnerGroupInfo(
                        isFromDeepLink: false,
                        groupDetails: groupDetails,
                      )),
            );
          }

          if (userId != groupDetails['createdBy']) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GroupInfoScreen(
                        isFromDeepLink: false,
                        groupDetails: groupDetails,
                      )),
            );
          }
        },
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  '${groupDetails['Name']} - ${groupDetails['Link Type']}',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                if (verified)
                  const Icon(Icons.verified, color: Colors.green, size: 16),
              ],
            ),
            const SizedBox(
              height: 4,
            ),
            Row(
              children: [
                Text(
                  '${groupDetails['favourites'].toString()} Favorities',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityItemSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  color: const Color(0xFF141312),
                  width: 120,
                  height: 15,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  color: const Color(0xFF141312),
                  width: 90,
                  height: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
