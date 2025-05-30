import 'package:bliitz/Features/Favorites/favourites_page.dart';
import 'package:bliitz/utils/_index.dart';
import 'package:flutter/material.dart';

class FavoriteDeepLinkPage extends StatefulWidget {
  const FavoriteDeepLinkPage({
    super.key,
    required this.userId,
  });
  final String userId;
  @override
  State<FavoriteDeepLinkPage> createState() => _FavoriteDeepLinkPageState();
}

class _FavoriteDeepLinkPageState extends State<FavoriteDeepLinkPage> {
  @override
  Widget build(BuildContext context) {
    Adapt.initContext(context);
    return LikedGroups(
      userId: widget.userId,
      isFromDeepLink: true,
    );
  }
}
