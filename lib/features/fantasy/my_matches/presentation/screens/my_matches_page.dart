// ignore_for_file: use_build_context_synchronously

import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/no_data_widget.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/my_matches_model.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/my_matches_datasource.dart';
import 'package:unified_dream247/features/fantasy/my_matches/domain/use_cases/my_matches_usecases.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/widgets/my_match_card.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/widgets/my_match_shimmer_view_widget.dart';

class MyMatchesPage extends StatefulWidget {
  final Function(int) updateIndex;
  const MyMatchesPage({super.key, required this.updateIndex});

  @override
  State<MyMatchesPage> createState() => _MyMatchesPage();
}

class _MyMatchesPage extends State<MyMatchesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  Future<List<MyMatchesModel>?>? upcomingMatchList;
  Future<List<MyMatchesModel>?>? liveMatchList;
  Future<List<MyMatchesModel>?>? completedMatchList;

  bool hasFetchedUpcoming = false;
  bool hasFetchedLive = false;
  bool hasFetchedCompleted = false;
  bool isViewingOldMatches = false;
  DateTime? lastUpcomingFetch;
  DateTime? lastLiveFetch;
  DateTime? lastCompletedFetch;
  int skip = 0;
  int limit = 300;
  int cursor = 0;

  MyMatchesUsecases myMatchesUsecases = MyMatchesUsecases(
    MyMatchesDatasource(ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();

    fetchMatches(0);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        fetchMatches(_tabController.index);
        _pageController.jumpToPage(_tabController.index);
      }
    });
  }

  void fetchMatches(int index) async {
    DateTime now = DateTime.now();

    if (index == 0 && !hasFetchedUpcoming) {
      upcomingMatchList = myMatchesUsecases.getUpcomingMatches(
        context,
        'Cricket',
      );
      hasFetchedUpcoming = true;
      lastUpcomingFetch = now;
    } else if (index == 1 && !hasFetchedLive) {
      if (mounted) setState(() => liveMatchList = null);

      liveMatchList = myMatchesUsecases.getLiveMatches(context, 'Cricket');
      hasFetchedLive = true;
      lastLiveFetch = now;
    } else if (index == 2 && !hasFetchedCompleted) {
      completedMatchList = isViewingOldMatches
          ? myMatchesUsecases.getCompletedOldMatches(
              context,
              'Cricket',
              skip,
              limit,
            )
          : myMatchesUsecases.getCompletedMatches(
              context,
              'Cricket',
              cursor,
            );

      hasFetchedCompleted = true;
      lastCompletedFetch = now;
    }

    if (mounted) setState(() {});
  }

  Future<void> refreshMatches() async {
    DateTime now = DateTime.now();
    int index = _tabController.index;

    if (index == 0 &&
        (lastUpcomingFetch == null ||
            now.difference(lastUpcomingFetch!) > const Duration(minutes: 1))) {
      upcomingMatchList = myMatchesUsecases.getUpcomingMatches(
        context,
        'Cricket',
      );
      lastUpcomingFetch = now;
    } else if (index == 1 &&
        (lastLiveFetch == null ||
            now.difference(lastLiveFetch!) > const Duration(minutes: 1))) {
      if (mounted) setState(() => liveMatchList = null);

      liveMatchList = myMatchesUsecases.getLiveMatches(context, 'Cricket');
      lastLiveFetch = now;
    } else if (index == 2 &&
        (lastCompletedFetch == null ||
            now.difference(lastCompletedFetch!) > const Duration(minutes: 1))) {
      completedMatchList = isViewingOldMatches
          ? myMatchesUsecases.getCompletedOldMatches(
              context,
              'Cricket',
              skip,
              limit,
            )
          : myMatchesUsecases.getCompletedMatches(
              context,
              'Cricket',
              cursor,
            );
      lastCompletedFetch = now;
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: TabBar(
        tabAlignment: TabAlignment.center,
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          color: AppColors.mainLightColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.mainColor, width: 1),
        ),
        indicatorPadding: const EdgeInsets.symmetric(vertical: 4),
        labelColor: AppColors.blackColor,
        unselectedLabelColor: AppColors.black,
        labelStyle: GoogleFonts.exo2(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: GoogleFonts.exo2(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        splashBorderRadius: BorderRadius.circular(10),
        labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        tabs: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(
              'Upcoming',
              style: GoogleFonts.exo2(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(
              'Live',
              style: GoogleFonts.exo2(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(
              'Completed',
              style: GoogleFonts.exo2(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          _tabController.index = index;
          fetchMatches(index);
        },
        children: [
          matchTab(upcomingMatchList, 'Upcoming'),
          matchTab(liveMatchList, 'Live'),
          matchTab(completedMatchList, 'Completed'),
        ],
      ),
    );
  }

  Widget matchTab(Future<List<MyMatchesModel>?>? futureList, String mode) {
    return FutureBuilder(
      future: futureList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return const MyMatchShimmerViewWidget();
            },
          );
        } else if (snapshot.hasError) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return const MyMatchShimmerViewWidget();
            },
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Stack(
            alignment: Alignment.center,
            children: [
              NoDataWidget(
                image: Images.noContestImage,
                title: "You Haven't Joined any Contest",
                showButton: true,
                onTap: () {
                  widget.updateIndex(0);
                },
              ),
            ],
          );
        } else {
          return RefreshIndicator(
            color: AppColors.mainColor,
            onRefresh: () => refreshMatches(),
            child: ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                MyMatchesModel data = snapshot.data![index];
                return MyMatchCard(
                  data: data,
                  mode: mode,
                  isViewingOldMatches: isViewingOldMatches,
                  gameType: 'Cricket',
                );
              },
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
