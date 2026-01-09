import 'package:flutter/widgets.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/sub_container.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  Widget _heading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _body(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        height: 1.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SubContainer(
      showAppBar: true,
      showWalletIcon: false,
      headerText: Strings.aboutUs,
      addPadding: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heading("About Us"),
            _body(
              "Dream247 Fantasy\n"
              "At Dream247 Fantasy, We're Passionate About Fantasy Sports And Committed To Providing An Unparalleled Gaming Experience To Sports Enthusiasts Across India. "
              "Our Platform Is Designed To Bring The Excitement Of Real Sports Into The Virtual World, Allowing You To Immerse Yourself In The Game, Showcase Your Sports Knowledge, And Win Big.",
            ),
            _heading("Why Choose Dream247 Fantasy?"),
            _body(
              "• Variety Of Sports: We Offer A Wide Range Of Sports, Including Cricket, Football, Basketball, And More. You Can Create Your Dream Team For Various Leagues And Tournaments.\n\n"
              "• User-Friendly Interface: Our Platform Is Easy To Navigate, Making It Accessible To Both Beginners And Experienced Fantasy Sports Players.\n\n"
              "• Fair Play: Dream247 Fantasy Is Dedicated To Ensuring Fair And Transparent Gameplay. We Use Cutting-Edge Technology To Maintain The Integrity Of Every Match And Contest.\n\n"
              "• Instant Rewards: Win Cash Prizes, Bonus Offers, And Exclusive Rewards By Participating In Our Contests. We Provide Instant Withdrawals, So You Can Enjoy Your Earnings Without Delay.\n\n"
              "• Affiliate Program: Earn Money By Becoming Our Affiliate Partner. Promote Dream247 Fantasy On Your Platform And Receive Commissions For Every User Who Joins Through Your Referral.\n\n"
              "• 24/7 Customer Support: Our Dedicated Support Team Is Available Round The Clock To Assist You With Any Queries Or Concerns.",
            ),
            _heading("Our Mission"),
            _body(
              "At Our Mission At Dream247 Fantasy Is To Revolutionize The Fantasy Sports Industry In India. "
              "We're Driven By The Vision Of Making Sports More Engaging And Rewarding For Fans. "
              "Whether You're A Casual Player Or A Die-Hard Sports Enthusiast, Dream247 Fantasy Is Your Gateway To An Exciting World Of Fantasy Sports.",
            ),
            _heading("Join Us Today"),
            _body(
              "Ready To Experience The Thrill Of Fantasy Sports? Join Dream247 Fantasy Today, Create Your Winning Team, And Start Playing! "
              "With Dream247 Fantasy, Every Match Becomes A Chance To Showcase Your Skills, Compete With Fellow Sports Lovers, And Win Incredible Rewards.\n\n"
              "Get In The Game With Dream247 Fantasy And Take Your Love For Sports To New Heights!",
            ),
          ],
        ),
      ),
    );
  }
}
