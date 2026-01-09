import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/common_shimmer_view_widget.dart';
import 'package:unified_dream247/features/fantasy/features/my_matches/data/models/match_player_teams_model.dart';
import 'package:unified_dream247/features/fantasy/features/my_matches/data/my_matches_datasource.dart';
import 'package:unified_dream247/features/fantasy/features/my_matches/domain/use_cases/my_matches_usecases.dart';

class PreviewPlayerinfoScreen extends StatefulWidget {
  final String? joinTeamId;
  final String? playerId;
  const PreviewPlayerinfoScreen({super.key, this.joinTeamId, this.playerId});

  @override
  State<PreviewPlayerinfoScreen> createState() =>
      _PreviewPlayerinfoScreenState();
}

class _PreviewPlayerinfoScreenState extends State<PreviewPlayerinfoScreen> {
  Future<List<MatchPlayerTeamsModel>?>? list;
  int initialIndex = 0;
  MyMatchesUsecases myMatchesUsecases = MyMatchesUsecases(
    MyMatchesDatasource(ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final allPlayers = await myMatchesUsecases.matchPlayerTeams(
      context,
      widget.joinTeamId ?? "",
    );
    if (allPlayers == null) {
      list = Future.value([]);
      return;
    }

    if (widget.playerId != null) {
      int foundIndex = allPlayers.indexWhere((p) => p.id == widget.playerId);
      if (foundIndex != -1) {
        initialIndex = foundIndex;
      }
    }

    list = Future.value(allPlayers);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.letterColor.withAlpha(153),
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * .96,
          child: FutureBuilder(
            future: list,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CarouselSlider.builder(
                  key: ValueKey(initialIndex),
                  options: CarouselOptions(
                    initialPage: initialIndex,
                    height: MediaQuery.of(context).size.height * 0.83,
                    enlargeCenterPage: true,
                    autoPlay: false,
                    enableInfiniteScroll: true,
                    viewportFraction: 0.83,
                    scrollPhysics: const AlwaysScrollableScrollPhysics(),
                  ),
                  itemCount: 11,
                  itemBuilder: (context, index, realIndex) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 150,
                          decoration: const BoxDecoration(
                            color: AppColors.letterColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    Text(
                                      'Player Info',
                                      style: GoogleFonts.exo2(
                                        color: AppColors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Icon(
                                        Icons.cancel,
                                        size: 24,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    ShimmerWidget(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(50),
                                      ),
                                      width: 65,
                                      height: 65,
                                    ),
                                    SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ShimmerWidget(
                                          height: 12,
                                          width: 100,
                                          margin: EdgeInsets.all(3),
                                        ),
                                        ShimmerWidget(
                                          height: 12,
                                          width: 50,
                                          margin: EdgeInsets.all(3),
                                        ),
                                        Row(
                                          children: [
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Selected By',
                                                  style: TextStyle(
                                                    color: AppColors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                ShimmerWidget(
                                                  height: 12,
                                                  width: 20,
                                                  margin: EdgeInsets.all(3),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: 20),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Credits',
                                                  style: TextStyle(
                                                    color: AppColors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                ShimmerWidget(
                                                  height: 12,
                                                  width: 20,
                                                  margin: EdgeInsets.all(3),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: 20),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Points',
                                                  style: TextStyle(
                                                    color: AppColors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                ShimmerWidget(
                                                  height: 12,
                                                  width: 20,
                                                  margin: EdgeInsets.all(3),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.letterColor,
                                width: 0.1,
                              ),
                              top: BorderSide(
                                color: AppColors.letterColor,
                                width: 0.1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Text(
                                    'Event',
                                    style: GoogleFonts.exo2(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: AppColors.greyColor,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Text(
                                      'Actual',
                                      style: GoogleFonts.exo2(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: AppColors.greyColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Text(
                                      'Points',
                                      style: GoogleFonts.exo2(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: AppColors.greyColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: 10,
                              itemBuilder: (context, cardIndex) {
                                return const Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 15,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.all(2),
                                              child: ShimmerWidget(
                                                height: 14,
                                                width: 80,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Padding(
                                                padding: EdgeInsets.all(2),
                                                child: ShimmerWidget(
                                                  height: 14,
                                                  width: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Padding(
                                                padding: EdgeInsets.all(2),
                                                child: ShimmerWidget(
                                                  height: 14,
                                                  width: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  },
                );
              } else if (snapshot.data == null ||
                  (snapshot.data ?? []).isEmpty) {
                return CarouselSlider.builder(
                  options: CarouselOptions(
                    initialPage: initialIndex,
                    height: MediaQuery.of(context).size.height * 0.83,
                    enlargeCenterPage: true,
                    autoPlay: false,
                    enableInfiniteScroll: true,
                    viewportFraction: 0.83,
                    scrollPhysics: const AlwaysScrollableScrollPhysics(),
                  ),
                  itemCount: 11,
                  itemBuilder: (context, index, realIndex) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 150,
                          decoration: const BoxDecoration(
                            color: AppColors.letterColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    Text(
                                      'Player Info',
                                      style: GoogleFonts.exo2(
                                        color: AppColors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Icon(
                                        Icons.cancel,
                                        size: 24,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 10,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 65,
                                      height: 65,
                                      child: Image.asset(
                                        Images.imageDefalutPlayer,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "---",
                                          style: GoogleFonts.exo2(
                                            color: AppColors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "---",
                                          style: GoogleFonts.exo2(
                                            color: AppColors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Selected By',
                                                  style: TextStyle(
                                                    color: AppColors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  '0%',
                                                  style: GoogleFonts.tomorrow(
                                                    color: AppColors.white,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 20),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  'Credits',
                                                  style: TextStyle(
                                                    color: AppColors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  '0',
                                                  style: GoogleFonts.tomorrow(
                                                    color: AppColors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 20),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  'Points',
                                                  style: TextStyle(
                                                    color: AppColors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  '0',
                                                  style: GoogleFonts.tomorrow(
                                                    color: AppColors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.letterColor,
                                width: 0.1,
                              ),
                              top: BorderSide(
                                color: AppColors.letterColor,
                                width: 0.1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Text(
                                    'Event',
                                    style: GoogleFonts.exo2(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: AppColors.greyColor,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Text(
                                      'Actual',
                                      style: GoogleFonts.exo2(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: AppColors.greyColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Text(
                                      'Points',
                                      style: GoogleFonts.exo2(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: AppColors.greyColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Player data not available',
                                style: TextStyle(
                                  color: AppColors.blackColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else {
                return CarouselSlider.builder(
                  options: CarouselOptions(
                    initialPage: initialIndex,
                    height: MediaQuery.of(context).size.height * 0.83,
                    enlargeCenterPage: true,
                    autoPlay: false,
                    enableInfiniteScroll: true,
                    viewportFraction: 0.83,
                    scrollPhysics: const AlwaysScrollableScrollPhysics(),
                  ),
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index, realIndex) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 150,
                          decoration: const BoxDecoration(
                            color: AppColors.letterColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    Text(
                                      'Player Info',
                                      style: GoogleFonts.exo2(
                                        color: AppColors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Icon(
                                        Icons.cancel,
                                        size: 24,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: Image.network(
                                        snapshot.data?[index].image ?? '',
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${snapshot.data?[index].name}',
                                          style: GoogleFonts.exo2(
                                            color: AppColors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${snapshot.data?[index].role?.toUpperCase()}',
                                          style: GoogleFonts.exo2(
                                            color: AppColors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Selected By',
                                                  style: TextStyle(
                                                    color: AppColors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  '${snapshot.data?[index].totalSelected}%',
                                                  style: GoogleFonts.tomorrow(
                                                    color: AppColors.white,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 20),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  'Credits',
                                                  style: TextStyle(
                                                    color: AppColors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  '${snapshot.data?[index].credit}',
                                                  style: GoogleFonts.tomorrow(
                                                    color: AppColors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 20),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  'Points',
                                                  style: TextStyle(
                                                    color: AppColors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  '${snapshot.data?[index].total}',
                                                  style: GoogleFonts.tomorrow(
                                                    color: AppColors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.letterColor,
                                width: 0.1,
                              ),
                              top: BorderSide(
                                color: AppColors.letterColor,
                                width: 0.1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Text(
                                    'Event',
                                    style: GoogleFonts.exo2(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: AppColors.greyColor,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Text(
                                      'Actual',
                                      style: GoogleFonts.exo2(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: AppColors.greyColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Text(
                                      'Points',
                                      style: GoogleFonts.exo2(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: AppColors.greyColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data?[index].card?.length,
                              itemBuilder: (context, cardIndex) {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 15,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(2),
                                              child: Text(
                                                '${snapshot.data?[index].card?[cardIndex].type}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: AppColors.letterColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  2,
                                                ),
                                                child: Text(
                                                  '${snapshot.data?[index].card?[cardIndex].actual}',
                                                  style: GoogleFonts.tomorrow(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                    color:
                                                        AppColors.letterColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  2,
                                                ),
                                                child: Text(
                                                  (snapshot
                                                              .data?[index]
                                                              .card?[cardIndex]
                                                              .type ==
                                                          "Ball Faced")
                                                      ? "NA"
                                                      : '${snapshot.data?[index].card?[cardIndex].points ?? "0"}',
                                                  style: GoogleFonts.tomorrow(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                    color:
                                                        AppColors.letterColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
