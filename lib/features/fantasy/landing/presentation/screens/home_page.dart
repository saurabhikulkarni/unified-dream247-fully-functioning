// ignore_for_file: use_build_context_synchronously

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/no_data_widget.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/size_widget.dart';
import 'package:unified_dream247/features/fantasy/landing/data/home_datasource.dart';
import 'package:unified_dream247/features/fantasy/landing/data/models/banners_get_set.dart';
import 'package:unified_dream247/features/fantasy/landing/data/models/joined_matches_model.dart';
import 'package:unified_dream247/features/fantasy/landing/data/models/match_list_model.dart';
import 'package:unified_dream247/features/fantasy/landing/domain/use_cases/home_usecases.dart';
import 'package:unified_dream247/features/fantasy/landing/presentation/widgets/match_card.dart';
import 'package:unified_dream247/features/fantasy/landing/presentation/widgets/match_list_shimmer_widget.dart';
import 'package:unified_dream247/features/fantasy/landing/presentation/widgets/recent_match_card.dart';
import 'package:unified_dream247/features/fantasy/onboarding/data/onboarding_datasource.dart';
import 'package:unified_dream247/features/fantasy/onboarding/domain/use_cases/onboarding_usecases.dart';

class HomePage extends StatefulWidget {
  final String? gameType;
  final Function(int) updateIndex;
  const HomePage({super.key, this.gameType, required this.updateIndex});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? selectedSeriesIndex;
  List<BannersGetSet>? bannerList;
  List<JoinedMatchesModel> joinedMatches = [];
  List<MatchListModel>? matchList;
  HomeUsecases homeUsecases = HomeUsecases(
    HomeDatasource(ApiImplWithAccessToken()),
  );
  OnboardingUsecases onboardingUsecases = OnboardingUsecases(
    OnboardingDatasource(ApiImpl()),
  );
  bool _isLoading = true;
  DateTime? lastRefreshTime;
  List<String> series = [];

  int? selectedFilterIndex;
  List<MatchListModel> _allMatches = [];
  final List<String> filterOptions = [
    "Recommended",
    "Starting Soon",
    "Popular",
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> handleRefresh() async {
    DateTime now = DateTime.now();
    if (lastRefreshTime == null ||
        now.difference(lastRefreshTime!) > const Duration(minutes: 1)) {
      setState(() {
        lastRefreshTime = now;
      });
      await loadData(silent: true);
    } else {
      debugPrint("Refresh blocked: Try again after 1 minute.");
    }
  }

  Future<void> loadData({bool silent = false}) async {
    if (!mounted) return;
    if (!silent) setState(() => _isLoading = true);

    final joinedData = await homeUsecases.getJoinedMatches(
      context,
      widget.gameType ?? "Cricket",
    );
    final matchData = await homeUsecases.getMatchList(context, "");
    final banners = await onboardingUsecases.getMainBanner(context);

    // Filter only banners where type == "app"
    final filteredBanners = banners
        ?.where((banner) => banner.type?.toLowerCase() == "app")
        .toList();

    if (!mounted) return;
    setState(() {
      joinedMatches = joinedData ?? [];
      matchList = matchData ?? [];
      _allMatches = List.from(matchList!);
      bannerList = filteredBanners;
      series = matchList
              ?.map((match) => match.seriesname ?? "")
              .where((name) => name.isNotEmpty)
              .toSet()
              .toList() ??
          [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightCard,
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: AppColors.bgColor,
          color: AppColors.mainColor,
          onRefresh: () => handleRefresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///  Premium Header (Banner + Recent)
                Container(
                  decoration: const BoxDecoration(
                      // gradient: LinearGradient(
                      //   colors: [AppColors.mainColor, AppColors.blackColor],
                      //   begin: Alignment.topCenter,
                      //   end: Alignment.bottomCenter,
                      // ),
                      ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      hBox(16),
                      //  Banner Carousel
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: 100.h,
                              autoPlay: true,
                              autoPlayCurve: Curves.easeInOutCubic,
                              enlargeCenterPage: true,
                              viewportFraction: 0.85,
                            ),
                            items: bannerList?.map((item) {
                              // Fallback handling for null, empty or invalid image
                              final String imageUrl = (item.image != null &&
                                      (item.image ?? "").trim().isNotEmpty)
                                  ? item.image ??
                                      "http://143.244.140.102:5001/uploads/sideBanner-1756816917767-JDAANUQZ.jpeg"
                                  : "http://143.244.140.102:5001/uploads/sideBanner-1756816917767-JDAANUQZ.jpeg";

                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: ShaderMask(
                                      shaderCallback: (rect) =>
                                          const LinearGradient(
                                        colors: [
                                          Color.fromARGB(31, 255, 202, 202),
                                          Color.fromARGB(136, 255, 240, 240),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ).createShader(rect),
                                      blendMode: BlendMode.darken,
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.network(
                                          "http://143.244.140.102:5001/uploads/sideBanner-1756816917767-JDAANUQZ.jpeg",
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      hBox(12),

                      //  Recent Matches
                      if (joinedMatches.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "Recent Matches",
                            style: GoogleFonts.poppins(
                              color: AppColors.blackColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 10.h,
                      ),
                      if (joinedMatches.isNotEmpty)
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 0.13.sh,
                            viewportFraction: 0.9,
                            autoPlay: false,
                          ),
                          items: joinedMatches
                              .map((item) => RecentMatchCard(data: item))
                              .toList(),
                        ),
                    ],
                  ),
                ),
                hBox(20),

                ///  Series Chips (Modern Style)
                if (series.isNotEmpty)
                  Container(
                    height: 40,
                    padding: const EdgeInsets.only(left: 12),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: series.length,
                      itemBuilder: (context, index) {
                        bool selected = selectedSeriesIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSeriesIndex = selected ? null : index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: selected
                                    ? AppColors.transparent
                                    : AppColors.black,
                                width: 0.1,
                              ),
                              gradient: selected
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors.mainLightColor,
                                        AppColors.mainColor,
                                      ],
                                    )
                                  : const LinearGradient(
                                      colors: [
                                        AppColors.lightCard,
                                        AppColors.lightGrey,
                                      ],
                                    ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.lightCard.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 8.r,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                series[index],
                                style: GoogleFonts.poppins(
                                  color: selected
                                      ? AppColors.whiteFade1
                                      : AppColors.greyColor,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                hBox(10),

                ///  Filter Tabs
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(filterOptions.length, (index) {
                        bool selected = selectedFilterIndex == index;
                        return GestureDetector(
                          onTap: () async {
                            // Toggle off if same filter tapped again
                            if (selectedFilterIndex == index) {
                              setState(() {
                                selectedFilterIndex = null;
                                matchList = List.from(_allMatches);
                              });
                              return;
                            }

                            final filterKey = index == 1
                                ? "startingsoon"
                                : filterOptions[index].toLowerCase();

                            final filtered = await homeUsecases.getMatchList(
                                context, filterKey);

                            setState(() {
                              selectedFilterIndex = index;
                              // If API returns empty → fallback to all matches
                              matchList = (filtered == null || filtered.isEmpty)
                                  ? List.from(_allMatches)
                                  : filtered;
                            });
                          },
                          // onTap: () async {
                          //   matchList = await homeUsecases.getMatchList(
                          //     context,
                          //     index == 1
                          //         ? "startingsoon"
                          //         : filterOptions[index].toLowerCase(),
                          //   );
                          //   setState(() => selectedFilterIndex = index);
                          // },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 6.h,
                            ),
                            margin: EdgeInsets.only(right: 10.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.r),
                              color: selected
                                  ? AppColors.mainLightColor.withValues(
                                      alpha: 0.15,
                                    )
                                  : AppColors.transparent,
                              border: Border.all(
                                color: selected
                                    ? AppColors.black
                                    : AppColors.whiteFade1,
                                width: 0.3,
                              ),
                            ),
                            child: Text(
                              filterOptions[index],
                              style: GoogleFonts.poppins(
                                color: selected
                                    ? AppColors.blackColor
                                    : AppColors.greyColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                ///  Match List Section
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isLoading
                      ? ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: 3,
                          itemBuilder: (context, index) =>
                              const MatchListShimmerViewWidget(),
                        )
                      : _buildMatchList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchList() {
    List<MatchListModel> filteredMatches;
    if (selectedSeriesIndex == null) {
      filteredMatches = matchList ?? [];
    } else {
      String selectedSeries = series[selectedSeriesIndex!];
      filteredMatches = matchList
              ?.where((match) => match.seriesname == selectedSeries)
              .toList() ??
          [];
    }

    if (filteredMatches.isEmpty) {
      return const Center(
        child: NoDataWidget(title: 'No Matches Available!', showButton: false),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: filteredMatches.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: MatchCard(
          data: filteredMatches[index],
          gameType: widget.gameType ?? "Cricket",
          index: index,
        ),
      ),
    );
  }
}
