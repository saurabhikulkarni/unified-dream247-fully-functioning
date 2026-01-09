import 'package:flutter/material.dart';

class DashedUnderlineText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double dashWidth;
  final double dashSpace;

  const DashedUnderlineText({
    super.key,
    required this.text,
    required this.style,
    this.dashWidth = 4,
    this.dashSpace = 3,
  });

  @override
  Widget build(BuildContext context) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final textWidth = textPainter.width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: style),
        const SizedBox(height: 3),
        SizedBox(
          width: textWidth, // 🔥 THIS FIXES IT
          height: 1,
          child: CustomPaint(
            painter: _DashedLinePainter(
              color: style.color ?? Colors.black,
              dashWidth: dashWidth,
              dashSpace: dashSpace,
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  _DashedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
