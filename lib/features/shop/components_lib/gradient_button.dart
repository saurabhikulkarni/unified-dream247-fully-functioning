import 'package:flutter/material.dart';
import 'package:unified_dream247/features/shop/constants.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsets padding;
  final Size minimumSize;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding = const EdgeInsets.all(defaultPadding),
    this.minimumSize = const Size(double.infinity, 56),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6441A5),
            Color(0xFF472575),
            Color(0xFF2A0845),
          ],
        ),
        borderRadius: BorderRadius.circular(defaultBorderRadious),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(defaultBorderRadious),
          child: Padding(
            padding: padding,
            child: Align(
              alignment: Alignment.center,
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
