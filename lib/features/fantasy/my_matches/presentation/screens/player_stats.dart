// ignore_for_file: use_build_context_synchronously

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/common_shimmer_view_widget.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/no_data_widget.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/match_player_teams_model.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/my_matches_datasource.dart';
import 'package:unified_dream247/features/fantasy/my_matches/domain/use_cases/my_matches_usecases.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/provider/player_stats_provider.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/screens/player_stats_details.dart';

class PlayerStats extends StatefulWidget {
  final String? mode;
  const PlayerStats({super.key, this.mode});

  @override
  State<PlayerStats> createState() => _PlayerStats();
}

class _PlayerStats extends State<PlayerStats> {
  List<MatchPlayerTeamsModel>? players;
  String sortBy = '';
  bool isPlayerEnable = false;
  bool isPointsEnable = false;
  bool isSelectByEnable = false;
  bool isLoading = false;
  MyMatchesUsecases myMatchesUsecases = MyMatchesUsecases(
    MyMatchesDatasource(ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    fetchPlayers();
  }

  Future<void> fetchPlayers() async {
    var provider = Provider.of<PlayerStatsProvider>(context, listen: false);
    String matchKey = AppSingleton.singleton.matchData.id ?? '';

    setState(() {
      isLoading = true;
    });

    if (widget.mode == 'Completed' ||
        widget.mode == 'Abandoned' ||
        widget.mode == 'Cancelled') {
      if ((provider.matchPlayer[matchKey]?.isNotEmpty ?? false)) {
        setState(() {
          players = provider.matchPlayer[matchKey];
          isLoading = false;
        });
        return;
      } else {
        final data = await myMatchesUsecases.matchplayerfantasyscorecards(
          context,
        );
        setState(() {
          players = data;
          isLoading = false;
        });
        return;
      }
    }

    if (widget.mode == 'Live') {
      final data = await myMatchesUsecases.matchplayerfantasyscorecards(
        context,
      );
      setState(() {
        players = data;
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (players == null && isLoading) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: 15,
        itemBuilder: (context, index) {
          return ShimmerWidget(
            width: MediaQuery.of(context).size.width,
            height: 50,
            margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
          );
        },
      );
    } else if (players == null) {
      return const Center(child: Text(Strings.somethingWentWrong));
    } else if (players!.isEmpty) {
      return const Center(
        child: NoDataWidget(title: 'No Player Data Found', showButton: false),
      );
    }
    List<MatchPlayerTeamsModel> sortedList = [...players!];
    if (sortBy == 'player') {
      sortedList.sort(
        (a, b) => isPlayerEnable
            ? a.name!.compareTo(b.name!)
            : b.name!.compareTo(a.name!),
      );
    } else if (sortBy == 'points') {
      sortedList.sort(
        (a, b) => isPointsEnable
            ? a.total!.compareTo(b.total!)
            : b.total!.compareTo(a.total!),
      );
    } else if (sortBy == 'selection') {
      sortedList.sort(
        (a, b) => isSelectByEnable
            ? a.totalSelected!.compareTo(b.totalSelected!)
            : b.totalSelected!.compareTo(a.totalSelected!),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await fetchPlayers();
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.white,
          border: Border.all(color: AppColors.whiteFade1, width: 2),
        ),
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // 🔹 Header Row
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.mainColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackColor.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                    color: AppColors.lightGrey.withValues(alpha: 0.3),),
              ),
              child: Row(
                children: [
                  // 🔸 Player Column Header
                  Expanded(
                    flex: 5,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        setState(() {
                          sortBy = 'player';
                          isPlayerEnable = !isPlayerEnable;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'PLAYER',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.exo2(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.letterColor,
                              ),
                            ),
                          ),
                          if (sortBy == 'player') ...[
                            const SizedBox(width: 3),
                            Icon(
                              isPlayerEnable
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              color: AppColors.letterColor,
                              size: 13,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Divider
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 1,
                    height: 28,
                    color: AppColors.lightGrey.withValues(alpha: 0.6),
                  ),

                  // 🔸 Points Column Header
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        setState(() {
                          sortBy = 'points';
                          isPointsEnable = !isPointsEnable;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'POINTS',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.exo2(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.letterColor,
                              ),
                            ),
                          ),
                          if (sortBy == 'points') ...[
                            const SizedBox(width: 3),
                            Icon(
                              isPointsEnable
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              color: AppColors.letterColor,
                              size: 13,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Divider
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 1,
                    height: 28,
                    color: AppColors.lightGrey.withValues(alpha: 0.6),
                  ),

                  // 🔸 %Sel By Column Header
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        setState(() {
                          sortBy = 'selection';
                          isSelectByEnable = !isSelectByEnable;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              '%SEL BY',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.exo2(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.letterColor,
                              ),
                            ),
                          ),
                          if (sortBy == 'selection') ...[
                            const SizedBox(width: 3),
                            Icon(
                              isSelectByEnable
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              color: AppColors.letterColor,
                              size: 13,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Player List
            MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Expanded(
                child: ListView.builder(
                  itemCount: sortedList.length,
                  itemBuilder: (context, index) {
                    return singlePlayerStats(sortedList, index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget singlePlayerStats(List<MatchPlayerTeamsModel> data, int index) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) =>
                PlayerStatsDetails(
              fantasyType: 'Cricket',
              playerId: data[index].id,
              list: data,
            ),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 Player Image
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.network(
                '${data[index].image}',
                height: 46,
                width: 46,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 46,
                  width: 46,
                  color: AppColors.lightCard,
                  child: const Icon(
                    Icons.person,
                    color: AppColors.lightGrey,
                    size: 22,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // 🔹 Player Name + Team + Role
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data[index].name ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.exo2(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.letterColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${data[index].teamName ?? ""} • ${AppUtils.changeRole(data[index].role)}',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.exo2(
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      color: AppColors.greyColor,
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Divider
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 1,
              height: 40,
              color: AppColors.lightGrey.withValues(alpha: 0.6),
            ),

            // 🔹 Total points
            Expanded(
              flex: 2,
              child: Text(
                '${data[index].total}',
                textAlign: TextAlign.center,
                style: GoogleFonts.tomorrow(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.letterColor,
                ),
              ),
            ),

            // 🔹 Selected percentage
            Expanded(
              flex: 2,
              child: Text(
                '${data[index].totalSelected}%',
                textAlign: TextAlign.center,
                style: GoogleFonts.exo2(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppColors.greyColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
