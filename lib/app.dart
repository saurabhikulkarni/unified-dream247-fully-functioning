import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import 'config/routes/app_router.dart';
import 'config/theme/app_theme.dart';

// Shop providers
import 'core/providers/shop_tokens_provider.dart';

// Fantasy providers (all 11 providers as specified)
import 'features/fantasy/accounts/presentation/providers/wallet_details_provider.dart';
import 'features/fantasy/menu_items/presentation/providers/user_data_provider.dart';
import 'features/fantasy/my_matches/presentation/provider/joined_live_contest_provider.dart';
import 'features/fantasy/my_matches/presentation/provider/live_leaderboard_provider.dart';
import 'features/fantasy/my_matches/presentation/provider/live_score_provider.dart';
import 'features/fantasy/my_matches/presentation/provider/player_stats_provider.dart';
import 'features/fantasy/my_matches/presentation/provider/scorecard_provider.dart';
import 'features/fantasy/upcoming_matches/presentation/providers/all_players_provider.dart';
import 'features/fantasy/upcoming_matches/presentation/providers/myteams_provider.dart';
import 'features/fantasy/upcoming_matches/presentation/providers/team_preview_provider.dart';
import 'features/fantasy/user_verification/presentation/providers/kyc_details_provider.dart';

/// Main application widget with unified providers
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Setup global BLoC observer
    Bloc.observer = GlobalBlocObserver();

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            // Shop providers
            ChangeNotifierProvider(create: (_) => ShopTokensProvider(refreshInterval: 30)),
            
            // Fantasy gaming providers (11 providers)
            ChangeNotifierProvider(create: (_) => UserDataProvider()),
            ChangeNotifierProvider(create: (_) => MyTeamsProvider()),
            ChangeNotifierProvider(create: (_) => TeamPreviewProvider()),
            ChangeNotifierProvider(create: (_) => AllPlayersProvider()),
            ChangeNotifierProvider(create: (_) => WalletDetailsProvider()),
            ChangeNotifierProvider(create: (_) => KycDetailsProvider()),
            ChangeNotifierProvider(create: (_) => PlayerStatsProvider()),
            ChangeNotifierProvider(create: (_) => ScorecardProvider()),
            ChangeNotifierProvider(create: (_) => LiveScoreProvider()),
            ChangeNotifierProvider(create: (_) => JoinedLiveContestProvider()),
            ChangeNotifierProvider(create: (_) => LiveLeaderboardProvider()),
          ],
          child: OKToast(
            position: ToastPosition.bottom,
            duration: const Duration(seconds: 2),
            child: MaterialApp.router(
              title: 'DREAM 247',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.light,
              routerConfig: AppRouter.router,
            ),
          ),
        );
      },
    );
  }
}

/// Global BLoC observer for debugging and monitoring
class GlobalBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    // Log bloc changes in debug mode
    // ignore: avoid_print
    print('${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    // Log bloc errors
    // ignore: avoid_print
    print('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}
