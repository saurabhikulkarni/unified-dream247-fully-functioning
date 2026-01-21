// ignore_for_file: use_build_context_synchronously

import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_pages.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/custom_textfield.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/dashed_border.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/main_button.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/menu_items/presentation/providers/user_data_provider.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/price_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/teams_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/upcoming_match_datsource.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/domain/use_cases/upcoming_match_usecase.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/providers/myteams_provider.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/widgets/contest_head.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/widgets/join_contest_bottomsheet.dart';

class CreatePrivateContest extends StatefulWidget {
  final String? teamType;
  const CreatePrivateContest({super.key, this.teamType});

  @override
  State<CreatePrivateContest> createState() => _CreatePrivateContest();
}

class _CreatePrivateContest extends State<CreatePrivateContest> {
  TextEditingController teamNameController = TextEditingController();
  TextEditingController entryFeeController = TextEditingController();
  TextEditingController spotsController = TextEditingController();
  int maxPrizePool = 0;
  int numWinners = 1;
  num firstPrize = 0;
  List<PriceCardData> priceCardList = [];
  List<PriceCardWinnerData> priceList = [];
  int selectedIndex = 0;

  UpcomingMatchUsecase upcomingMatchUsecase = UpcomingMatchUsecase(
    UpcomingMatchDatsource(ApiImpl(), ApiImplWithAccessToken()),
  );

  void calculateData() {
    if (entryFeeController.text.isNotEmpty && spotsController.text.isNotEmpty) {
      loadPriceCard();
    } else {
      setState(() {
        maxPrizePool = 0;
        numWinners = 1;
        firstPrize = 0;
        priceList = [];
      });
    }
  }

  void loadPriceCard() {
    upcomingMatchUsecase
        .getPriceCard(
      context,
      entryFeeController.text,
      spotsController.text,
      numWinners,
    )
        .then((value) {
      if (value != null) {
        priceList = PriceCardModel.fromJson(value).data!;
        priceList.sort((b, a) => a.winner!.compareTo(b.winner!));
        selectedIndex = 0;
        setState(() {});
      }
    });
  }

  void createContest() {
    upcomingMatchUsecase
        .createContest(
      context,
      entryFeeController.text,
      spotsController.text,
      numWinners,
      teamNameController.text,
    )
        .then((value) {
      if (value != null) {
        if (value['status']) {
          String matchchallengeid = value['data']['matchchallengeid'];
          upcomingMatchUsecase
              .getTeamswithChallengeId(context, matchchallengeid)
              .then((value) async {
            int count = 0;
            for (var i in value) {
              if (!i.isSelected!) {
                count++;
              }
            }
            if (count == 0) {
              Navigator.pop(context);
              await AppNavigation.gotoCreateTeamScreen(
                  context,
                  (value.length + 1),
                  false,
                  AppSingleton.singleton.matchData.id!,
                  matchchallengeid,
                  0,
                  '',
                  '',
                  '',
                  '',
                  0,
                  false,
                  widget.teamType ?? '10-1',);
              List<TeamsModel> updatedTeams =
                  await upcomingMatchUsecase.getMyTeams(context);
              Provider.of<MyTeamsProvider>(
                context,
                listen: false,
              ).updateMyTeams(
                updatedTeams,
                AppSingleton.singleton.matchData.id ?? '',
              );
            } else if (count == 1) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(10.0),
                  ),
                ),
                builder: (BuildContext context) {
                  return JoinContestBottomsheet(
                    discount: 0,
                    isClosedContestNew: false,
                    fantasyType: 'Cricket',
                    previousJoined: false,
                    challengeId: matchchallengeid,
                    selectedTeam: value[0].jointeamid!,
                    isContestDetail: false,
                    removePage: () {
                      Navigator.of(context).pop();
                    },
                  );
                },
              );
            } else {
              Navigator.pop(context);
              await AppNavigation.gotoMyTeamsChallenges(
                context,
                widget.teamType ?? '10-1',
                matchchallengeid,
                value,
                1,
                'Join Team',
                '',
                '',
                false,
                0,
                num.parse(entryFeeController.text),
              );
            }
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    teamNameController.text =
        Provider.of<UserDataProvider>(context, listen: false).userData?.team ??
            '';
  }

  @override
  Widget build(BuildContext context) {
    return ContestHead(
      safeAreaColor: AppColors.white,
      showAppBar: true,
      showWalletIcon: true,
      addPadding: false,
      updateIndex: (p0) => 0,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 1,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          color: AppColors.lightYellow.withAlpha(27),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Contest By ${Provider.of<UserDataProvider>(context, listen: false).userData?.team}',
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                TextEditingController contestNameController =
                                    TextEditingController();
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Wrap(
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                            ),
                                            color: AppColors.white,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                  top: 10,
                                                  bottom: 10,
                                                ),
                                                child: Text(
                                                  'Contest Name',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.letterColor,
                                                  ),
                                                ),
                                              ),
                                              TextField(
                                                controller:
                                                    contestNameController,
                                                decoration:
                                                    const InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(
                                                        5,
                                                      ),
                                                    ),
                                                  ),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 10,
                                                  ),
                                                  hintText:
                                                      'Enter Contest Name',
                                                ),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 12,
                                                  color: AppColors.letterColor,
                                                ),
                                                textAlign: TextAlign.justify,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                              ),
                                              MainButton(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 25,
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    teamNameController.text =
                                                        contestNameController
                                                            .text;
                                                    Navigator.pop(context);
                                                  });
                                                },
                                                color: AppColors.green,
                                                text: 'Submit Details',
                                                textColor: AppColors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: AppColors.letterColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2,
                            child: CustomTextfield(
                              onChanged: (value) {
                                setState(() {
                                  calculateData();
                                });
                              },
                              margin: EdgeInsets.zero,
                              maxLength: 6,
                              keyboardType: TextInputType.number,
                              controller: entryFeeController,
                              labelText: 'Entry Fee',
                              hintText: 'Entry Fee',
                              prefixIcon: const Icon(Icons.currency_rupee),
                              style: GoogleFonts.tomorrow(
                                color: AppColors.blackColor,
                                fontSize: 16,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                entryFeeController.text = '25';
                                setState(() {
                                  calculateData();
                                });
                              },
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  border: Border.all(
                                    color: AppColors.whiteFade1,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3.0,
                                ),
                                child: Center(
                                  child: Text(
                                    '${Strings.indianRupee}25',
                                    style: GoogleFonts.tomorrow(
                                      color: AppColors.letterColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                entryFeeController.text = '50';
                                setState(() {
                                  calculateData();
                                });
                              },
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  border: Border.all(
                                    color: AppColors.whiteFade1,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3.0,
                                ),
                                child: Center(
                                  child: Text(
                                    '${Strings.indianRupee}50',
                                    style: GoogleFonts.tomorrow(
                                      color: AppColors.letterColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                entryFeeController.text = '75';
                                setState(() {
                                  calculateData();
                                });
                              },
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  border: Border.all(
                                    color: AppColors.whiteFade1,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3.0,
                                ),
                                child: Center(
                                  child: Text(
                                    '${Strings.indianRupee}75',
                                    style: GoogleFonts.tomorrow(
                                      color: AppColors.letterColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 5,
                      ),
                      child: const Center(
                        child: DashedBorderContainer(
                          dashWidth: 5,
                          dashSpace: 6,
                          strokeWidth: 0.25,
                          color: AppColors.letterColor,
                          child: SizedBox(width: double.infinity),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      width: MediaQuery.of(context).size.width / 2,
                      child: CustomTextfield(
                        margin: EdgeInsets.zero,
                        onChanged: (value) {
                          setState(() {
                            calculateData();
                          });
                        },
                        keyboardType: TextInputType.number,
                        controller: spotsController,
                        maxLength: 6,
                        labelText: 'Spots',
                        style: GoogleFonts.tomorrow(
                          color: AppColors.blackColor,
                          fontSize: 16,
                        ),
                        hintText: 'Spots',
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  Images.imageTrophy,
                                  width: 25,
                                  height: 25,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Max Prize Pool',
                                      style: TextStyle(
                                        color: AppColors.letterColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${Strings.indianRupee}$maxPrizePool',
                                      style: GoogleFonts.tomorrow(
                                        color: AppColors.mainLightColor,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            color: AppColors.letterColor,
                            width: 0.25,
                            height: 50,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'No. of Winners',
                                  style: TextStyle(
                                    color: AppColors.letterColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$numWinners',
                                      style: const TextStyle(
                                        color: AppColors.mainLightColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        text: '(1st Prize - ',
                                        style: const TextStyle(
                                          overflow: TextOverflow.clip,
                                          color: AppColors.letterColor,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text:
                                                '${Strings.indianRupee}${firstPrize.toStringAsFixed(2)})',
                                            style: GoogleFonts.tomorrow(
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.letterColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.letterColor,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: AppColors.letterColor,
                      height: 0.25,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 10),
                    if (priceList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select the numbers of winners',
                              style: TextStyle(
                                color: AppColors.letterColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              height: 30,
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: priceList.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () => {
                                      setState(() {
                                        selectedIndex = index;
                                        loadPriceCardList(index);
                                      }),
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: (selectedIndex == index)
                                            ? AppColors.letterColor
                                            : AppColors.white,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 5,
                                      ),
                                      child: Text(
                                        '${priceList[index].winner}',
                                        style: TextStyle(
                                          color: (selectedIndex == index)
                                              ? AppColors.white
                                              : AppColors.letterColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.letterColor,
                                  width: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: Text(
                                          'Rank',
                                          style: TextStyle(
                                            color: AppColors.letterColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: Text(
                                          'Max Winnings',
                                          style: TextStyle(
                                            color: AppColors.letterColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    color: AppColors.letterColor,
                                    thickness: 0.15,
                                    height: 0.15,
                                  ),
                                  if (priceList.isNotEmpty)
                                    loadPriceCardList(selectedIndex),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: priceList.isNotEmpty,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: AppColors.white,
                child: GestureDetector(
                  onTap: () {
                    createContest();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.mainColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Center(
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget loadPriceCardList(int i) {
    priceCardList = (priceList[i].priceCard ?? [])
        .where((e) => e.rank != null && e.rank != 0)
        .toList();
    maxPrizePool = priceList[i].details?.totalWiningAmount?.toInt() ?? 0;
    firstPrize = priceList[i].details?.fristPrice ?? 0;
    numWinners = priceList[i].winner ?? 1;

    setState(() {});

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: priceCardList.length,
      itemBuilder: (context, index) {
        PriceCardData data = priceCardList[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 18,
                  ),
                  child: Text(
                    data.rank != null ? '#${data.rank}' : '',
                    style: const TextStyle(
                      color: AppColors.letterColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 18,
                  ),
                  child: Text(
                    '${Strings.indianRupee}${data.prize}',
                    style: GoogleFonts.tomorrow(
                      color: AppColors.letterColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(
              color: AppColors.letterColor,
              thickness: 0.15,
              height: 0.15,
            ),
          ],
        );
      },
    );
  }
}
