import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/components/list_tile/divider_list_tile.dart';
import 'package:shop/utils/responsive_extension.dart';

class ProfileMenuListTile extends StatelessWidget {
  const ProfileMenuListTile({
    super.key,
    required this.text,
    required this.svgSrc,
    required this.press,
    this.isShowDivider = true,
  });

  final String text, svgSrc;
  final VoidCallback press;
  final bool isShowDivider;

  @override
  Widget build(BuildContext context) {
    final iconSize = context.isTablet ? 28.0 : 24.0;
    final fontSize = context.fontSize(14, minSize: 12, maxSize: 16);
    
    return DividerListTile(
      minLeadingWidth: iconSize,
      leading: SvgPicture.asset(
        svgSrc,
        height: iconSize,
        width: iconSize,
        colorFilter: ColorFilter.mode(
          Theme.of(context).iconTheme.color!,
          BlendMode.srcIn,
        ),
      ),
      title: Text(
        text,
        style: TextStyle(fontSize: fontSize, height: 1),
      ),
      press: press,
      isShowDivider: isShowDivider,
    );
  }
}
