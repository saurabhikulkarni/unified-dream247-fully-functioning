import 'package:flutter/material.dart';
import 'package:unified_dream247/features/shop/constants.dart';

class EnableNotificationScreen extends StatefulWidget {
  const EnableNotificationScreen({super.key});

  @override
  State<EnableNotificationScreen> createState() => _EnableNotificationScreenState();
}

class _EnableNotificationScreenState extends State<EnableNotificationScreen> {
  bool _ordersNotifications = false;
  bool _offersNotifications = false;
  bool _newsNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enable Notifications"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: [
          const Text("Select which notifications you'd like to receive"),
          const SizedBox(height: defaultPadding),
          SwitchListTile(
            title: const Text("Order Updates"),
            subtitle: const Text("Get notified about your orders"),
            value: _ordersNotifications,
            onChanged: (value) {
              setState(() {
                _ordersNotifications = value;
              });
            },
          ),
          // Removed sales-related notifications wording
          SwitchListTile(
            title: const Text("Recommendations"),
            subtitle: const Text("Get personalized product suggestions"),
            value: _offersNotifications,
            onChanged: (value) {
              setState(() {
                _offersNotifications = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text("News & Updates"),
            subtitle: const Text("Stay updated with latest news"),
            value: _newsNotifications,
            onChanged: (value) {
              setState(() {
                _newsNotifications = value;
              });
            },
          ),
          const SizedBox(height: defaultPadding * 2),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Preferences saved")),
              );
            },
            child: const Text("Save Preferences"),
          ),
        ],
      ),
    );
  }
}
