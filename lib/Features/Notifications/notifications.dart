import 'package:bliitz/Features/Notifications/cubit/get_notifcations_cubit.dart';
import 'package:bliitz/services/sql_services.dart';
import 'package:bliitz/utils/_index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ValueNotifier<List<BackgroundNotification>> notificationItems =
      ValueNotifier<List<BackgroundNotification>>([]);

  @override
  void initState() {
    super.initState();

    context
        .read<GetBackgroundNotificationsCubit>()
        .getBackgroundNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            Row(
              children: [
                GestureDetector(
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
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Notifications',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF141312),
                border: Border.all(
                  color: Colors.grey,
                  width: 0.1,
                ),
                borderRadius: BorderRadius.circular(80.0),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              removeTop: true,
              child: BlocConsumer<GetBackgroundNotificationsCubit,
                  GetBackgroundNotificationsState>(
                listener: (context, state) {},
                builder: (context, state) {
                  if (state is GetBackgroundNotificationsStateLoaded) {
                    if (state.backgroundNotifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: Adapt.screenH() * .27),
                            SvgPicture.asset(
                              'assets/icons/sad.svg',
                              height: 24,
                              width: 24,
                              colorFilter: ColorFilter.mode(
                                Colors.white.withOpacity(0.4),
                                BlendMode.srcIn,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text(
                                'Looks like there are no notifications yet. Stay tuned!',
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
                          ],
                        ),
                      );
                    } else {
                      return Expanded(
                        child: ListView(
                            children: state.backgroundNotifications
                                .map((e) => NotificationItem(
                                      title: e.title!,
                                      subtitle: e.message!,
                                    ))
                                .toList()),
                      );
                    }
                  }
                  if (state is GetBackgroundNotificationsStateLoading) {
                    return Expanded(
                      child: ListView(
                          children: [1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5]
                              .map((e) => const NotificationItemSkeleton())
                              .toList()),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Opacity(
                opacity: .9,
                child: SvgPicture.asset(
                  'assets/images/logo.svg',
                  height: 24,
                  width: 24,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                'Bliitz team - $title',
                style: TextStyle(
                  fontFamily: 'Questrial',
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.25,
                  decorationColor: Colors.white.withOpacity(0.75),
                ),
                overflow: TextOverflow.visible,
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 8,
                ),
                height: 4,
                width: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Flexible(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Questrial',
                    color: Colors.white.withOpacity(0.4),
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    letterSpacing: 0.25,
                    decorationColor: Colors.white.withOpacity(0.75),
                  ),
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NotificationItemSkeleton extends StatelessWidget {
  const NotificationItemSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Opacity(
                opacity: 1,
                child: SvgPicture.asset(
                  'assets/images/logo.svg',
                  height: 24,
                  width: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF141312),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: const Color(0xFF141312),
                  width: 100,
                  height: 15,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 8,
                ),
                height: 4,
                width: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF141312),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: const Color(0xFF141312),
                  width: 300,
                  height: 30,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
