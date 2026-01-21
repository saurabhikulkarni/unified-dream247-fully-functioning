// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/main_button.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/upcoming_match_datsource.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/domain/use_cases/upcoming_match_usecase.dart';

class ContestFilledBottomSheet extends StatefulWidget {
  final String entryFee;
  final String totalBonus;
  final String totalWinners;
  final String winAmount;
  final String spots;
  final int discountFee;
  final String joinTeamId;
  final String challengeId;
  final bool previousJoined;
  final bool? newTeam;
  final bool? isContestDetail;
  final Function() onDismiss;
  const ContestFilledBottomSheet({
    super.key,
    required this.entryFee,
    required this.winAmount,
    required this.totalBonus,
    required this.spots,
    required this.discountFee,
    required this.joinTeamId,
    required this.challengeId,
    required this.previousJoined,
    required this.newTeam,
    this.isContestDetail,
    required this.onDismiss,
    required this.totalWinners,
  });

  @override
  State<ContestFilledBottomSheet> createState() =>
      _ContestFilledBottomSheetState();
}

class _ContestFilledBottomSheetState extends State<ContestFilledBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  UpcomingMatchUsecase upcomingMatchUsecase = UpcomingMatchUsecase(
    UpcomingMatchDatsource(ApiImpl(), ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: SafeArea(
        child: Container(
          height: 370,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.close,
                    size: 24,
                    color: AppColors.letterColor,
                  ),
                ),
              ),
              Image.asset(Images.icSadEmoji, height: 30, width: 30),
              Text(
                'So close! That contest filled up',
                style: GoogleFonts.exo2(
                  color: AppColors.letterColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "No worries, join this contest instead! It's exactly the same type",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greyColor,
                  overflow: TextOverflow.clip,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                margin: const EdgeInsets.all(12).copyWith(bottom: 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.white,
                  border: Border.all(color: AppColors.white, width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3,
                            vertical: 3,
                          ),
                          child: Row(
                            children: [
                              Text(
                                Strings.prizePool,
                                style: TextStyle(
                                  color: AppColors.letterColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            '${Strings.indianRupee}${widget.winAmount}',
                            style: GoogleFonts.tomorrow(
                              color: AppColors.letterColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3,
                            vertical: 1,
                          ),
                          child: Text(
                            'No. of Winners',
                            style: TextStyle(
                              color: AppColors.letterColor,
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3),
                          child: Text(
                            (AppSingleton.singleton.contestData.totalwinners)
                                .toString(),
                            style: GoogleFonts.tomorrow(
                              color: AppColors.letterColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3,
                            vertical: 1,
                          ),
                          child: Text(
                            '',
                            style: TextStyle(
                              color: AppColors.letterColor,
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3),
                          child: Text(
                            widget.spots,
                            style: GoogleFonts.tomorrow(
                              color: AppColors.letterColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'You can check other competitors after joining the contest',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greyColor,
                  overflow: TextOverflow.clip,
                ),
              ),
              const SizedBox(height: 5),
              MainButton(
                color: AppColors.green,
                textColor: AppColors.white,
                text: 'Join ${Strings.indianRupee}${widget.entryFee}',
                onTap: () async {
                  Navigator.pop(context);
                  await upcomingMatchUsecase.closedContestJoin(
                    context,
                    int.parse(widget.entryFee),
                    int.parse(widget.winAmount),
                    int.parse(widget.spots),
                    widget.discountFee.toString(),
                    widget.joinTeamId,
                  );
                  if (widget.newTeam == true &&
                      widget.isContestDetail == true) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  } else if (widget.newTeam == true ||
                      widget.isContestDetail == true) {
                    Navigator.pop(context);
                  }
                  widget.onDismiss();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
