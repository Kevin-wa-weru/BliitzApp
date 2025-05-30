import 'package:bliitz/Features/HomeScreen/LinkPages/link_info_page.dart';
import 'package:bliitz/Features/HomeScreen/LinkPages/owner_link_info.dart';
import 'package:bliitz/Features/HomeScreen/home_screen.dart';
import 'package:bliitz/services/link_services.dart';
import 'package:bliitz/utils/_index.dart';
import 'package:bliitz/widgets/custom_loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LinkInfoPageDeepLink extends StatefulWidget {
  const LinkInfoPageDeepLink({
    super.key,
    required this.linkId,
    required this.userId,
  });
  final String linkId;
  final String userId;

  @override
  State<LinkInfoPageDeepLink> createState() => _LinkInfoPageDeepLinkState();
}

class _LinkInfoPageDeepLinkState extends State<LinkInfoPageDeepLink> {
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<Map<String, dynamic>> groupDetails = ValueNotifier({});
  getLinkDetails() async {
    isLoading.value = true;
    final linkDetails =
        await LinkServicesImpl().fetchLinkDetails(widget.linkId);

    if (linkDetails != null) {
      groupDetails.value = linkDetails;
      isLoading.value = false;
    } else {
      isLoading.value = false;
    }
  }

  @override
  void initState() {
    getLinkDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Adapt.initContext(context);
    return ValueListenableBuilder<Map<String, dynamic>>(
        valueListenable: groupDetails,
        builder: (context, groupInfo, child) {
          return ValueListenableBuilder<bool>(
              valueListenable: isLoading,
              builder: (context, loading, child) {
                if (loading) {
                  return const Center(
                    child: EqualizerLoader(
                      color: Color(0xCC01DE27),
                    ),
                  );
                } else {
                  if (FirebaseAuth.instance.currentUser != null &&
                      widget.userId.trim() ==
                          FirebaseAuth.instance.currentUser?.uid) {
                    return OwnerGroupInfo(
                      groupDetails: groupInfo,
                      isFromDeepLink: false,
                    );
                  }

                  if (FirebaseAuth.instance.currentUser != null &&
                      widget.userId.trim() !=
                          FirebaseAuth.instance.currentUser?.uid) {
                    return GroupInfoScreen(
                      groupDetails: groupInfo,
                      isFromDeepLink: false,
                    );
                  } else {
                    return const HomeScreen();
                  }
                }
              });
        });
  }
}
