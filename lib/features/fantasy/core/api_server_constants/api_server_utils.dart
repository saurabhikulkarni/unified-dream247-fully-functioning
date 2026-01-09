import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_pages.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_storage_keys.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/app_toast.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_storage.dart';
import 'package:unified_dream247/features/fantasy/features/menu_items/presentation/providers/user_data_provider.dart';
import 'package:unified_dream247/features/fantasy/features/onboarding/presentation/screens/login_screen.dart';
import 'package:unified_dream247/features/fantasy/features/upcoming_matches/presentation/providers/myteams_provider.dart';
import 'package:unified_dream247/features/fantasy/features/accounts/presentation/providers/wallet_details_provider.dart';
import 'package:unified_dream247/features/fantasy/features/my_matches/presentation/provider/joined_live_contest_provider.dart';
import 'package:unified_dream247/features/fantasy/features/my_matches/presentation/provider/live_leaderboard_provider.dart';
import 'package:unified_dream247/features/fantasy/features/my_matches/presentation/provider/live_score_provider.dart';
import 'package:unified_dream247/features/fantasy/features/my_matches/presentation/provider/player_stats_provider.dart';
import 'package:unified_dream247/features/fantasy/features/my_matches/presentation/provider/scorecard_provider.dart';
import 'package:unified_dream247/features/fantasy/features/upcoming_matches/presentation/providers/team_preview_provider.dart';
import 'package:unified_dream247/features/fantasy/features/user_verification/presentation/providers/kyc_details_provider.dart';

class ApiServerUtil {
  static bool validateStatusCode(int statusCode) {
    if (statusCode == 200 || statusCode == 202 || statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  static void showAppToastforApi(String body, BuildContext context) {
    appToast(body, context);
  }

  /// Handle Dio error responses
  static Future<void> handleDioError(
    dynamic error,
    BuildContext context,
  ) async {
    if (error is DioException) {
      final response = error.response;
      // Handle based on status code
      if (response != null) {
        await manageException(response, context);
      } else {
        appToast("Connection failed. Please try again later.", context);
      }
    } else {
      appToast("Unexpected error occurred.", context);
    }
  }

  /// Manage known server errors
  static Future<void> manageException(response, BuildContext context) async {
    final statusCode = response.statusCode;

    if (statusCode == 401 || statusCode == 440) {
      await AppStorage.saveToStorageBool(AppStorageKeys.logedIn, false);
      await AppStorage.saveToStorageString(AppStorageKeys.authToken, "");
      await AppStorage.clear();

      if (context.mounted) {
        Provider.of<UserDataProvider>(context, listen: false).clearUserData();
        Provider.of<MyTeamsProvider>(context, listen: false).clearUserData();
        Provider.of<TeamPreviewProvider>(
          context,
          listen: false,
        ).clearUserData();
        Provider.of<KycDetailsProvider>(context, listen: false).clearkycData();
        Provider.of<PlayerStatsProvider>(
          context,
          listen: false,
        ).clearUserData();
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
        Get.to(() => LoginScreen());
      }
    } else if (statusCode == 500) {
      appToast(Strings.internalServerError, context);
    } else if (statusCode == 503) {
      AppNavigation.gotoSplashScreen(context);
    } else {
      final message = response.data?['message'] ?? Strings.somethingWentWrong;
      appToast(message, context);
    }
  }
}
