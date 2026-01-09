import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';

class SafeNetworkImage extends StatelessWidget {
  final String? url;
  final double size;

  const SafeNetworkImage({super.key, this.url, this.size = 60});

  bool get _isValid =>
      url != null &&
      url!.isNotEmpty &&
      (url!.startsWith('http://') || url!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    if (!_isValid) {
      return Image.asset(
        Images.imageDefalutPlayer,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      url!,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Image.asset(
          Images.imageDefalutPlayer,
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: size,
          height: size,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 1.2),
          ),
        );
      },
    );
  }
}
