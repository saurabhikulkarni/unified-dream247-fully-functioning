// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/material.dart';
// import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl_header.dart';
// import 'package:Dream247/core/app_constants/app_colors.dart';
// import 'package:Dream247/core/app_constants/app_pages.dart';
// import 'package:Dream247/core/app_constants/images.dart';
// import 'package:Dream247/core/app_constants/strings.dart';
// import 'package:Dream247/core/global_widgets/app_toast.dart';
// import 'package:Dream247/core/utils/app_utils.dart';
// import 'package:Dream247/features/landing/data/singleton/app_singleton.dart';
// import 'package:Dream247/features/my_matches/data/models/live_challenges_model.dart';
// import 'package:Dream247/features/my_matches/data/my_matches_datasource.dart';
// import 'package:Dream247/features/my_matches/domain/use_cases/my_matches_usecases.dart';
// import 'package:Dream247/features/my_matches/presentation/widgets/live_leaderboard_shimmer_widget.dart';
// import 'package:Dream247/features/upcoming_matches/data/models/leaderboard_model.dart';

// class LiveContestView extends StatefulWidget {
//   final String? mode;
//   final LiveChallengesData data;
//   final String challengeId;
//   final String finalStatus;
//   const LiveContestView({
//     super.key,
//     required this.data,
//     this.mode,
//     required this.challengeId,
//     required this.finalStatus,
//   });

//   @override
//   State<LiveContestView> createState() => _LiveContestView();
// }

// class _LiveContestView extends State<LiveContestView> {
//   bool isExpanded = false;
//   List<LiveJointeams> list = [];
//   List<LiveJointeams> fullList = [];
//   int currentDisplayCount = 5;
//   int skip = 0;
//   int limit = 100;
//   bool isLoadingMore = false;
//   MyMatchesUsecases myMatchesUsecases = MyMatchesUsecases(
//     MyMatchesDatasource(ApiImplWithAccessToken()),
//   );

//   @override
//   void initState() {
//     super.initState();
//     if (AppSingleton.singleton.appData.myJoinedContest == true) {
//       loadSelfData();
//     }
//   }

//   void loadSelfData() async {
//     setState(() {
//       isLoadingMore = true;
//     });
//     final response = await myMatchesUsecases.getSelfLeaderboardLive(
//       context,
//       widget.challengeId,
//       widget.finalStatus,
//       skip,
//       limit,
//     );
//     if (response != null) {
//       final selfList =
//           LiveLeaderboardModel.fromJson(response).data?.jointeams ?? [];

//       setState(() {
//         fullList = selfList;
//         list = fullList.take(currentDisplayCount).toList();
//         isLoadingMore = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.zero,
//       margin: const EdgeInsets.all(10).copyWith(bottom: 0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: AppColors.shade1White,
//         border: Border.all(color: AppColors.lightGrey, width: 1.0),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.black.withValues(alpha:0.05),
//             blurRadius: 10,
//             spreadRadius: 20,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: InkWell(
//         onTap: () {
//           if (widget.data.matchChallengeStatus != 'canceled') {
//             AppNavigation.gotoLiveContestDetails(
//               context,
//               widget.data,
//               widget.mode,
//             );
//           } else {
//             appToast('This contest is cancelled', context);
//           }
//         },
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 3,
//                           vertical: 3,
//                         ),
//                         child:
//                             ((widget.data.flexibleContest ?? "0") == "1")
//                                 ? Row(
//                                   children: [
//                                     const Icon(
//                                       Icons.trending_up_rounded,
//                                       size: 15,
//                                       color: AppColors.letterColor,
//                                     ),
//                                     Text(
//                                       Strings.flexiblePrizePool,
//                                       style: GoogleFonts.exo2(
//                                         color: AppColors.greyColor,
//                                         fontWeight: FontWeight.w400,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ],
//                                 )
//                                 : (widget.data.confirmedChallenge == 1)
//                                 ? Row(
//                                   children: [
//                                     Image.asset(
//                                       Images.verified,
//                                       height: 15,
//                                       width: 15,
//                                     ),
//                                     const SizedBox(width: 2),
//                                     Text(
//                                       Strings.guaranteePrizePool,
//                                       style: GoogleFonts.exo2(
//                                         color: AppColors.greyColor,
//                                         fontWeight: FontWeight.w400,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ],
//                                 )
//                                 : Text(
//                                   Strings.prizePool,
//                                   style: GoogleFonts.exo2(
//                                     color: AppColors.greyColor,
//                                     fontWeight: FontWeight.w400,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(4),
//                         child: Text(
//                           '${Strings.indianRupee}${AppUtils.changeNumberToValue(widget.data.winAmount?.toInt() ?? 0)}',
//                           style: GoogleFonts.tomorrow(
//                             color: AppColors.letterColor,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       const Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 3,
//                           vertical: 1,
//                         ),
//                         child: Text(
//                           'Entry',
//                           style: TextStyle(
//                             color: AppColors.letterColor,
//                             fontWeight: FontWeight.w400,
//                             fontSize: 10,
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(3),
//                         child: Text(
//                           '${Strings.indianRupee}${AppUtils.stringifyNumber(widget.data.entryfee!)}',
//                           style: GoogleFonts.tomorrow(
//                             color: AppColors.letterColor,
//                             fontWeight: FontWeight.w500,
//                             fontSize: 13,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//               decoration: BoxDecoration(
//                 color: AppColors.mainColor.withAlpha(20),
//                 borderRadius:
//                     (AppSingleton.singleton.appData.myJoinedContest == false)
//                         ? const BorderRadius.only(
//                           bottomLeft: Radius.circular(10),
//                           bottomRight: Radius.circular(10),
//                         )
//                         : BorderRadius.zero,
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Tooltip(
//                         message:
//                             widget.data.matchpricecards!.isEmpty
//                                 ? 'First Prize = ${Strings.indianRupee}${AppUtils.changeNumberToValue(widget.data.winAmount!.toInt())}'
//                                 : 'First Prize = ${Strings.indianRupee}${AppUtils.changeNumberToValue(widget.data.matchpricecards![0].price!.toInt())}',
//                         showDuration: const Duration(seconds: 2),
//                         triggerMode: TooltipTriggerMode.tap,
//                         padding: const EdgeInsets.all(8),
//                         textStyle: const TextStyle(
//                           color: AppColors.letterColor,
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         decoration: BoxDecoration(
//                           color: AppColors.white,
//                           border: Border.all(color: AppColors.whiteFade1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Stack(
//                               alignment: Alignment.center,
//                               children: [
//                                 Image.asset(
//                                   Images.winner,
//                                   height: 18,
//                                   width: 18,
//                                 ),
//                                 const Text(
//                                   "1",
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     color: AppColors.letterColor,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 5,
//                               ),
//                               child: Text(
//                                 widget.data.matchpricecards!.isEmpty
//                                     ? '${Strings.indianRupee}${AppUtils.changeNumberToValue(widget.data.winAmount!.toInt())}'
//                                     : '${Strings.indianRupee}${AppUtils.changeNumberToValue(widget.data.matchpricecards![0].price!.toInt())}',
//                                 style: GoogleFonts.tomorrow(
//                                   fontSize: 11,
//                                   color: AppColors.letterColor,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Tooltip(
//                         message:
//                             "${(widget.data.totalwinners ?? 1)} Teams win the contest",
//                         showDuration: const Duration(seconds: 2),
//                         triggerMode: TooltipTriggerMode.tap,
//                         padding: const EdgeInsets.all(8),
//                         textStyle: const TextStyle(
//                           color: AppColors.letterColor,
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         decoration: BoxDecoration(
//                           color: AppColors.white,
//                           border: Border.all(color: AppColors.whiteFade1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(
//                               Icons.emoji_events_outlined,
//                               size: 20,
//                               color: AppColors.letterColor,
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 2,
//                               ),
//                               child: Text(
//                                 (((widget.data.totalwinners ?? 1) /
//                                                 (widget.data.maximumUser ??
//                                                     1)) *
//                                             100) <
//                                         1
//                                     ? "1%"
//                                     : "${(((widget.data.totalwinners ?? 1) / (widget.data.maximumUser ?? 1)) * 100).round()}%",
//                                 style: GoogleFonts.exo2(
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 11,
//                                   color: AppColors.letterColor,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Tooltip(
//                         message:
//                             widget.data.multiEntry == 1
//                                 ? "Max ${widget.data.teamLimit} entry per user in this contest"
//                                 : "Max 1 entry per user in this contest",
//                         showDuration: const Duration(seconds: 2),
//                         triggerMode: TooltipTriggerMode.tap,
//                         padding: const EdgeInsets.all(8),
//                         textStyle: const TextStyle(
//                           color: AppColors.greyColor,
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         decoration: BoxDecoration(
//                           color: AppColors.white,
//                           border: Border.all(color: AppColors.whiteFade1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               width: 16,
//                               height: 16,
//                               decoration: BoxDecoration(
//                                 border: Border.all(width: 1),
//                                 borderRadius: BorderRadius.circular(2),
//                               ),
//                               child: Text(
//                                 widget.data.multiEntry == 1 ? 'M' : 'S',
//                                 textAlign: TextAlign.center,
//                                 style: const TextStyle(
//                                   fontSize: 9,
//                                   color: AppColors.greyColor,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 5,
//                               ),
//                               child: Text(
//                                 widget.data.multiEntry == 1
//                                     ? '${widget.data.teamLimit}'
//                                     : '',
//                                 style: GoogleFonts.exo2(
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 11,
//                                   color: AppColors.greyColor,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "${AppUtils.changeNumberToValue(widget.data.maximumUser ?? 1)} Spots",
//                         style: GoogleFonts.exo2(
//                           color: AppColors.letterColor,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 11,
//                         ),
//                       ),
//                       if (widget.data.matchChallengeStatus == 'canceled')
//                         Align(
//                           alignment: Alignment.center,
//                           child: Tooltip(
//                             message: "This contest is Cancelled",
//                             showDuration: const Duration(seconds: 2),
//                             triggerMode: TooltipTriggerMode.tap,
//                             padding: const EdgeInsets.all(8),
//                             textStyle: const TextStyle(
//                               color: AppColors.greyColor,
//                               fontSize: 11,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             decoration: BoxDecoration(
//                               color: AppColors.white,
//                               border: Border.all(color: AppColors.whiteFade1),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Text(
//                                 'Cancelled',
//                                 style: GoogleFonts.exo2(
//                                   color: AppColors.red,
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       if (widget.data.isPrivate == 1)
//                         Tooltip(
//                           message: "This contest is Private",
//                           showDuration: const Duration(seconds: 2),
//                           triggerMode: TooltipTriggerMode.tap,
//                           padding: const EdgeInsets.all(8),
//                           textStyle: const TextStyle(
//                             color: AppColors.greyColor,
//                             fontSize: 11,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           decoration: BoxDecoration(
//                             color: AppColors.white,
//                             border: Border.all(color: AppColors.whiteFade1),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.lock,
//                                 size: 15,
//                                 color: AppColors.greyColor,
//                               ),
//                               Text(
//                                 "P",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 12,
//                                   color: AppColors.greyColor,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       if (widget.data.isPromoCodeContest == true)
//                         Tooltip(
//                           message: "Join this contest with Coupon Code",
//                           showDuration: const Duration(seconds: 2),
//                           triggerMode: TooltipTriggerMode.tap,
//                           padding: const EdgeInsets.all(8),
//                           textStyle: const TextStyle(
//                             color: AppColors.greyColor,
//                             fontSize: 11,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           decoration: BoxDecoration(
//                             color: AppColors.white,
//                             border: Border.all(color: AppColors.whiteFade1),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.confirmation_num_outlined,
//                                 size: 18,
//                                 color: AppColors.greyColor,
//                               ),
//                               SizedBox(width: 2),
//                               Text(
//                                 "CC",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 12,
//                                   color: AppColors.greyColor,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             (AppSingleton.singleton.appData.myJoinedContest == true)
//                 ? isLoadingMore
//                     ? const LiveLeaderboardShimmerWidget()
//                     : ListView.builder(
//                       physics: const NeverScrollableScrollPhysics(),
//                       shrinkWrap: true,
//                       itemCount: 2,
//                       itemBuilder: (context, index) {
//                         final team = list[index];

//                         return Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 8,
//                           ),
//                           decoration: BoxDecoration(
//                             color: AppColors.yellowColor.withAlpha(8),
//                             borderRadius:
//                                 index == list.length - 1
//                                     ? const BorderRadius.only(
//                                       bottomLeft: Radius.circular(10),
//                                       bottomRight: Radius.circular(10),
//                                     )
//                                     : BorderRadius.zero,
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     '${team.teamname ?? ""} - T${team.teamnumber}',
//                                     style: GoogleFonts.tomorrow(
//                                       fontSize: 11,
//                                       color: AppColors.letterColor,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   Text(
//                                     '${team.points ?? 0}',
//                                     style: GoogleFonts.exo2(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 11,
//                                       color: AppColors.letterColor,
//                                     ),
//                                   ),
//                                   Text(
//                                     '#${team.getcurrentrank ?? 0}',
//                                     style: GoogleFonts.exo2(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 11,
//                                       color: AppColors.letterColor,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   if ((team.winingamount?.isNotEmpty ??
//                                           false) &&
//                                       double.tryParse(team.winingamount!) != 0)
//                                     Padding(
//                                       padding: const EdgeInsets.all(1),
//                                       child: Text(
//                                         'Won ${Strings.indianRupee}${AppUtils.changeNumberToValue(num.parse(team.winingamount ?? "0"))}',
//                                         style: GoogleFonts.tomorrow(
//                                           color: AppColors.mainColor,
//                                           fontSize: 11,
//                                           fontWeight: FontWeight.w400,
//                                         ),
//                                       ),
//                                     )
//                                   else
//                                     Visibility(
//                                       visible:
//                                           (team.getcurrentrank ?? 0) <=
//                                           (widget.data.totalwinners ?? 0),
//                                       replacement: const SizedBox(height: 14),
//                                       child: const Padding(
//                                         padding: EdgeInsets.all(1),
//                                         child: Text(
//                                           'In Winning Zone',
//                                           style: TextStyle(
//                                             color: AppColors.green,
//                                             fontSize: 11,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   if (index == list.length - 1 &&
//                                       fullList.length > list.length)
//                                     InkWell(
//                                       onTap: () {
//                                         setState(() {
//                                           currentDisplayCount += 5;
//                                           list =
//                                               fullList
//                                                   .take(currentDisplayCount)
//                                                   .toList();
//                                         });
//                                       },
//                                       child: const Icon(
//                                         Icons.arrow_drop_down,
//                                         color: AppColors.greyColor,
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     )
//                 : const SizedBox.shrink(),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/app_pages.dart';
import 'package:Dream247/core/app_constants/images.dart';
import 'package:Dream247/core/app_constants/strings.dart';
import 'package:Dream247/core/global_widgets/app_toast.dart';
import 'package:Dream247/core/utils/app_utils.dart';
import 'package:Dream247/features/landing/data/singleton/app_singleton.dart';
import 'package:Dream247/features/my_matches/data/models/live_challenges_model.dart';
import 'package:Dream247/features/my_matches/data/my_matches_datasource.dart';
import 'package:Dream247/features/my_matches/domain/use_cases/my_matches_usecases.dart';
import 'package:Dream247/features/my_matches/presentation/widgets/live_leaderboard_shimmer_widget.dart';
import 'package:Dream247/features/upcoming_matches/data/models/leaderboard_model.dart';

class LiveContestView extends StatefulWidget {
  final String? mode;
  final LiveChallengesData data;
  final String challengeId;
  final String finalStatus;
  const LiveContestView({
    super.key,
    required this.data,
    this.mode,
    required this.challengeId,
    required this.finalStatus,
  });

  @override
  State<LiveContestView> createState() => _LiveContestViewState();
}

class _LiveContestViewState extends State<LiveContestView> {
  bool isExpanded = false;
  List<LiveJointeams> list = [];
  List<LiveJointeams> fullList = [];
  int currentDisplayCount = 5;
  int skip = 0;
  int limit = 100;
  bool isLoadingMore = false;

  MyMatchesUsecases myMatchesUsecases = MyMatchesUsecases(
    MyMatchesDatasource(ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    if (AppSingleton.singleton.appData.myJoinedContest == true) {
      loadSelfData();
    }
  }

  void loadSelfData() async {
    setState(() => isLoadingMore = true);
    final response = await myMatchesUsecases.getSelfLeaderboardLive(
      context,
      widget.challengeId,
      widget.finalStatus,
      skip,
      limit,
    );
    if (response != null) {
      final selfList =
          LiveLeaderboardModel.fromJson(response).data?.jointeams ?? [];
      setState(() {
        fullList = selfList;
        list = fullList.take(currentDisplayCount).toList();
        isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.white,
            AppColors.whiteFade1.withValues(alpha: 0.9)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.whiteFade1, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        splashColor: AppColors.mainColor.withValues(alpha: 0.15),
        highlightColor: AppColors.mainColor.withValues(alpha: 0.05),
        onTap: () {
          if (widget.data.matchChallengeStatus != 'canceled') {
            AppNavigation.gotoLiveContestDetails(
              context,
              widget.data,
              widget.mode,
            );
          } else {
            appToast('This contest is cancelled', context);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Prize Pool Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPrizeType(),
                      const SizedBox(height: 4),
                      Text(
                        '${Strings.indianRupee}${AppUtils.changeNumberToValue(widget.data.winAmount?.toInt() ?? 0)}',
                        style: GoogleFonts.tomorrow(
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  // Entry Fee Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Entry',
                        style: GoogleFonts.exo2(
                          color: AppColors.greyColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.appBarGradient,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${Strings.indianRupee}${AppUtils.stringifyNumber(widget.data.entryfee!)}',
                          style: GoogleFonts.tomorrow(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Divider Line
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.mainColor.withValues(alpha: 0.3),
                    AppColors.transparent,
                    AppColors.mainColor.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),

            // Contest Details Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.mainColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.vertical(
                  bottom:
                      (AppSingleton.singleton.appData.myJoinedContest == false)
                          ? const Radius.circular(14)
                          : Radius.zero,
                ),
              ),
              child: _buildContestMeta(context),
            ),

            // My Leaderboard (if joined)
            if (AppSingleton.singleton.appData.myJoinedContest == true)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isLoadingMore
                    ? const LiveLeaderboardShimmerWidget()
                    : _buildLeaderboardList(),
              ),
          ],
        ),
      ),
    );
  }

  // --- Widget Extracts ---

  Widget _buildPrizeType() {
    if ((widget.data.flexibleContest ?? "0") == "1") {
      return Row(
        children: [
          const Icon(
            Icons.trending_up_rounded,
            size: 16,
            color: AppColors.greyColor,
          ),
          const SizedBox(width: 4),
          Text(
            Strings.flexiblePrizePool,
            style: GoogleFonts.exo2(
              color: AppColors.greyColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      );
    } else if (widget.data.confirmedChallenge == 1) {
      return Row(
        children: [
          Image.asset(Images.verified, height: 16, width: 16),
          const SizedBox(width: 4),
          Text(
            Strings.guaranteePrizePool,
            style: GoogleFonts.exo2(
              color: AppColors.greyColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      );
    } else {
      return Text(
        Strings.prizePool,
        style: GoogleFonts.exo2(
          color: AppColors.greyColor,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      );
    }
  }

  Widget _buildContestMeta(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left section with icons and tooltips
        Row(
          children: [
            _tooltipItem(
              icon: Images.winner,
              label:
                  '${Strings.indianRupee}${AppUtils.changeNumberToValue(widget.data.matchpricecards!.isEmpty ? widget.data.winAmount!.toInt() : widget.data.matchpricecards![0].price!.toInt())}',
              message:
                  'First Prize = ${Strings.indianRupee}${AppUtils.changeNumberToValue(widget.data.matchpricecards!.isEmpty ? widget.data.winAmount!.toInt() : widget.data.matchpricecards![0].price!.toInt())}',
            ),
            const SizedBox(width: 10),
            _tooltipItem(
              icon: Icons.emoji_events_outlined,
              label:
                  '${(((widget.data.totalwinners ?? 1) / (widget.data.maximumUser ?? 1)) * 100).round()}%',
              message:
                  "${(widget.data.totalwinners ?? 1)} Teams win the contest",
            ),
            const SizedBox(width: 10),
            _tooltipItem(
              icon: Icons.group_outlined,
              label: widget.data.multiEntry == 1
                  ? 'M${widget.data.teamLimit}'
                  : 'S',
              message: widget.data.multiEntry == 1
                  ? "Max ${widget.data.teamLimit} entries"
                  : "Single entry only",
            ),
          ],
        ),

        // Right side labels
        Row(
          children: [
            Text(
              "${AppUtils.changeNumberToValue(widget.data.maximumUser ?? 1)} Spots",
              style: GoogleFonts.exo2(
                color: AppColors.letterColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            if (widget.data.matchChallengeStatus == 'canceled')
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  'Cancelled',
                  style: GoogleFonts.exo2(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _tooltipItem({
    required dynamic icon,
    required String label,
    required String message,
  }) {
    return Tooltip(
      message: message,
      showDuration: const Duration(seconds: 2),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.whiteFade1),
      ),
      textStyle: GoogleFonts.exo2(
        color: AppColors.letterColor,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
      child: Row(
        children: [
          if (icon is String)
            Image.asset(icon, height: 18, width: 18)
          else
            Icon(icon, size: 18, color: AppColors.letterColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.tomorrow(
              fontSize: 11,
              color: AppColors.letterColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: list.length.clamp(0, 2),
      itemBuilder: (context, index) {
        final team = list[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.yellowColor.withValues(alpha: 0.1),
            borderRadius: index == list.length - 1
                ? const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  )
                : BorderRadius.zero,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${team.teamname ?? ""} - T${team.teamnumber}',
                    style: GoogleFonts.tomorrow(
                      fontSize: 11,
                      color: AppColors.letterColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${team.points ?? 0}',
                    style: GoogleFonts.exo2(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: AppColors.mainColor,
                    ),
                  ),
                  Text(
                    '#${team.getcurrentrank ?? 0}',
                    style: GoogleFonts.exo2(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: AppColors.letterColor,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if ((team.winingamount?.isNotEmpty ?? false) &&
                      double.tryParse(team.winingamount!) != 0)
                    Text(
                      'Won ${Strings.indianRupee}${AppUtils.changeNumberToValue(num.parse(team.winingamount ?? "0"))}',
                      style: GoogleFonts.tomorrow(
                        color: AppColors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    Visibility(
                      visible: (team.getcurrentrank ?? 0) <=
                          (widget.data.totalwinners ?? 0),
                      replacement: const SizedBox(height: 14),
                      child: Text(
                        'In Winning Zone',
                        style: GoogleFonts.exo2(
                          color: AppColors.mainColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (index == list.length - 1 && fullList.length > list.length)
                    InkWell(
                      onTap: () {
                        setState(() {
                          currentDisplayCount += 5;
                          list = fullList.take(currentDisplayCount).toList();
                        });
                      },
                      child: const Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.greyColor,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
