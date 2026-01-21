import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/sub_container.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/accounts_datasource.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/tds_dashboard_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/domain/use_cases/accounts_usecases.dart';

class TdsDetailsScreen extends StatefulWidget {
  const TdsDetailsScreen({super.key});

  @override
  State<TdsDetailsScreen> createState() => _TdsDetailsScreenState();
}

class _TdsDetailsScreenState extends State<TdsDetailsScreen> {
  AccountsUsecases accountsUsecases = AccountsUsecases(
    AccountsDatasource(ApiImpl(), ApiImplWithAccessToken()),
  );

  TdsDashboardModel? tdsDataList;
  FinancialReport? selectedTdsData;
  List<String>? financialYearList;
  String selectedFy = '';

  @override
  void initState() {
    super.initState();
    tdsDetails();
  }

  void tdsDetails() async {
    var response = await accountsUsecases.tdsDashboard(context);
    if (response != null && (response.financialReport ?? []).isNotEmpty) {
      setState(() {
        tdsDataList = response;
        financialYearList = response.financialReport
            ?.map((e) => e.financialYear ?? '')
            .toList();
        selectedFy = financialYearList?.first ?? '2025-2026';
        selectedTdsData = tdsDataList?.financialReport?.firstWhere(
          (element) => element.financialYear == selectedFy,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubContainer(
      showAppBar: true,
      showWalletIcon: false,
      headerText: Strings.tdsDashboard,
      addPadding: false,
      child: Column(
        children: [
          Container(
            color: AppColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 12,
                    bottom: 6,
                  ),
                  child: Text(
                    Strings.financialYear,
                    style: GoogleFonts.tomorrow(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: DropdownMenu<String>(
                    inputDecorationTheme: InputDecorationTheme(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    expandedInsets: EdgeInsets.zero,
                    initialSelection: selectedFy,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      color: AppColors.letterColor,
                      fontWeight: FontWeight.w500,
                    ),
                    menuStyle: MenuStyle(
                      backgroundColor: const WidgetStatePropertyAll(AppColors.white),
                      elevation: const WidgetStatePropertyAll(5),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    onSelected: (String? value) {
                      if (value != null) {
                        setState(() {
                          selectedFy = value;
                          selectedTdsData =
                              tdsDataList?.financialReport?.firstWhere(
                            (element) => element.financialYear == value,
                          );
                        });
                      }
                    },
                    dropdownMenuEntries: financialYearList?.map((String item) {
                          return DropdownMenuEntry<String>(
                            value: item,
                            label: item,
                          );
                        }).toList() ??
                        [],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 1,
                  color: AppColors.lightGrey,
                  width: double.infinity,
                ),
                tdsInfo(
                  Strings.oeningBalance,
                  Strings.totalopeningBalanceBeforeFinancialYear,
                  "${Strings.indianRupee}${selectedTdsData?.openingBalance ?? "0.0"}",
                ),
                Container(
                  height: 1,
                  color: AppColors.lightGrey,
                  width: double.infinity,
                ),
                tdsInfo(
                  Strings.netWinning,
                  '${Strings.totalCommissionTillDate} ${selectedTdsData?.financialYear}',
                  "${Strings.indianRupee}${AppUtils.formatAmount(selectedTdsData?.netWin.toString() ?? "0.0")}",
                ),
                Container(
                  height: 1,
                  color: AppColors.lightGrey,
                  width: double.infinity,
                ),
                tdsInfo(
                  Strings.totalDeposit,
                  '${Strings.totalDepositTillDate} ${selectedTdsData?.financialYear}',
                  "${Strings.indianRupee}${AppUtils.formatAmount(selectedTdsData?.successDeposit.toString() ?? "0.0")}",
                ),
                Container(
                  height: 1,
                  color: AppColors.lightGrey,
                  width: double.infinity,
                ),
                tdsInfo(
                  Strings.totalWithdraw,
                  '${Strings.totalWithdrawTillDate} ${selectedTdsData?.financialYear}',
                  "${Strings.indianRupee}${AppUtils.formatAmount(selectedTdsData?.successWithdraw.toString() ?? "0.0")}",
                ),
                Container(
                  height: 1,
                  color: AppColors.lightGrey,
                  width: double.infinity,
                ),
                tdsInfo(
                  Strings.tdsPaid,
                  null,
                  "${Strings.indianRupee}${AppUtils.formatAmount(selectedTdsData?.tdsAlreadyPaid.toString() ?? "0.0")}",
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: AppColors.green),
            ),
            margin: const EdgeInsets.all(16.0),
            child: tdsInfo(
              Strings.tdstobePaid,
              null,
              "${Strings.indianRupee}${AppUtils.formatAmount(selectedTdsData?.tdsToBeDeducted.toString() ?? "0.0")}",
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 15.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  tdsDataList?.tdsFormula ?? '',
                  style: GoogleFonts.exo2(
                    color: AppColors.letterColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                Text(
                  tdsDataList?.example ?? '',
                  style: GoogleFonts.exo2(
                    color: AppColors.letterColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget tdsInfo(String title, String? subtitle, String? amount) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.exo2(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.letterColor,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.letterColor,
                    ),
                  ),
              ],
            ),
          ),
          if (amount != null)
            Text(
              amount,
              style: GoogleFonts.tomorrow(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.letterColor,
              ),
            ),
        ],
      ),
    );
  }
}
