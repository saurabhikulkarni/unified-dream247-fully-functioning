import 'package:flutter/material.dart';
import '../../../../shared/components/custom_app_bar.dart';

/// Add money page
class AddMoneyPage extends StatelessWidget {
  const AddMoneyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Add Money'),
      body: Center(
        child: Text('Add Money Page - Coming Soon'),
      ),
    );
  }
}
