// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:bliitz/Features/Authentication/new_login.dart';
import 'package:bliitz/Features/HomeScreen/home_screen.dart';
import 'package:bliitz/services/auth_services.dart';
import 'package:bliitz/utils/_index.dart';
import 'package:bliitz/utils/misc.dart';
import 'package:bliitz/utils/sound_player.dart';
import 'package:bliitz/widgets/custom_loader.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Future<void> preLoadSound() async {
    await SoundPlayer.preload();
    // ActionServicesImpl().syncUserLinkActionsWithBackend();
  }

  Future<void> getBackendCatgeories() async {
    await MiscImpl().persistCategoryCountsLocally();
  }

  listenToFCMchange() async {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await AuthServicesImpl().updateFcmToken(newToken);
    });
  }

  checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    var isLoggedIn = prefs.getBool('is_loggedIn');

    if (isLoggedIn != null && isLoggedIn) {
      // context.pushReplacement('/home_screen');
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          opaque: true,
          barrierColor: Colors.black,
        ),
      );
    } else {
      // context.pushReplacement('/sign_in');
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SignIn(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
  }

  @override
  void initState() {
    super.initState();

    checkIfLoggedIn();
    preLoadSound();
    getBackendCatgeories();
    listenToFCMchange();

    MiscImpl()
      ..initiateForegroundNotifications(context)
      ..handleTerminatedNotificationTap(context);
  }

  @override
  Widget build(BuildContext context) {
    Adapt.initContext(context);
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
