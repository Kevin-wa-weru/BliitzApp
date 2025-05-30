import 'package:bliitz/Features/HomeScreen/LinkPages/create_link_page.dart';
import 'package:bliitz/Features/Payments/get_verified_screen.dart';
import 'package:bliitz/Features/HomeScreen/Profile/user_account_page.dart';
import 'package:bliitz/Features/HomeScreen/LinkPages/cubit/get_owners_links.dart';
import 'package:bliitz/Features/HomeScreen/Profile/cubit/get_pofile_details_cubit.dart';
import 'package:bliitz/widgets/custom_app_bar.dart';
import 'package:bliitz/widgets/group_item.dart';
import 'package:bliitz/services/auth_services.dart';
import 'package:bliitz/utils/_index.dart';
import 'package:bliitz/widgets/custom_loader.dart';
import 'package:bliitz/widgets/empty_data_widget.dart';
import 'package:bliitz/widgets/social_chips.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:octo_image/octo_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.isPopupOpen});
  final ValueNotifier<bool> isPopupOpen;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ValueNotifier<String> selectedSocial = ValueNotifier<String>('');
  final ValueNotifier<String> communitiesCount = ValueNotifier<String>('0');
  final ValueNotifier<String> favoritesCount = ValueNotifier<String>('0');
  final ValueNotifier<String> impressionsCount = ValueNotifier<String>('0');

  final ValueNotifier<bool> isAdmin = ValueNotifier<bool>(false);
  final userId = FirebaseAuth.instance.currentUser?.uid;

  checkIfAdmin() async {
    var response = await AuthServicesImpl().isUserAdmin();
    isAdmin.value = response;
  }

  getUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    var commCount = prefs.getString('totalCommunities');
    var favCount = prefs.getString('totalFavorites');
    var impCount = prefs.getString('totalImpressions');

    communitiesCount.value = commCount!;
    favoritesCount.value = favCount!;
    impressionsCount.value = impCount!;
  }

  @override
  void initState() {
    super.initState();
    checkIfAdmin();
    getUserStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          CustomAppBar(
            title: 'Profile',
            isPopupOpen: widget.isPopupOpen,
            currentPage: 'Profile',
          ),
          BlocConsumer<GetProfileDetailsCubit, GetProfileDetailsState>(
            buildWhen: (previous, current) {
              return current is GetProfileDetailsStateLoaded &&
                      current.isOwnerProfile! ||
                  current is GetProfileDetailsStateLoading &&
                      current.isOwnerProfile;

              // 👈 only rebuild if it matches!
            },
            listener: (context, state) {},
            builder: (context, state) {
              if (state is GetProfileDetailsStateLoaded) {
                return ValueListenableBuilder<bool>(
                    valueListenable: isAdmin,
                    builder: (context, admin, _) {
                      return Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Account(
                                              profileUrl: state.imageUrl,
                                              userName: state.userName!,
                                              aboutUser: state.aboutUser,
                                              isVerfied: state.isVerified,
                                              isAdmin: admin,
                                            )),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF141312),
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  child: Text(
                                    'Account',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontFamily: 'Questrial',
                                      fontWeight: FontWeight.w300,
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                      height: 1.2,
                                      decorationColor:
                                          Colors.white.withOpacity(0.75),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: state.imageUrl == null
                                    ? Container(
                                        color: const Color(0xFF141312),
                                        width: 156,
                                        height: 156,
                                        child: Center(
                                          child: SvgPicture.asset(
                                            'assets/icons/person.svg',
                                            height: 48,
                                            width: 48,
                                            colorFilter: ColorFilter.mode(
                                              Colors.white.withOpacity(.3),
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                      )
                                    : OctoImage(
                                        width: 156,
                                        height: 156,
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
                                              backgroundColor: Colors.white
                                                  .withOpacity(0.12),
                                              color: const Color(0xFF141312),
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stacktrace) =>
                                                const Icon(Icons.error),
                                      ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    state.userName!,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  state.isVerified!
                                      ? GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const GetVerified()),
                                            );
                                          },
                                          child: Icon(
                                            Icons.verified,
                                            size: 18,
                                            color:
                                                Colors.white.withOpacity(0.7),
                                          ),
                                        )
                                      : const SizedBox.shrink()
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, right: 16),
                                child: Center(
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    state.aboutUser != null
                                        ? state.aboutUser!
                                        : "✨ No bio yet ✨\n"
                                            "Share something to make your profile shine! ",
                                    style: TextStyle(
                                      color: state.aboutUser == null
                                          ? Colors.white.withOpacity(0.5)
                                          : Colors.white.withOpacity(0.5),
                                      fontFamily: 'Questrial',
                                      fontWeight: FontWeight.w300,
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                      height: 1.2,
                                      decorationColor:
                                          Colors.white.withOpacity(0.75),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'My Links',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const CreateGroupPage(
                                                      isFromProfilePage: true,
                                                    )),
                                          );
                                        },
                                        child: Card(
                                          color: const Color(0xE601DE27),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(200.0),
                                          ),
                                          elevation: 2,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xE601DE27),
                                              borderRadius:
                                                  BorderRadius.circular(200.0),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Center(
                                                child: SvgPicture.asset(
                                                  'assets/icons/add.svg',
                                                  height: 24,
                                                  width: 24,
                                                  colorFilter:
                                                      const ColorFilter.mode(
                                                    Colors.black,
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          const String screen = 'PROFILE';
                                          final data = {"userId": userId};

                                          final uri = Uri(
                                            scheme: 'https',
                                            host: 'bliitz-655ea.web.app',
                                            path: 'profile/$screen',
                                            queryParameters: data,
                                          );

                                          await Share.share(
                                              'Check out ${state.userName!}\'s Bliitz profile : $uri');
                                        },
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
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            ValueListenableBuilder<String>(
                                                valueListenable:
                                                    communitiesCount,
                                                builder:
                                                    (context, comCount, _) {
                                                  return Text(
                                                    comCount,
                                                    style: TextStyle(
                                                      fontFamily: 'Questrial',
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12,
                                                      letterSpacing: 0.25,
                                                      height: 1.5,
                                                      decorationColor: Colors
                                                          .white
                                                          .withOpacity(0.75),
                                                    ),
                                                  );
                                                }),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              'Communities',
                                              style: TextStyle(
                                                fontFamily: 'Questrial',
                                                color: Colors.white
                                                    .withOpacity(0.6),
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                letterSpacing: 0.25,
                                                height: 1.5,
                                                decorationColor: Colors.white
                                                    .withOpacity(0.75),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 16,
                                        ),
                                        Row(
                                          children: [
                                            ValueListenableBuilder<String>(
                                                valueListenable:
                                                    impressionsCount,
                                                builder:
                                                    (context, impCount, _) {
                                                  return Text(
                                                    impCount,
                                                    style: TextStyle(
                                                      fontFamily: 'Questrial',
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12,
                                                      letterSpacing: 0.25,
                                                      height: 1.5,
                                                      decorationColor: Colors
                                                          .white
                                                          .withOpacity(0.75),
                                                    ),
                                                  );
                                                }),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              'Impressions',
                                              style: TextStyle(
                                                fontFamily: 'Questrial',
                                                color: Colors.white
                                                    .withOpacity(0.6),
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                letterSpacing: 0.25,
                                                height: 1.5,
                                                decorationColor: Colors.white
                                                    .withOpacity(0.75),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 16,
                                        ),
                                        Row(
                                          children: [
                                            ValueListenableBuilder<String>(
                                                valueListenable: favoritesCount,
                                                builder:
                                                    (context, favCount, _) {
                                                  return Text(
                                                    favCount,
                                                    style: TextStyle(
                                                      fontFamily: 'Questrial',
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12,
                                                      letterSpacing: 0.25,
                                                      height: 1.5,
                                                      decorationColor: Colors
                                                          .white
                                                          .withOpacity(0.75),
                                                    ),
                                                  );
                                                }),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              'Favorites',
                                              style: TextStyle(
                                                fontFamily: 'Questrial',
                                                color: Colors.white
                                                    .withOpacity(0.6),
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                letterSpacing: 0.25,
                                                height: 1.5,
                                                decorationColor: Colors.white
                                                    .withOpacity(0.75),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  SocialChips(
                                    isProfilePage: true,
                                    selectedSocial: selectedSocial,
                                    currentPage: 'Profile',
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                ],
                              ),
                              BlocConsumer<GetOwnersLinksCubit,
                                  GetOwnersLinksState>(
                                listener: (context, state) {},
                                builder: (context, stateTwo) {
                                  if (stateTwo is GetOwnersLinksStateLoaded) {
                                    if (stateTwo.links.isEmpty) {
                                      return const Padding(
                                        padding: EdgeInsets.only(top: 16.0),
                                        child: EmptyDataWidget(),
                                      );
                                    } else {
                                      return Column(
                                        children: [
                                          Column(
                                            children:
                                                stateTwo.links.map((item) {
                                              return SingleGroupItem(
                                                groupDetails: item,
                                                isOwnersGroups: true,
                                                isViewinginGroupInfo: false,
                                              );
                                            }).toList(),
                                          ),
                                          const SizedBox(
                                            height: 32,
                                          ),
                                        ],
                                      );
                                    }
                                  }
                                  if (stateTwo is GetOwnersLinksStateLoading) {
                                    return const Padding(
                                      padding: EdgeInsets.only(top: 24.0),
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
                          ),
                        ),
                      );
                    });
              } else {
                return Column(
                  children: [
                    SizedBox(height: Adapt.screenH() * .27),
                    const EqualizerLoader(
                      color: Color(0xCC01DE27),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
