import 'package:flutter/material.dart';

class GradientProgressBar extends StatelessWidget {
  final int percent;
  final LinearGradient gradient;
  final Color backgroundColor;

  const GradientProgressBar(
      {required this.percent,
      required this.gradient,
      required this.backgroundColor,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: percent,
          fit: FlexFit.tight,
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: percent == 100
                  ? const BorderRadius.all(Radius.circular(4))
                  : const BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      topLeft: Radius.circular(4)),
            ),
            child: const SizedBox(height: 5.0),
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          flex: 100 - percent,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: percent == 0
                  ? const BorderRadius.all(Radius.circular(4))
                  : const BorderRadius.only(
                      bottomRight: Radius.circular(4),
                      topRight: Radius.circular(4)),
            ),
            child: const SizedBox(height: 5.0),
          ),
        ),
      ],
    );
  }
}
