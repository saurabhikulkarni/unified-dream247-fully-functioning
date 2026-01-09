// ignore_for_file: use_build_context_synchronously, unused_import
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/sub_container.dart';
import 'package:unified_dream247/features/fantasy/menu_items/presentation/widgets/logout_dialogbox.dart';
import 'package:unified_dream247/features/fantasy/onboarding/presentation/controllers/login_controller.dart';
import 'package:provider/provider.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_storage_keys.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_storage.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/providers/wallet_details_provider.dart';
import 'package:unified_dream247/features/fantasy/menu_items/presentation/providers/user_data_provider.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/provider/joined_live_contest_provider.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/provider/live_leaderboard_provider.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/provider/live_score_provider.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/provider/player_stats_provider.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/provider/scorecard_provider.dart';
import 'package:unified_dream247/features/fantasy/onboarding/presentation/screens/login_screen.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/providers/myteams_provider.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/providers/team_preview_provider.dart';
import 'package:unified_dream247/features/fantasy/user_verification/presentation/providers/kyc_details_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool biomatricLock = false;
  bool notificationSound = false;
  String downloadDirectory = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    // AppStorage.getStorageValueBool(AppStorageKeys.biometricLock)
    //     .then((value) => {
    //           setState(() {
    //             biomatricLock = value ?? false;
    //           })
    //         });
    // AppStorage.getStorageValueBool(AppStorageKeys.notificationSound)
    //     .then((value) => {
    //           setState(() {
    //             notificationSound = value ?? false;
    //           })
    //         });
  }

  void checkforUpdate(BuildContext context) async {
    // PackageInfo packageInfo = await PackageInfo.fromPlatform();

    // int liveVersion = Platform.isAndroid
    // ? AppSingleton.singleton.appData.version ?? 1
    // : AppSingleton.singleton.appData.iosVersion ?? 1;

    //   int currentVersion = int.parse(packageInfo.buildNumber);

    //   debugPrint("CurrentVersion : $currentVersion");
    //   debugPrint("LiveVersion : $liveVersion");

    //   if (currentVersion >= liveVersion) {
    //     appToast("The application is up to date.", context);
    //   } else {
    //     showModalBottomSheet<void>(
    //         context: context,
    //         isScrollControlled: true,
    //         shape: const RoundedRectangleBorder(
    //           borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
    //         ),
    //         builder: (BuildContext context) {
    //           return const AppUpdateBottomSheet();
    //         });
    //   }
  }

  @override
  Widget build(BuildContext context) {
    return SubContainer(
      showAppBar: true,
      showWalletIcon: false,
      headerText: Strings.settings,
      addPadding: false,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.white,
              AppColors.lightBlue.withValues(alpha: 0.05)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSettingCard(
                icon: Icons.notifications_active,
                title: 'Allow Notification Sound',
                trailing: Switch(
                  value: notificationSound,
                  onChanged: (value) {
                    setState(() {
                      notificationSound = value;
                    });
                  },
                  activeTrackColor: AppColors.mainColor.withValues(alpha: 0.5),
                  activeThumbColor: AppColors.mainColor,
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingCard(
                icon: Icons.downloading_rounded,
                title: 'Check for Updates',
                onTap: () => checkforUpdate(context),
              ),
              const SizedBox(height: 16),
              _buildSettingCard(
                  icon: Icons.logout_rounded,
                  title: Strings.logout,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => LogoutDialog(),
                    );
                  },
                  titleColor: AppColors.black),
            ],
          ),
        ),
      ),
    );
  }

  /// Premium Setting Card Widget
  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    Color? titleColor,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.lightBlue.withValues(alpha: 0.3),
                    AppColors.mainColor.withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mainColor.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(1, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.letterColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: titleColor ?? AppColors.letterColor,
                ),
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.letterColor.withValues(alpha: 0.4),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
