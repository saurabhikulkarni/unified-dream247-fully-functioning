import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_pages.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';

class MoreOptionsPage extends StatefulWidget {
  const MoreOptionsPage({super.key});

  @override
  State<MoreOptionsPage> createState() => _MoreOptionsPageState();
}

class _MoreOptionsPageState extends State<MoreOptionsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.white,
            AppColors.lightBlue.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildOptionList()],
        ),
      ),
    );
  }

  Widget _buildOptionList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _moreTile(
            onTap: () => AppNavigation.gotoFantasyPointSystem(context),
            image: Image.asset(
              Images.imagePointsSystem,
              height: 24,
              width: 24,
              color: AppColors.letterColor,
            ),
            title: Strings.fantasyPointSystem,
          ),
          _divider(),
          _moreTile(
            onTap: () => AppNavigation.gotoHowtoPlayPage(context),
            image: SvgPicture.asset(
              Images.howToPlay,
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.letterColor,
                BlendMode.srcIn,
              ),
            ),
            title: Strings.howToPlay,
          ),
          _divider(),
          _moreTile(
            onTap: () => AppNavigation.gotoPrivacyPolicyPage(context),
            image: Image.asset(
              Images.imagePrivacyPolicy,
              height: 24,
              width: 24,
              color: AppColors.letterColor,
            ),
            title: Strings.privacyPolicy,
          ),
          _divider(),
          _moreTile(
            onTap: () => AppNavigation.gotoFaqPage(context),
            image: Image.asset(
              Images.imageFaq,
              height: 24,
              width: 24,
              color: AppColors.letterColor,
            ),
            title: Strings.frequentlyAskedQuestions,
          ),
          _divider(),
          _moreTile(
            onTap: () => AppNavigation.gotoAboutUsPage(context),
            image: Image.asset(
              Images.imageAboutUs,
              height: 24,
              width: 24,
              color: AppColors.letterColor,
            ),
            title: Strings.aboutUs,
          ),
          _divider(),
          // _moreTile(
          //   onTap: () => AppNavigation.gotoWebViewScreen(
          //     context,
          //     Strings.contactUs,
          //     "https://www.Dream247.com/contact-us/",
          //   ),
          //   image: const Icon(
          //     Icons.headset_mic_outlined,
          //     size: 24,
          //     color: AppColors.letterColor,
          //   ),
          //   title: Strings.contactUs,
          // ),
          // _divider(),
          _moreTile(
            onTap: () => AppNavigation.gotoTermsConditionsPage(context),
            image: Image.asset(
              Images.imageTerms,
              height: 24,
              width: 24,
              color: AppColors.letterColor,
            ),
            title: Strings.termsConditions,
          ),
          _divider(),
          // _moreTile(
          //   onTap: () => AppNavigation.gotoWebViewScreen(
          //     context,
          //     Strings.legality,
          //     "https://www.Dream247.com/legalities/",
          //   ),
          //   image: Image.asset(
          //     Images.imageLegality,
          //     height: 24,
          //     width: 24,
          //     color: AppColors.letterColor,
          //   ),
          //   title: Strings.legality,
          // ),
          // _divider(),
          _moreTile(
            onTap: () => AppNavigation.gotoResponsibleGamingPage(context),
            image: SvgPicture.asset(
              Images.respplay,
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.letterColor,
                BlendMode.srcIn,
              ),
            ),
            title: Strings.responsibleGaming,
          ),
          _divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'App Version : 1.0.0',
              style: TextStyle(
                color: AppColors.letterColor.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        height: 0.8,
        color: AppColors.lightGrey.withValues(alpha: 0.15),
        margin: const EdgeInsets.symmetric(horizontal: 16),
      );

  Widget _moreTile({
    required Function() onTap,
    required Widget image,
    required String title,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.lightBlue.withValues(alpha: 0.15),
                    AppColors.lightBlue.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: image),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.letterColor,
                ),
              ),
            ),
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
