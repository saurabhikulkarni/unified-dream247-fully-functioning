import 'package:flutter/material.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/global_widgets/container_painter.dart';

class TriangularContainer extends CustomPainter {
  final int flipX;
  final Color color;
  TriangularContainer({required this.flipX, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.whiteFade1
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    var path = Path();

    if (flipX == 1) {
      // upper side diagonal more, right side top round

      path.moveTo(0, size.height - 5);
      path.arcToPoint(
        Offset(5, size.height),
        radius: const Radius.circular(8),
        clockwise: false,
      );
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 8);
      path.arcToPoint(
        Offset(size.width - 8, 0),
        radius: const Radius.circular(8),
        clockwise: false,
      );
      path.lineTo(-size.width * 0.2, 0);
      path.close();
    } else if (flipX == 2) {
      // lower side diagonal more, left side top round
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width * 1.1, size.height);
      path.lineTo(8, size.height);
      path.arcToPoint(
        Offset(0, size.height),
        radius: const Radius.circular(8),
        clockwise: false,
      );
      path.close();
    } else if (flipX == 3) {
      // lower side diagonal more, right side top round
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 8);
      path.arcToPoint(
        Offset(size.width - 10, 0),
        radius: const Radius.circular(8),
        clockwise: false,
      );
      path.lineTo(8, 0);
      path.close();
    } else if (flipX == 4) {
    } else {
      // upper side diagonal more, left side top round
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width * 1.1, 0);
      path.lineTo(8, 0);
      path.arcToPoint(
        const Offset(0, 8),
        radius: const Radius.circular(8),
        clockwise: false,
      );
      path.close();
    }

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CustomContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final int flipX;
  final Color gradient;
  final Widget? child;

  const CustomContainer({
    super.key,
    this.width,
    this.height,
    this.flipX = 0,
    required this.gradient,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size(width ?? 0.0, height ?? 0.0),
          painter: ContainerPainter(flipX: flipX, color: gradient),
        ),
        if (child != null) SizedBox(width: width, height: height, child: child),
      ],
    );
  }
}
