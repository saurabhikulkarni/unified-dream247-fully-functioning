import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/strings.dart';

class ImagePopupDialog extends StatefulWidget {
  final String? image;
  const ImagePopupDialog({super.key, this.image});

  @override
  State<ImagePopupDialog> createState() => _ImagePopupDialogState();
}

class _ImagePopupDialogState extends State<ImagePopupDialog> {
  bool _isImageLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if ((widget.image ?? "").isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
              child: CachedNetworkImage(
                imageUrl: widget.image ?? "",
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  height: 200,
                  width: 200,
                  alignment: Alignment.center,
                  // child: const SizedBox(
                  //   height: 30,
                  //   width: 30,
                  //   child: LoadingIndicator(
                  //     indicatorType: Indicator.lineSpinFadeLoader,
                  //     colors: [AppColors.white],
                  //     strokeWidth: 2.0,
                  //     backgroundColor: AppColors.transparent,
                  //     pathBackgroundColor: AppColors.transparent,
                  //   ),
                  // ),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error, color: Colors.red),
                imageBuilder: (context, imageProvider) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!_isImageLoaded) {
                      setState(() {
                        _isImageLoaded = true;
                      });
                    }
                  });
                  return Image(image: imageProvider);
                },
              ),
            ),
          if (_isImageLoaded)
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.letterColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(12.0),
                    bottomLeft: Radius.circular(12.0),
                  ),
                ),
                padding: const EdgeInsets.all(15),
                child: Text(
                  Strings.dismiss.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
