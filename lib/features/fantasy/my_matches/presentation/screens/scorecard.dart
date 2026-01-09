// ignore_for_file: prefer_is_empty

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/global_widgets/common_shimmer_view_widget.dart';
import 'package:Dream247/features/landing/data/singleton/app_singleton.dart';
import 'package:Dream247/features/my_matches/data/models/scorecard_model.dart';
import 'package:Dream247/features/my_matches/data/my_matches_datasource.dart';
import 'package:Dream247/features/my_matches/domain/use_cases/my_matches_usecases.dart';
import 'package:Dream247/features/my_matches/presentation/provider/scorecard_provider.dart';
import 'package:Dream247/features/my_matches/presentation/widgets/scorecard_view.dart';

class Scorecard extends StatefulWidget {
  final String? mode;
  final Function() updateScoreboard;
  const Scorecard({super.key, required this.updateScoreboard, this.mode});

  @override
  State<Scorecard> createState() => _ScorecardState();
}

class _ScorecardState extends State<Scorecard> {
  List<ScorecardModel>? list;
  bool? isLoading;
  bool? isTeam1Expand = true, isTeam2Expand;
  MyMatchesUsecases myMatchesUsecases = MyMatchesUsecases(
    MyMatchesDatasource(ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    fetchScore();
    widget.updateScoreboard();
  }

  Future<void> fetchScore() async {
    var provider = Provider.of<ScorecardProvider>(context, listen: false);
    String matchKey = AppSingleton.singleton.matchData.id ?? "";

    setState(() {
      isLoading = true;
    });

    if (widget.mode == "Completed" ||
        widget.mode == "Abandoned" ||
        widget.mode == "Cancelled") {
      if ((provider.scoreCard[matchKey]?.isNotEmpty ?? false)) {
        setState(() {
          list = provider.scoreCard[matchKey];
          isLoading = false;
        });
        return;
      } else {
        final data = await myMatchesUsecases.getScorecard(context);
        if (mounted) {
          setState(() {
            list = data;
            isLoading = false;
          });
        }
        return;
      }
    }

    if (widget.mode == "Live") {
      final data = await myMatchesUsecases.getScorecard(context);
      if (mounted) {
        setState(() {
          list = data;
          isLoading = false;
        });
      }
      return;
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading ?? false) {
      return const ShimmerWidget();
    }
    if ((list ?? []).isEmpty) {
      return const Center(
        child: Text(
          "No Score Found",
          style: TextStyle(
            color: AppColors.letterColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          if (list!.length > 0)
            InkWell(
              onTap: () {
                setState(() {
                  isTeam1Expand = !(isTeam1Expand ?? false);
                  isTeam2Expand = false;
                });
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: AppColors.greyColor, width: 0.2),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 15, 10, 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ClipOval(
                                child: Image.network(
                                  (list?[0].shortName ==
                                          AppSingleton
                                              .singleton.matchData.team1Name)
                                      ? AppSingleton
                                              .singleton.matchData.team2Logo ??
                                          ""
                                      : AppSingleton
                                              .singleton.matchData.team1Logo ??
                                          "",
                                  height: 35,
                                  width: 35,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "${list?[0].shortName}",
                                style: GoogleFonts.exo2(
                                  fontSize: 16,
                                  color: AppColors.letterColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                list?[0].scores ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: GoogleFonts.tomorrow(
                                  color: AppColors.mainColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Icon(
                                (isTeam1Expand ?? false)
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 24,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isTeam1Expand ?? false) ScorecardView(data: list![0]),
                  ],
                ),
              ),
            ),
          if (list!.length > 1)
            InkWell(
              onTap: () {
                setState(() {
                  isTeam2Expand = !(isTeam2Expand ?? false);
                  isTeam1Expand = false;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: AppColors.greyColor, width: 0.2),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 15,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ClipOval(
                              child: Image.network(
                                (list?[1].shortName ==
                                        AppSingleton
                                            .singleton.matchData.team2Name)
                                    ? AppSingleton
                                            .singleton.matchData.team1Logo ??
                                        ""
                                    : AppSingleton
                                            .singleton.matchData.team2Logo ??
                                        "",
                                height: 35,
                                width: 35,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "${list?[1].shortName}",
                              style: GoogleFonts.exo2(
                                fontSize: 16,
                                color: AppColors.letterColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              list?[1].scores ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: GoogleFonts.tomorrow(
                                color: AppColors.mainColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Icon(
                              (isTeam2Expand ?? false)
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 24,
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (isTeam2Expand ?? false) ScorecardView(data: list![1]),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
