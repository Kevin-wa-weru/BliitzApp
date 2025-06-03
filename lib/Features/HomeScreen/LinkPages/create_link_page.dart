// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:bliitz/Features/HomeScreen/CategoryPages/cubit/get_links_category_page.dart';
import 'package:bliitz/Features/HomeScreen/LinkPages/cubit/get_owners_links.dart';
import 'package:bliitz/services/link_services.dart';
import 'package:bliitz/utils/_index.dart';
import 'package:bliitz/utils/check_internet.dart';
import 'package:bliitz/utils/misc.dart';
import 'package:bliitz/widgets/custom_loader.dart';
import 'package:bliitz/widgets/photo_grid_view.dart';
import 'package:bliitz/widgets/social_chips.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage(
      {super.key,
      required this.isFromProfilePage,
      this.preselectedCategory,
      this.preselectedSocialType});
  final bool isFromProfilePage;
  final String? preselectedCategory;
  final String? preselectedSocialType;
  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage>
    with TickerProviderStateMixin {
  AssetEntity? _selectedPhoto;

  final ValueNotifier<double> _opacity = ValueNotifier<double>(0.0);
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ValueNotifier<String> selectedLinkType = ValueNotifier<String>('');
  final ValueNotifier<String> selectedCategory = ValueNotifier<String>('');
  final ValueNotifier<bool> _linkIsInvalid = ValueNotifier<bool>(true);

  final ValueNotifier<String> selectedSocial = ValueNotifier<String>('');

  late AnimationController _glowControllerOne;
  late Animation<Color?> _glowAnimationOne;

  late AnimationController _glowControllerTwo;
  late Animation<Color?> _glowAnimationTwo;

  late AnimationController _glowControllerThree;
  late Animation<Color?> _glowAnimationThree;

  late AnimationController _glowControllerFour;
  late Animation<Color?> _glowAnimationFour;

  late AnimationController _glowControllerFive;
  late Animation<Color?> _glowAnimationFive;

  void _onPickPhoto() async {
    PermissionStatus status = await Permission.storage.request();
    if (!status.isGranted) {
      bool granted = await MiscImpl().requestGalleryAndCameraPermission();

      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission to access photos denied')),
        );
      }

      return;
    }

    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
    );

    late List<AssetEntity> photos = [];
    if (albums.isNotEmpty) {
      photos = await albums.first.getAssetListPaged(page: 0, size: 100);
    }
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: const Color(0xFF141312),
      isScrollControlled: true,
      transitionAnimationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
      builder: (context) {
        return PhotoGridBottomSheet(
          photos: photos,
          onPhotoSelected: (asset) {
            setState(() {
              _selectedPhoto = asset;
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> _handleForm() async {
    if (_nameController.text.isEmpty) {
      _glowControllerOne.forward().then((_) {
        _glowControllerOne.reverse();
      });
    }

    if (_linkController.text.isEmpty) {
      _glowControllerTwo.forward().then((_) {
        _glowControllerTwo.reverse();
      });
    }

    if (_linkController.text.isNotEmpty &&
        !MiscImpl().isValidUrl(_linkController.text)) {
      _linkIsInvalid.value = false;
    }

    if (_linkController.text.isNotEmpty &&
        MiscImpl().isValidUrl(_linkController.text)) {
      _linkIsInvalid.value = true;
    }

    if (_descriptionController.text.isEmpty) {
      _glowControllerThree.forward().then((_) {
        _glowControllerThree.reverse();
      });
    }

    if (selectedLinkType.value.isEmpty) {
      _glowControllerFour.forward().then((_) {
        _glowControllerFour.reverse();
      });
    }

    if (widget.isFromProfilePage) {
      if (selectedCategory.value.isEmpty) {
        _glowControllerFive.forward().then((_) {
          _glowControllerFive.reverse();
        });
      }
    }

    if (selectedSocial.value.isEmpty &&
        _nameController.text.isNotEmpty &&
        _linkController.text.isNotEmpty &&
        MiscImpl().isValidUrl(_linkController.text) &&
        selectedLinkType.value.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        selectedCategory.value.isNotEmpty) {
      showDialog(
        context: context,
        builder: (_) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: Colors.black,
            title: Text(
              "Missing Field",
              style: TextStyle(
                color: Colors.white.withOpacity(.8),
                fontWeight: FontWeight.w400,
                fontFamily: 'Questrial',
                letterSpacing: 0.3,
                height: 1.5,
              ),
            ),
            content: Text(
              "Kindly select the social app before proceeding",
              style: TextStyle(
                color: Colors.white.withOpacity(.6),
                fontWeight: FontWeight.w400,
                fontFamily: 'Questrial',
                letterSpacing: 0.3,
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "OK",
                  style: TextStyle(color: Color(0xE601DE27)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (selectedSocial.value.isNotEmpty &&
        _nameController.text.isNotEmpty &&
        _linkController.text.isNotEmpty &&
        MiscImpl().isValidUrl(_linkController.text) &&
        selectedLinkType.value.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        selectedCategory.value.isNotEmpty) {
      bool isConnected = await ConnectivityHelper.isConnected();
      if (!isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: const Color(0xE601DE27).withOpacity(.5),
            content: const Text('No internet connection')));

        return;
      }

      if (_selectedPhoto == null) {
        Future<bool> uploaded = LinkServicesImpl().uploadAndSaveLink(
            social: selectedSocial.value,
            name: _nameController.text,
            link: _linkController.text,
            linkType: selectedLinkType.value,
            category: selectedCategory.value,
            description: _descriptionController.text);

        FocusScope.of(context).unfocus();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: const AlertDialog(
                backgroundColor: Colors.transparent,
                content: EqualizerLoader(color: Color(0xE601DE27))),
          ),
        );
        if (await uploaded) {
          Navigator.pop(context);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Link has been created')));
          if (!widget.isFromProfilePage) {
            context
                .read<GetLinksInCategoriesPageCubit>()
                .filtertLinksBySocialAndCatgory(
                    widget.preselectedSocialType!, widget.preselectedCategory!);
          }
          context.read<GetOwnersLinksCubit>().getLinks();
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('An Error Ocurred')));
        }
      } else {
        Future<bool> uploaded = LinkServicesImpl().uploadAndSaveLink(
            imageFile: await _selectedPhoto?.file,
            social: selectedSocial.value,
            name: _nameController.text,
            link: _linkController.text,
            linkType: selectedLinkType.value,
            category: selectedCategory.value,
            description: _descriptionController.text);

        FocusScope.of(context).unfocus();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: const AlertDialog(
                backgroundColor: Colors.transparent,
                content: EqualizerLoader(color: Color(0xE601DE27))),
          ),
        );
        if (await uploaded) {
          Navigator.pop(context);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Link has been created')));

          if (!widget.isFromProfilePage) {
            context
                .read<GetLinksInCategoriesPageCubit>()
                .filtertLinksBySocialAndCatgory(
                    widget.preselectedSocialType!, widget.preselectedCategory!);
          }
          context.read<GetOwnersLinksCubit>().getLinks();
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('An Error Ocurred')));
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _opacity.value = 0.2;
    });

    _glowControllerOne = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _glowAnimationOne = ColorTween(
      begin: Colors.transparent,
      end: Colors.white,
    ).animate(_glowControllerOne);

    _glowControllerTwo = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _glowAnimationTwo = ColorTween(
      begin: Colors.transparent,
      end: Colors.white,
    ).animate(_glowControllerTwo);

    _glowControllerThree = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _glowAnimationThree = ColorTween(
      begin: Colors.grey,
      end: Colors.white,
    ).animate(_glowControllerThree);

    _glowControllerFour = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _glowAnimationFour = ColorTween(
      begin: const Color(0xFF141312),
      end: const Color(0xFF2C2B2A),
    ).animate(_glowControllerFour);

    _glowControllerFive = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _glowAnimationFive = ColorTween(
      begin: const Color(0xFF141312),
      end: const Color(0xFF2C2B2A),
    ).animate(_glowControllerFive);

    if (!widget.isFromProfilePage) {
      selectedCategory.value = widget.preselectedCategory!;
      selectedSocial.value = widget.preselectedSocialType!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 48.0),
                      child: SizedBox(
                        height: Adapt.px(70),
                        child: Center(
                          child: Text(
                            'Socials',
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
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 16,
                  ),
                  !widget.isFromProfilePage
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            SocialChips(
                              isProfilePage: false,
                              selectedSocial: selectedSocial,
                              currentPage: 'Create Group',
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                          ],
                        ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            _onPickPhoto();
                          },
                          child: Container(
                              height: 120,
                              width: Adapt.screenW() * .3,
                              decoration: BoxDecoration(
                                color: const Color(0xFF141312),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: _selectedPhoto == null
                                  ? Center(
                                      child: SvgPicture.asset(
                                        'assets/icons/camera.svg',
                                        height: 24,
                                        width: 24,
                                        colorFilter: ColorFilter.mode(
                                          Colors.white.withOpacity(0.7),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    )
                                  : FutureBuilder(
                                      future: _selectedPhoto!
                                          .thumbnailDataWithSize(
                                              const ThumbnailSize(300, 300)),
                                      builder: (_, snapshot) {
                                        if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            snapshot.hasData) {
                                          return ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(16),
                                            ),
                                            child: Image.memory(
                                                fit: BoxFit.cover,
                                                snapshot.data as Uint8List),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    )),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      SizedBox(
                        width: Adapt.screenW() * .6,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: AnimatedBuilder(
                                  animation: _glowAnimationOne,
                                  builder: (context, child) {
                                    return SizedBox(
                                      height: 45,
                                      child: TextField(
                                        controller: _nameController,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: InputDecoration(
                                          hintText: 'Add Name',
                                          hintStyle: TextStyle(
                                            fontFamily: 'Questrial',
                                            color:
                                                Colors.white.withOpacity(0.5),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            letterSpacing: 0.4,
                                            height: 1.5,
                                            decorationColor:
                                                Colors.white.withOpacity(0.75),
                                          ),
                                          filled: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16),
                                          fillColor: const Color(0xFF141312),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: const BorderSide(
                                                color: Colors.transparent,
                                                width: .2),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            borderSide: BorderSide(
                                              color: _glowAnimationTwo.value!,
                                              width: .2,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            borderSide: BorderSide(
                                              color: _glowAnimationTwo.value!,
                                              width: .2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: SizedBox(
                                height: 45,
                                child: AnimatedBuilder(
                                    animation: _glowAnimationTwo,
                                    builder: (context, child) {
                                      return ValueListenableBuilder<bool>(
                                          valueListenable: _linkIsInvalid,
                                          builder: (context, validLink, _) {
                                            return TextField(
                                              contextMenuBuilder:
                                                  (context, editableTextState) {
                                                return AdaptiveTextSelectionToolbar
                                                    .editableText(
                                                  editableTextState:
                                                      editableTextState,
                                                );
                                              },
                                              onChanged: (value) {
                                                if (_linkController
                                                        .text.isNotEmpty &&
                                                    MiscImpl().isValidUrl(
                                                        _linkController.text)) {
                                                  _linkIsInvalid.value = true;
                                                }
                                              },
                                              controller: _linkController,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                              decoration: InputDecoration(
                                                hintText: 'Enter/Paste Link',
                                                hintStyle: TextStyle(
                                                  fontFamily: 'Questrial',
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                  letterSpacing: 0.4,
                                                  height: 1.5,
                                                  decorationColor:
                                                      Colors.transparent,
                                                ),
                                                filled: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16),
                                                fillColor:
                                                    const Color(0xFF141312),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  borderSide: const BorderSide(
                                                      color: Colors.grey,
                                                      width: .2),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          24.0),
                                                  borderSide: BorderSide(
                                                    color: !validLink
                                                        ? Colors.red
                                                        : _glowAnimationTwo
                                                            .value!,
                                                    width: !validLink ? 2 : .2,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          24.0),
                                                  borderSide: BorderSide(
                                                    color: !validLink
                                                        ? Colors.red
                                                        : _glowAnimationTwo
                                                            .value!,
                                                    width: !validLink ? 2 : .2,
                                                  ),
                                                ),
                                              ),
                                            );
                                          });
                                    }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  ValueListenableBuilder<bool>(
                      valueListenable: _linkIsInvalid,
                      builder: (context, validLink, _) {
                        return validLink
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.only(right: 36.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Invalid Link',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.red.withOpacity(.8),
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Questrial',
                                        letterSpacing: 0.3,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                      }),
                  const SizedBox(
                    height: 22,
                  ),
                  ValueListenableBuilder<String>(
                      valueListenable: selectedLinkType,
                      builder: (context, selectedLink, _) {
                        return AnimatedBuilder(
                            animation: _glowAnimationFour,
                            builder: (context, child) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        selectedLinkType.value = 'Group',
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 8.0),
                                      decoration: BoxDecoration(
                                        color: selectedLink.isEmpty
                                            ? _glowAnimationFour.value
                                            : selectedLink == 'Group'
                                                ? const Color(0xCC01DE27)
                                                    .withOpacity(.5)
                                                : const Color(0xFF141312),
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      ),
                                      child: Text(
                                        'Group',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontFamily: 'Questrial',
                                          fontWeight: FontWeight.w300,
                                          fontSize: 12,
                                          letterSpacing: 0.5,
                                          height: 1.2,
                                          decorationColor:
                                              Colors.white.withOpacity(0.75),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  GestureDetector(
                                    onTap: () =>
                                        selectedLinkType.value = 'Channel',
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 8.0),
                                      decoration: BoxDecoration(
                                        color: selectedLink.isEmpty
                                            ? _glowAnimationFour.value
                                            : selectedLink == 'Channel'
                                                ? const Color(0xCC01DE27)
                                                    .withOpacity(.5)
                                                : const Color(0xFF141312),
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      ),
                                      child: Text(
                                        'Channel',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontFamily: 'Questrial',
                                          fontWeight: FontWeight.w300,
                                          fontSize: 12,
                                          letterSpacing: 0.5,
                                          height: 1.2,
                                          decorationColor:
                                              Colors.white.withOpacity(0.75),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  GestureDetector(
                                    onTap: () =>
                                        selectedLinkType.value = 'Page',
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 8.0),
                                      decoration: BoxDecoration(
                                        color: selectedLink.isEmpty
                                            ? _glowAnimationFour.value
                                            : selectedLink == 'Page'
                                                ? const Color(0xCC01DE27)
                                                    .withOpacity(.5)
                                                : const Color(0xFF141312),
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      ),
                                      child: Text(
                                        'Page',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontFamily: 'Questrial',
                                          fontWeight: FontWeight.w300,
                                          fontSize: 12,
                                          letterSpacing: 0.5,
                                          height: 1.2,
                                          decorationColor:
                                              Colors.white.withOpacity(0.75),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            });
                      }),
                  const SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AnimatedBuilder(
                        animation: _glowAnimationThree,
                        builder: (context, child) {
                          return TextField(
                            maxLength: 100,
                            controller: _descriptionController,
                            maxLines: 5,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Description...',
                              hintStyle: TextStyle(
                                fontFamily: 'Questrial',
                                color: Colors.white.withOpacity(0.5),
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                letterSpacing: 0.4,
                                height: 1.5,
                                decorationColor: Colors.white.withOpacity(0.75),
                              ),
                              filled: true,
                              fillColor: Colors.black,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: .2),
                              ),
                              contentPadding: const EdgeInsets.only(top: 16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24.0),
                                borderSide: BorderSide(
                                  color: _glowAnimationThree.value!,
                                  width: .2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24.0),
                                borderSide: BorderSide(
                                  color: _glowAnimationThree.value!,
                                  width: .2,
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  !widget.isFromProfilePage
                      ? const SizedBox.shrink()
                      : Center(
                          child: Text(
                            'Category',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
                              height: 1.4,
                            ),
                          ),
                        ),
                  const SizedBox(
                    height: 16,
                  ),
                  !widget.isFromProfilePage
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Wrap(
                              spacing: 8,
                              runSpacing: 12,
                              children: MiscImpl()
                                  .getCategoryItems()
                                  .map((e) => SingleChip(
                                        title: e['name'],
                                        selectedCategory: selectedCategory,
                                        glowAnimationFive: _glowAnimationFive,
                                      ))
                                  .toList()),
                        ),
                  const SizedBox(
                    height: 32,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _handleForm();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 16.0),
                          decoration: BoxDecoration(
                            color: const Color(0xCC01DE27),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: Text(
                            'Connect',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Questrial',
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              letterSpacing: 0.5,
                              height: 1.2,
                              decorationColor: Colors.white.withOpacity(0.75),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SingleChip extends StatelessWidget {
  const SingleChip({
    super.key,
    required this.title,
    required this.selectedCategory,
    required this.glowAnimationFive,
  });
  final String title;
  final ValueNotifier<String> selectedCategory;
  final Animation<Color?> glowAnimationFive;
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: glowAnimationFive,
        builder: (context, child) {
          return ValueListenableBuilder<String>(
              valueListenable: selectedCategory,
              builder: (context, selectedCateg, _) {
                return GestureDetector(
                  onTap: () => selectedCategory.value = title,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: selectedCateg.isEmpty
                          ? glowAnimationFive.value
                          : selectedCateg == title
                              ? const Color(0xCC01DE27).withOpacity(.5)
                              : const Color(0xFF141312),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: 'Questrial',
                        fontWeight: FontWeight.w300,
                        fontSize: 12,
                        letterSpacing: 0.5,
                        height: 1.2,
                        decorationColor: Colors.white.withOpacity(0.75),
                      ),
                    ),
                  ),
                );
              });
        });
  }
}
