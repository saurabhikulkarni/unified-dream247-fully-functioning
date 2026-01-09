import 'package:flutter/cupertino.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';

class MainButton extends StatelessWidget {
  final String text;
  final Function? onTap;
  final Color? color;
  final Color? textColor;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final bool isLoading;

  const MainButton({
    super.key,
    required this.text,
    this.onTap,
    this.color,
    this.textColor,
    this.height,
    this.margin,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isLoading && onTap != null) {
          onTap!();
        }
      },
      child: Container(
        margin: margin,
        height: height ?? 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color ?? AppColors.lightCard,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CupertinoActivityIndicator(color: AppColors.white),
                )
              : Text(
                  text,
                  style: TextStyle(
                    color: textColor ?? AppColors.lightBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}
