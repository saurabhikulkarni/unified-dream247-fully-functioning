import 'package:flutter/widgets.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/sub_container.dart';

class HowToPlay extends StatelessWidget {
  const HowToPlay({super.key});

  @override
  Widget build(BuildContext context) {
    return SubContainer(
      showAppBar: true,
      showWalletIcon: false,
      headerText: Strings.howToPlay,
      addPadding: true,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Heading
            const Text(
              Strings.howToPlay,
              style: TextStyle(
                color: AppColors.black,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 18),

            /// Intro
            Text(
              'Follow four simple steps in the Dream247 app to create your fantasy cricket team and start winning:',
              style: TextStyle(
                color: AppColors.black.withValues(alpha: 0.85),
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 25),

            // ------------------ STEP 1 ------------------
            _stepTitle('1. Choose a Match'),
            _stepDesc(
              'Open the app, choose an upcoming cricket match (T20, ODI, or Test), and create your team before the deadline.',
            ),

            const SizedBox(height: 20),

            // ------------------ STEP 2 ------------------
            _stepTitle('2. Create Fantasy Team'),
            _stepDesc(
              'Select 11 players from both teams within your budget. Maximum 7 players can be picked from one team.\n\n'
              '• Captain = 2× points\n'
              '• Vice-Captain = 1.5× points',
            ),

            const SizedBox(height: 20),

            // ------------------ STEP 3 ------------------
            _stepTitle('3. Join Contests'),
            _stepDesc(
              'Choose any contest based on entry fee, ranking size, and potential winnings. Track your team’s performance as the match goes live.',
            ),

            const SizedBox(height: 20),

            // ------------------ STEP 4 ------------------
            _stepTitle('4. Track Leaderboards & Withdraw'),
            _stepDesc(
              'Monitor your rank during the match. Withdraw your winnings easily through bank transfer, UPI, or other available payment methods.',
            ),

            const SizedBox(height: 25),

            // ------------------ FINAL SECTION ------------------
            Text(
              'After completing all four steps, your predictions will appear on the Fantasy Cricket Table. '
              'Once the match ends, the total points for each Cricket Table will be displayed.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.black.withValues(alpha: 0.85),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 15),

            /// HIGHLIGHTED WEBSITE
            const Text(
              'So what are you waiting for?\nCreate your Cricket Table now on the Dream247 App.\n\n'
              'Download now:  ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
                height: 1.5,
              ),
            ),

            const Text(
              'www.Dream247.com',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.blackColor,
                decoration: TextDecoration.underline,
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  /// 🔹 Reusable Step Title
  Widget _stepTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
      ),
    );
  }

  /// 🔹 Reusable Step Description
  Widget _stepDesc(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.black.withValues(alpha: 0.85),
          height: 1.5,
        ),
      ),
    );
  }
}
