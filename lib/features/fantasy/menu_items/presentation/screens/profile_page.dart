import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/app_pages.dart';
import 'package:Dream247/core/app_constants/images.dart';
import 'package:Dream247/core/app_constants/strings.dart';
import 'package:Dream247/core/global_widgets/cached_images.dart';
import 'package:Dream247/core/global_widgets/main_button.dart';
import 'package:Dream247/core/global_widgets/sub_container.dart';
import 'package:Dream247/features/accounts/presentation/providers/wallet_details_provider.dart';
import 'package:Dream247/features/menu_items/data/models/level_reward_model.dart';
import 'package:Dream247/features/menu_items/data/user_datasource.dart';
import 'package:Dream247/features/menu_items/domain/use_cases/user_usecases.dart';
import 'package:Dream247/features/menu_items/presentation/providers/user_data_provider.dart';
import 'package:Dream247/features/menu_items/presentation/screens/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  LevelRewardModel? data;
  UserUsecases userUsecases = UserUsecases(
    UserDatasource(ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    levelData();
  }

  levelData() async {
    data = await userUsecases.loadLevelRewards(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userData =
        Provider.of<UserDataProvider>(context, listen: false).userData;
    final walletData =
        Provider.of<WalletDetailsProvider>(context, listen: false).walletData;

    return SubContainer(
      showAppBar: true,
      showWalletIcon: true,
      headerText: Strings.profile,
      addPadding: false,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                      border: Border.all(
                        color: AppColors.mainColor,
                        width: 3.0,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 42,
                      child: ClipOval(
                        child: CachedImage(
                          imageUrl: userData?.image ?? "",
                          errorWidget: Image.asset(
                            Images.imageDefalutPlayer,
                            height: 35,
                            width: 35,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userData?.team ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.letterColor,
                        ),
                      ),
                      Text(
                        ((userData?.name ?? "").isNotEmpty)
                            ? userData?.name ?? "---"
                            : '---',
                        style: const TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 13,
                          color: AppColors.letterColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: MainButton(
                        onTap: () {
                          Get.to(() => EditProfile());
                        },
                        height: 36,
                        text: 'Edit Profile',
                        color: AppColors.mainColor,
                        textColor: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: MainButton(
                        onTap: () {
                          AppNavigation.gotoVerifyDetailsScreen(context);
                        },
                        height: 36,
                        text: 'KYC',
                        color: AppColors.mainColor,
                        textColor: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (data != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.white,
                    border: Border.all(color: AppColors.whiteFade1, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (data!.allLevelCompleted == false)
                          ? Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Level',
                                            style: TextStyle(
                                              color: AppColors.letterColor,
                                              fontWeight: FontWeight.w300,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            data?.currentLevel.toString() ??
                                                "0",
                                            style: const TextStyle(
                                              color: AppColors.letterColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          const Text(
                                            'Level',
                                            style: TextStyle(
                                              color: AppColors.greyColor,
                                              fontWeight: FontWeight.w300,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            data?.nextLevel.toString() ?? "0",
                                            style: const TextStyle(
                                              color: AppColors.letterColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      'To move to next level you need to',
                                      style: TextStyle(
                                        color: AppColors.letterColor,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        const Text(
                                          'Play',
                                          style: TextStyle(
                                            color: AppColors.greyColor,
                                            fontWeight: FontWeight.w300,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          data?.totalPlayContest.toString() ??
                                              "0",
                                          style: const TextStyle(
                                            color: AppColors.letterColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const Text(
                                          'Cash Contests',
                                          style: TextStyle(
                                            color: AppColors.greyColor,
                                            fontWeight: FontWeight.w300,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Text(
                                      '&',
                                      style: TextStyle(
                                        color: AppColors.letterColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        const Text(
                                          'Win',
                                          style: TextStyle(
                                            color: AppColors.greyColor,
                                            fontWeight: FontWeight.w300,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          data?.numberOfWinningContest
                                                  .toString() ??
                                              "0",
                                          style: const TextStyle(
                                            color: AppColors.letterColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const Text(
                                          'Cash Contests',
                                          style: TextStyle(
                                            color: AppColors.greyColor,
                                            fontWeight: FontWeight.w300,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      'You will earn ${Strings.indianRupee}${data?.nextLevelReward} in ${data?.rewardType}',
                                      style: const TextStyle(
                                        color: AppColors.letterColor,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image(
                                  image: AssetImage(Images.hurrah),
                                  height: 80,
                                  width: 80,
                                ),
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 5,
                                    ),
                                    child: Text(
                                      'Hurrah! You have completed all the levels.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: AppColors.letterColor,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 5,
                                  ),
                                  child: Text(
                                    'Keep Playing!!!',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: AppColors.letterColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 5,
                        ),
                        child: Text(
                          'Career Stats',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.letterColor,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Contests',
                                    style: TextStyle(
                                      color: AppColors.greyColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    '${walletData?.totaljoinedcontest ?? 0}',
                                    style: const TextStyle(
                                      color: AppColors.letterColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 0.8,
                            color: AppColors.greyColor,
                            height: 73,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(
                                15,
                              ).copyWith(bottom: 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Matches',
                                    style: TextStyle(
                                      color: AppColors.greyColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    '${walletData?.totaljoinedmatches ?? 0}',
                                    style: const TextStyle(
                                      color: AppColors.letterColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        color: AppColors.greyColor,
                        height: .15,
                        thickness: .15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Series',
                                    style: TextStyle(
                                      color: AppColors.greyColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    '${walletData?.totaljoinedseries ?? 0}',
                                    style: const TextStyle(
                                      color: AppColors.letterColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 0.8,
                            color: AppColors.greyColor,
                            height: 73,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Total Winnings',
                                    style: TextStyle(
                                      color: AppColors.greyColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    '${Strings.indianRupee}${walletData?.totalwoncontest ?? 0}',
                                    style: GoogleFonts.tomorrow(
                                      color: AppColors.letterColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        color: AppColors.greyColor,
                        height: 0.5,
                        thickness: 0.5,
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: RichText(
                          text: TextSpan(
                            text:
                                'You have been playing on {APIServerUrl.appName} since ',
                            style: const TextStyle(
                              overflow: TextOverflow.clip,
                              color: AppColors.letterColor,
                              fontWeight: FontWeight.w300,
                              fontSize: 13,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: '${userData?.joiningDate}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
