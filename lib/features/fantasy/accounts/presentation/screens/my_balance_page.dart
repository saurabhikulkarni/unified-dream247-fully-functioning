import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:Dream247/features/landing/data/singleton/app_singleton.dart';
import 'package:provider/provider.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:Dream247/core/api_server_constants/api_server_urls.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/app_pages.dart';
import 'package:Dream247/core/app_constants/images.dart';
import 'package:Dream247/core/app_constants/strings.dart';
import 'package:Dream247/core/global_widgets/sub_container.dart';
import 'package:Dream247/core/utils/app_utils.dart';
import 'package:Dream247/features/accounts/data/accounts_datasource.dart';
import 'package:Dream247/features/accounts/domain/use_cases/accounts_usecases.dart';
import 'package:Dream247/features/accounts/presentation/providers/wallet_details_provider.dart';
import 'package:Dream247/features/accounts/presentation/screens/add_money_page.dart';

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

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    DateTime now = DateTime.now();

    if (lastRefreshTime != null &&
        now.difference(lastRefreshTime!).inSeconds < 5) {
      return;
    }

    lastRefreshTime = now;
    await accountsUsecases.myWalletDetails(context);
    setState(() {});
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
                              title: "Shop Token",
                              value:
                                  "${AppUtils.stringifyNumber(num.parse(walletData?.balance ?? "0"))}",
                              color: AppColors.lightGreen.withAlpha(20),
                              isShopToken: true,
                              gradientButton: true,
                              buttonText: "Add Cash",
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
                                title: "Game Token",
                                value: "${walletData?.bonus ?? "0"}",
                                color: AppColors.blueColor.withAlpha(40),
                                tooltip: "Use these Tokens to play Games.",
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
                      "Invite your friends on ${APIServerUrl.appName} and play with them!",
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color ?? AppColors.lightCard,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Image.asset(icon, width: 28, height: 28),
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
                Row(
                  children: [
                    isShopToken
                        ? Image.asset(
                            Images.tokenImage,
                            // Images.imageWallet,
                            height: 18,
                            width: 18,
                            // color: AppColors.white,
                          )
                        : SizedBox(),
                    isTokenIcon
                        ? Image.asset(
                            Images.matchToken,
                            height: 15,
                          )
                        : SizedBox(),
                    isDiamondIcon
                        ? Icon(
                            Icons.diamond_outlined,
                            color: AppColors.blueColor,
                          )
                        : SizedBox(),
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
