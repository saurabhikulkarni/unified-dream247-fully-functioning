import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class RefundPolicyScreen extends StatelessWidget {
  const RefundPolicyScreen({super.key});

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
        title: const Text('Refund & Cancellation Policy'),
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
            _buildSection(
              context,
              title: null,
              content:
                'Thank you for using Dream247.\n\n'
                'This Returns, Refunds & Cancellation Policy ("Policy") governs purchases and transactions made on Dream247, operated by BrightHex Technologies Private Limited ("Company", "we", "us", or "our"), through our website https://dream247.shop, mobile application, and related services (collectively, the "Platform").\n\n'
                'This Policy must be read together with our Terms of Service, Privacy Policy, Delivery and Shipping Policy, and Game Rules. By accessing the Platform or completing any transaction, you expressly agree to this Policy.',
            ),

            _buildSection(
              context,
              title: 'RBI PPI FRAMEWORK AND WALLET NATURE',
              content:
                'The Dream247 Wallet operates as a closed-loop Prepaid Payment Instrument (PPI) in accordance with guidelines issued by the Reserve Bank of India (RBI).\n\n'
                'Accordingly:\n'
                '• Funds loaded into the Wallet can only be used within the Dream247 ecosystem\n'
                '• Wallet balances cannot be transferred, withdrawn, or redeemed for cash except where expressly permitted under Applicable Law\n'
                '• Wallet balances do not earn interest\n'
                '• The Company is not a bank or financial institution\n\n'
                'All credits, tokens, and balances available in the Wallet are governed by RBI PPI regulations and the terms outlined herein.',
            ),

            _buildSection(
              context,
              title: 'NO RETURNS POLICY',
              content:
                'Are returns allowed on Dream247?\n\n'
                'No. All products, services, digital items, vouchers, and in-app purchases available on Dream247 are strictly non-returnable.\n\n'
                'Once a transaction is successfully completed:\n'
                '• Ownership or usage rights are deemed transferred\n'
                '• The transaction is final and irrevocable\n'
                '• No return requests will be entertained\n\n'
                'This applies to all categories of goods, whether physical or digital.',
            ),

            _buildSection(
              context,
              title: 'NO REPLACEMENTS POLICY',
              content:
                'Dream247 does not offer replacements under any circumstances, including but not limited to:\n'
                '• Damaged or defective items\n'
                '• Incorrect or incomplete deliveries\n'
                '• Missing items\n'
                '• Tampered or empty packages\n'
                '• Technical or compatibility issues\n'
                '• Quality dissatisfaction\n\n'
                'Users are advised to carefully review product descriptions, specifications, and terms prior to completing a purchase.',
            ),

            _buildSection(
              context,
              title: 'NO CANCELLATION POLICY',
              content:
                'Can I cancel an order after payment?\n\n'
                'No. Order cancellations are not permitted.\n\n'
                'Once a payment is successfully processed through the Wallet or supported payment modes:\n'
                '• The transaction cannot be cancelled\n'
                '• The order cannot be modified\n'
                '• The order cannot be reversed\n\n'
                'This applies regardless of delivery status, user error, or change of mind.',
            ),

            _buildSection(
              context,
              title: 'NO REFUNDS POLICY (RBI-ALIGNED)',
              content:
                'Are refunds provided in cash or wallet balance?\n\n'
                'No. Dream247 does not provide refunds in any form, including:\n'
                '• Cash refunds\n'
                '• Bank transfers\n'
                '• Re-credit to original payment method\n'
                '• Wallet balance reversal\n'
                '• Shopping credits, tokens, or vouchers\n\n'
                'As per RBI PPI guidelines applicable to closed-loop PPIs, once funds are loaded into the Wallet and utilized for transactions on the Platform, such funds are non-refundable and non-reversible.',
            ),

            _buildSection(
              context,
              title: 'Failed or Incomplete Transactions',
              content:
                'In rare cases where a payment is debited but:\n'
                '• The transaction fails at the system level, and\n'
                '• The order is not successfully recorded in the Platform\n\n'
                'The matter will be reviewed internally and with the payment service provider. Any resolution will be handled strictly as per RBI norms and payment processor settlement rules. No automatic or guaranteed refund applies.',
            ),

            _buildSection(
              context,
              title: 'DIGITAL GOODS, VOUCHERS & GIFT CARDS',
              content:
                'All digital products offered on Dream247, including but not limited to:\n'
                '• Gift cards\n'
                '• Discount vouchers\n'
                '• Subscription codes\n'
                '• Promotional credits\n'
                '• In-app digital items\n\n'
                'are non-refundable, non-cancellable, and non-replaceable.\n\n'
                'The Company is not responsible for redemption issues, expiry, third-party service quality, or technical failures of external vendors. Users must approach the respective service provider directly.',
            ),

            _buildSection(
              context,
              title: 'DELIVERY DELAYS AND THIRD-PARTY LOGISTICS',
              content:
                'Delivery timelines are indicative and may be affected by external factors such as logistics partners, regulatory restrictions, force majeure events, or technical issues.\n\n'
                'Delays or non-delivery do not qualify for refunds, replacements, or cancellations.',
            ),

            _buildSection(
              context,
              title: 'USER ACKNOWLEDGEMENT AND CONSENT',
              content:
                'By completing a transaction on Dream247, you expressly acknowledge and agree that:\n'
                '• The Dream247 Wallet is a closed-loop PPI\n'
                '• All transactions are final once completed\n'
                '• You waive any claim for refunds, cancellations, or replacements\n'
                '• You understand and accept RBI-aligned wallet restrictions\n\n'
                'This acknowledgement is deemed to be provided electronically at the time of transaction completion.',
            ),

            _buildSectionWithEmail(
              context,
              title: 'GRIEVANCE REDRESSAL',
              lines: [
                'In compliance with Applicable Law and RBI guidelines, users may raise concerns with our Grievance Officer:',
                '',
                'Name: Ruth V.',
                'Email: marketing@brighthex.in',
                '',
                'All grievances will be reviewed on a best-effort basis, subject to this Policy and Applicable Law.',
              ],
              emailIndex: 3,
            ),

            _buildSectionWithLinks(
              context,
              title: 'CONTACT DETAILS',
              lines: [
                'For general support or clarification:',
                '',
                'Email: marketing@brighthex.in',
                'Website: https://dream247.shop',
              ],
              emailIndex: 2,
              websiteIndex: 3,
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
            } else if (websiteIndex != null && index == websiteIndex && line.contains('https://dream247.shop')) {
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
