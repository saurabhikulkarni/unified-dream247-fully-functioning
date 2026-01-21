import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/all_contests_model.dart';

class PriceCard extends StatefulWidget {
  final String? mode;
  final List<Matchpricecards>? currentFillCards;
  final List<Matchpricecards> list;
  final List<Extrapricecard>? extraPriceList;
  final String? flexible;
  final String? textNote;

  const PriceCard({
    super.key,
    required this.list,
    this.flexible,
    this.textNote,
    this.extraPriceList,
    this.currentFillCards,
    this.mode,
  });

  @override
  State<PriceCard> createState() => _PriceCardState();
}

class _PriceCardState extends State<PriceCard> {
  bool isMaxFillSelected = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFlexible = AppSingleton.singleton.appData.flexibleContest == 1;
    final currentList = (isFlexible)
        ? (isMaxFillSelected
            ? widget.list
            : widget.currentFillCards ?? widget.list)
        : widget.list;

    List<Matchpricecards> sortedList = List.from(currentList);
    sortedList.sort(
      (a, b) => (a.maxPosition ?? 0).compareTo(b.maxPosition ?? 0),
    );

    return Column(
      children: [
        // (widget.mode == "Upcoming" &&
        //         AppSingleton.singleton.appData.flexibleContest == 1)
        //     ? (widget.flexible == "1")
        //         ? Padding(
        //           padding: const EdgeInsets.symmetric(vertical: 8),
        //           child: Row(
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             children: [
        //               _toggleButton("Max Fill", isMaxFillSelected, () {
        //                 setState(() => isMaxFillSelected = true);
        //               }),
        //               const SizedBox(width: 10),
        //               _toggleButton("Current Fill", !isMaxFillSelected, () {
        //                 setState(() => isMaxFillSelected = false);
        //               }),
        //             ],
        //           ),
        //         )
        //         : const SizedBox.shrink()
        //     : const SizedBox.shrink(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Table(
            columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(2)},
            children: const [
              TableRow(
                decoration: BoxDecoration(color: AppColors.white),
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Rank',
                      style: TextStyle(
                        color: AppColors.letterColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Winnings',
                        style: TextStyle(
                          color: AppColors.letterColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(4),
                    1: FlexColumnWidth(2),
                  },
                  children: _buildAllTableRows(sortedList),
                ),
                // if (isFlexible &&
                //     !isMaxFillSelected &&
                //     (widget.currentFillCards?.isEmpty ?? true))
                //   Padding(
                //     padding: const EdgeInsets.all(30),
                //     child: Text(
                //       "Current Fill price card not available yet.",
                //       style: GoogleFonts.exo2(
                //         color: AppColors.blackOne,
                //         fontSize: 14,
                //         fontWeight: FontWeight.w500,
                //       ),
                //     ),
                //   ),
                if (widget.textNote != null && widget.textNote!.isNotEmpty)
                  Container(
                    color: AppColors.bgColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 3.0,
                      horizontal: 15,
                    ),
                    child: Center(
                      child: Text(
                        widget.textNote ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if ((widget.flexible ?? '0') == '1')
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'The price card for this contest can be adjusted based on the number of entries received.',
              style: TextStyle(
                color: AppColors.letterColor,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  // Widget _toggleButton(String title, bool isSelected, Function() onTap) {
  //   return InkWell(
  //     onTap: onTap,
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(12.0),
  //         color: isSelected ? AppColors.mainColor : AppColors.letterColor,
  //       ),
  //       child: Text(
  //         title,
  //         style: const TextStyle(
  //           fontSize: 12,
  //           color: AppColors.white,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  List<TableRow> _buildAllTableRows(List<Matchpricecards> currentList) {
    List<TableRow> allRows = [];
    final Map<int, int> extraRankMap = {
      for (var e in (widget.extraPriceList ?? []))
        (e.rank ?? 0): e.price?.toInt() ?? 0,
    };

    final Set<int> shownRanks = {};

    for (var data in currentList) {
      int start = (data.minPosition ?? 0) + 1;
      int end = data.maxPosition ?? 1;
      int basePrize = data.price?.toInt() ?? 0;

      int rangeStart = start;

      for (int i = start; i <= end; i++) {
        if (extraRankMap.containsKey(i)) {
          if (rangeStart < i) {
            allRows.add(_buildRangeRow(rangeStart, i - 1, basePrize));
            for (int r = rangeStart; r < i; r++) {
              shownRanks.add(r);
            }
          }
          allRows.add(_buildSingleRow(i, basePrize, extraRankMap[i]!));
          shownRanks.add(i);
          rangeStart = i + 1;
        }
      }

      if (rangeStart <= end) {
        allRows.add(_buildRangeRow(rangeStart, end, basePrize));
        for (int r = rangeStart; r <= end; r++) {
          shownRanks.add(r);
        }
      }
    }

    // Add any extra ranks outside main pricecard ranges
    for (var extra in (widget.extraPriceList ?? [])) {
      int rank = extra.rank ?? 0;
      if (!shownRanks.contains(rank)) {
        allRows.add(_buildSingleRow(rank, 0, extra.price?.toInt() ?? 0));
        shownRanks.add(rank);
      }
    }

    return allRows;
  }

  TableRow _buildRangeRow(int start, int end, int basePrize) {
    String rankText = (start == end)
        ? (start <= 3 ? '' : '#${AppUtils.stringifyNumber(start)}')
        : '#${AppUtils.stringifyNumber(start)} - ${AppUtils.stringifyNumber(end)}';

    return TableRow(
      children: [
        Container(
          height: 50,
          color: (start <= 3 && end <= 3)
              ? AppColors.shade1White
              : AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              if (start == end && start <= 3)
                _buildRankIndicator(start)
              else
                Text(
                  rankText,
                  style: const TextStyle(
                    color: AppColors.letterColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        Container(
          height: 50,
          color: (start <= 3 && end <= 3)
              ? AppColors.shade1White
              : AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          alignment: Alignment.centerRight,
          child: Text(
            '${Strings.indianRupee}${AppUtils.changeNumberToValue(basePrize)}',
            style: GoogleFonts.tomorrow(
              color: AppColors.letterColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  TableRow _buildSingleRow(int rank, int basePrize, int extraPrize) {
    bool onlyExtraPrize = basePrize == 0 && extraPrize > 0;

    return TableRow(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/upcoming_matches/rect_box.png'),
          fit: BoxFit.fill,
        ),
      ),
      children: [
        Container(
          height: 60,
          padding: const EdgeInsets.fromLTRB(15, 8, 0, 8),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              if (rank <= 3)
                _buildRankIndicator(rank)
              else
                Text(
                  '#${AppUtils.stringifyNumber(rank)}',
                  style: const TextStyle(
                    color: AppColors.letterColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        Container(
          height: 60,
          padding: const EdgeInsets.fromLTRB(0, 8, 10, 8),
          alignment: onlyExtraPrize ? Alignment.center : Alignment.centerRight,
          child: Column(
            mainAxisAlignment: onlyExtraPrize
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            crossAxisAlignment: onlyExtraPrize
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.end,
            children: [
              if (basePrize > 0)
                Text(
                  '${Strings.indianRupee}${AppUtils.changeNumberToValue(basePrize)}',
                  style: GoogleFonts.tomorrow(
                    color: AppColors.letterColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (extraPrize > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(Images.extraCashBox),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      '${basePrize > 0 ? "+ " : ""}${Strings.indianRupee}${AppUtils.changeNumberToValue(extraPrize)} Extra Cash Prize  ',
                      style: GoogleFonts.tomorrow(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankIndicator(int? position) {
    if (position == 1 || position == 2 || position == 3) {
      return Text(
        '#${AppUtils.stringifyNumber(num.parse(position.toString()))}',
        style: const TextStyle(
          color: AppColors.letterColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
