import 'package:bliitz/Features/HomeScreen/CategoryPages/categroy_details.dart';
import 'package:bliitz/utils/_index.dart';
import 'package:flutter/material.dart';

class CategoryDetailPageDeepLink extends StatefulWidget {
  const CategoryDetailPageDeepLink({
    super.key,
    required this.categoryImageUrl,
    required this.category,
    required this.socialType,
  });
  final String categoryImageUrl;
  final String category;
  final String socialType;
  @override
  State<CategoryDetailPageDeepLink> createState() =>
      _CategoryDetailPageDeepLinkState();
}

class _CategoryDetailPageDeepLinkState
    extends State<CategoryDetailPageDeepLink> {
  @override
  Widget build(BuildContext context) {
    Adapt.initContext(context);
    return CategroyDetails(
      categoryImageUrl: widget.categoryImageUrl,
      category: widget.category,
      socialType: widget.socialType,
      isFromDeepLink: true,
    );
  }
}
