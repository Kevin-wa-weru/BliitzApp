// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:bliitz/Features/Payments/payment_plans_screen.dart';
import 'package:bliitz/Features/Policy%20Documents/about_us_page.dart';
import 'package:bliitz/Features/Authentication/new_login.dart';
import 'package:bliitz/Features/HomeScreen/Profile/cubit/get_pofile_details_cubit.dart';
import 'package:bliitz/Features/HomeScreen/Profile/edit_user_profile.dart';
import 'package:bliitz/Features/HomeScreen/Profile/send_notifications_admin_page.dart';
import 'package:bliitz/Features/Support%20&%20Report/support.dart';
import 'package:bliitz/Features/Policy%20Documents/privacy_policy_page.dart';
import 'package:bliitz/services/auth_services.dart';
import 'package:bliitz/Features/Policy%20Documents/terms_condtions_page.dart';
import 'package:bliitz/utils/_index.dart';
import 'package:bliitz/utils/check_internet.dart';
import 'package:bliitz/utils/misc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:octo_image/octo_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Account extends StatefulWidget {
  const Account(
      {super.key,
      required this.profileUrl,
      required this.userName,
      required this.aboutUser,
      this.isVerfied,
      required this.isAdmin});
  final String? profileUrl;
  final String userName;
  final String? aboutUser;
  final bool? isVerfied;
  final bool isAdmin;
  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final ValueNotifier<List<String>> _tileItems =
      ValueNotifier<List<String>>([]);

  checkIfHasPaid(List<String> items) async {
    final prefs = await SharedPreferences.getInstance();
    var paymentPlanId = prefs.getString('paymentPlanId');

    if (paymentPlanId != null && paymentPlanId.isNotEmpty) {
      var planTitle = MiscImpl().resolvePlanTitle(planId: paymentPlanId);

      items.add('Manage Pay Plans - $planTitle');
    }

    _tileItems.value = items;
  }

  @override
  void initState() {
    super.initState();

    context
        .read<GetProfileDetailsCubit>()
        .getProfileWithoutBio(widget.aboutUser, widget.isVerfied!, true);

    if (widget.isAdmin) {
      final List<String> items = MiscImpl().getAccountList();
      items.add('Send Notifications');
      checkIfHasPaid(items);
    } else {
      final List<String> items = MiscImpl().getAccountList();

      checkIfHasPaid(items);
    }
  }

  onDissmis() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
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
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        'Menu',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 300),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const SupportPage(),
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
                    child: Opacity(
                      opacity: .9,
                      child: SvgPicture.asset(
                        'assets/icons/support.svg',
                        height: 24,
                        width: 24,
                        color: Colors.white.withOpacity(0.7),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF292929),
                      border: Border.all(
                        color: Colors.transparent,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                width: 72,
                              ),
                              BlocBuilder<GetProfileDetailsCubit,
                                  GetProfileDetailsState>(
                                buildWhen: (previous, current) {
                                  return current
                                              is GetProfileDetailsStateLoaded &&
                                          current.isOwnerProfile! ||
                                      current is GetProfileDetailsStateLoading &&
                                          current.isOwnerProfile;

                                  // 👈 only rebuild if it matches!
                                },
                                builder: (context, state) {
                                  if (state is GetProfileDetailsStateLoaded) {
                                    return Text(
                                      state.userName!,
                                      style: TextStyle(
                                        fontFamily: 'Questrial',
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        letterSpacing: 0.25,
                                        height: 1.5,
                                        decorationColor:
                                            Colors.white.withOpacity(0.75),
                                      ),
                                    );
                                  } else {
                                    return Text(
                                      widget.userName,
                                      style: TextStyle(
                                        fontFamily: 'Questrial',
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        letterSpacing: 0.25,
                                        height: 1.5,
                                        decorationColor:
                                            Colors.white.withOpacity(0.75),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    transitionDuration:
                                        const Duration(milliseconds: 300),
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        EditProfile(
                                      userName: widget.userName,
                                      profileUrl: widget.profileUrl,
                                      aboutUser: widget.aboutUser,
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
                                  color: const Color(0xCC01DE27),
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                child: Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Questrial',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                    height: 1.2,
                                    decorationColor:
                                        Colors.white.withOpacity(0.75),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Transform.translate(
                      offset: const Offset(0, 13),
                      child: BlocBuilder<GetProfileDetailsCubit,
                          GetProfileDetailsState>(
                        buildWhen: (previous, current) {
                          return current is GetProfileDetailsStateLoaded &&
                                  current.isOwnerProfile! ||
                              current is GetProfileDetailsStateLoading &&
                                  current.isOwnerProfile;

                          // 👈 only rebuild if it matches!
                        },
                        builder: (context, state) {
                          if (state is GetProfileDetailsStateLoaded) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: state.imageUrl == null
                                  ? Container(
                                      color: const Color(0xFF333333),
                                      width: 56,
                                      height: 56,
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
                                      width: 56,
                                      height: 56,
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
                                    ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ValueListenableBuilder<List<String>>(
                valueListenable: _tileItems,
                builder: (context, items, _) {
                  return Column(
                      children: items
                          .map((e) => SingleAccountItem(
                                title: e,
                                tileItemsNotifier: _tileItems,
                                items: items,
                                onDismiss: () {
                                  setState(() {});
                                },
                              ))
                          .toList());
                })
          ],
        ),
      ),
    );
  }
}

class SingleAccountItem extends StatelessWidget {
  SingleAccountItem({
    super.key,
    required this.title,
    required this.tileItemsNotifier,
    required this.items,
    required this.onDismiss,
  });
  final String title;
  final ValueNotifier<List<String>> tileItemsNotifier;
  final List<String> items;
  final VoidCallback onDismiss;

  final ValueNotifier<int> planTitle = ValueNotifier<int>(0);

  void showCustomCupertinoDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onDismiss,
  ) {
    final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
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
                    CupertinoDialogAction(
                      onPressed: () async {
                        if (title == 'Log Out?') {
                          bool isConnected =
                              await ConnectivityHelper.isConnected();
                          if (!isConnected) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor:
                                    const Color(0xE601DE27).withOpacity(.5),
                                content: const Text('No internet connection')));

                            return;
                          }
                          isLoading.value = true;
                          bool isLoggedOut = await AuthServicesImpl().logOut();

                          if (isLoggedOut) {
                            isLoading.value = false;

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const SignIn()),
                            );
                          } else {
                            isLoading.value = false;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Logout failed, An Error Occurred')));
                          }
                        }

                        if (title == 'Delete Account?') {
                          bool isConnected =
                              await ConnectivityHelper.isConnected();
                          if (!isConnected) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor:
                                    const Color(0xE601DE27).withOpacity(.5),
                                content: const Text('No internet connection')));

                            return;
                          }

                          isLoading.value = true;
                          bool isDeleted =
                              await AuthServicesImpl().deleteUserAccount();

                          if (isDeleted) {
                            isLoading.value = false;

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const SignIn()),
                            );
                          } else {
                            isLoading.value = false;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Operation falied, An Error Occurred')));
                          }
                        }

                        if (title == 'Change Plan ?') {
                          onDismiss();
                        }
                      },
                      child: ValueListenableBuilder<bool>(
                          valueListenable: isLoading,
                          builder: (context, loading, _) {
                            if (loading) {
                              return const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xCC01DE27),
                                ),
                              );
                            } else {
                              return const Text(
                                "OK",
                                style: TextStyle(
                                    fontFamily: 'Questrial',
                                    color: Color(0xCC01DE27)), // Green accent
                              );
                            }
                          }),
                    ),
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    String getTextAfterHyphen(String input) {
      final parts = input.split('-');
      return parts.length > 1 ? parts.sublist(1).join('-').trim() : '';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () {
          if (title == 'Send Notifications') {
            Navigator.of(context).push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const SendNotifications(),
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
          }

          if (title == 'Privacy Policy') {
            Navigator.of(context).push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const PrivacyPoliciy(),
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
          }

          if (title == 'Terms of Service') {
            Navigator.of(context).push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const TermsAndConditions(),
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
          }

          if (title == 'About Us') {
            Navigator.of(context).push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const AboutUsScreen(),
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
          }

          if (title == 'Log Out') {
            showCustomCupertinoDialog(context, 'Log Out?',
                'Are you sure you want to log out?', () {});
          }

          if (title == 'Delete Account') {
            showCustomCupertinoDialog(context, 'Delete Account?',
                'Are you sure you want to Delete Account?', () {});
          }
          if (title.contains('Manage Pay Plans')) {
            showCustomCupertinoDialog(context, 'Change Plan ?',
                'Are you sure you want to proceed to change plan?', () async {
              final prefs = await SharedPreferences.getInstance();
              var paymentPlanId = prefs.getString('paymentPlanId');

              final updatedItem = await Navigator.of(context).push(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      PromoteScreen(
                    fromPage: 'AccountsPage',
                    currentPlanId: paymentPlanId,
                  ),
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

              final itemCopy = items;

              itemCopy.removeWhere((item) => item.contains('Manage Pay Plans'));

              var planTitle =
                  MiscImpl().resolvePlanTitle(planId: updatedItem['planId']);

              itemCopy.add('Manage Pay Plans - $planTitle');

              tileItemsNotifier.value = itemCopy;

              onDismiss();

              Navigator.pop(context);
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: const Color(0xFF292929),
            border: Border.all(
              color: Colors.transparent,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: [
                      Text(
                        title.contains('Manage Pay Plans')
                            ? 'Manage Plans'
                            : title,
                        style: TextStyle(
                          fontFamily: 'Questrial',
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          letterSpacing: 0.25,
                          height: 1.5,
                          decorationColor: Colors.white.withOpacity(0.75),
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      title.contains('Manage Pay Plans')
                          ? Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xCC01DE27),
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  child: Text(
                                    getTextAfterHyphen(title),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Questrial',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                      height: 1.2,
                                      decorationColor:
                                          Colors.white.withOpacity(0.75),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                const Icon(
                                  Icons.verified,
                                  size: 18,
                                  color: Color(0xE601DE27),
                                )
                              ],
                            )
                          : const SizedBox.shrink()
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.75),
                    size: 16,
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
