// ignore_for_file: use_build_context_synchronously

import 'package:bliitz/Features/HomeScreen/home_screen.dart';
import 'package:bliitz/Features/Policy%20Documents/privacy_policy_page.dart';
import 'package:bliitz/services/auth_services.dart';
import 'package:bliitz/Features/Policy%20Documents/terms_condtions_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> with TickerProviderStateMixin {
  late AnimationController _termsController;
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  late Animation<double> _shakeAnimation;
  bool validateCheckbox = false;
  final ValueNotifier<bool> isChecked = ValueNotifier<bool>(false);

  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    //
    _termsController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
    ]).animate(_termsController);

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);

    _glowAnimation =
        Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void showCustomCupertinoDialog(
      {required BuildContext context,
      required String title,
      required String message}) {
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
                onPressed: () async {
                  Navigator.pop(context);
                },
                child: const Text(
                  "OK",
                  style: TextStyle(
                      fontFamily: 'Questrial',
                      color: Color(0xCC01DE27)), // Green accent
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Opacity(
            opacity: .6,
            child: Image.asset(
              fit: BoxFit.fitWidth,
              "assets/images/daft.jpg",
              height: 250,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              Container(
                height: 150,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black,
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.transparent,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10.0,
                        right: 10,
                      ),
                      child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/images/logo.svg',
                                height: 45,
                                width: 45,
                              ),
                              const SizedBox(height: 40),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.5,
                                    height: 1.3,
                                  ),
                                  children: [
                                    const TextSpan(text: "Make your"),
                                    TextSpan(
                                      text: ' online ',
                                      style: TextStyle(
                                        color: const Color(0xFF01de27)
                                            .withOpacity(.6),
                                        fontFamily: 'Poppins',
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.5,
                                        height: 1.3,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: "experience",
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'more interesting',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.5,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                          Column(
                            children: [
                              _buildSignUpButton(
                                  title: 'Continue with Facebook',
                                  color: const Color(0xFF1877F2),
                                  svgPath: 'assets/images/facebook.svg',
                                  colorFilter: ColorFilter.mode(
                                    Colors.white.withOpacity(0.8),
                                    BlendMode.srcIn,
                                  ),
                                  isGoogle: false),
                              const SizedBox(height: 20),
                              _buildSignUpButton(
                                  title: 'Continue with Google      ',
                                  color: const Color(0xFF1E1D1C),
                                  svgPath: 'assets/icons/google.svg',
                                  colorFilter: null,
                                  isGoogle: true),
                              const SizedBox(height: 30),
                              AnimatedBuilder(
                                animation: _shakeAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(_shakeAnimation.value, 0),
                                    child: child,
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ValueListenableBuilder<bool>(
                                      valueListenable: isChecked,
                                      builder: (context, value, _) {
                                        return Checkbox(
                                          value: value,
                                          onChanged: (newValue) {
                                            isChecked.value = newValue ?? false;
                                          },
                                          activeColor: Colors.green,
                                          checkColor: Colors.white,
                                          splashRadius: 20.0,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        );
                                      },
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontFamily: 'Questrial',
                                          color: Colors.green,
                                          fontSize: 12,
                                          letterSpacing: 0.3,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: "Agree to the ",
                                            style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.6)),
                                          ),
                                          TextSpan(
                                            text: "terms of use",
                                            style: const TextStyle(
                                                color: Colors.green),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                Navigator.of(context).push(
                                                  PageRouteBuilder(
                                                    transitionDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                    pageBuilder: (context,
                                                            animation,
                                                            secondaryAnimation) =>
                                                        const TermsAndConditions(),
                                                    transitionsBuilder:
                                                        (context,
                                                            animation,
                                                            secondaryAnimation,
                                                            child) {
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
                                          ),
                                          TextSpan(
                                            text: " and ",
                                            style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.6)),
                                          ),
                                          TextSpan(
                                            text: "privacy policy",
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                Navigator.of(context).push(
                                                  PageRouteBuilder(
                                                    transitionDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                    pageBuilder: (context,
                                                            animation,
                                                            secondaryAnimation) =>
                                                        const PrivacyPoliciy(),
                                                    transitionsBuilder:
                                                        (context,
                                                            animation,
                                                            secondaryAnimation,
                                                            child) {
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
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton(
      {required String title,
      required Color color,
      required String svgPath,
      required bool isGoogle,
      ColorFilter? colorFilter}) {
    return ValueListenableBuilder<bool>(
        valueListenable: _isLoading,
        builder: (context, appLoading, child) {
          return GestureDetector(
            onTap: () async {
              if (isChecked.value == false) {
                showCustomCupertinoDialog(
                    context: context,
                    title: 'Terms & Policy Agreement',
                    message:
                        'Kindly agree to the Bliitz\'s Terms of Use & Privacy Policy before proceeding with Sign In');
                return;
              }

              _isLoading.value == true;
              if (isGoogle) {
                if (!appLoading) {
                  try {
                    final userCredential =
                        await AuthServicesImpl().signInWithGoogle();
                    debugPrint(
                        'Signed in asss: ${userCredential.user?.displayName.toString()}');

                    FirebaseMessaging messaging = FirebaseMessaging.instance;
                    String? token = await messaging.getToken();

                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(userCredential.user!.uid)
                        .set({
                      'name': userCredential.user?.displayName.toString(),
                      'email': userCredential.user?.email == null
                          ? ''
                          : userCredential.user?.email.toString(),
                      'photoURL': userCredential.user?.photoURL,
                      'createdAt': FieldValue.serverTimestamp(),
                      'totalFavorites': 0,
                      'totalCommunities': 0,
                      'totalImpressions': 0,
                      'verified': false,
                      'paymentPlanId': '',
                      'purchaseverificationData': '',
                      'fcmToken': token,
                    }, SetOptions(merge: true));
                    _isLoading.value == false;
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const HomeScreen(),
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
                  } catch (e) {
                    _isLoading.value == false;
                    debugPrint('Error: ${e.toString()}');
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              } else {
                if (!appLoading) {
                  try {
                    final userCredential =
                        await AuthServicesImpl().loginWithFacebook();
                    debugPrint(
                        'Signed in asss: ${userCredential.user?.displayName.toString()}');
                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(userCredential.user!.uid)
                        .set({
                      'name': userCredential.user?.displayName.toString(),
                      'email': userCredential.user?.email == null
                          ? ''
                          : userCredential.user?.email.toString(),
                      'photoURL': userCredential.user?.photoURL,
                      'createdAt': FieldValue.serverTimestamp(),
                      'totalFavorites': 0,
                      'totalCommunities': 0,
                      'totalImpressions': 0,
                      'verified': false,
                    }, SetOptions(merge: true));
                    _isLoading.value == false;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  } catch (e) {
                    debugPrint('Error: ${e.toString()}');
                    _isLoading.value == false;
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              }
            },
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: !appLoading
                        ? color
                        : color.withOpacity(_glowAnimation.value),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: IntrinsicWidth(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Opacity(
                          opacity: appLoading ? .5 : 1,
                          child: SvgPicture.asset(
                            svgPath,
                            height: 22,
                            width: 22,
                            colorFilter: colorFilter,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          title,
                          style: TextStyle(
                              color: appLoading
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              fontFamily: 'Questrial',
                              letterSpacing: 0.3,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }
}
