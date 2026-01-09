import 'package:flutter/material.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ShippingPolicyScreen extends StatelessWidget {
  const ShippingPolicyScreen({super.key});

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
        title: const Text('Shipping & Delivery Policy'),
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
                'Thank you for shopping with Dream247.\n\n'
                'This Shipping & Delivery Policy ("Policy") outlines the terms and conditions related to the delivery of products purchased through Dream247, operated by BrightHex Technologies Private Limited ("Company", "we", "us", or "our").\n\n'
                'By placing an order on our website or mobile application, you agree to the terms of this Policy along with our Terms of Service and Privacy Policy.',
            ),

            _buildSection(
              context,
              title: '1. Shipping Coverage',
              content:
                'Dream247 currently ships products across India. We partner with trusted logistics providers to ensure safe and timely delivery of your orders.\n\n'
                'Shipping is subject to product availability and delivery location serviceability. Some remote areas may experience longer delivery times or may not be serviceable.',
            ),

            _buildSection(
              context,
              title: '2. Delivery Timelines',
              content:
                'Estimated delivery timelines are provided at the time of order placement and typically range from 5-15 business days, depending on:\n'
                '• Product availability\n'
                '• Delivery location\n'
                '• Logistics partner capacity\n'
                '• Weather conditions and force majeure events\n\n'
                'Please note that delivery timelines are indicative and not guaranteed. Actual delivery may be earlier or later than estimated.',
            ),

            _buildSection(
              context,
              title: '3. Order Processing',
              content:
                'Once your order is confirmed and payment is processed:\n'
                '• You will receive an order confirmation via email and SMS\n'
                '• Orders are typically processed within 1-3 business days\n'
                '• You will receive shipping updates with tracking information once the order is dispatched\n\n'
                'Order processing may be delayed during peak sale periods, holidays, or due to inventory availability.',
            ),

            _buildSection(
              context,
              title: '4. Shipping Charges',
              content:
                'Shipping charges, if applicable, will be displayed at checkout before payment. These charges may vary based on:\n'
                '• Order value\n'
                '• Delivery location\n'
                '• Product size and weight\n'
                '• Promotional offers or free shipping thresholds\n\n'
                'Dream247 may offer free shipping on select orders that meet minimum order value criteria or during promotional periods.',
            ),

            _buildSection(
              context,
              title: '5. Order Tracking',
              content:
                'Once your order is shipped, you will receive:\n'
                '• A tracking number via email and SMS\n'
                '• Real-time tracking updates through the Dream247 app under "Orders"\n'
                '• Notifications at key delivery milestones\n\n'
                'You can track your order status and estimated delivery date directly from the app.',
            ),

            _buildSection(
              context,
              title: '6. Delivery Address',
              content:
                'Please ensure that the delivery address provided during checkout is accurate and complete. Dream247 is not responsible for:\n'
                '• Delivery failures due to incorrect or incomplete addresses\n'
                '• Delays caused by recipient unavailability\n'
                '• Non-delivery to addresses that are not serviceable\n\n'
                'Address changes after order placement may not be possible. Contact our support team immediately if you need to update your delivery address.',
            ),

            _buildSection(
              context,
              title: '7. Failed Delivery Attempts',
              content:
                'If a delivery attempt fails due to:\n'
                '• Recipient unavailability\n'
                '• Incorrect address\n'
                '• Refusal to accept delivery\n'
                '• Inability to contact recipient\n\n'
                'The logistics partner may make additional delivery attempts. If multiple attempts fail, the order may be returned to our warehouse.\n\n'
                'Please ensure someone is available to receive the order at the provided address during the estimated delivery window.',
            ),

            _buildSection(
              context,
              title: '8. Non-Delivery and Delays',
              content:
                'In rare cases, orders may be delayed or not delivered due to:\n'
                '• Force majeure events (natural disasters, strikes, riots)\n'
                '• Regulatory restrictions or customs delays\n'
                '• Logistics partner issues\n'
                '• Technical or operational failures\n\n'
                'Dream247 will make reasonable efforts to notify you of significant delays and provide alternative solutions where possible.\n\n'
                'As per our Refund & Cancellation Policy, delivery delays or non-delivery do not automatically qualify for refunds or cancellations.',
            ),

            _buildSection(
              context,
              title: '9. Damaged or Missing Items',
              content:
                'While we take utmost care in packaging, if you receive:\n'
                '• A damaged package\n'
                '• Missing items\n'
                '• Incorrect items\n\n'
                'Please contact our support team immediately with:\n'
                '• Order details\n'
                '• Photos of the damaged package or items\n'
                '• Description of the issue\n\n'
                'We will review your case and provide resolution as per our Returns & Refund Policy and RBI PPI guidelines.\n\n'
                'Note: Dream247 follows a strict No Returns, No Refunds policy. Resolution is at the sole discretion of the Company.',
            ),

            _buildSection(
              context,
              title: '10. Undelivered Orders',
              content:
                'Orders that are returned to us due to delivery failure will be reviewed on a case-by-case basis. The Company reserves the right to:\n'
                '• Re-attempt delivery after verification\n'
                '• Cancel the order without refund if delivery is not possible\n'
                '• Deduct shipping and handling charges from any applicable resolution\n\n'
                'Users are advised to track their orders and coordinate with logistics partners to ensure successful delivery.',
            ),

            _buildSection(
              context,
              title: '11. Digital Products',
              content:
                'For digital products, vouchers, and gift cards:\n'
                '• Delivery is instant and sent to your registered email address\n'
                '• You will also find them in your Dream247 app under "Orders"\n'
                '• No physical shipping is involved\n\n'
                'Digital products are non-refundable and non-cancellable as per our Refund Policy.',
            ),

            _buildSection(
              context,
              title: '12. International Shipping',
              content:
                'Dream247 currently does not offer international shipping. Orders can only be shipped within India.\n\n'
                'International shipping may be introduced in the future, subject to regulatory approvals and operational feasibility.',
            ),

            _buildSection(
              context,
              title: '13. Disclaimers',
              content:
                '• Dream247 is not liable for delays caused by third-party logistics partners\n'
                '• Estimated delivery dates are indicative and not binding\n'
                '• Orders are subject to product availability and serviceability checks\n'
                '• Dream247 reserves the right to cancel orders that cannot be fulfilled due to operational or regulatory constraints\n\n'
                'This Policy must be read in conjunction with our Terms of Service and Refund & Cancellation Policy.',
            ),

            _buildSectionWithLinks(
              context,
              title: 'Contact Us',
              lines: [
                'For shipping-related queries or support:',
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
