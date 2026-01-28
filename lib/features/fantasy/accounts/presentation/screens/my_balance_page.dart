import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_dream247/config/api_config.dart';
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
import 'package:unified_dream247/features/fantasy/landing/data/home_datasource.dart';
import 'package:unified_dream247/features/fantasy/landing/domain/use_cases/home_usecases.dart';
import 'package:unified_dream247/features/fantasy/menu_items/data/user_datasource.dart';
import 'package:unified_dream247/features/fantasy/menu_items/domain/use_cases/user_usecases.dart';
import 'package:unified_dream247/core/services/wallet_service.dart';
import 'package:unified_dream247/core/providers/shop_tokens_provider.dart';
import 'package:unified_dream247/features/shop/services/auth_service.dart'
    as shop_auth;
import 'package:unified_dream247/config/routes/app_router.dart';

class MyBalancePage extends StatefulWidget {
  const MyBalancePage({super.key});

  @override
  State<MyBalancePage> createState() => _MyBalancePage();
}

class _MyBalancePage extends State<MyBalancePage> with RouteAware {
  AccountsUsecases accountsUsecases = AccountsUsecases(
    AccountsDatasource(ApiImpl(), ApiImplWithAccessToken()),
  );
  DateTime? lastRefreshTime;
  double _shopTokens = 0.0;
  double _totalSpent = 0.0;
  double _totalAdded = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeFantasyDataIfNeeded();
    loadData();
    _loadShopTokens();
    _loadGameTokens();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route observer for auto-refresh when returning to this page
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when returning to this page from another page (e.g., after adding cash or order)
    debugPrint('🔄 [WALLET] ⬆️ RETURN_TO_WALLET: Page regained focus, refreshing all data...');
    _refreshAllData();
  }

  /// Refresh all wallet data (shop tokens, game tokens, wallet details)
  Future<void> _refreshAllData() async {
    debugPrint('🔄 [ACCOUNTS] Starting full refresh...');
    lastRefreshTime = null; // Reset throttle to force refresh

    // Small delay to ensure backend has processed any pending transactions
    await Future.delayed(const Duration(milliseconds: 500));

    // Force refresh wallet details from backend
    await accountsUsecases.myWalletDetails(context);
    debugPrint('✅ [ACCOUNTS] Wallet details refreshed');

    // Load full wallet data
    await _loadFullWalletBalance();
    debugPrint('✅ [ACCOUNTS] Full wallet balance loaded');

    // Refresh individual token components
    await _loadShopTokens();
    await _loadGameTokens();
    debugPrint('✅ [ACCOUNTS] Individual tokens refreshed');

    if (mounted) {
      setState(() {
        // Force UI rebuild
      });
      debugPrint('✅ [ACCOUNTS] UI state updated');
    }
    debugPrint('✅ [ACCOUNTS] Auto-refresh complete');
  }

  /// Initialize Fantasy module data if not already loaded
  /// This ensures app data and user data are available when navigating directly to wallet
  Future<void> _initializeFantasyDataIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1️⃣ First, ensure we have a valid Fantasy token
      String? token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        debugPrint('⚠️ [WALLET] No fantasy token found, fetching...');

        final phone = prefs.getString('user_phone') ?? '';
        final name = prefs.getString('user_name') ?? '';

        if (phone.isNotEmpty) {
          final authService = shop_auth.AuthService();
          token = await authService.fetchFantasyToken(
            phone: phone,
            name: name,
            userId: prefs.getString('user_id') ?? '',
          );

          if (token != null && token.isNotEmpty) {
            await prefs.setString('token', token);
            debugPrint('✅ [WALLET] Fantasy token refreshed');
          } else {
            debugPrint('❌ [WALLET] Could not obtain fantasy token');
          }
        } else {
          debugPrint('❌ [WALLET] No phone number available for token refresh');
        }
      } else {
        debugPrint('✅ [WALLET] Fantasy token exists');
      }

      // 2️⃣ Check if app data is already loaded (has payment gateway config)
      final hasAppData =
          AppSingleton.singleton.appData.androidpaymentgateway != null;

      if (!hasAppData) {
        debugPrint(
            '📥 [WALLET] Loading app data (navigated directly to wallet)...',);
        final homeUsecases = HomeUsecases(
          HomeDatasource(ApiImplWithAccessToken()),
        );
        await homeUsecases.getAppDataWithHeader(context);
        debugPrint('✅ [WALLET] App data loaded');
      }

      // 3️⃣ Load user details if not already loaded
      final userUsecases =
          UserUsecases(UserDatasource(ApiImplWithAccessToken()));
      await userUsecases.getUserDetails(context);
      debugPrint('✅ [WALLET] User details loaded');
    } catch (e) {
      debugPrint('⚠️ [WALLET] Error initializing Fantasy data: $e');
    }
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
    debugPrint('📲 [WALLET] Loading shop tokens from wallet service...');
    await walletService.initialize();
    final shopTokens = await walletService.getShopTokens();
    
    debugPrint('💰 [WALLET] ✅ FETCHED_SHOP_TOKENS: $shopTokens');
    debugPrint('   - Source: SharedPreferences (updated by order deduction)');
    
    setState(() {
      _shopTokens = shopTokens;
    });

    // Sync to ShopTokensProvider for shop app
    if (mounted) {
      try {
        final shopTokensProvider = context.read<ShopTokensProvider>();
        await shopTokensProvider.updateTokens(shopTokens.toInt());
        debugPrint(
            '✅ [WALLET] 📤 SYNCED_TO_PROVIDER: Shop tokens updated in provider to ${shopTokens.toInt()}',);
      } catch (e) {
        debugPrint('⚠️ [WALLET] Could not sync to provider: $e');
      }
    }
  }

  /// Load full wallet balance from optimized endpoint
  Future<void> _loadFullWalletBalance() async {
    try {
      final authToken = await _getWalletAuthToken();
      if (authToken == null) {
        debugPrint('⚠️ [WALLET_SCREEN] No auth token, using fallback');
        return;
      }

      final response = await http.get(
        Uri.parse(ApiConfig.fantasyWalletBalanceEndpoint),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final walletData = data['data'] ?? data;

        setState(() {
          _shopTokens = (walletData['shopTokens'] as num?)?.toDouble() ?? 0.0;
          _totalSpent = (walletData['totalSpent'] as num?)?.toDouble() ?? 0.0;
          _totalAdded = (walletData['totalAdded'] as num?)?.toDouble() ?? 0.0;
        });

        debugPrint('✅ [WALLET_SCREEN] Full wallet loaded');
        debugPrint('   Shop Tokens: $_shopTokens');
        debugPrint('   Total Spent: $_totalSpent');
        debugPrint('   Total Added: $_totalAdded');

        // Sync shop tokens to ShopTokensProvider
        if (mounted) {
          try {
            final shopTokensProvider = context.read<ShopTokensProvider>();
            await shopTokensProvider.updateTokens(_shopTokens.toInt());
            debugPrint(
                '✅ [WALLET_SCREEN] Shop tokens synced to provider: ${_shopTokens.toInt()}',);
          } catch (e) {
            debugPrint('⚠️ [WALLET_SCREEN] Could not sync to provider: $e');
          }
        }
      } else {
        debugPrint('❌ [WALLET_SCREEN] Failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [WALLET_SCREEN] Error loading full wallet: $e');
    }
  }

  /// Get auth token from SharedPreferences
  Future<String?> _getWalletAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token') ??
          prefs.getString('auth_token') ??
          prefs.getString('fantasy_token');
    } catch (e) {
      debugPrint('⚠️ [WALLET_SCREEN] Error getting auth token: $e');
      return null;
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

    // Load full wallet data from optimized endpoint
    await _loadFullWalletBalance();

    // Also load individual components for redundancy
    await _loadShopTokens();
    await _loadGameTokens();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletDetailsProvider>(
      builder: (context, walletProvider, child) {
        final walletData = walletProvider.walletData;

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
                                  value: AppUtils.stringifyNumber(num.parse(
                                          walletData?.balance.toString() ?? '0',),
                                      // num.parse(_shopTokens.toStringAsFixed(0))
                                      ),
                                  color: AppColors.lightGreen.withAlpha(20),
                                  isShopToken: true,
                                  gradientButton: true,
                                  buttonText: 'Add Cash',
                                  onButtonTap: () async {
                                    // Navigate to Add Money page and refresh when returning
                                    final result = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const AddMoneyPage(),),
                                    );
                                    // Always refresh when returning, regardless of result
                                    debugPrint(
                                        '🔄 [ACCOUNTS] Returned from Add Money (result: $result), refreshing...',);
                                    await _refreshAllData();
                                  },
                                ),
                                const SizedBox(height: 12),
                                _walletInfoTile(
                                  icon: Images.icWinning,
                                  title: Strings.winning,
                                  isDiamondIcon: true,
                                  value: walletData?.winning ?? '0',
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
                                  value: walletData?.bonus ?? '0',
                                  color: AppColors.blueColor.withAlpha(40),
                                  tooltip: 'Use these Tokens to play Games.',
                                  isTokenIcon: true,
                                ),
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

                    const SizedBox(height: 24),

                    // Transaction, TDS, KYC, Refer Section
                    _actionTile(
                      icon: Icons.currency_exchange_rounded,
                      title: 'My Transactions',
                      subtitle: 'Review last 6 months transactions',
                      onTap: () =>
                          AppNavigation.gotoMyTransactionScreen(context),
                    ),
                    if (AppSingleton.singleton.appData.tds != 0)
                      _actionTile(
                        icon: Icons.request_quote_outlined,
                        title: 'TDS Dashboard',
                        subtitle:
                            'Review TDS transactions of all financial years',
                        onTap: () =>
                            AppNavigation.gotoTdsDetailsScreen(context),
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
      },
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
                  ? Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF8E1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/coin.svg',
                          width: 22,
                          height: 22,
                        ),
                      ),
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
