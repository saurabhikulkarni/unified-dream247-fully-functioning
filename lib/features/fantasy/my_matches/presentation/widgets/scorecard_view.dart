import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/scorecard_model.dart';

class ScorecardView extends StatelessWidget {
  final ScorecardModel data;
  const ScorecardView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(color: AppColors.whiteFade1),
              padding: const EdgeInsets.only(left: 10.0, top: 5.0, bottom: 5.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.34,
                    child: const Text(
                      'Batsmen',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.letterColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Text(
                    'R',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.letterColor,
                      fontSize: 12,
                    ),
                  ),
                  const Text(
                    'B',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.letterColor,
                      fontSize: 12,
                    ),
                  ),
                  const Text(
                    '4s',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.letterColor,
                      fontSize: 12,
                    ),
                  ),
                  const Text(
                    '6s',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.letterColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(
                    width: 50,
                    child: Text(
                      'SR',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.letterColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.batsmen?.length,
                itemBuilder: (context, index) {
                  return singleBatsman(context, data.batsmen![index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Extras'.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            color: AppColors.letterColor,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '(Wd ${data.extraRuns!.wides}, NB ${data.extraRuns!.noballs}, B ${data.extraRuns!.byes}, LB ${data.extraRuns!.legbyes}, Pen ${data.extraRuns!.penalty})',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.letterColor,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.48,
                    child: Text(
                      '${data.extraRuns?.total ?? "0"}',
                      style: GoogleFonts.tomorrow(
                        fontWeight: FontWeight.w600,
                        color: AppColors.letterColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: Text(
                            'Total'.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              color: AppColors.letterColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          '(${data.equations?.wickets} Wickets, ${data.equations?.overs} Overs)',
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            color: AppColors.letterColor,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${data.equations?.runs ?? "0"}',
                      style: GoogleFonts.tomorrow(
                        fontWeight: FontWeight.w600,
                        color: AppColors.letterColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Did Not Bat',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: AppColors.letterColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${data.didNotBat}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        color: AppColors.letterColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(color: AppColors.whiteFade1),
              margin: const EdgeInsets.only(top: 15),
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 5.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: const Text(
                      'Bowler',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.letterColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Text(
                    'O',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.letterColor,
                      fontSize: 12,
                    ),
                  ),
                  const Text(
                    'M',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.letterColor,
                      fontSize: 12,
                    ),
                  ),
                  const Text(
                    'R',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.letterColor,
                      fontSize: 12,
                    ),
                  ),
                  const Text(
                    'W',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.letterColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(
                    width: 40,
                    child: Text(
                      'ER',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.letterColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.bowlers?.length,
                itemBuilder: (context, index) {
                  return singleBolwer(data.bowlers![index], context);
                },
              ),
            ),
            Container(
              decoration: const BoxDecoration(color: AppColors.whiteFade1),
              margin: const EdgeInsets.only(top: 15),
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 5.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: const Text(
                      'Fall Of Wicket',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.letterColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Text(
                    'Score',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.letterColor,
                      fontSize: 12,
                    ),
                  ),
                  const Text(
                    'Over',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.letterColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.fallOfWickets!.length,
                itemBuilder: (context, index) {
                  return singleFallOfWicket(
                      context, data.fallOfWickets![index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget singleBatsman(BuildContext context, Batsmen data) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.34,
            child: Row(
              children: [
                const Image(
                  image: AssetImage(Images.imageDefalutPlayer),
                  height: 30,
                  width: 30,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name ?? "",
                        style: GoogleFonts.exo2(
                          fontWeight: FontWeight.w600,
                          color: AppColors.letterColor,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        data.howOut ?? "",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: (data.howOut == 'Not out')
                              ? AppColors.green
                              : AppColors.letterColor,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            data.runs ?? "",
            style: GoogleFonts.tomorrow(
              fontWeight: FontWeight.w600,
              color: AppColors.letterColor,
              fontSize: 12,
            ),
          ),
          Text(
            data.balls ?? "0",
            style: GoogleFonts.tomorrow(
              fontWeight: FontWeight.w600,
              color: AppColors.letterColor,
              fontSize: 12,
            ),
          ),
          Text(
            data.fours ?? "0",
            style: GoogleFonts.tomorrow(
              fontWeight: FontWeight.w600,
              color: AppColors.letterColor,
              fontSize: 12,
            ),
          ),
          Text(
            data.sixes ?? "0",
            style: GoogleFonts.tomorrow(
              fontWeight: FontWeight.w600,
              color: AppColors.letterColor,
              fontSize: 12,
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              data.strikeRate ?? "0.0",
              textAlign: TextAlign.center,
              style: GoogleFonts.tomorrow(
                fontWeight: FontWeight.w600,
                color: AppColors.letterColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget singleBolwer(Bowlers data, BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.27,
            child: Text(
              data.name ?? "",
              style: GoogleFonts.exo2(
                fontWeight: FontWeight.w600,
                color: AppColors.letterColor,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            data.overs ?? "0",
            style: GoogleFonts.exo2(
              fontWeight: FontWeight.w600,
              color: AppColors.letterColor,
              fontSize: 12,
            ),
          ),
          Text(
            data.maidens ?? "0",
            style: GoogleFonts.tomorrow(
              fontWeight: FontWeight.w600,
              color: AppColors.letterColor,
              fontSize: 12,
            ),
          ),
          Text(
            data.runs ?? "0",
            style: GoogleFonts.tomorrow(
              fontWeight: FontWeight.w600,
              color: AppColors.letterColor,
              fontSize: 12,
            ),
          ),
          Text(
            data.wickets ?? "0",
            style: GoogleFonts.tomorrow(
              fontWeight: FontWeight.w600,
              color: AppColors.letterColor,
              fontSize: 12,
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              data.economyRate ?? "0.0",
              textAlign: TextAlign.center,
              style: GoogleFonts.tomorrow(
                fontWeight: FontWeight.w600,
                color: AppColors.letterColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget singleFallOfWicket(BuildContext context, FallOfWickets data) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Text(
              data.name ?? "0",
              style: GoogleFonts.exo2(
                fontWeight: FontWeight.w600,
                color: AppColors.letterColor,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            '${data.scoreAtDismissal ?? "0"}-${data.number}',
            style: GoogleFonts.tomorrow(
              fontWeight: FontWeight.w600,
              color: AppColors.letterColor,
              fontSize: 12,
            ),
          ),
          Text(
            data.oversAtDismissal ?? "0",
            style: GoogleFonts.tomorrow(
              fontWeight: FontWeight.w600,
              color: AppColors.letterColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
