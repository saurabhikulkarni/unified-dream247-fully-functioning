import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_pages.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/main_container.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/no_data_widget.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/size_widget.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/features/winners/data/models/winners_model.dart';
import 'package:unified_dream247/features/fantasy/features/winners/data/models/stories_model.dart';
import 'package:unified_dream247/features/fantasy/features/winners/data/winners_datasource.dart';
import 'package:unified_dream247/features/fantasy/features/winners/domain/use_cases/winners_usecases.dart';
import 'package:unified_dream247/features/fantasy/features/winners/presentation/widgets/winner_shimmer.dart';

class WinnersPage extends StatefulWidget {
  const WinnersPage({super.key});

  @override
  State<WinnersPage> createState() => _WinnersPageState();
}

class _WinnersPageState extends State<WinnersPage> {
  Future<List<StoriesModel>?>? storiesList;
  Future<List<WinnersModel>?>? recentMatchesList;
  DateTime? lastRefreshTime;
  WinnersUsecases winnersUsecases = WinnersUsecases(
    WinnersDatasource(ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    loadRecentWinners();
  }

  Future<void> loadRecentWinners() async {
    setState(() {
      storiesList = winnersUsecases.getStories(context);
      recentMatchesList = winnersUsecases.getRecentMatches(context);
    });
  }

  Future<void> handleRefresh() async {
    if (lastRefreshTime != null) {
      final difference = DateTime.now().difference(lastRefreshTime!);
      if (difference.inMinutes < 5) {
        return;
      }
    }

    lastRefreshTime = DateTime.now();
    await loadRecentWinners();
  }

  @override
  Widget build(BuildContext context) {
    return MainContainer(
      child: RefreshIndicator(
        color: AppColors.mainColor,
        onRefresh: () => handleRefresh(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: storiesList,
              builder: (context, snapshot) {
                List<StoriesModel> stories = snapshot.data ?? [];
                return (stories.isNotEmpty)
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: stories.length,
                          itemBuilder: (context, index) {
                            final story = stories[index];
                            return InkWell(
                              onTap: () {
                                story.isActive = false;
                                AppNavigation.gotoStoryPage(
                                  context,
                                  stories,
                                  index,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 5,
                                ),
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(
                                    story.storyProfileImage ?? "",
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Mega Contest Winners',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.letterColor,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 8),
              child: Text(
                'Recent Matches',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.letterColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: recentMatchesList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return const WinnerShimmer();
                      },
                    );
                  } else if (snapshot.hasError) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return const WinnerShimmer();
                      },
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: NoDataWidget(
                        title: 'No Winners Available!',
                        showButton: false,
                      ),
                    );
                  } else {
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 20),
                      shrinkWrap: true,
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        WinnersModel data = snapshot.data![index];
                        return recentWinner(context, data);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget recentWinner(BuildContext context, WinnersModel data) {
  return GestureDetector(
    onTap: () {
      AppNavigation.gotoWinnersDetailScreen(context, data);
    },
    child: SizedBox(
      height: 350,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          MainContainer(
            height: 170,
            color: AppColors.bgColor,
            margin: const EdgeInsets.all(10).copyWith(bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            textAlign: TextAlign.center,
                            data.seriesName ?? "",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.letterColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        AppUtils.formatDate(data.startDate ?? ""),
                        style: TextStyle(
                          color: AppColors.letterColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ClipOval(
                                  child: Image.network(
                                    data.teamAImage ?? "",
                                    height: 35,
                                    width: 35,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "${data.teamAShortName}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.letterColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3.0),
                            Text(
                              "${data.teamAName}",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.letterColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      wBox(10),
                      Image.asset(Images.icVersus, height: 35, width: 120),
                      wBox(10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "${data.teamBShortName}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.letterColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                ClipOval(
                                  child: Image.network(
                                    data.teamBImage ?? "",
                                    height: 35,
                                    width: 35,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3.0),
                            Text(
                              "${data.teamBName}",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.letterColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                const Divider(
                  color: AppColors.letterColor,
                  height: 0.15,
                  thickness: 0.15,
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Image.asset(Images.icWinners),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Strings.indianRupee ${AppUtils.changeNumberToValue(data.firstContesWinAmount ?? 0)}',
                        style: TextStyle(
                          color: AppColors.letterColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 155,
            left: 12,
            right: -12,
            child: SizedBox(
              height: 190,
              child: ListView.builder(
                padding: const EdgeInsets.only(right: 24),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: data.winContestData?.length,
                itemBuilder: (context, index) {
                  WinContestData contestData = data.winContestData![index];
                  return singleRankWinner(contestData);
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget singleRankWinner(WinContestData data) {
  return Container(
    width: 130,
    margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: AppColors.blackColor.withAlpha(10),
          blurRadius: 4,
          offset: const Offset(2, 2),
        ),
      ],
      borderRadius: BorderRadius.circular(12),
      color: AppColors.white,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Container(
              margin: const EdgeInsets.only(
                left: 0,
                top: 0,
                bottom: 0,
                right: 20,
              ),
              decoration: const BoxDecoration(
                gradient: AppColors.mainGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(Images.crown, height: 12, width: 12),
                  const SizedBox(width: 4),
                  Text(
                    'Rank ${AppUtils.stringifyNumber(num.parse(data.rank.toString()))}',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${data.userTeamName}',
              style: TextStyle(
                color: AppColors.blackColor,
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 29,
                child: ClipOval(child: Image.asset(Images.profileImg)),
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            color: AppColors.whiteFade1,
          ),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Won",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: AppColors.letterColor,
                ),
              ),
              Text(
                (data.prize == "" || (data.prize ?? "").isEmpty)
                    ? ' ${Strings.indianRupee}${AppUtils.changeNumberToValue(data.amount?.toInt() ?? 0)}'
                    : ' ${Strings.indianRupee}${AppUtils.changeNumberToValue(num.parse(data.prize ?? "0"))}',
                style: TextStyle(
                  color: AppColors.letterColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
