// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:bliitz/Features/HomeScreen/Profile/cubit/get_pofile_details_cubit.dart';
import 'package:bliitz/services/auth_services.dart';
import 'package:bliitz/utils/misc.dart';
import 'package:bliitz/widgets/custom_loader.dart';
import 'package:bliitz/widgets/photo_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:octo_image/octo_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../utils/_index.dart';

class EditProfile extends StatefulWidget {
  const EditProfile(
      {super.key, this.profileUrl, required this.userName, this.aboutUser});

  @override
  State<EditProfile> createState() => _EditProfileState();
  final String? profileUrl;
  final String userName;
  final String? aboutUser;
}

class _EditProfileState extends State<EditProfile>
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
    _nameController.text = widget.userName;
    if (widget.aboutUser != null) {
      _aboutController.text = widget.aboutUser!;
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
      Future<bool> uploaded = AuthServicesImpl().updateProfile(
          imageFile: _selectedPhoto == null ? null : await _selectedPhoto!.file,
          name: _nameController.text,
          bio: _aboutController.text);

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
            const SnackBar(content: Text('Profile has been updated')));
        context.read<GetProfileDetailsCubit>().getProfileDetails(true);
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: GestureDetector(
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
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          _onPickPhoto();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF141312),
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          child: Text(
                            'Edit pofile picture',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
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
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            GestureDetector(
              onTap: () {
                _onPickPhoto();
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: widget.profileUrl == null
                    ? Container(
                        color: const Color(0xFF141312),
                        width: 156,
                        height: 156,
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
                                future: _selectedPhoto!.thumbnailDataWithSize(
                                    const ThumbnailSize(300, 300)),
                                builder: (_, snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.hasData) {
                                    return ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(16),
                                      ),
                                      child: Image.memory(
                                          fit: BoxFit.cover,
                                          snapshot.data as Uint8List),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ))
                    : _selectedPhoto != null
                        ? Container(
                            color: const Color(0xFF141312),
                            width: 156,
                            height: 156,
                            child: FutureBuilder(
                              future: _selectedPhoto!.thumbnailDataWithSize(
                                  const ThumbnailSize(300, 300)),
                              builder: (_, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.hasData) {
                                  return ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(16),
                                    ),
                                    child: Image.memory(
                                        fit: BoxFit.cover,
                                        snapshot.data as Uint8List),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          )
                        : OctoImage(
                            width: 156,
                            height: 156,
                            fit: BoxFit.cover,
                            image:
                                CachedNetworkImageProvider(widget.profileUrl!),
                            progressIndicatorBuilder: (context, p) {
                              double? value;
                              final expectedBytes = p?.expectedTotalBytes;
                              if (p != null && expectedBytes != null) {
                                value = p.cumulativeBytesLoaded / expectedBytes;
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
                            errorBuilder: (context, error, stacktrace) =>
                                const Icon(Icons.error),
                          ),
              ),
            ),
            const SizedBox(
              height: 32,
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
                        style: TextStyle(color: Colors.white.withOpacity(.8)),
                        decoration: InputDecoration(
                          hintText: widget.userName,
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
              height: 40,
            ),
            Text(
              'DESCRIPTION',
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
                          borderSide: BorderSide(color: Colors.grey, width: .2),
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
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                handleForm();
              },
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
          ],
        ),
      ),
    );
  }
}
