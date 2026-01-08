import 'package:flutter/material.dart';
import '../../shared/components/custom_app_bar.dart';

/// Match detail page
class MatchDetailPage extends StatelessWidget {
  final String matchId;

  const MatchDetailPage({
    super.key,
    required this.matchId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Match Detail'),
      body: Center(
        child: Text('Match Detail Page - ID: $matchId'),
      ),
    );
  }
}
