import 'package:flutter/widgets.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/sub_container.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  Widget _heading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
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
      headerText: Strings.privacyPolicy,
      addPadding: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heading('PRIVACY POLICY'),
            _body(
                'Dream247 LLP operates the portal in India, which offers cricket as Dream247 game through the android mobile application (collectively referred to as the Portal) (Dream247 LLP referred to herein as Dream247 or we or us or our).'
                '\n\nAny person utilizing the Portal (User or you or your) or any of its features including participation in the various contests, games (including Dream247 games (Game) (Services) being conducted on the Portal) shall be bound by this Privacy Policy.'
                '\n\nDream247 respects the privacy of its Users and is committed to protect it in all respects. With a view to offer an enriching and holistic internet experience to its Users, Dream247 offers Dream247 Cricket game service.'
                '\n\nBefore you submit any information to the Portal, please read this Privacy Policy for an explanation of how we will treat your personal information. By using any part of the Portal, you consent to the collection, use, disclosure and transfer of your personal information as outlined herein.'),
            _heading('Use of the Services'),
            _body(
                'To avail certain Services on the Portal, Users would be required to provide certain information for the registration process namely:'
                '\nUsername\nPassword\nEmail address\nEmail address'
                '\n\nYou may also be required to furnish additional information including your Permanent Account Number.'
                '\n\nIn certain instances, we may collect Sensitive Personal Information (“SPI”) such as health condition, medical records, biometric information, sexual orientation, financial info including cardholder details, wallet details etc.'
                '\n\nExcept for financial information provided during payments, Dream247 does not collect other SPI. Any SPI collected will not be disclosed to third parties without your express consent except where required by law.'
                '\n\nIn the course of providing Services, Users may invite other users (‘Invited Users’) via email or Facebook username for contests.'),
            _heading('Data Disclosure/Sharing'),
            _body(
                'Dream247 may share user data with third-party service providers for analytics, storage, fraud prevention or service improvement.'
                '\n\nDream247 may share or transfer data if it sells or transfers business assets. Dream247 may disclose information when legally required.'
                '\n\nYour IP address may be collected automatically to tailor the Portal experience and measure traffic.'),
            _heading('Web Links'),
            _body(
                'Dream247 may include links to external websites. Their privacy practices are beyond our control. Please review the privacy policies of such external sites separately.',),
            _heading('Security Encryptions'),
            _body(
                'All information is securely stored behind firewalls with restricted access. However, no system is 100% secure and Dream247 cannot guarantee complete protection.'
                '\n\nInternet is an evolving medium; Dream247 may update its policy without prior notice. Updates will be posted on this page.'),
            _heading('Advertisement by Dream247'),
            _body(
                'Aggregated statistics may be presented to advertisers. Beware of fake emails/websites pretending to be Dream247. Do not share login details or respond to suspicious communication.',),
            _heading('Conditions of Use'),
            _body(
                'Dream247 DOES NOT WARRANT THAT THE PORTAL OR EMAILS ARE VIRUS-FREE. Dream247 WILL NOT BE LIABLE FOR ANY FORM OF DAMAGES. MAXIMUM LIABILITY IS INR 50 ONLY.',),
            _heading('Data Storage'),
            _body(
                'Your personal information may be retained until its purpose is fulfilled or as required by law.',),
            _heading('Applicable Law and Jurisdiction'),
            _body(
                'By visiting this Portal, you agree that Indian laws govern this Privacy Policy. Disputes shall be handled as per the Terms and Conditions.',),
            _heading('Updating Information'),
            _body(
                'You must promptly notify Dream247 of any updates or modifications to your information. You may update your preferences through your Profile page.',),
            _heading('Contact Us'),
            _body(
                'Any queries or feedback regarding this Policy may be sent to: info.support@Dream247.com',),
          ],
        ),
      ),
    );
  }
}
