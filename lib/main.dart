import 'package:bliitz/Features/HomeScreen/main_page.dart';

import 'package:bliitz/services/sql_services.dart';
import 'package:bliitz/utils/_index.dart';
import 'package:bliitz/widgets/internet_banner.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// SETTING UP IOS DEEP LINKS.

/* avoids code removal during tree-shaking. Without this annotation, background
handler  function will be ignored during build */
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final backgroundPersistence = BackgroundPersistence();

  final backgroundNotification = BackgroundNotification(
    notificationId: '',
    title: message.notification!.title,
    message: message.notification!.body,
    isread: 'no',
  );
  await backgroundPersistence.insertMessage(backgroundNotification);
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp();
  InternetNotifier().startMonitoring();

  runApp(
    MultiBlocProvider(
      providers: Singletons.registerCubits(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // final GoRouter router = GoRouter(
    //   routes: [
    //     GoRoute(
    //       path: '/',
    //       builder: (context, state) => const MainPage(),
    //     ),
    //     GoRoute(
    //       path: '/profile/:screen',
    //       builder: (context, state) {
    //         final screen = state.pathParameters['screen']!;
    //         final query = state.uri.queryParameters;

    //         if (screen.contains('PROFILE')) {
    //           return ProfilePageDeepLink(
    //             userId: query['userId']!,
    //           );
    //         }
    //         if (screen.contains('CATEGORY')) {
    //           return CategoryDetailPageDeepLink(
    //             categoryImageUrl: query['categoryImageUrl']!,
    //             category: query['category']!,
    //             socialType: query['socialType']!,
    //           );
    //         }
    //         if (screen.contains('FAVORITE')) {
    //           return FavoriteDeepLinkPage(
    //             userId: query['userId']!,
    //           );
    //         }

    //         if (screen.contains('LINKINFO')) {
    //           return LinkInfoPageDeepLink(
    //             userId: query['userId']!,
    //             linkId: query['linkId']!,
    //           );
    //         } else {
    //           return const MainPage();
    //         }
    //       },
    //     ),
    //     GoRoute(
    //       path: '/home_screen',
    //       builder: (context, state) => const HomeScreen(),
    //     ),
    //     GoRoute(
    //       path: '/sign_in',
    //       builder: (context, state) => const SignIn(),
    //     ),
    //   ],
    // );

    // SystemChrome.setSystemUIOverlayStyle(
    //   const SystemUiOverlayStyle(
    //     systemNavigationBarColor: Color(0xFF141312),
    //     systemNavigationBarIconBrightness: Brightness.light,
    //   ),
    // );
//  MaterialApp.router
    return MaterialApp(
      // routerConfig: router,
      home: const MainPage(),
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'Bliitz App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(
              color: Colors.grey,
              width: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
