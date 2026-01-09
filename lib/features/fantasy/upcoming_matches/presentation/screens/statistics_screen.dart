import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            //======================= Pitch / Weather / Good For =====================
            dividerContainer(Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                probabilityContainer(Images.batImage, "Pitch", "Batting"),
                probabilityContainer(Images.weather, "Weather", "Cloudy"),
                probabilityContainer(Images.bowlImage, "Good For", "Spinners"),
              ],
            )),

            //============================== Venue ===================================
            dividerContainer(Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  Images.location,
                  height: 30.h,
                ),
                10.horizontalSpace,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Venue",
                      style: TextStyle(
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "The County Ground, New Road Worcester",
                      style: TextStyle(
                          color: AppColors.black, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "(New Road, England)",
                      style: TextStyle(
                          color: AppColors.black, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              ],
            )),

            //====================== Recent 5 Matches =============================
            dividerContainer(Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.refresh_outlined, color: Colors.blue),
                    5.horizontalSpace,
                    Text(
                      "Recent Performances - Recent 5 Matches",
                      style: TextStyle(
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                5.verticalSpace,
                innerContainer(
                  last5MatchRow("https://flagsapi.com/GB/flat/64.png", "EN-W"),
                  last5MatchRow("https://flagsapi.com/IN/flat/64.png", "IN-W"),
                )
              ],
            )),

            //====================== One vs One - Recent 10 Matches =================
            dividerContainer(Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "assets/others/1V1.png",
                        height: 20,
                      ),
                      10.horizontalSpace,
                      Text(
                        "One vs One - Recent 10 matches",
                        style: TextStyle(
                            color: AppColors.blackColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  10.verticalSpace,

                  // EN-W
                  oneVsOneRow(
                      "https://flagsapi.com/GB/flat/64.png", "EN-W", 6, 10),

                  10.verticalSpace,

                  // IN-W
                  oneVsOneRow(
                      "https://flagsapi.com/IN/flat/64.png", "IN-W", 4, 10),
                ],
              ),
            )),

            //=========================== Venue Scoring ==============================
            dividerContainer(Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "assets/others/venue.png",
                        height: 20,
                      ),
                      10.horizontalSpace,
                      Text(
                        "Venue Scoring",
                        style: TextStyle(
                            color: AppColors.blackColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  5.verticalSpace,
                  Text(
                    "The County Ground, New Road Worcester\n(New Road, England)",
                    style: TextStyle(
                        color: AppColors.black, fontWeight: FontWeight.bold),
                  ),
                  15.verticalSpace,
                  // 1st row stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      venueStatBox("231", "1st Batting\nAvg Score"),
                      venueStatBox("180", "2nd Batting\nAvg Score"),
                      venueStatBox("240", "Highest\nBatting Score"),
                    ],
                  ),
                  20.verticalSpace,
                  // Avg Match Won
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      avgWinBox(
                        percent: 0.5,
                        score: "38",
                        label: "1st Batting",
                        progressColor: Colors.green,
                      ),
                      avgWinBox(
                        percent: 0.5,
                        score: "47",
                        label: "2nd Batting",
                        progressColor: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

Widget dividerContainer(Widget child) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Material(
      elevation: 3,
      child: Container(
        padding: EdgeInsets.all(10),
        color: AppColors.white,
        child: child,
      ),
    ),
  );
}

Widget probabilityContainer(String image, String type, String typeName) {
  return Container(
    padding:
        EdgeInsets.symmetric(horizontal: 10, vertical: 5).copyWith(right: 15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border:
          Border.all(width: 1, color: AppColors.black.withValues(alpha: 0.1)),
    ),
    child: Row(
      children: [
        Image.asset(image, height: 30.h),
        5.horizontalSpace,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(type,
                style: TextStyle(color: AppColors.greyColor, fontSize: 12.sp)),
            Text(typeName,
                style: TextStyle(
                    color: AppColors.blackColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp)),
          ],
        )
      ],
    ),
  );
}

Widget innerContainer(Widget child1, Widget child2) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border:
          Border.all(width: 1, color: AppColors.black.withValues(alpha: 0.2)),
    ),
    child: Column(
      children: [
        child1,
        Container(height: 1, color: AppColors.black.withValues(alpha: 0.2)),
        child2,
      ],
    ),
  );
}

Widget last5MatchRow(String url, String teamName) {
  return Padding(
    padding: EdgeInsets.all(10),
    child: Row(
      children: [
        CircleAvatar(backgroundImage: NetworkImage(url)),
        5.horizontalSpace,
        Text(teamName, style: TextStyle(color: AppColors.blackColor)),
        35.horizontalSpace,
        ...["W", "L", "W", "L", "W"].map(
          (result) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              padding: EdgeInsets.all(5),
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: result == "W" ? AppColors.green : Colors.red,
              ),
              child: Center(
                  child:
                      Text(result, style: TextStyle(color: AppColors.white))),
            ),
          ),
        )
      ],
    ),
  );
}

Widget oneVsOneRow(String url, String teamName, int won, int total) {
  double percent = won / total;

  return Row(
    children: [
      CircleAvatar(backgroundImage: NetworkImage(url)),
      10.horizontalSpace,
      Text(teamName, style: TextStyle(color: AppColors.blackColor)),
      20.horizontalSpace,
      Expanded(
        child: Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Container(
              height: 10,
              width: percent * 200,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
            )
          ],
        ),
      ),
      10.horizontalSpace,
      Text("Won $won", style: TextStyle(color: AppColors.blackColor))
    ],
  );
}

Widget venueStatBox(String value, String label) {
  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.black.withValues(alpha: 0.3), width: 1)),
    child: Column(
      children: [
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black)),
        SizedBox(height: 5),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87, fontSize: 12)),
      ],
    ),
  );
}

Widget avgWinBox({
  required double percent, // 0.0 to 1.0
  required String score,
  required String label,
  required Color progressColor,
}) {
  return Container(
    width: 160,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppColors.black.withValues(alpha: 0.2),
      ),
    ),
    child: Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CustomPaint(
                painter: AvgWinPainter(
                  percent: percent,
                  progressColor: progressColor,
                ),
              ),
            ),
            Text(
              "${(percent * 100).toInt()}%",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              score,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class AvgWinPainter extends CustomPainter {
  final double percent;
  final Color progressColor;

  AvgWinPainter({
    required this.percent,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 6.0;
    final center = size.center(Offset.zero);
    final radius = (size.width / 2) - strokeWidth;

    final backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Background ring
    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final startAngle = -90 * 3.1416 / 180;
    final sweepAngle = 2 * 3.1416 * percent;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
