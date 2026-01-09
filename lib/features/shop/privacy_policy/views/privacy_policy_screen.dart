import 'package:flutter/material.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  void _launchEmail(BuildContext context, String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open email client')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error opening email client')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: appPrimaryGradient,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Updated: 16 December 2025',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: blackColor60,
              ),
            ),
            const SizedBox(height: defaultPadding * 1.5),

            _buildSection(
              context,
              title: null,
              content:
                'We at Dream247 ("Dream247", "we", "us", "our") are committed to protecting the privacy and security of your personal information. Your privacy matters to us, and maintaining your trust is important.\n\n'
                'This Privacy Policy explains how we collect, use, process, store, and disclose information about you. By using the Dream247 website, mobile application, and affiliated services (collectively, the "App" or "Services"), you agree to the terms of this Privacy Policy along with our Terms of Use. We encourage you to review this Privacy Policy periodically to stay informed about any updates.\n\n'
                'This Privacy Policy applies to all Dream247 websites, products, and services that link to it. It does not apply to third-party partners or affiliates that maintain their own privacy policies. In such cases, we recommend reviewing the applicable third-party privacy policy. Capitalised terms not defined in this Privacy Policy shall have the same meaning as set out in the Terms of Use.',
            ),

            _buildSection(
              context,
              title: '1. Information We Collect',
              content: 'The following categories of information may be collected by or on behalf of Dream247.',
            ),

            _buildSection(
              context,
              title: '1.1 Information You Provide to Us',
              content:
                'When you register on or use the Dream247 App, we collect certain information provided by you through registration forms, in-app interactions, customer support communications, or other features of the App.\n\n'
                'At the time of registration, we collect the following personal information:\n'
                '• First and last name\n'
                '• Mobile number\n'
                '• Email address\n\n'
                'Depending on the services you choose to use, we may request additional information, including but not limited to:\n'
                '• Date of birth\n'
                '• Address\n'
                '• Payment or banking information\n'
                '• Credit or debit card details\n'
                '• Credit score\n'
                '• Other government-issued identification documents\n\n'
                'Providing such additional information may be required to access specific services or claim certain rewards.\n\n'
                'We also maintain records of information shared by you while interacting with our customer support team.\n\n'
                'From time to time, Dream247 may request access to additional device or app-related information such as SMS, contact details, or geo-location data. We always seek your explicit consent before accessing such information. Even after consent is granted, we only read transactional or promotional SMS and do not access personal messages.\n\n'
                'Some features may be limited or unavailable if certain information is not provided. For example, delivery-related services require a valid address, and some rewards may require PAN or Aadhaar verification.',
            ),

            _buildSection(
              context,
              title: '1.2 Information Collected Automatically',
              content:
                'We collect information related to your use of the App through automated technologies. This includes:\n'
                '• Transaction details such as services used, payment method, amounts, and related financial data\n'
                '• Order and delivery details for rewards or e-commerce transactions\n'
                '• Technical information such as IP address, browser type, mobile operating system, device manufacturer and model, preferred language, access times, session duration, and approximate location\n'
                '• Pages viewed and actions taken within the App\n\n'
                'We also retain records of customer support interactions for query resolution and service improvement. This information is not shared with third parties except as described in this Privacy Policy.',
            ),

            _buildSection(
              context,
              title: '1.3 Information from Third Parties',
              content:
                'With your consent, we may receive information about you from third-party service providers or partners to help personalise your experience or enable certain services.\n\n'
                'We may also receive information related to fraud prevention, security, and compliance from third-party verification services, advertising partners, or analytics providers, and combine it with information we already hold.',
            ),

            _buildSection(
              context,
              title: '2. How We Use the Information',
              content:
                'We use your information to:\n'
                '1. Provide, operate, and improve the Dream247 App and Services\n'
                '2. Maintain a safe, secure, and compliant platform\n'
                '3. Personalise and enhance user experience\n'
                '4. Meet legal, regulatory, and contractual obligations',
            ),

            _buildSection(
              context,
              title: '2.1 Providing and Improving Services',
              content:
                'Information provided by you is used to create and manage your account, process transactions, deliver services, and communicate with you.\n\n'
                'To complete financial transactions, we may share necessary payment-related information with authorised third-party payment processors, banks, or financial institutions. We do not store credit or debit card details unless required by law or permitted under applicable regulations.\n\n'
                'We use collected data for internal purposes such as debugging, data analysis, research, testing, and monitoring usage trends, based on our legitimate interest in improving the Services.\n\n'
                'If we introduce new features or services that require additional information, we will seek your explicit, purpose-specific consent.',
            ),

            _buildSection(
              context,
              title: '2.2 Safety, Security, and Issue Resolution',
              content:
                'We use personal information to:\n'
                '• Comply with legal and regulatory requirements, including anti-money laundering obligations\n'
                '• Detect and prevent fraud, abuse, spam, and security incidents\n'
                '• Maintain platform integrity and user safety\n\n'
                'Customer support interactions, including calls and chats, may be monitored or recorded for quality assurance, training, dispute resolution, and record-keeping purposes.\n\n'
                'We implement reasonable physical, administrative, and technical safeguards to protect your personal information against unauthorised access, use, or disclosure. Sensitive information is encrypted during transmission, and our partners are required to follow appropriate security standards.',
            ),

            _buildSectionWithEmail(
              context,
              title: '2.3 Sharing and Disclosure',
              lines: [
                'We may disclose your information where required by law, regulation, or legal process, including to regulatory authorities, law enforcement agencies, courts, or professional advisors.',
                '',
                'Certain Dream247 products or services may be offered in partnership with third parties. In such cases, relevant information may be shared with those partners to provide the service. Their use of the information will be governed by their respective terms and privacy policies.',
                '',
                'With your prior consent, we may:',
                '• Send you marketing or promotional communications',
                '• Share limited information with Dream247 affiliates or partners for specified purposes',
                '',
                'You may opt out of marketing communications at any time using the unsubscribe link in emails or by contacting us at marketing@brighthex.in.',
                '',
                'We do not sell or lease your personal information to third parties.',
                '',
                'The App may display third-party advertisements or contain links to third-party websites or apps. Dream247 is not responsible for the privacy practices or content of such third parties.',
              ],
              emailIndex: 8,
            ),

            _buildSectionWithEmail(
              context,
              title: '3. Account Deletion and Deactivation',
              lines: [
                'You may request account deletion through the support section of the Dream247 App. Upon verification, we will delete personal information associated with your account unless retention is required for legal, regulatory, or legitimate business purposes.',
                '',
                'In some cases, account deletion may be delayed due to ongoing disputes or compliance requirements. Once resolved, the data will be permanently deleted and cannot be recovered.',
                '',
                'You may also request temporary account or card deactivation. Reactivation can be requested by contacting marketing@brighthex.in.',
              ],
              emailIndex: 4,
            ),

            _buildSection(
              context,
              title: '4. Cookies',
              content:
                'We use cookies and similar technologies to analyse App usage, improve functionality, personalise content, and enhance security.\n\n'
                'Cookies help remember your preferences, reduce the need for repeated logins, and tailor services to your interests. You may disable cookies through your device or browser settings, though some features of the App may not function properly as a result.',
            ),

            _buildSection(
              context,
              title: '5. Changes to This Privacy Policy',
              content:
                'We may update this Privacy Policy from time to time. Any changes will be effective upon posting the revised version on the Dream247 website or App. Continued use of the Services indicates acceptance of the updated policy.',
            ),

            _buildSectionWithEmail(
              context,
              title: '6. Access, Updates, and Queries',
              lines: [
                'If you have questions, concerns, or requests related to this Privacy Policy or your personal information, you may contact us via the "Contact Us" section on our website or by emailing marketing@brighthex.in.',
                '',
                'You may request access to, correction of, or a copy of your personal information. For security reasons, we may require identity verification before processing such requests. We aim to respond within 30 days.',
              ],
              emailIndex: 0,
            ),

            _buildSection(
              context,
              title: '7. Compliance and Data Localisation',
              content:
                'We maintain industry-standard information security policies and procedures.\n\n'
                'All customer data is stored within India in compliance with Reserve Bank of India (RBI) data localisation requirements, with data centres located in Nashik, Maharashtra.\n\n'
                'Dream247\'s use of information received from Google APIs complies with the Google API Services User Data Policy, including Limited Use requirements.',
            ),

            _buildSectionWithEmail(
              context,
              title: '8. Grievance Redressal Officer',
              lines: [
                'If you have a grievance related to privacy or data usage, you may contact our Grievance Redressal Officer:',
                '',
                'Name: Ruth V.',
                'Email: marketing@brighthex.in',
                '',
                'All grievances will be addressed within one month from the date of receipt.',
              ],
              emailIndex: 3,
            ),

            const SizedBox(height: defaultPadding),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {String? title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: defaultPadding * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: defaultPadding / 2),
          ],
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionWithEmail(BuildContext context, {required String title, required List<String> lines, required int emailIndex}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: defaultPadding * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          ...lines.asMap().entries.map((entry) {
            final index = entry.key;
            final line = entry.value;
            
            if (index == emailIndex && line.contains('marketing@brighthex.in')) {
              final parts = line.split('marketing@brighthex.in');
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Wrap(
                  children: [
                    Text(
                      parts[0],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                      ),
                    ),
                    InkWell(
                      onTap: () => _launchEmail(context, 'marketing@brighthex.in'),
                      child: Text(
                        'marketing@brighthex.in',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    if (parts.length > 1)
                      Text(
                        parts[1],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                      ),
                  ],
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  line,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
                ),
              );
            }
          }),
        ],
      ),
    );
  }
}
