// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_pages.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/all_contests_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/teams_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/upcoming_match_datsource.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/domain/use_cases/upcoming_match_usecase.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/providers/myteams_provider.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/screens/all_contest.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/screens/guru_teams.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/screens/my_contest.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/screens/my_teams.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/widgets/contest_head.dart';

class ContestPage extends StatefulWidget {
  final String? mode;
  const ContestPage({super.key, this.mode});

  @override
  State<ContestPage> createState() => _ContestPageState();
}

class _ContestPageState extends State<ContestPage>
    with SingleTickerProviderStateMixin {
  int contestCount = 0;
  int teamsCount = 0;
  late TabController _tabController;
  Future<List<AllContestResponseModel>?>? contestList;
  Future<List<AllNewContestResponseModel>?>? newContestList;
  UpcomingMatchUsecase upcomingMatchUsecase = UpcomingMatchUsecase(
    UpcomingMatchDatsource(ApiImpl(), ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: (AppSingleton.singleton.appData.guruTeam == 1) ? 4 : 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _goToTab(int index) {
    _tabController.animateTo(index);
  }

  void showMatchTimeOverDialog(BuildContext ctx) async {
    showDialog(
      context: ctx,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.sports_esports,
                  color: AppColors.lightGreen.withAlpha(200),),
              const SizedBox(width: 8),
              Text(
                'Time Over!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGreen.withAlpha(200),
                ),
              ),
            ],
          ),
          content: const Text(
            '🎉 Contest for this match are closed now, Join upcoming matches and enjoy winnings. 🎉',
            style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.5),
          ),
          actions: <Widget>[
            InkWell(
              child: const Text('OK'),
              onTap: () {
                AppNavigation.gotoLandingScreenReplacement(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ContestHead(
      safeAreaColor: AppColors.white,
      isLiveContest: false,
      showWalletIcon: true,
      showAppBar: true,
      addPadding: false,
      updateIndex: (p0) => 0,
      child: DefaultTabController(
        length: (AppSingleton.singleton.appData.guruTeam == 1) ? 4 : 3,
        child: Scaffold(
          backgroundColor: AppColors.white,
          appBar: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicator: BoxDecoration(
              color: AppColors.mainColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.mainColor, width: 1),
            ),
            indicatorPadding: const EdgeInsets.symmetric(vertical: 6),
            labelColor: AppColors.blackColor,
            unselectedLabelColor: AppColors.blackColor.withValues(alpha: 0.6),
            labelStyle: GoogleFonts.exo2(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            unselectedLabelStyle: GoogleFonts.exo2(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            splashBorderRadius: BorderRadius.circular(10),
            labelPadding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 6,
            ),
            tabs: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 12,
                ),
                child: Text(
                  Strings.contests,
                  style: GoogleFonts.exo2(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              ValueListenableBuilder<int>(
                valueListenable: AppUtils.contestCount,
                builder: (BuildContext context, int value, Widget? child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    child: Text(
                      'My Contest ($value)',
                      style: GoogleFonts.exo2(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
              ValueListenableBuilder<int>(
                valueListenable: AppUtils.teamsCount,
                builder: (BuildContext context, int value, Widget? child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    child: Text(
                      'My Teams ($value)',
                      style: GoogleFonts.exo2(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
              if (AppSingleton.singleton.appData.guruTeam == 1)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  child: Text(
                    'Guru',
                    style: GoogleFonts.exo2(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(
              //     vertical: 6,
              //     horizontal: 12,
              //   ),
              //   child: Text(
              //     'Statistics',
              //     style: GoogleFonts.exo2(
              //       fontWeight: FontWeight.bold,
              //       fontSize: 12,
              //     ),
              //   ),
              // )
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              AllContests(mode: widget.mode),
              MyContests(mode: widget.mode),
              MyTeams(
                mode: 'Upcoming',
                switchTab: () {
                  if (AppSingleton.singleton.appData.guruTeam == 1) {
                    _goToTab(3);
                  }
                },
                updateHasChanges: (canLoad) async {
                  if (canLoad) {
                    List<TeamsModel> updatedTeams =
                        await upcomingMatchUsecase.getMyTeams(context);
                    Provider.of<MyTeamsProvider>(
                      context,
                      listen: false,
                    ).updateMyTeams(
                      updatedTeams,
                      AppSingleton.singleton.matchData.id ?? '',
                    );
                  }
                },
              ),
              if (AppSingleton.singleton.appData.guruTeam == 1)
                const GuruTeams(),
              // StatisticsScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
