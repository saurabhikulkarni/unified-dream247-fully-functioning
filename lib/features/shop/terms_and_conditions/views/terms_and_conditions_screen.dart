import 'package:flutter/material.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

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

  void _launchUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open website')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error opening website')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
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
            // Last Updated
            
            const SizedBox(height: defaultPadding * 1.5),

            // Introduction
            _buildSection(
              context,
              title: null,
              content: 
                'Welcome to Dream247. These Terms & Conditions govern your access to and use of our website, mobile application, and related services. By accessing or using Dream247, you agree to be bound by these Terms.\n\n'
                'This document is an electronic record generated under the Information Technology Act, 2000 and applicable rules thereunder. It does not require physical or digital signatures.',
            ),

            // About Us
            _buildSection(
              context,
              title: 'About Us',
              content:
                'These Terms constitute a legally binding agreement between BrightHex Technologies Private Limited ("Company", "we", "our", or "us") and you ("User", "you", or "your").\n\n'
                'Dream247 is owned and operated by BrightHex Technologies Private Limited and is accessible via:\n'
                '• Website: https://dream247.shop\n'
                '• Mobile Application: Dream247',
            ),

            // Platform Description
            _buildSection(
              context,
              title: 'About the Platform',
              content:
                'Dream247 is an online shopping platform that enables users to browse, purchase, and pay for products offered by the platform or its partnered sellers. The platform provides a digital wallet and shopping credits that can be used for purchases within Dream247 only.',
            ),

            // Acceptance of Terms
            _buildSection(
              context,
              title: 'Acceptance of Terms',
              content:
                'By using Dream247, you confirm that:\n'
                '• You have read and understood these Terms\n'
                '• You agree to be bound by these Terms\n'
                '• You agree to comply with applicable Indian laws',
            ),

            // Account Registration & Security
            _buildSection(
              context,
              title: 'Account Registration & Security',
              content:
                'Users must register using a valid mobile number and authenticate via OTP. No password-based login is used.\n\n'
                '• You are responsible for your account activity\n'
                '• You must keep your account information accurate\n'
                '• You must not share your OTP with others',
            ),

            // Payments & Wallet
            _buildSection(
              context,
              title: 'Payments & Wallet',
              content:
                '• All payments are processed in INR\n'
                '• Supported methods include UPI, cards, and wallets\n'
                '• Wallet balance is non-transferable',
            ),

            // Refunds & Cancellations
            _buildSection(
              context,
              title: 'Refunds & Cancellations',
              content:
                'All purchases are final. No refunds or cancellations are permitted except in rare cases approved after internal verification by Dream247.',
            ),

            // Prohibited Activities
            _buildSection(
              context,
              title: 'Prohibited Activities',
              content:
                '• Fraudulent transactions\n'
                '• Multiple or fake accounts\n'
                '• Misuse of wallet or credits\n'
                '• Violation of applicable laws',
            ),

            // Limitation of Liability
            _buildSection(
              context,
              title: 'Limitation of Liability',
              content:
                'Dream247 shall not be liable for indirect, incidental, or consequential damages arising from platform usage.',
            ),

            // Governing Law
            _buildSection(
              context,
              title: 'Governing Law',
              content:
                'These Terms are governed by Indian law. Courts in Nashik, Maharashtra shall have exclusive jurisdiction.',
            ),

            // Grievance Redressal
            _buildSectionWithEmail(
              context,
              title: 'Grievance Redressal',
              lines: [
                'Name: Ruth V.',
                'Email: marketing@brighthex.in',
              ],
              emailIndex: 1,
            ),

            // Contact Us
            _buildSectionWithLinks(
              context,
              title: 'Contact Us',
              lines: [
                'Email: marketing@brighthex.in',
                'Website: https://dream247.shop',
              ],
              emailIndex: 0,
              websiteIndex: 1,
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
              // Extract the email from the line
              final parts = line.split('marketing@brighthex.in');
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
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

  Widget _buildSectionWithLinks(BuildContext context, {required String title, required List<String> lines, required int emailIndex, int? websiteIndex}) {
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
            
            // Handle email link
            if (index == emailIndex && line.contains('marketing@brighthex.in')) {
              final parts = line.split('marketing@brighthex.in');
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
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
            } 
            // Handle website link
            else if (websiteIndex != null && index == websiteIndex && line.contains('https://dream247.shop')) {
              final parts = line.split('https://dream247.shop');
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    Text(
                      parts[0],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                      ),
                    ),
                    InkWell(
                      onTap: () => _launchUrl(context, 'https://dream247.shop'),
                      child: Text(
                        'https://dream247.shop',
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
            } 
            // Regular text line
            else {
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
