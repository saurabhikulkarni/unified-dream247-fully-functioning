// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_urls.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_pages.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/app_toast.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/cached_images.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/menu_items/presentation/providers/user_data_provider.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/my_matches_datasource.dart';
import 'package:unified_dream247/features/fantasy/my_matches/domain/use_cases/my_matches_usecases.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/widgets/download_pdf_bottomsheet.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/widgets/live_leaderboard_shimmer_widget.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/all_contests_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/leaderboard_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/user_teams_model.dart';

class LiveLeaderboard extends StatefulWidget {
  final String? totalCount;
  final String matchKey;
  final String challengeId;
  final int totalwinners;
  final String finalStatus;
  final List<Extrapricecard>? extraPriceCard;
  const LiveLeaderboard({
    super.key,
    required this.matchKey,
    required this.challengeId,
    required this.totalwinners,
    required this.finalStatus,
    this.totalCount,
    this.extraPriceCard,
  });

  @override
  State<LiveLeaderboard> createState() => _LiveLeaderboard();
}

class _LiveLeaderboard extends State<LiveLeaderboard> {
  List<LiveJointeams> list = [];
  List<LiveJointeams> displayedList = [];
  int skip = 0;
  int limit = 300;
  bool scroll = true;
  bool compare = false;
  late ScrollController _scrollController;
  String team1id = '', team2id = '';
  String team1Name = '', team2Name = '';
  String l1 = '', l2 = '';
  int _currentMax = 15;
  bool isLoadingMore = false;
  bool isDownloading = false;
  double progress = 0.0;

  MyMatchesUsecases myMatchesUsecases = MyMatchesUsecases(
    MyMatchesDatasource(ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    loadSelfData();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!isLoadingMore && _currentMax < list.length) {
        loadMoreData();
      }
    }
  }

  void loadSelfData() async {
    setState(() {
      isLoadingMore = true;
    });
    await myMatchesUsecases
        .getSelfLeaderboardLive(
      context,
      widget.challengeId,
      widget.finalStatus,
      skip,
      limit,
    )
        .then((value) {
      setState(() {
        if (value != null) {
          List<LiveJointeams> selfList = LiveLeaderboardModel.fromJson(
            value,
          ).data?.jointeams?.toList() ?? [];
          list.addAll(selfList);
          displayedList = list.take(_currentMax).toList();
          isLoadingMore = false;
        }
      });
      loadData();
    });
  }

  void loadData() async {
    setState(() {
      isLoadingMore = true;
    });
    myMatchesUsecases
        .getLeaderboardLive(
      context,
      widget.challengeId,
      widget.finalStatus,
      skip,
      limit,
    )
        .then((value) {
      setState(() {
        if (value != null) {
          List<LiveJointeams> list1 = LiveLeaderboardModel.fromJson(
                value,
              ).data?.jointeams?.toList() ??
              [];
          if (list1.isEmpty) {
            scroll = false;
          } else {
            list.addAll(list1);
            displayedList = list.take(_currentMax).toList();
            skip += limit;
          }
          isLoadingMore = false;
        }
      });
    });
  }

  void loadMoreData() {
    if (_currentMax < list.length) {
      setState(() {
        isLoadingMore = true;
      });
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _currentMax += 20;
          displayedList = list.take(_currentMax).toList();
          isLoadingMore = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.mainLightColor,
      onRefresh: () async {
        final refreshedData = await myMatchesUsecases.getSelfLeaderboardLive(
          context,
          widget.challengeId,
          widget.finalStatus,
          0,
          limit,
        );
        if (refreshedData != null) {
          List<LiveJointeams> newSelfList = LiveLeaderboardModel.fromJson(
                refreshedData,
              ).data?.jointeams?.toList() ??
              [];
          final refreshedLeaderboard =
              await myMatchesUsecases.getLeaderboardLive(
            context,
            widget.challengeId,
            widget.finalStatus,
            0,
            limit,
          );
          if (refreshedLeaderboard != null) {
            List<LiveJointeams> newLeaderboardList =
                LiveLeaderboardModel.fromJson(
                      refreshedLeaderboard,
                    ).data?.jointeams?.toList() ??
                    [];
            list = [...newSelfList, ...newLeaderboardList];
            displayedList = list.take(_currentMax).toList();
            skip = limit;
            if (mounted) setState(() {});
          }
        }
      },
      child: Column(
        children: [
          _headerSection(context),
          const Divider(height: 0.5, color: AppColors.lightGrey),
          _tableHeader(),
          Expanded(
            child: Container(
              color: AppColors.bgColor,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: displayedList.length + (isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == displayedList.length && isLoadingMore) {
                    return const LiveLeaderboardShimmerWidget();
                  }
                  return _teamTile(displayedList[index], widget.totalwinners);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                compare = !compare;
                if (!compare) {
                  team1id = '';
                  team2id = '';
                  l1 = '';
                  l2 = '';
                }
              });
            },
            child: Column(
              children: [
                Icon(
                  Icons.compare_arrows,
                  size: 22,
                  color: AppColors.blackColor.withValues(alpha: 0.9),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Compare',
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (isDownloading)
            SizedBox(
              height: 30,
              width: 30,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: (progress > 0 && progress <= 1) ? progress : null,
                    strokeWidth: 3.0,
                    color: AppColors.mainLightColor,
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () {
              String pdfUrl =
                  '${AppSingleton.singleton.appData.pdfUrl}/${AppSingleton.singleton.appData.s3Folder}/matchkey_${widget.matchKey}/challenge_${widget.challengeId}.pdf';
              String fileName =
                  '${APIServerUrl.appName}-Contest-${widget.challengeId}.pdf';

              if (pdfUrl.isEmpty || pdfUrl == 'null') {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return DownloadPdfBottomsheet(
                      challengeId: widget.challengeId,
                    );
                  },
                );
              } else {
                downloadPdf(pdfUrl, fileName, widget.challengeId, context);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.mainColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.download_rounded,
                    size: 18,
                    color: AppColors.mainLightColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Download',
                    style: GoogleFonts.inter(
                      color: AppColors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'All Teams',
              style: TextStyle(
                color: AppColors.letterColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              'Points',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.letterColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              'Rank',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.letterColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamTile(LiveJointeams data, int totalwinners) {
    bool isTeamSelected =
        (data.jointeamid == team1id || data.jointeamid == team2id);
    bool isUserTeam = data.teamname ==
        Provider.of<UserDataProvider>(context, listen: false).userData!.team!;
    return Card(
      elevation: 0.8,
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
      color: isUserTeam ? AppColors.whiteFade1 : AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () async {
          await myMatchesUsecases
              .liveViewTeam(
            context,
            data.jointeamid ?? '',
            data.teamnumber ?? 1,
            data.userid ?? '',
          )
              ?.then((value) {
            List<UserTeamsModel> finalPlayers = [];
            for (var zz in value ?? []) {
              finalPlayers.add(
                UserTeamsModel(
                  playerid: zz.playerid,
                  playerimg: zz.image,
                  image: zz.image,
                  team: zz.team,
                  name: zz.name,
                  role: zz.role,
                  credit: zz.credit!.toDouble(),
                  points: zz.points,
                  playingstatus: zz.playingstatus,
                  captain: zz.captain,
                  vicecaptain: zz.vicecaptain,
                ),
              );
            }
            AppNavigation.gotoPreviewScreen(
              context,
              data.jointeamid,
              false,
              finalPlayers,
              data.teamname,
              'live',
              data.teamnumber,
              false,
              data.userid ?? '',
            );
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            children: [
              if (compare)
                Checkbox(
                  activeColor: AppColors.mainColor,
                  value: isTeamSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        final selfTeamName = Provider.of<UserDataProvider>(
                          context,
                          listen: false,
                        ).userData!.team!;
                        if (team1id.isEmpty) {
                          if (data.teamname != selfTeamName) {
                            appToast('Choose your own team first', context);
                            return;
                          }
                          team1id = data.jointeamid!;
                          team1Name = data.teamname!;
                          l1 = data.id ?? '';
                          appToast('Choose another team to compare', context);
                        } else if (team2id.isEmpty) {
                          if (data.jointeamid == team1id) {
                            appToast("Can't compare same team", context);
                            return;
                          }
                          if (data.teamname == selfTeamName) {
                            appToast(
                              "Can't choose your own team again",
                              context,
                            );
                            return;
                          }
                          team2id = data.jointeamid!;
                          team2Name = data.teamname!;
                          l2 = data.id ?? '';
                          AppNavigation.gotoTeamCompareScreen(
                            context,
                            team1id,
                            team2id,
                            data.userid ?? '',
                            widget.challengeId,
                            l1,
                            l2,
                          );
                        }
                      } else {
                        if (data.jointeamid == team1id) {
                          team1id = '';
                          l1 = '';
                        } else if (data.jointeamid == team2id) {
                          team2id = '';
                          l2 = '';
                        }
                      }
                    });
                  },
                ),
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.transparent,
                child: ClipOval(
                  child: CachedImage(
                    imageUrl: '${data.image}',
                    errorWidget: Image.asset(Images.imageDefalutPlayer),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${data.teamname}',
                            style: GoogleFonts.inter(
                              color: AppColors.letterColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bgColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'T${data.teamnumber}',
                            style: const TextStyle(
                              color: AppColors.greyColor,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    if (data.winingamount != '' &&
                        double.parse(data.winingamount!) != 0)
                      Text(
                        'Won ${Strings.indianRupee}${AppUtils.changeNumberToValue(num.parse(data.winingamount!))}',
                        style: GoogleFonts.tomorrow(
                          color: AppColors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else if ((data.getcurrentrank ?? 0) <= totalwinners ||
                        ((widget.extraPriceCard ?? []).isNotEmpty &&
                            widget.extraPriceCard!.any(
                              (element) =>
                                  element.rank == (data.getcurrentrank ?? 0),
                            )))
                      const Text(
                        'In Winning Zone',
                        style: TextStyle(
                          color: AppColors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  '${data.points}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: AppColors.letterColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                width: 60,
                child: Text(
                  '#${data.getcurrentrank}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: AppColors.mainLightColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> downloadPdf(
    String url,
    String fileName,
    String challengeId,
    BuildContext context,
  ) async {
    try {
      setState(() {
        isDownloading = true;
        progress = 0.0;
      });
      final directory = await getDownloadDirectoryPath();
      final filePath = '${directory.path}/$fileName';
      Dio dio = Dio();
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              progress = received / total;
            });
          }
        },
      );
      setState(() {
        isDownloading = false;
        progress = 0.0;
      });
      appToast('PDF downloaded to $filePath', context);
      await openFile(filePath);
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
      appToast('Failed to download PDF. Please try again.', context);
    }
  }

  Future<Directory> getDownloadDirectoryPath() async {
    if (Platform.isAndroid) {
      final downloadPath = Directory('/storage/emulated/0/Download');
      if (!await downloadPath.exists()) {
        await downloadPath.create(recursive: true);
      }
      return downloadPath;
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  Future<void> openFile(String filePath) async {
    if (await File(filePath).exists()) {
      await OpenFile.open(filePath);
    }
  }
}
