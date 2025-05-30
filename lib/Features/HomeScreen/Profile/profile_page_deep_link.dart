import 'package:bliitz/Features/HomeScreen/Profile/pofile_visit_page.dart';
import 'package:bliitz/utils/_index.dart';
import 'package:flutter/material.dart';

class ProfilePageDeepLink extends StatefulWidget {
  const ProfilePageDeepLink({super.key, required this.userId});
  final String userId;
  @override
  State<ProfilePageDeepLink> createState() => _ProfilePageDeepLinkState();
}

class _ProfilePageDeepLinkState extends State<ProfilePageDeepLink> {
  @override
  Widget build(BuildContext context) {
    Adapt.initContext(context);
    return ProfileVisitPage(
      isPopupOpen: ValueNotifier<bool>(false),
      creatorId: widget.userId,
      isFromDeepLink: true,
    );
  }
}
