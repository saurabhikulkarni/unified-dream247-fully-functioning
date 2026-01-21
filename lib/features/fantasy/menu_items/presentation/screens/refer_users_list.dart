import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/sub_container.dart';
import 'package:unified_dream247/features/fantasy/menu_items/data/models/referral_dashboard_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class ReferUsersList extends StatefulWidget {
  const ReferUsersList({super.key});

  @override
  State<ReferUsersList> createState() => _ReferUsersList();
}

class _ReferUsersList extends State<ReferUsersList> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Future<ReferralDashboardModel?>? _dashboardData;
  
  // TODO: Implement API call to fetch referral dashboard data
  // This should be replaced with actual API integration
  // UserUsecases userUsecases = UserUsecases(UserDatasource(ApiImplWithAccessToken()));

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    // TODO: Replace with actual API call
    // _dashboardData = userUsecases.getReferralDashboard(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SubContainer(
      showAppBar: true,
      showWalletIcon: true,
      headerText: Strings.referedUsers,
      addPadding: false,
      child: Column(
        children: [
          // Dashboard Summary Card
          _buildDashboardSummary(),
          
          // Tab Bar
          Container(
            color: AppColors.bgColor,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.mainLightColor,
              unselectedLabelColor: AppColors.greyColor,
              indicatorColor: AppColors.mainLightColor,
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Referred Users'),
                Tab(text: 'Commission History'),
              ],
            ),
          ),
          
          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReferredUsersTab(),
                _buildCommissionHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardSummary() {
    return FutureBuilder<ReferralDashboardModel?>(
      future: _dashboardData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final dashboard = snapshot.data;
        final totalBalance = dashboard?.totalBalance ?? 0;
        final totalReferrals = dashboard?.totalReferrals ?? 0;
        final totalCommission = dashboard?.totalCommission ?? 0;

        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.mainLightColor, AppColors.mainLightColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.mainLightColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Referral Dashboard',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDashboardStat('Balance', '${Strings.indianRupee}$totalBalance'),
                  _buildDivider(),
                  _buildDashboardStat('Referrals', '$totalReferrals'),
                  _buildDivider(),
                  _buildDashboardStat('Commission', '${Strings.indianRupee}$totalCommission'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboardStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.white.withOpacity(0.3),
    );
  }

  Widget _buildReferredUsersTab() {
    return FutureBuilder<ReferralDashboardModel?>(
      future: _dashboardData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data?.referredUsers ?? [];
        
        if (users.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: AppColors.greyColor),
                SizedBox(height: 16),
                Text(
                  'NO REFERRED USERS',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.letterColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start referring friends to earn commission',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.greyColor,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: users.length,
          itemBuilder: (context, index) {
            return _buildReferredUserCard(users[index]);
          },
        );
      },
    );
  }

  Widget _buildReferredUserCard(ReferredUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greyColor.withOpacity(0.2)),
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // User Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.mainLightColor.withOpacity(0.1),
            child: user.image != null && user.image!.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: user.image!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.person),
                    ),
                  )
                : const Icon(Icons.person, size: 32, color: AppColors.mainLightColor),
          ),
          const SizedBox(width: 12),
          
          // User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.letterColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.team ?? user.mobile ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: AppColors.greyColor,
                  ),
                ),
                if (user.joinedDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Joined: ${_formatDate(user.joinedDate!)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.greyColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Commission Earned
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${Strings.indianRupee}${user.commissionEarned ?? 0}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.mainLightColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.mainLightColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Earned',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mainLightColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionHistoryTab() {
    return FutureBuilder<ReferralDashboardModel?>(
      future: _dashboardData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = snapshot.data?.commissionHistory ?? [];
        
        if (transactions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: AppColors.greyColor),
                SizedBox(height: 16),
                Text(
                  'NO COMMISSION HISTORY',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.letterColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your commission transactions will appear here',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.greyColor,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            return _buildCommissionCard(transactions[index]);
          },
        );
      },
    );
  }

  Widget _buildCommissionCard(CommissionTransaction transaction) {
    final isCredit = transaction.commissionAmount != null && transaction.commissionAmount! > 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greyColor.withOpacity(0.2)),
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Transaction Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isCredit ? Colors.green : AppColors.greyColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.info_outline,
              color: isCredit ? Colors.green : AppColors.greyColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // Transaction Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? transaction.transactionType ?? 'Commission',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.letterColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (transaction.referredUsername != null)
                  Text(
                    'From: ${transaction.referredUsername}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.greyColor,
                    ),
                  ),
                if (transaction.transactionDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(transaction.transactionDate!),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.greyColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Amount
          Text(
            '${isCredit ? '+' : ''}${Strings.indianRupee}${transaction.commissionAmount ?? 0}',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: isCredit ? Colors.green : AppColors.greyColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
