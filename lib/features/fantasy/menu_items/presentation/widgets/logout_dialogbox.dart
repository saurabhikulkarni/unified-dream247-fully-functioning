import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:unified_dream247/config/routes/route_names.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/providers/wallet_details_provider.dart';
import 'package:unified_dream247/features/fantasy/menu_items/presentation/providers/user_data_provider.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/provider/joined_live_contest_provider.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/provider/live_leaderboard_provider.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/provider/live_score_provider.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/provider/player_stats_provider.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/provider/scorecard_provider.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/providers/myteams_provider.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/providers/team_preview_provider.dart';
import 'package:unified_dream247/features/fantasy/user_verification/presentation/providers/kyc_details_provider.dart';
import 'package:unified_dream247/features/shop/services/auth_service.dart';

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
            Navigator.of(context).pop();
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

  void logout(BuildContext context) async {
    // Use unified logout to clear both shop and fantasy data
    final authService = AuthService();
    await authService.unifiedLogout();
    
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
    if (context.mounted) {
      context.go(RouteNames.login);
    }
  }
}
