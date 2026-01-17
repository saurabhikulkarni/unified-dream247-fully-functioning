import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:provider/provider.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_urls.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_pages.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/sub_container.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/accounts_datasource.dart';
import 'package:unified_dream247/features/fantasy/accounts/domain/use_cases/accounts_usecases.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/providers/wallet_details_provider.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/screens/add_money_page.dart';
import 'package:unified_dream247/core/services/wallet_service.dart';

class MyBalancePage extends StatefulWidget {
  const MyBalancePage({super.key});

  @override
  State<MyBalancePage> createState() => _MyBalancePage();
}

class _MyBalancePage extends State<MyBalancePage> {
  AccountsUsecases accountsUsecases = AccountsUsecases(
    AccountsDatasource(ApiImpl(), ApiImplWithAccessToken()),
  );
  DateTime? lastRefreshTime;
  double _shopTokens = 0.0;
  List<Map<String, dynamic>> _mergedTransactions = [];
  bool _isLoadingTransactions = false;

  @override
  void initState() {
    super.initState();
    loadData();
    _loadShopTokens();
    _loadGameTokens();
    _loadTransactionHistory();
  }

  /// Load and sync game tokens from Fantasy backend
  Future<void> _loadGameTokens() async {
    try {
      await walletService.initialize();
      
      // Fetch from Fantasy backend
      final gameTokens = await walletService.getGameTokens();
      setState(() {});
      
      debugPrint('📊 [FANTASY_WALLET] Game tokens synced: $gameTokens');
    } catch (e) {
      debugPrint('⚠️ [FANTASY_WALLET] Error loading game tokens: $e');
    }
  }

  /// Load shop tokens from unified wallet service
  Future<void> _loadShopTokens() async {
    await walletService.initialize();
    final shopTokens = await walletService.getShopTokens();
    setState(() {
      _shopTokens = shopTokens;
    });
    debugPrint('📊 [FANTASY_WALLET] Shop tokens loaded: $shopTokens');
  }

  /// Load merged transaction history (Shop + Fantasy)
  Future<void> _loadTransactionHistory() async {
    setState(() => _isLoadingTransactions = true);
    try {
      await walletService.initialize();
      
      // Get merged transactions from wallet service
      final merged = await walletService.getMergedTransactionHistory(
        fantasyTransactions: [], // Add fantasy transactions if available
      );
      
      setState(() {
        _mergedTransactions = merged;
      });
      
      debugPrint('✅ [FANTASY_WALLET] Loaded ${merged.length} transactions');
    } catch (e) {
      debugPrint('❌ [FANTASY_WALLET] Error loading transactions: $e');
    } finally {
      setState(() => _isLoadingTransactions = false);
    }
  }

  Future<void> loadData() async {
    DateTime now = DateTime.now();

    if (lastRefreshTime != null &&
        now.difference(lastRefreshTime!).inSeconds < 5) {
      return;
    }

    lastRefreshTime = now;
    await accountsUsecases.myWalletDetails(context);
    await _loadShopTokens();
    await _loadGameTokens();
    await _loadTransactionHistory();
    setState(() {});
  }

  /// Format date for display
  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dtDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dtDate == today) {
      return 'Today • ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (dtDate == yesterday) {
      return 'Yesterday • ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day} ${_getMonthName(dateTime.month)} • ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  /// Get month name from number
  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final walletData =
        Provider.of<WalletDetailsProvider>(context, listen: false).walletData;

    return SubContainer(
      showAppBar: true,
      showWalletIcon: false,
      headerText: Strings.accounts,
      addPadding: false,
      child: RefreshIndicator(
        onRefresh: () => loadData(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wallet Summary Card
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.mainLightColor.withValues(alpha: 0.05),
                        AppColors.whiteFade1,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //     vertical: 20,
                      //     horizontal: 16,
                      //   ),
                      //   child: Row(
                      //     children: [
                      //       Container(
                      //         padding: const EdgeInsets.all(10),
                      //         decoration: BoxDecoration(
                      //           color: AppColors.white,
                      //           borderRadius: BorderRadius.circular(10),
                      //           boxShadow: [
                      //             BoxShadow(
                      //               color:
                      //                   AppColors.black.withValues(alpha: 0.08),
                      //               blurRadius: 5,
                      //             ),
                      //           ],
                      //         ),
                      //         child: Image.asset(
                      //           Images.icAddCash,
                      //           color: AppColors.mainColor,
                      //           width: 32,
                      //           height: 32,
                      //         ),
                      //       ),
                      //       const SizedBox(width: 14),
                      //       Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Text(
                      //             'Current Balance',
                      //             style: GoogleFonts.inter(
                      //               color: AppColors.black,
                      //               fontSize: 14,
                      //               fontWeight: FontWeight.w500,
                      //             ),
                      //           ),
                      //           const SizedBox(height: 4),
                      //           Text(
                      //             '${Strings.indianRupee}${AppUtils.stringifyNumber(num.parse(walletData?.totalamount ?? "0"))}',
                      //             style: GoogleFonts.montserrat(
                      //               color: AppColors.mainColor,
                      //               fontSize: 20,
                      //               fontWeight: FontWeight.w700,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //       const Spacer(),
                      //       GestureDetector(
                      //         onTap: () {
                      //           Get.to(
                      //             () => AddMoneyPage(),
                      //             transition: Transition.cupertino,
                      //           );
                      //         },
                      //         child: Container(
                      //           decoration: BoxDecoration(
                      //               borderRadius: BorderRadius.circular(12.0),
                      //               gradient: AppColors.appBarGradient),
                      //           padding: const EdgeInsets.symmetric(
                      //             vertical: 12,
                      //             horizontal: 18,
                      //           ),
                      //           child: Text(
                      //             Strings.addCash.toUpperCase(),
                      //             style: const TextStyle(
                      //               color: AppColors.white,
                      //               fontSize: 13,
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //           ),
                      //         ),
                      //       )
                      //     ],
                      //   ),
                      // ),
                      // Deposit, Winning & Bonus Cards
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _walletInfoTile(
                              icon: Images.icDeposit,
                              title: 'Shop Token',
                              value:
                                  '${AppUtils.stringifyNumber(num.parse(_shopTokens.toStringAsFixed(0)))}',
                              color: AppColors.lightGreen.withAlpha(20),
                              isShopToken: true,
                              gradientButton: true,
                              buttonText: 'Add Cash',
                              onButtonTap: () {
                                Get.to(() => AddMoneyPage());
                              },
                            ),
                            const SizedBox(height: 12),
                            _walletInfoTile(
                              icon: Images.icWinning,
                              title: Strings.winning,
                              isDiamondIcon: true,
                              value: "${walletData?.winning ?? "0"}",
                              color: AppColors.orangeColor.withAlpha(40),
                              buttonText:
                                  // (Provider.of<WalletDetailsProvider>(
                                  //           context,
                                  //           listen: false,
                                  //         ).walletData?.allverify ==
                                  //         1)?
                                  'Withdraw',
                              // : 'Verify Account',
                              onButtonTap: () {
                                // if (Provider.of<WalletDetailsProvider>(
                                //       context,
                                //       listen: false,
                                //     ).walletData?.allverify ==
                                //     1) {
                                AppNavigation.gotoWithdrawScreen(
                                  context,
                                ).then((value) => setState(loadData));
                                // } else {
                                //   AppNavigation.gotoVerifyDetailsScreen(
                                //     context,
                                //   ).then((value) => setState(loadData));
                                // }
                              },
                            ),
                            const SizedBox(height: 12),
                            _walletInfoTile(
                                icon: Images.icCashback,
                                title: 'Game Token',
                                value: "${walletData?.bonus ?? "0"}",
                                color: AppColors.blueColor.withAlpha(40),
                                tooltip: 'Use these Tokens to play Games.',
                                isTokenIcon: true),
                            // const SizedBox(height: 10),
                            // Container(
                            //   padding: const EdgeInsets.all(12),
                            //   decoration: BoxDecoration(
                            //     borderRadius: BorderRadius.circular(14),
                            //     color: AppColors.whiteFade1,
                            //   ),
                            //   child: Row(
                            //     children: [
                            //       Image.asset(
                            //         Images.icBonusNote,
                            //         height: 26,
                            //         width: 26,
                            //       ),
                            //       // const SizedBox(width: 8),
                            //       // Expanded(
                            //       //   child: Text.rich(
                            //       //     TextSpan(
                            //       //       text:
                            //       //           "Maximum 10% or Flat Discount can be used per contest. ",
                            //       //       style: GoogleFonts.inter(
                            //       //         fontSize: 13,
                            //       //         color: AppColors.black,
                            //       //       ),
                            //       //       children: [
                            //       //         TextSpan(
                            //       //           text: "[T&C]",
                            //       //           style: GoogleFonts.inter(
                            //       //             fontSize: 11,
                            //       //             fontWeight: FontWeight.w700,
                            //       //             color: AppColors.mainColor,
                            //       //           ),
                            //       //         ),
                            //       //       ],
                            //       //     ),
                            //       //   ),
                            //       // ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ═══════ UNIFIED TRANSACTION HISTORY SECTION ═══════
                Container(
                  margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Header
                      Text(
                        'Transaction History',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Transaction List or Empty State
                      if (_isLoadingTransactions)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        )
                      else if (_mergedTransactions.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          alignment: Alignment.center,
                          child: Text(
                            'No transactions yet',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.black.withValues(alpha: 0.5),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _mergedTransactions.length,
                          itemBuilder: (context, index) {
                            final txn = _mergedTransactions[index];
                            final isPositive = txn['isPositive'] as bool? ?? true;
                            final amount = (txn['amount'] as num?)?.toDouble() ?? 0.0;
                            final description = txn['description'] as String? ?? '';
                            final icon = txn['icon'] as String? ?? '📝';
                            final module = txn['module'] as String? ?? 'unknown';
                            final timestamp = txn['timestamp'] is DateTime
                                ? txn['timestamp'] as DateTime
                                : DateTime.parse(txn['timestamp'] as String);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: AppColors.whiteFade1,
                                  border: Border.all(
                                    color: isPositive
                                        ? AppColors.lightGreen.withValues(alpha: 0.3)
                                        : AppColors.orangeColor.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Transaction Icon
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isPositive
                                            ? AppColors.lightGreen.withValues(alpha: 0.2)
                                            : AppColors.orangeColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        icon,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Transaction Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            description,
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.black,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                _formatDate(timestamp),
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: AppColors.black.withValues(alpha: 0.6),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: module == 'shop'
                                                      ? AppColors.lightGreen.withValues(alpha: 0.2)
                                                      : AppColors.blueColor.withValues(alpha: 0.2),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  module == 'shop' ? '🪙 Shop' : '💎 Game',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Amount
                                    Text(
                                      '${isPositive ? '+' : ''}${amount.toStringAsFixed(0)}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isPositive
                                            ? AppColors.lightGreen
                                            : AppColors.orangeColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Transaction, TDS, KYC, Refer Section
                _actionTile(
                  icon: Icons.currency_exchange_rounded,
                  title: 'My Transactions',
                  subtitle: 'Review last 6 months transactions',
                  onTap: () => AppNavigation.gotoMyTransactionScreen(context),
                ),
                if (AppSingleton.singleton.appData.tds != 0)
                  _actionTile(
                    icon: Icons.request_quote_outlined,
                    title: 'TDS Dashboard',
                    subtitle: 'Review TDS transactions of all financial years',
                    onTap: () => AppNavigation.gotoTdsDetailsScreen(context),
                  ),
                _actionTile(
                  icon: Icons.contact_emergency_outlined,
                  title: 'My KYC Details',
                  subtitle: 'View Mobile & Bank A/C',
                  onTap: () => AppNavigation.gotoVerifyDetailsScreen(
                    context,
                  ).then((_) => setState(loadData)),
                ),
                _actionTile(
                  icon: Icons.verified_outlined,
                  title: Strings.referEarn,
                  subtitle:
                      'Invite your friends on ${APIServerUrl.appName} and play with them!',
                  onTap: () => AppNavigation.gotoReferEarnScreen(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _walletInfoTile({
    required String icon,
    required String title,
    required String value,
    bool isTokenIcon = false,
    bool isShopToken = false,
    bool isDiamondIcon = false,
    bool gradientButton = false,
    Color? color,
    String? buttonText,
    VoidCallback? onButtonTap,
    String? tooltip,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color ?? AppColors.lightCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: isShopToken
                  ? SvgPicture.asset(
                      'assets/icons/coin.svg',
                      width: 24,
                      height: 24,
                      // ignore: deprecated_member_use
                      color: AppColors.mainColor,
                    )
                  : isDiamondIcon
                      ? const Icon(
                          Icons.diamond_outlined,
                          size: 24,
                          color: AppColors.orangeColor,
                        )
                      : isTokenIcon
                          ? Image.asset(
                              Images.matchToken,
                              width: 24,
                              height: 24,
                            )
                          : Image.asset(
                              icon,
                              width: 24,
                              height: 24,
                              color: AppColors.mainColor,
                            ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: AppColors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (tooltip != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Tooltip(
                          message: tooltip,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.whiteFade1,
                              width: 1,
                            ),
                          ),
                          textStyle: const TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 12,
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: AppColors.lightGrey,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          if (buttonText != null)
            InkWell(
              onTap: onButtonTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 18,
                ),
                decoration: BoxDecoration(
                  gradient: gradientButton ? AppColors.mainGradient : null,
                  color: AppColors.whiteFade1,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  buttonText,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: gradientButton ? AppColors.white : AppColors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.mainColor, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.black),
            ],
          ),
        ),
      ),
    );
  }
}
