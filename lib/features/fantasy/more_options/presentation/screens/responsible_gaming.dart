import 'package:flutter/cupertino.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/sub_container.dart';

class ResponsibleGaming extends StatelessWidget {
  const ResponsibleGaming({super.key});

  Widget _heading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
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
        color: AppColors.blackColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SubContainer(
      showAppBar: true,
      showWalletIcon: false,
      headerText: Strings.responsibleGaming,
      addPadding: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heading("Responsible Gaming Policy"),
            _body(
                "Dream247 is committed to responsible gaming and, as a part of its corporate social responsibility, advises its users to follow responsible gaming practices as mentioned in the Dream247 Responsible Gaming guide."
                "\n\nAt Dream247, we are dedicated to ascertaining that our users have a fun, entertaining, safe, secure and responsible gaming experience. Thus, we have implemented a strict Responsible Gaming Policy."),
            _heading("Responsible Gaming Policy For Fantasy:"),
            _body(
                "Dream247 appreciates your love of gaming. As a result, we have implemented strict guidelines so that you can play your game and excel at it. Our player-focused project, Responsible Gaming for Fantasy Games, includes a list of carefully developed guidelines that you must follow in order to keep using our site."
                "\n\nWe hope to make each day more fruitful and exciting for you through fantasy. The key components of our fantasy game responsible gaming policy are listed below."),
            _body(
                "\n1. Our fantasy gaming services are wholly skill-based activities."
                "\n2. Even while they might be used for entertainment and have alluring reward systems, they cannot and must not be compared to a steady source of revenue."
                "\n3. You should keep track of how much time and money you spend using our services. If you think it's impacting you personally or financially, we advise you to quit right away."
                "\n4. Play with a cheerful attitude and not to make up for previous \"losses.\""
                "\n5. Please refrain from asking for money to play these games."
                "\n6. Before moving ahead, be sure to consult your family and friends."
                "\n7. Additionally, we forbid gamers under the age of 18 from using our services."
                "\n8. We proactively monitor users and their activities to identify vulnerable users and ensure responsible play."
                "\n9. We advise you to set restrictions on how much time you can devote to our online games."
                "\n10. Use only an amount that you could afford to lose and think carefully about bank management."),
            _heading("Responsible Play Guide:"),
            _body(
                "Daily Fantasy Sports may be addictive at times and since paid games involve time and money, please play responsibly at your own risk."
                "\n\n• Consider moderation while using our platform."
                "\n• Do not chase losses."
                "\n• Do proper financial planning and set an entertainment budget."
                "\n• Balance your professional, personal, and family life."
                "\n• Avoid playing under the influence of alcohol or emotional stress."
                "\n• Do not be coerced by others to spend beyond your limits."
                "\n\nResponsible gaming requires cooperation between you and us. Kindly exercise due caution and read this policy thoroughly."),
            _heading("Contact Us:"),
            _body(
                "Any questions, clarifications, complaints, or feedback may be sent to: support@Dream247.com"),
          ],
        ),
      ),
    );
  }
}
