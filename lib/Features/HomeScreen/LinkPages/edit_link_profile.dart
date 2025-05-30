// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:bliitz/Features/HomeScreen/LinkPages/cubit/get_link_details.dart';
import 'package:bliitz/Features/HomeScreen/LinkPages/cubit/get_owners_links.dart';
import 'package:bliitz/services/link_services.dart';
import 'package:bliitz/utils/_index.dart';
import 'package:bliitz/utils/misc.dart';
import 'package:bliitz/widgets/custom_loader.dart';
import 'package:bliitz/widgets/photo_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:octo_image/octo_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

class EditGroupInfo extends StatefulWidget {
  const EditGroupInfo({
    super.key,
    this.imageUrl,
    required this.groupName,
    required this.groupId,
    this.groupBio,
  });
  final String? imageUrl;
  final String groupName;
  final String? groupBio;
  final String groupId;
  @override
  State<EditGroupInfo> createState() => _EditGroupInfoState();
}

class _EditGroupInfoState extends State<EditGroupInfo>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  AssetEntity? _selectedPhoto;

  late AnimationController _glowControllerOne;
  late Animation<Color?> _glowAnimationOne;

  late AnimationController _glowControllerTwo;
  late Animation<Color?> _glowAnimationTwo;

  @override
  void initState() {
    super.initState();

    _glowControllerOne = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _glowAnimationOne = ColorTween(
      begin: Colors.white.withOpacity(.4),
      end: Colors.white,
    ).animate(_glowControllerOne);

    _glowControllerTwo = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _glowAnimationTwo = ColorTween(
      begin: Colors.white.withOpacity(.4),
      end: Colors.white,
    ).animate(_glowControllerTwo);
    _nameController.text = widget.groupName;
    if (widget.groupBio != null) {
      _aboutController.text = widget.groupBio!;
    }
  }

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

    List<AssetEntity> photos =
        await albums.first.getAssetListPaged(page: 0, size: 100);

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

  handleForm() async {
    if (_nameController.text.isEmpty) {
      _glowControllerOne.forward().then((_) {
        _glowControllerOne.reverse();
      });
    }

    if (_aboutController.text.isEmpty) {
      _glowControllerTwo.forward().then((_) {
        _glowControllerTwo.reverse();
      });
    }

    if (_nameController.text.isNotEmpty && _aboutController.text.isNotEmpty) {
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

      Map<String, dynamic> uploaded = await LinkServicesImpl().updateLink(
          linkId: widget.groupId,
          imageFile: _selectedPhoto == null ? null : await _selectedPhoto!.file,
          name: _nameController.text,
          description: _aboutController.text);

      if (await uploaded['success'] as bool == true) {
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Group details have been updated')));

        if (_selectedPhoto == null) {
          context.read<GetLinkDetailsCubit>().updateLinkDetails(
              widget.imageUrl!, _nameController.text, _aboutController.text);
        } else {
          context.read<GetLinkDetailsCubit>().updateLinkDetails(
              uploaded['imageUrl'],
              _nameController.text,
              _aboutController.text);
        }

        context.read<GetOwnersLinksCubit>().getLinks();
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('An Error Ocurred')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: Adapt.screenH() * .45,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _onPickPhoto();
                        },
                        child: widget.imageUrl == ''
                            ? _selectedPhoto != null
                                ? Container(
                                    color: const Color(0xFF141312),
                                    width: Adapt.screenW(),
                                    height: Adapt.screenH() * .5,
                                    child: FutureBuilder(
                                      future: _selectedPhoto!
                                          .thumbnailDataWithSize(
                                              const ThumbnailSize(300, 300)),
                                      builder: (_, snapshot) {
                                        if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            snapshot.hasData) {
                                          return Image.memory(
                                              fit: BoxFit.cover,
                                              snapshot.data as Uint8List);
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  )
                                : Container(
                                    color: const Color(0xFF141312),
                                    width: Adapt.screenW(),
                                    height: Adapt.screenH() * .5,
                                    child: _selectedPhoto == null
                                        ? Center(
                                            child: SvgPicture.asset(
                                              'assets/icons/person.svg',
                                              height: 48,
                                              width: 48,
                                              colorFilter: ColorFilter.mode(
                                                Colors.white.withOpacity(.3),
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          )
                                        : FutureBuilder(
                                            future: _selectedPhoto!
                                                .thumbnailDataWithSize(
                                                    const ThumbnailSize(
                                                        300, 300)),
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
                                                      snapshot.data
                                                          as Uint8List),
                                                );
                                              }
                                              return const SizedBox.shrink();
                                            },
                                          ))
                            : _selectedPhoto != null
                                ? Container(
                                    color: const Color(0xFF141312),
                                    width: Adapt.screenW(),
                                    height: Adapt.screenH() * .5,
                                    child: FutureBuilder(
                                      future: _selectedPhoto!
                                          .thumbnailDataWithSize(
                                              const ThumbnailSize(300, 300)),
                                      builder: (_, snapshot) {
                                        if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            snapshot.hasData) {
                                          return Image.memory(
                                              fit: BoxFit.cover,
                                              snapshot.data as Uint8List);
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  )
                                : OctoImage(
                                    width: Adapt.screenW(),
                                    height: Adapt.screenH() * .5,
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                        widget.imageUrl!),
                                    progressIndicatorBuilder: (context, p) {
                                      double? value;
                                      final expectedBytes =
                                          p?.expectedTotalBytes;
                                      if (p != null && expectedBytes != null) {
                                        value = p.cumulativeBytesLoaded /
                                            expectedBytes;
                                      }
                                      return Align(
                                        child: CircularProgressIndicator(
                                          value: value,
                                          strokeWidth: 2,
                                          backgroundColor:
                                              Colors.white.withOpacity(0.12),
                                          color: const Color(0xFF141312),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stacktrace) =>
                                            const Icon(Icons.error),
                                  ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 8.0, top: Adapt.padTopH()),
                        child: Stack(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: Adapt.px(80),
                                    width: Adapt.px(80),
                                    decoration: const BoxDecoration(
                                      color: Color(0x80141312),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(100.0),
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.arrow_back,
                                        color: Colors.white.withOpacity(0.8),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      _onPickPhoto();
                                    },
                                    child: Container(
                                      height: Adapt.px(80),
                                      width: Adapt.px(80),
                                      decoration: const BoxDecoration(
                                        color: Color(0x80141312),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(100.0),
                                        ),
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          'assets/icons/edit.svg',
                                          height: 24,
                                          width: 24,
                                          colorFilter: ColorFilter.mode(
                                            Colors.white.withOpacity(0.8),
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    ),
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
                const SizedBox(
                  height: 24,
                ),
                Text(
                  'NAME',
                  style: TextStyle(
                    fontFamily: 'Questrial',
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    letterSpacing: 0.25,
                    height: 1.5,
                    decorationColor: Colors.white.withOpacity(0.75),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: SizedBox(
                    height: 45,
                    child: AnimatedBuilder(
                        animation: _glowAnimationOne,
                        builder: (context, child) {
                          return TextField(
                            controller: _nameController,
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.white.withOpacity(.8)),
                            decoration: InputDecoration(
                              hintText: widget.groupName,
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
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              fillColor: Colors.transparent,
                              border: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: .2),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: _glowAnimationOne.value!,
                                  width: .2,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: _glowAnimationOne.value!,
                                  width: .2,
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                Text(
                  'DESCRIPTION',
                  style: TextStyle(
                    fontFamily: 'Questrial',
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    letterSpacing: 0.25,
                    height: 1.5,
                    decorationColor: Colors.white.withOpacity(0.75),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedBuilder(
                      animation: _glowAnimationTwo,
                      builder: (context, child) {
                        return TextField(
                          maxLines: 3,
                          controller: _aboutController,
                          maxLength: 200,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(.8)),
                          decoration: InputDecoration(
                            border: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: .2),
                            ),
                            hintText: 'Write message...',
                            hintStyle: TextStyle(
                              fontFamily: 'Questrial',
                              color: Colors.white.withOpacity(0.2),
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              letterSpacing: 0.4,
                              height: 1.5,
                              decorationColor: Colors.white.withOpacity(0.75),
                            ),
                            filled: true,
                            fillColor: Colors.black,
                            contentPadding: const EdgeInsets.only(top: 16),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: _glowAnimationTwo.value!,
                                width: .2,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: _glowAnimationTwo.value!,
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
                GestureDetector(
                  onTap: handleForm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xCC01DE27),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Text(
                      'Save',
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
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              height: Adapt.padTopH(),
              width: Adapt.screenW(),
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
