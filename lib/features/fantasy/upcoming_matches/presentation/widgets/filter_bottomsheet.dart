// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
// import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
// import 'package:unified_dream247/features/fantasy/core/global_widgets/main_button.dart';

// class FilterBottomSheet extends StatefulWidget {
//   final Function(Set<String>) onApplyFilters;
//   final Set<String> initialSelectedFilters;

//   const FilterBottomSheet({
//     super.key,
//     required this.onApplyFilters,
//     required this.initialSelectedFilters,
//   });

//   @override
//   State<FilterBottomSheet> createState() => _FilterBottomSheetState();
// }

// class _FilterBottomSheetState extends State<FilterBottomSheet> {
//   late Set<String> selectedFilters;

//   @override
//   void initState() {
//     super.initState();
//     selectedFilters = Set.from(widget.initialSelectedFilters);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: AppColors.white,
//       child: SafeArea(
//         child: Container(
//           decoration: BoxDecoration(
//             color: AppColors.white,
//             borderRadius: BorderRadius.circular(20.0),
//           ),
//           width: MediaQuery.of(context).size.width,
//           height: MediaQuery.of(context).size.height * 0.85,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(15),
//                       color: AppColors.lightCard,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           InkWell(
//                             onTap: () {
//                               Navigator.pop(context);
//                             },
//                             child: const Icon(Icons.close, size: 22),
//                           ),
//                           const Text(
//                             'Filters',
//                             style: TextStyle(
//                               color: AppColors.letterColor,
//                               fontWeight: FontWeight.w800,
//                               fontSize: 16,
//                             ),
//                           ),
//                           InkWell(
//                             onTap: () {
//                               setState(() {
//                                 selectedFilters.clear();
//                               });
//                             },
//                             child: Text(
//                               'Clear'.toUpperCase(),
//                               style: const TextStyle(
//                                 color: AppColors.letterColor,
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(10.0),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             Strings.entryFee,
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                               color: AppColors.letterColor,
//                             ),
//                           ),
//                           Wrap(
//                             children: [
//                               selectionFilterBox(
//                                 "${Strings.indianRupee}0 - ${Strings.indianRupee}50",
//                               ),
//                               selectionFilterBox(
//                                 "${Strings.indianRupee}51 - ${Strings.indianRupee}100",
//                               ),
//                               selectionFilterBox(
//                                 "${Strings.indianRupee}101 - ${Strings.indianRupee}1,000",
//                               ),
//                               selectionFilterBox(
//                                 "${Strings.indianRupee}1001 & above",
//                               ),
//                             ],
//                           ),
//                           const Text(
//                             Strings.spots,
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                               color: AppColors.letterColor,
//                             ),
//                           ),
//                           Wrap(
//                             children: [
//                               selectionFilterBox("2"),
//                               selectionFilterBox("3 - 10"),
//                               selectionFilterBox("11 - 100"),
//                               selectionFilterBox("101 - 1,000"),
//                               selectionFilterBox("1,001 & above"),
//                             ],
//                           ),
//                           const Text(
//                             Strings.prizePool,
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                               color: AppColors.letterColor,
//                             ),
//                           ),
//                           Wrap(
//                             children: [
//                               selectionFilterBox(
//                                 "${Strings.indianRupee}1 - ${Strings.indianRupee}10,000",
//                               ),
//                               selectionFilterBox(
//                                 "${Strings.indianRupee}10,000 - ${Strings.indianRupee}1 Lakh",
//                               ),
//                               selectionFilterBox(
//                                 "${Strings.indianRupee}1 Lakh - ${Strings.indianRupee}10 Lakh",
//                               ),
//                               selectionFilterBox(
//                                 "${Strings.indianRupee}10 Lakh - ${Strings.indianRupee}25 Lakh",
//                               ),
//                               selectionFilterBox(
//                                 "${Strings.indianRupee}25 Lakh or more",
//                               ),
//                             ],
//                           ),
//                           const Text(
//                             Strings.contestType,
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                               color: AppColors.letterColor,
//                             ),
//                           ),
//                           Wrap(
//                             children: [
//                               selectionFilterBox(Strings.singleEntry),
//                               selectionFilterBox(Strings.multiEntry),
//                               selectionFilterBox(Strings.singleWinner),
//                               selectionFilterBox(Strings.multiWinner),
//                               selectionFilterBox(Strings.guaranteed),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Center(
//                 child: MainButton(
//                   margin: const EdgeInsets.all(10.0),
//                   color: AppColors.green,
//                   text: Strings.apply,
//                   textColor: AppColors.white,
//                   onTap: () {
//                     widget.onApplyFilters(selectedFilters);
//                     Navigator.pop(context);
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget selectionFilterBox(String textValue) {
//     bool isSelected = selectedFilters.contains(textValue);
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           if (isSelected) {
//             selectedFilters.remove(textValue);
//           } else {
//             selectedFilters.add(textValue);
//           }
//         });
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
//         padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 8.0),
//         decoration: BoxDecoration(
//           color: isSelected ? AppColors.green.withAlpha(26) : AppColors.white,
//           border: Border.all(
//             color: isSelected ? AppColors.green : AppColors.whiteFade1,
//           ),
//           borderRadius: BorderRadius.circular(18.0),
//         ),
//         child: Text(
//           textValue,
//           style:
//               (textValue.contains(Strings.indianRupee, 0))
//                   ? GoogleFonts.tomorrow(
//                     fontSize: 14,
//                     color: isSelected ? AppColors.green : AppColors.letterColor,
//                   )
//                   : TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: isSelected ? AppColors.green : AppColors.letterColor,
//                   ),
//         ),
//       ),
//     );
//   }
// }

import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';

class FilterBottomSheet extends StatefulWidget {
  final Function(Set<String>) onApplyFilters;
  final Set<String> initialSelectedFilters;

  const FilterBottomSheet({
    super.key,
    required this.onApplyFilters,
    required this.initialSelectedFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Set<String> selectedFilters;

  @override
  void initState() {
    super.initState();
    selectedFilters = Set.from(widget.initialSelectedFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------- HEADER ----------
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.mainGradient,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.mainColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(
                                Icons.close,
                                size: 22,
                                color: AppColors.white,
                              ),
                            ),
                            Text(
                              'Filters',
                              style: GoogleFonts.tomorrow(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  selectedFilters.clear();
                                });
                              },
                              child: Text(
                                'CLEAR',
                                style: GoogleFonts.tomorrow(
                                  color: AppColors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ---------- FILTER BODY ----------
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle(Strings.entryFee),
                            _filterGroup([
                              "${Strings.indianRupee}0 - ${Strings.indianRupee}50",
                              "${Strings.indianRupee}51 - ${Strings.indianRupee}100",
                              "${Strings.indianRupee}101 - ${Strings.indianRupee}1,000",
                              "${Strings.indianRupee}1001 & above",
                            ], isGameToken: true),
                            _sectionTitle(Strings.spots),
                            _filterGroup([
                              "2",
                              "3 - 10",
                              "11 - 100",
                              "101 - 1,000",
                              "1,001 & above",
                            ]),
                            _sectionTitle(Strings.prizePool),
                            _filterGroup([
                              "${Strings.indianRupee}1 - ${Strings.indianRupee}10,000",
                              "${Strings.indianRupee}10,000 - ${Strings.indianRupee}1 Lakh",
                              "${Strings.indianRupee}1 Lakh - ${Strings.indianRupee}10 Lakh",
                              "${Strings.indianRupee}10 Lakh - ${Strings.indianRupee}25 Lakh",
                              "${Strings.indianRupee}25 Lakh or more",
                            ]),
                            _sectionTitle(Strings.contestType),
                            _filterGroup([
                              Strings.singleEntry,
                              Strings.multiEntry,
                              Strings.singleWinner,
                              Strings.multiWinner,
                              Strings.guaranteed,
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---------- APPLY BUTTON ----------
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.transparent,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    widget.onApplyFilters(selectedFilters);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.mainGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mainColor.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      Strings.apply.toUpperCase(),
                      style: GoogleFonts.tomorrow(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Section title ----------
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        title,
        style: GoogleFonts.exo2(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.letterColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  // ---------- Filter group ----------
  Widget _filterGroup(List<String> items, {bool isGameToken = false}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          items.map((text) => selectionFilterBox(text, isGameToken)).toList(),
    );
  }

  // ---------- Filter chip ----------
  Widget selectionFilterBox(String textValue, bool isGameToken) {
    bool isSelected = selectedFilters.contains(textValue);

    final displayText = isGameToken
        ? textValue.replaceAll(Strings.indianRupee, "").trim()
        : textValue;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedFilters.remove(textValue);
          } else {
            selectedFilters.add(textValue);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.mainGradient : null,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? AppColors.mainColor : AppColors.whiteFade1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isGameToken) ...[
              Image.asset(
                Images.matchToken,
                height: 14,
                width: 14,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              displayText,
              style: GoogleFonts.tomorrow(
                fontSize: 13.5,
                color: isSelected ? AppColors.white : AppColors.letterColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
