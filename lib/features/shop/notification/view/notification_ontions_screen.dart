import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class NotificationOptionsScreen extends StatefulWidget {
  const NotificationOptionsScreen({super.key});

  @override
  State<NotificationOptionsScreen> createState() => _NotificationOptionsScreenState();
}

class _NotificationOptionsScreenState extends State<NotificationOptionsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: [
          Text(
            "Notification Methods",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: defaultPadding),
          SwitchListTile(
            title: const Text("Push Notifications"),
            subtitle: const Text("Get notifications on your device"),
            value: _pushNotifications,
            onChanged: (value) {
              setState(() {
                _pushNotifications = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text("Email Notifications"),
            subtitle: const Text("Receive emails for updates"),
            value: _emailNotifications,
            onChanged: (value) {
              setState(() {
                _emailNotifications = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text("SMS Notifications"),
            subtitle: const Text("Get SMS messages for important updates"),
            value: _smsNotifications,
            onChanged: (value) {
              setState(() {
                _smsNotifications = value;
              });
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: Text(
              "Frequency",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            title: const Text("Real-time"),
            subtitle: const Text("Get notified immediately"),
            trailing: const Icon(Icons.check),
            onTap: () {},
          ),
          ListTile(
            title: const Text("Daily Digest"),
            subtitle: const Text("Get summary once a day"),
            onTap: () {},
          ),
          ListTile(
            title: const Text("Weekly"),
            subtitle: const Text("Get summary once a week"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
