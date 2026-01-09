import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Dream247/features/onboarding/presentation/controllers/login_controller.dart';
import 'package:provider/provider.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/app_storage_keys.dart';
import 'package:Dream247/core/app_constants/strings.dart';
import 'package:Dream247/core/utils/app_storage.dart';
import 'package:Dream247/features/accounts/presentation/providers/wallet_details_provider.dart';
import 'package:Dream247/features/menu_items/presentation/providers/user_data_provider.dart';
import 'package:Dream247/features/my_matches/presentation/provider/joined_live_contest_provider.dart';
import 'package:Dream247/features/my_matches/presentation/provider/live_leaderboard_provider.dart';
import 'package:Dream247/features/my_matches/presentation/provider/live_score_provider.dart';
import 'package:Dream247/features/my_matches/presentation/provider/player_stats_provider.dart';
import 'package:Dream247/features/my_matches/presentation/provider/scorecard_provider.dart';
import 'package:Dream247/features/onboarding/presentation/screens/login_screen.dart';
import 'package:Dream247/features/upcoming_matches/presentation/providers/myteams_provider.dart';
import 'package:Dream247/features/upcoming_matches/presentation/providers/team_preview_provider.dart';
import 'package:Dream247/features/user_verification/presentation/providers/kyc_details_provider.dart';

class LogoutDialog extends StatefulWidget {
  const LogoutDialog({super.key});

  @override
  State<LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<LogoutDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgColor,
      title: const Text(
        Strings.logout,
        style: TextStyle(color: AppColors.blackColor),
      ),
      content: const Text(Strings.confirmLogout),
      actions: <Widget>[
        TextButton(
          child: const Text(
            Strings.cancel,
            style: TextStyle(color: AppColors.blackColor),
          ),
          onPressed: () {
            Get.back();
          },
        ),
        TextButton(
          child: const Text(
            Strings.logout,
            style: TextStyle(color: AppColors.blackColor),
          ),
          onPressed: () {
            logout(context);
          },
        ),
      ],
    );
  }

  void logout(BuildContext context) {
    AppStorage.saveToStorageBool(AppStorageKeys.logedIn, false);
    AppStorage.saveToStorageString(AppStorageKeys.authToken, "");
    AppStorage.clear();
    Navigator.of(context).pop();
    if (context.mounted) {
      Provider.of<UserDataProvider>(context, listen: false).clearUserData();
      Provider.of<MyTeamsProvider>(context, listen: false).clearUserData();
      Provider.of<TeamPreviewProvider>(context, listen: false).clearUserData();
      Provider.of<KycDetailsProvider>(context, listen: false).clearkycData();
      Provider.of<PlayerStatsProvider>(context, listen: false).clearUserData();
      Provider.of<WalletDetailsProvider>(
        context,
        listen: false,
      ).clearWalletData();
      Provider.of<ScorecardProvider>(context, listen: false).clearScoreCard();
      Provider.of<LiveScoreProvider>(context, listen: false).clearLiveScore();
      Provider.of<JoinedLiveContestProvider>(
        context,
        listen: false,
      ).clearjoinedContest();
      Provider.of<LiveLeaderboardProvider>(
        context,
        listen: false,
      ).clearliveJoinTeams();
    }
    Get.find<LoginController>().isOtpScreen.value = false;
    Get.offAll(() => LoginScreen());
  }
}
