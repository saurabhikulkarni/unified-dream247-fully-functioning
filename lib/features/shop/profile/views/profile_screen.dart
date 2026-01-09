import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'components/profile_card.dart';
import 'components/profile_menu_item_list_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'User';
  bool _isTestUser = false;
  
  @override
  void initState() {
    super.initState();
    _loadUserName();
    _checkTestUser();
  }
  
  Future<void> _loadUserName() async {
    final name = await AuthService().getUserName();
    if (mounted) {
      setState(() {
        _userName = name ?? 'User';
      });
    }
  }
  
  Future<void> _checkTestUser() async {
    final phone = await AuthService().getUserPhone();
    if (phone != null && mounted) {
      setState(() {
        _isTestUser = AuthService().isTestUser(phone);
      });
    }
  }

  void _openFAQ() async {
    const faqUrl = 'https://calm-shame-7ef.notion.site/Dream247-Frequently-Asked-Questions-FAQ-2cdfae02f0a1800da98ae8b2e447989e';
    
    try {
      if (await canLaunchUrl(Uri.parse(faqUrl))) {
        await launchUrl(
          Uri.parse(faqUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open FAQ')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error opening FAQ')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          if (_isTestUser)
            Container(
              margin: const EdgeInsets.all(defaultPadding),
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(defaultBorderRadious),
                border: Border.all(color: Colors.orange, width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.science, color: Colors.orange, size: 24),
                  const SizedBox(width: defaultPadding / 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🧪 TEST USER MODE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        Text(
                          'Using test account for Razorpay testing',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ProfileCard(
            name: _userName,
            email: "user@shop.com",
            // No default image after login
            imageSrc: null,
            // proLableText: "Sliver",
            // isPro: true, if the user is pro
            press: () {
              Navigator.pushNamed(context, userInfoScreenRoute);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: defaultPadding),
            child: Text(
              "Account",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          ProfileMenuListTile(
            text: "Orders",
            svgSrc: "assets/icons/Order.svg",
            press: () {
              Navigator.pushNamed(context, ordersScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Wishlist",
            svgSrc: "assets/icons/Wishlist.svg",
            press: () {
              Navigator.pushNamed(context, wishlistScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Addresses",
            svgSrc: "assets/icons/Address.svg",
            press: () {
              Navigator.pushNamed(context, addressesScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Wallet",
            svgSrc: "assets/icons/Wallet.svg",
            press: () {
              Navigator.pushNamed(context, walletScreenRoute);
            },
          ),
          const SizedBox(height: defaultPadding),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding / 2),
            child: Text(
              "Help & Support",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ProfileMenuListTile(
            text: "Get Help",
            svgSrc: "assets/icons/Help.svg",
            press: () {
              Navigator.pushNamed(context, getHelpScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "FAQ",
            svgSrc: "assets/icons/FAQ.svg",
            press: () {
              _openFAQ();
            },
          ),
          ProfileMenuListTile(
            text: "Terms & Conditions",
            svgSrc: "assets/icons/info.svg",
            press: () {
              Navigator.pushNamed(context, termsAndConditionsScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Privacy Policy",
            svgSrc: "assets/icons/Lock.svg",
            press: () {
              Navigator.pushNamed(context, privacyPolicyScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Refund Policy",
            svgSrc: "assets/icons/Return.svg",
            press: () {
              Navigator.pushNamed(context, refundPolicyScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Shipping Policy",
            svgSrc: "assets/icons/Delivery.svg",
            press: () {
              Navigator.pushNamed(context, shippingPolicyScreenRoute);
            },
            isShowDivider: false,
          ),
          const SizedBox(height: defaultPadding),

          // Log Out
          ListTile(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Log Out"),
                  content: const Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Clear session from AuthService
                        await AuthService().logout();
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          logInScreenRoute,
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "Log Out",
                        style: TextStyle(color: errorColor),
                      ),
                    ),
                  ],
                ),
              );
            },
            minLeadingWidth: 24,
            leading: SvgPicture.asset(
              "assets/icons/Logout.svg",
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                errorColor,
                BlendMode.srcIn,
              ),
            ),
            title: const Text(
              "Log Out",
              style: TextStyle(color: errorColor, fontSize: 14, height: 1),
            ),
          )
        ],
      ),
    );
  }
}
