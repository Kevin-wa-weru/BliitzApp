// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:bliitz/Features/Authentication/new_login.dart';
import 'package:bliitz/Features/HomeScreen/home_screen.dart';
import 'package:bliitz/services/actions_services.dart';
import 'package:bliitz/services/auth_services.dart';
import 'package:bliitz/utils/_index.dart';
import 'package:bliitz/utils/misc.dart';
import 'package:bliitz/utils/sound_player.dart';
import 'package:bliitz/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  ValueNotifier<int> resendCooldown = ValueNotifier<int>(30);
  Timer? _resendTimer;

  void startResendCooldown() {
    resendCooldown.value = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCooldown.value > 0) {
        resendCooldown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  // void showVerificationDialog(BuildContext context, String email) {
  //   final ValueNotifier<bool> showVerifyButton = ValueNotifier<bool>(false);
  //   final ValueNotifier<bool> showMessage = ValueNotifier(false);
  //   final ValueNotifier<String> extraMessage = ValueNotifier('');
  //   startResendCooldown();
  //   Future.delayed(const Duration(seconds: 0), () {
  //     showVerifyButton.value = true;
  //   });
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => BackdropFilter(
  //       filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
  //       child: WillPopScope(
  //         onWillPop: () async => false,
  //         child: AlertDialog(
  //           backgroundColor: Colors.black,
  //           title: Row(
  //             children: [
  //               Padding(
  //                 padding: const EdgeInsets.only(right: 16.0),
  //                 child: Icon(
  //                   Icons.email_outlined,
  //                   color: Colors.white.withOpacity(.8),
  //                 ),
  //               ),
  //               Text(
  //                 "Verify Your Email",
  //                 style: TextStyle(
  //                   color: Colors.white.withOpacity(.8),
  //                   fontWeight: FontWeight.w400,
  //                   fontFamily: 'Questrial',
  //                   letterSpacing: 0.3,
  //                   height: 1.5,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           content: SingleChildScrollView(
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min, // ⬅️ This is important
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 RichText(
  //                   text: TextSpan(
  //                     style: TextStyle(
  //                       color: Colors.white.withOpacity(.6),
  //                       fontWeight: FontWeight.w400,
  //                       fontFamily: 'Questrial',
  //                       letterSpacing: 0.3,
  //                       height: 1.5,
  //                     ),
  //                     children: [
  //                       const TextSpan(
  //                           text: "A verification link has been sent to "),
  //                       TextSpan(
  //                         text: email,
  //                         style: TextStyle(
  //                           color: const Color(0xFF01de27).withOpacity(.6),
  //                         ),
  //                       ),
  //                       const TextSpan(
  //                         text:
  //                             ". Please check your inbox and follow the instructions to verify your email.",
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 ValueListenableBuilder<String>(
  //                     valueListenable: extraMessage,
  //                     builder: (context, extraMsg, child) {
  //                       return ValueListenableBuilder<bool>(
  //                           valueListenable: showMessage,
  //                           builder: (context, shwMsg, child) {
  //                             return shwMsg
  //                                 ? const SizedBox.shrink()
  //                                 : Column(
  //                                     children: [
  //                                       const SizedBox(
  //                                         height: 8,
  //                                       ),
  //                                       Row(
  //                                         children: [
  //                                           TypewriterText(
  //                                             message: extraMsg,
  //                                             trigger: showMessage,
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ],
  //                                   );
  //                           });
  //                     })
  //               ],
  //             ),
  //           ),
  //           actions: [
  //             ValueListenableBuilder<bool>(
  //               valueListenable: showVerifyButton,
  //               builder: (context, value, _) {
  //                 return Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     if (value)
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.end,
  //                         children: [
  //                           TextButton(
  //                             onPressed: () async {
  //                               showMessage.value = true;
  //                               extraMessage.value = 'Checking...';

  //                               final isVerified = await AuthServicesImpl()
  //                                   .checkEmailVerified();

  //                               if (isVerified && mounted) {
  //                                 // context.pushReplacement('/home_screen');
  //                                 Navigator.pushReplacement(
  //                                   context,
  //                                   MaterialPageRoute(
  //                                       builder: (_) => const HomeScreen()),
  //                                 );
  //                               }
  //                               if (!isVerified) {
  //                                 showMessage.value = true;
  //                                 extraMessage.value =
  //                                     'Email has not yet been verified';
  //                               }
  //                             },
  //                             child: const Text(
  //                               "Click here once verified",
  //                               style: TextStyle(
  //                                 color: Color(0xFF01de27),
  //                                 fontWeight: FontWeight.w400,
  //                                 fontFamily: 'Questrial',
  //                                 letterSpacing: 0.3,
  //                                 height: 1.5,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     const SizedBox(
  //                       height: 8,
  //                     ),
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.end,
  //                       children: [
  //                         ValueListenableBuilder<int>(
  //                             valueListenable: resendCooldown,
  //                             builder: (context, value, _) {
  //                               final isDisabled = value > 0;
  //                               return GestureDetector(
  //                                 onTap: isDisabled
  //                                     ? null
  //                                     : () {
  //                                         AuthServicesImpl()
  //                                             .sendEmailVerification();
  //                                         startResendCooldown();
  //                                         showMessage.value = true;
  //                                         extraMessage.value =
  //                                             'Link has been resent.';
  //                                       },
  //                                 child: Container(
  //                                   decoration: BoxDecoration(
  //                                     color: isDisabled
  //                                         ? const Color(0xFF01de27)
  //                                             .withOpacity(.1)
  //                                         : const Color(0xFF01de27)
  //                                             .withOpacity(.2),
  //                                     borderRadius: BorderRadius.circular(25.0),
  //                                   ),
  //                                   child: Padding(
  //                                     padding: const EdgeInsets.symmetric(
  //                                         horizontal: 16.0, vertical: 8),
  //                                     child: Text(
  //                                       isDisabled
  //                                           ? 'Resend in $value sec'
  //                                           : "Resend link ",
  //                                       style: TextStyle(
  //                                         color: Colors.white.withOpacity(.6),
  //                                         fontWeight: FontWeight.w400,
  //                                         fontFamily: 'Questrial',
  //                                         letterSpacing: 0.3,
  //                                         height: 1.5,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ),
  //                               );
  //                             }),
  //                       ],
  //                     ),
  //                   ],
  //                 );
  //               },
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Future<String?> getSavedEmail() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('user_email');
  // }

  // Future<bool?> checkEmailVerification() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getBool('email_verified');
  // }

  // void loadEmail() async {
  //   final email = await getSavedEmail();
  //   final verification = await checkEmailVerification();
  //   print('Wakaal ${email} ${verification}');
  //   if (email != null) {
  //     if (!verification!) {
  //       bool isConnected = await ConnectivityHelper.isConnected();

  //       if (!isConnected) {
  //         // Show error message if no internet connection
  //         showDialog(
  //           context: context,
  //           builder: (_) => AlertDialog(
  //             backgroundColor: Colors.black,
  //             title: Text(
  //               "No Internet Connection",
  //               style: TextStyle(
  //                 color: Colors.white.withOpacity(.8),
  //                 fontWeight: FontWeight.w400,
  //                 fontFamily: 'Questrial',
  //                 letterSpacing: 0.3,
  //                 height: 1.5,
  //               ),
  //             ),
  //             content: Text(
  //               "Please check your internet connection and try again.",
  //               style: TextStyle(
  //                 color: Colors.white.withOpacity(.6),
  //                 fontWeight: FontWeight.w400,
  //                 fontFamily: 'Questrial',
  //                 letterSpacing: 0.3,
  //                 height: 1.5,
  //               ),
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () {
  //                   // context.pop()
  //                   Navigator.pop(context);
  //                 },
  //                 child: const Text("OK"),
  //               ),
  //             ],
  //           ),
  //         );
  //         return;
  //       }
  //       final user = FirebaseAuth.instance.currentUser;

  //       if (user != null) {
  //         await FirebaseAuth.instance.currentUser?.reload();
  //         if (user.emailVerified) {
  //           // context.pushReplacement('/home_screen');
  //           Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(builder: (_) => const HomeScreen()),
  //           );
  //         } else {
  //           showVerificationDialog(context, email);
  //         }
  //       } else {
  //         // context.pushReplacement('/sign_in');
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (_) => const SignIn()),
  //         );
  //       }
  //     }

  //     if (verification) {
  //       // context.pushReplacement('/home_screen');
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (_) => const HomeScreen()),
  //       );
  //     }
  //   } else {
  //     // context.pushReplacement('/sign_in');
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => const SignIn()),
  //     );
  //   }
  // }

  Future<void> resolveFavouritedLinks() async {
    await SoundPlayer.preload();
    ActionServicesImpl().syncFavoritesWithBackend();
    ActionServicesImpl().syncLikedLinksWithBackend();
    ActionServicesImpl().syncDisLikedLinksWithBackend();
  }

  Future<void> getBackendCatgeories() async {
    await MiscImpl().persistCategoryCountsLocally();
  }

  Future<void> checkIfAdmin() async {
    await AuthServicesImpl().checkAndPersistIfUserIsAdmin();
  }

  updateDeviceToken() async {
    await AuthServicesImpl().getFcmToken();
  }

  checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    var isLoggedIn = prefs.getBool('is_loggedIn');

    if (isLoggedIn != null && isLoggedIn) {
      // context.pushReplacement('/home_screen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // context.pushReplacement('/sign_in');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignIn()),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    checkIfLoggedIn();
    resolveFavouritedLinks();
    getBackendCatgeories();
    checkIfAdmin();
    updateDeviceToken();

    MiscImpl()
      ..initiateForegroundNotifications(context)
      ..handleTerminatedNotificationTap(context);
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    resendCooldown.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Adapt.initContext(context);
    // return const HomeScreen();
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: EqualizerLoader(
          color: Color(0xCC01DE27),
        ),
      ),
    );
  }
}
