import 'package:bliitz/Features/Payments/get_verified_screen.dart';
import 'package:bliitz/Features/HomeScreen/Profile/cubit/get_profilie_visited_cubit.dart';
import 'package:bliitz/Features/HomeScreen/Profile/cubit/get_specific_user_links_cubit.dart';
import 'package:bliitz/Features/Support%20&%20Report/reporting_screen.dart';
import 'package:bliitz/widgets/group_item.dart';
import 'package:bliitz/utils/_index.dart';
import 'package:bliitz/widgets/empty_data_widget.dart';
import 'package:bliitz/widgets/profile_visit_skeleton.dart';
import 'package:bliitz/widgets/social_chips.dart' show SocialChips;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:octo_image/octo_image.dart';
import 'package:share_plus/share_plus.dart';

class ProfileVisitPage extends StatefulWidget {
  const ProfileVisitPage(
      {super.key,
      required this.isPopupOpen,
      required this.creatorId,
      required this.isFromDeepLink});
  final ValueNotifier<bool> isPopupOpen;
  final String creatorId;
  final bool isFromDeepLink;
  @override
  State<ProfileVisitPage> createState() => _ProfileVisitPageState();
}

class _ProfileVisitPageState extends State<ProfileVisitPage> {
  final ValueNotifier<String> selectedSocial = ValueNotifier<String>('');
  final ValueNotifier<String> communitiesCount = ValueNotifier<String>('0');
  @override
  void initState() {
    super.initState();

    context
        .read<GetVisitedProfileDetailsCubit>()
        .getProfileDetails(widget.creatorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          if (widget.isFromDeepLink) {
                            context.pushReplacement('/home_screen');
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          height: Adapt.px(80),
                          width: Adapt.px(80),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.08),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(100.0),
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white60,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    widget.isFromDeepLink
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ReportScreen(
                                            reportedUserId: widget.creatorId,
                                          )),
                                );
                              },
                              child: Container(
                                height: Adapt.px(80),
                                width: Adapt.px(80),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.08),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(100.0),
                                  ),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icons/flag.svg',
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
            BlocConsumer<GetVisitedProfileDetailsCubit,
                GetVisitedProfileDetailsState>(
              listener: (context, state) {
                if (state is GetVisitedProfileDetailsStateLoaded) {
                  context
                      .read<GetSpecificUserLinksCubit>()
                      .getLinks(widget.creatorId);
                }
              },
              builder: (context, state) {
                if (state is GetVisitedProfileDetailsStateLoaded) {
                  //  return const ProfileVisitSkeleton();
                  return Column(
                    children: [
                      const SizedBox(
                        height: 24,
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
                                image:
                                    CachedNetworkImageProvider(state.imageUrl!),
                                progressIndicatorBuilder: (context, p) {
                                  double? value;
                                  final expectedBytes = p?.expectedTotalBytes;
                                  if (p != null && expectedBytes != null) {
                                    value =
                                        p.cumulativeBytesLoaded / expectedBytes;
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
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                )
                              : const SizedBox.shrink()
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16),
                        child: Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            state.aboutUser != null
                                ? state.aboutUser!
                                : "✨ No bio available ✨\n",
                            style: TextStyle(
                              color: state.aboutUser == null
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.white.withOpacity(0.5),
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
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Links',
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
                            onTap: () async {
                              await Share.share(
                                  'Check out ${state.userName!}\'s Bliitz profile : ${'https://bliitz-655ea.web.app/profile/${widget.creatorId}'}');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xE601DE27),
                                borderRadius: BorderRadius.circular(200.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icons/share.svg',
                                    height: 24,
                                    width: 24,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.black,
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  state.totalCommunities.toString(),
                                  style: TextStyle(
                                    fontFamily: 'Questrial',
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    letterSpacing: 0.25,
                                    height: 1.5,
                                    decorationColor:
                                        Colors.white.withOpacity(0.75),
                                  ),
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  'Communities',
                                  style: TextStyle(
                                    fontFamily: 'Questrial',
                                    color: Colors.white.withOpacity(0.6),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    letterSpacing: 0.25,
                                    height: 1.5,
                                    decorationColor:
                                        Colors.white.withOpacity(0.75),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Row(
                              children: [
                                Text(
                                  state.totalImpressions.toString(),
                                  style: TextStyle(
                                    fontFamily: 'Questrial',
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    letterSpacing: 0.25,
                                    height: 1.5,
                                    decorationColor:
                                        Colors.white.withOpacity(0.75),
                                  ),
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  'Impressions',
                                  style: TextStyle(
                                    fontFamily: 'Questrial',
                                    color: Colors.white.withOpacity(0.6),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    letterSpacing: 0.25,
                                    height: 1.5,
                                    decorationColor:
                                        Colors.white.withOpacity(0.75),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Row(
                              children: [
                                Text(
                                  state.totalFavs.toString(),
                                  style: TextStyle(
                                    fontFamily: 'Questrial',
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    letterSpacing: 0.25,
                                    height: 1.5,
                                    decorationColor:
                                        Colors.white.withOpacity(0.75),
                                  ),
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  'Favorites',
                                  style: TextStyle(
                                    fontFamily: 'Questrial',
                                    color: Colors.white.withOpacity(0.6),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    letterSpacing: 0.25,
                                    height: 1.5,
                                    decorationColor:
                                        Colors.white.withOpacity(0.75),
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
                        currentPage: 'Profile Visit',
                        creatorId: widget.creatorId,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      BlocConsumer<GetSpecificUserLinksCubit,
                          GetSpecificUserLinksState>(
                        listener: (context, state) {
                          if (state is GetSpecificUserLinksStateLoaded) {
                            communitiesCount.value =
                                state.links.length.toString();
                          }
                        },
                        builder: (context, stateTwo) {
                          if (stateTwo is GetSpecificUserLinksStateLoaded) {
                            if (stateTwo.links.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 24.0),
                                child: EmptyDataWidget(),
                              );
                            } else {
                              return Column(
                                children: [
                                  Column(
                                    children: stateTwo.links.map((item) {
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
                          if (stateTwo is GetSpecificUserLinksStateLoading) {
                            return const SingleGroupItemSkeleton();
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ],
                  );
                } else {
                  return const ProfileVisitSkeleton();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
