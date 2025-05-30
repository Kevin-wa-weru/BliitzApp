import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoGridBottomSheet extends StatelessWidget {
  final List<AssetEntity> photos;
  final Function(AssetEntity) onPhotoSelected;

  const PhotoGridBottomSheet({
    super.key,
    required this.photos,
    required this.onPhotoSelected,
  });

  Future<void> _openCamera(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final AssetEntity capturedAsset =
          await PhotoManager.editor.saveImageWithPath(image.path);
      // ignore: unnecessary_null_comparison
      if (capturedAsset != null) {
        onPhotoSelected(capturedAsset);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: photos.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Camera icon
            return GestureDetector(
              onTap: () => _openCamera(context),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                ),
                child: Container(
                  color: Colors.black,
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/camera.svg',
                      height: 24,
                      width: 24,
                      colorFilter: ColorFilter.mode(
                        Colors.white.withOpacity(0.9),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            final asset = photos[index - 1];
            return FutureBuilder(
              future:
                  asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return GestureDetector(
                    onTap: () => onPhotoSelected(asset),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topRight: index == 2
                            ? const Radius.circular(16)
                            : const Radius.circular(0),
                      ),
                      child: Image.memory(snapshot.data as Uint8List,
                          fit: BoxFit.cover),
                    ),
                  );
                }
                return Container(color: Colors.grey.shade300);
              },
            );
          }
        },
      ),
    );
  }
}
