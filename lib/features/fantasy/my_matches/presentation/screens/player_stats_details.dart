import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/match_player_teams_model.dart';

class PlayerStatsDetails extends StatefulWidget {
  final String fantasyType;
  final String? playerId;
  final List<MatchPlayerTeamsModel>? list;
  const PlayerStatsDetails({
    super.key,
    this.playerId,
    this.list,
    required this.fantasyType,
  });
  @override
  State<PlayerStatsDetails> createState() => _PlayerStatsDetailsState();
}

class _PlayerStatsDetailsState extends State<PlayerStatsDetails> {
  int initialIndex = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    if (widget.playerId != null) {
      int foundIndex = widget.list!.indexWhere((p) => p.id == widget.playerId);
      if (foundIndex != -1) {
        initialIndex = foundIndex;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.letterColor.withAlpha(153),
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * .96,
          child: ((widget.list ?? []).isNotEmpty)
              ? CarouselSlider.builder(
                  options: CarouselOptions(
                    initialPage: initialIndex,
                    height: MediaQuery.of(context).size.height * 0.83,
                    enlargeCenterPage: true,
                    autoPlay: false,
                    enableInfiniteScroll:
                        (widget.fantasyType == "Cricket") ? true : false,
                    viewportFraction: 0.83,
                    scrollPhysics: const AlwaysScrollableScrollPhysics(),
                  ),
                  itemCount: (widget.fantasyType == "Cricket")
                      ? widget.list?.length
                      : 1,
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
                                      width: 80,
                                      height: 80,
                                      child: Image.network(
                                        widget.list?[index].image ?? '',
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${widget.list?[index].name}',
                                          style: GoogleFonts.exo2(
                                            color: AppColors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${widget.list?[index].role?.toUpperCase()}',
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
                                                  '${widget.list?[index].totalSelected}%',
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
                                                  '${widget.list?[index].credit}',
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
                                                  '${widget.list?[index].total}',
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
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(2),
                                  child: Text(
                                    'Event',
                                    style: TextStyle(
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
                                    padding: EdgeInsets.all(2),
                                    child: Text(
                                      'Actual',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
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
                                    padding: EdgeInsets.all(2),
                                    child: Text(
                                      'Points',
                                      style: TextStyle(
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
                              itemCount: widget.list?[index].card?.length,
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
                                              padding: const EdgeInsets.all(
                                                2,
                                              ),
                                              child: Text(
                                                '${widget.list?[index].card?[cardIndex].type}',
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
                                                  '${widget.list?[index].card?[cardIndex].actual}',
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
                                                  (widget
                                                              .list?[index]
                                                              .card?[cardIndex]
                                                              .type ==
                                                          "Ball Faced")
                                                      ? "NA"
                                                      : '${widget.list?[index].card?[cardIndex].points ?? "0"}',
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
                )
              : CarouselSlider.builder(
                  options: CarouselOptions(
                    initialPage: initialIndex,
                    height: MediaQuery.of(context).size.height * 0.83,
                    enlargeCenterPage: true,
                    autoPlay: false,
                    enableInfiniteScroll:
                        (widget.fantasyType == "Cricket") ? true : false,
                    viewportFraction: 0.83,
                    scrollPhysics: const AlwaysScrollableScrollPhysics(),
                  ),
                  itemCount: (widget.fantasyType == "Cricket") ? 11 : 1,
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
                                  color: AppColors.black,
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
                ),
        ),
      ),
    );
  }
}
