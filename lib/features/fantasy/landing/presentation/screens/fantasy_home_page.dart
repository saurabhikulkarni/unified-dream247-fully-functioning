import 'package:flutter/material.dart';

/// Fantasy Home Page - Entry point for fantasy gaming features
/// Shows upcoming matches, contests, and gaming functionality
class FantasyHomePage extends StatefulWidget {
  final String? userId;
  
  const FantasyHomePage({super.key, this.userId});

  @override
  State<FantasyHomePage> createState() => _FantasyHomePageState();
}

class _FantasyHomePageState extends State<FantasyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Verify user ID is available for fantasy gaming
    if (widget.userId != null) {
      debugPrint('Fantasy Home: User ID received - ${widget.userId}');
    } else {
      debugPrint('Fantasy Home: Warning - No user ID provided');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fantasy Gaming'),
        backgroundColor: const Color(0xFF6441A5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () {
              // TODO: Navigate to wallet
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Live'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcomingMatches(),
          _buildLiveMatches(),
          _buildCompletedMatches(),
        ],
      ),
    );
  }

  Widget _buildUpcomingMatches() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Match ${index + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blue,
                            child: Text('T1', style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Team ${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'VS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.red,
                            child: Text('T2', style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Team ${index + 2}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '2 hours remaining',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to create team
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6441A5),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Create Team'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLiveMatches() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_cricket, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No live matches',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedMatches() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No completed matches',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
