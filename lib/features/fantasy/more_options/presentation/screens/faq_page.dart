import 'package:flutter/widgets.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/sub_container.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': 'Which gaming app gives cash?',
        'a': 'Dream247 allows you to earn cash by playing online games daily.',
      },
      {
        'q': 'What is the Dream247 app?',
        'a':
            'Dream247 is most trusted gaming app that allows users to play free and real-cash card games and fantasy sports online every day.',
      },
      {
        'q': 'Is the Dream247 app free?',
        'a':
            'Yes, the Dream247 app is completely free to download on Android and iOS devices.',
      },
      {
        'q': 'Is the Dream247 app safe?',
        'a':
            'Yes, the Dream247 app is fully safe, secure, legally compliant, and follows a strict fair-play policy.',
      },
      {
        'q': 'Minimum withdrawal amount?',
        'a':
            'Minimum withdrawal on the Dream247 app is ₹100. Amount can be transferred to bank accounts or digital wallets.',
      },
      {
        'q': 'Which games are available on the Dream247 app?',
        'a':
            'Dream247 offers fantasy sports, card games, casual skill-based games, and daily contests.',
      },
      {
        'q': 'How to win a bonus on the Dream247 app?',
        'a':
            'Earn bonuses through daily challenges, referrals, deposits, and running contests.',
      },
    ];

    return SubContainer(
      showAppBar: true,
      showWalletIcon: false,
      headerText: Strings.frequentlyAskedQuestions,
      addPadding: true,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 15),

            // Render all questions
            for (int i = 0; i < faqs.length; i++)
              _faqCard(
                index: i + 1,
                question: faqs[i]['q']!,
                answer: faqs[i]['a']!,
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ********* CARD STYLE FAQ ITEM ********* //
  Widget _faqCard({
    required int index,
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number + Question Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$index. ',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mainColor,
                ),
              ),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            answer,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.black.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}
