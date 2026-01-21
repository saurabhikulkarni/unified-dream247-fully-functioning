import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/sub_container.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/menu_items/presentation/providers/user_data_provider.dart';
import 'package:unified_dream247/features/fantasy/menu_items/presentation/screens/refer_users_list.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ReferAndEarnPage extends StatefulWidget {
  const ReferAndEarnPage({super.key});

  @override
  State<ReferAndEarnPage> createState() => _ReferAndEarnPage();
}

class _ReferAndEarnPage extends State<ReferAndEarnPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userData =
        Provider.of<UserDataProvider>(context, listen: false).userData;
    debugPrint(userData?.referCode);

    return SubContainer(
      showAppBar: true,
      showWalletIcon: false,
      headerText: Strings.referEarn,
      addPadding: true,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            /// Animated / Illustration Container
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  Images.imageReferEarn,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            /// Text content area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.greyColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.greyColor, width: 0.5),
              ),
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      'Refer your Friends with referral code',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Share this referral code with your friends and start creating your fantasy teams to compete in exciting matches!',
                    style: TextStyle(
                      color: AppColors.whiteFade1,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    ' Earn ${Strings.indianRupee}${AppSingleton.singleton.appData.referBonus} on each referral.',
                    style: GoogleFonts.exo2(
                      color: AppColors.whiteFade1,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// Referral Code Container
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AppColors.lightGrey,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Make this flexible
                  Expanded(
                    child: Row(
                      children: [
                        const Text(
                          'Referral Code',
                          style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          color: AppColors.black,
                          height: 25,
                          width: 1.0,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            userData?.referCode ?? 'Dream247AO12',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.blackColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: userData?.referCode ?? ''),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Code Copied to Clipboard'),
                          backgroundColor: AppColors.mainColor,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.copy,
                            color: AppColors.blackColor,
                            size: 14,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Copy',
                            style: TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            /// Refer and Earn button
            InkWell(
              onTap: () {
                String text = AppSingleton.singleton.appData.refermessage!
                    .replaceAll('%REFERCODE%', userData?.referCode ?? '');
                SharePlus.instance.share(ShareParams(text: text));
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [AppColors.mainLightColor, AppColors.mainColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: const Center(
                  child: Text(
                    'Refer and Earn',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),

            /// View All Refers button
            InkWell(
              onTap: () {
                // AppNavigation.gotoReferUserListScreen(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReferUsersList()),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'View All Referred Users',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationThickness: 2.0,
                    decorationStyle: TextDecorationStyle.solid,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.blackColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
