import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';

class UpcomingContestTimer extends StatefulWidget {
  final Function(int)? updateIndex;
  const UpcomingContestTimer({super.key, this.updateIndex});

  @override
  State<UpcomingContestTimer> createState() => _UpcomingContestTimerState();
}

class _UpcomingContestTimerState extends State<UpcomingContestTimer>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _isPaused = true;
    } else if (state == AppLifecycleState.resumed) {
      if (_isPaused) {
        _isPaused = false;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: AppSingleton.singleton.matchData.team1Name,
                style: GoogleFonts.exo2(
                  fontSize: 16.0,
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: " VS ",
                style: GoogleFonts.exo2(
                  fontSize: 14.0,
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: AppSingleton.singleton.matchData.team2Name,
                style: GoogleFonts.exo2(
                  fontSize: 16.0,
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 2,
          height: 16,
          color: AppColors.white,
        ),
        AppUtils().showCountdownTimer(
          AppSingleton.singleton.matchData.timeStart.toString(),
          () {
            if (mounted) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              widget.updateIndex?.call(0);
            }
          },
          context,
        ),
      ],
    );
  }
}
