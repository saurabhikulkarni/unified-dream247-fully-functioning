import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/common_shimmer_view_widget.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/sub_container.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/accounts_datasource.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/transactions_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/domain/use_cases/accounts_usecases.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/menu_items/presentation/providers/user_data_provider.dart';

class MyTransactions extends StatefulWidget {
  const MyTransactions({super.key});
  @override
  State<MyTransactions> createState() => _MyTransactions();
}

class _MyTransactions extends State<MyTransactions>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late PageController _pageController;
  bool isLoading = false;
  bool hasMore = true;
  int skip = 0;
  int limit = 15;
  String type = "depositAndWithdrawals";
  bool oldTransactions = false;
  int _currentIndex = 0;
  AccountsUsecases accountsUsecases = AccountsUsecases(
    AccountsDatasource(ApiImpl(), ApiImplWithAccessToken()),
  );
  String selectedStatus = "success";

  Map<String, List<TransactionData>> transactionsMap = {
    "depositAndWithdrawals": [],
    "credit": [],
    "debit": [],
    "reward": [],
    "promotion": [],
  };

  @override
  void initState() {
    super.initState();
    final userData =
        Provider.of<UserDataProvider>(context, listen: false).userData;
    int tabLength = (userData!.promoterVerify == 0 ||
            userData.promoterVerify == -1 ||
            userData.isPromoterBlocked == true)
        ? 4
        : 5;

    _tabController = TabController(length: tabLength, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _pageController = PageController();

    fetchTransactions(_currentIndex);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.jumpToPage(_tabController.index);
        _handleTabChange(_tabController.index);
      }
    });
  }

  void _handleTabChange(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
      skip = 0;
      hasMore = true;
    });

    switch (index) {
      case 0:
        type = 'depositAndWithdrawals';
        selectedStatus = 'success';
        break;
      case 1:
        type = 'credit';
        break;
      case 2:
        type = 'debit';
        break;
      case 3:
        type = 'reward';
        break;
      case 4:
        final userData =
            Provider.of<UserDataProvider>(context, listen: false).userData;
        if (userData?.promoterVerify == 1 &&
            userData?.isPromoterBlocked == false) {
          type = 'promotion';
        }
        break;
    }

    transactionsMap[type]!.clear();

    if (type == 'depositAndWithdrawals') {
      fetchTransactions(null, selectedStatus);
    } else {
      fetchTransactions();
    }
  }

  String _latestRequestId = "";

  void fetchTransactions([int? tabIndex, String? status]) async {
    if (tabIndex != null) {
      _handleTabChange(tabIndex);
    }

    if (status != null) {
      selectedStatus = status;
      transactionsMap[type]!.clear();
      skip = 0;
      hasMore = true;
    }

    if (transactionsMap[type]!.isNotEmpty && skip == 0) return;

    final String requestId = DateTime.now().millisecondsSinceEpoch.toString();
    _latestRequestId = requestId;

    setState(() {
      isLoading = true;
    });

    TransactionsModel? result;
    if ((oldTransactions)) {
      result = await accountsUsecases.getTransactions(
        context,
        type,
        skip,
        limit,
        selectedStatus,
      );
    } else {
      result = await accountsUsecases.getTransactionsRedis(
        context,
        type,
        skip,
        limit,
        selectedStatus,
      );
    }

    if (_latestRequestId != requestId) return;

    if (result != null && result.transactions != null) {
      setState(() {
        if ((result?.transactions ?? []).isNotEmpty) {
          transactionsMap[type]!.addAll(result?.transactions ?? []);
          skip += limit;
        } else {
          hasMore = false;
        }
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading &&
        hasMore) {
      fetchTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData =
        Provider.of<UserDataProvider>(context, listen: false).userData;
    return SubContainer(
      showAppBar: true,
      showWalletIcon: false,
      headerText: Strings.myTransactions,
      addPadding: false,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicator: BoxDecoration(
              color: AppColors.mainLightColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.mainColor, width: 1),
            ),
            labelColor: AppColors.blackColor,
            unselectedLabelColor: AppColors.black,
            labelStyle:
                GoogleFonts.exo2(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: GoogleFonts.exo2(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            splashBorderRadius: BorderRadius.circular(10),
            tabs: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Text(
                  'Deposit & Withdrawal',
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Text(
                  'Credit',
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Text(
                  'Debit',
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Text(
                  'Reward',
                ),
              ),
              if (userData!.promoterVerify == 1 &&
                  userData.isPromoterBlocked == false)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Text(
                    'Promoter',
                  ),
                ),
            ],
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                _tabController.index = index;
                _handleTabChange(index);
              },
              children: List.generate(_tabController.length, (index) {
                String tabType;
                switch (index) {
                  case 0:
                    tabType = 'depositAndWithdrawals';
                    break;
                  case 1:
                    tabType = 'credit';
                    break;
                  case 2:
                    tabType = 'debit';
                    break;
                  case 3:
                    tabType = 'reward';
                    break;
                  case 4:
                    tabType = 'promotion';
                    break;
                  default:
                    tabType = 'depositAndWithdrawals';
                }

                return transactionsMap[tabType]!.isEmpty && !isLoading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          (tabType == "depositAndWithdrawals")
                              ? Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () =>
                                          fetchTransactions(0, "success"),
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          left: 15,
                                          right: 5,
                                          top: 10,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: selectedStatus == "success"
                                              ? AppColors.mainLightColor
                                              : AppColors.white,
                                          border: Border.all(
                                            color: AppColors.letterColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          Strings.success,
                                          style: TextStyle(
                                            color: selectedStatus == "success"
                                                ? AppColors.white
                                                : AppColors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          fetchTransactions(0, "pending"),
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          left: 5,
                                          right: 5,
                                          top: 10,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: selectedStatus == "pending"
                                              ? AppColors.mainLightColor
                                              : AppColors.white,
                                          border: Border.all(
                                            color: AppColors.letterColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          Strings.pending,
                                          style: TextStyle(
                                            color: selectedStatus == "pending"
                                                ? AppColors.white
                                                : AppColors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          fetchTransactions(0, "failed"),
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          left: 5,
                                          right: 5,
                                          top: 10,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: selectedStatus == "failed"
                                              ? AppColors.mainLightColor
                                              : AppColors.white,
                                          border: Border.all(
                                            color: AppColors.letterColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          Strings.failed,
                                          style: TextStyle(
                                            color: selectedStatus == "failed"
                                                ? AppColors.white
                                                : AppColors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                Strings.noTransactionsFound,
                                style: TextStyle(
                                  color: AppColors.letterColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          (tabType == "depositAndWithdrawals")
                              ? Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () =>
                                          fetchTransactions(0, "success"),
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          left: 15,
                                          right: 5,
                                          top: 10,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: selectedStatus == "success"
                                              ? AppColors.mainLightColor
                                              : AppColors.white,
                                          border: Border.all(
                                            color: AppColors.letterColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          Strings.success,
                                          style: TextStyle(
                                            color: selectedStatus == "success"
                                                ? AppColors.white
                                                : AppColors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          fetchTransactions(0, "pending"),
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          left: 5,
                                          right: 5,
                                          top: 10,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: selectedStatus == "pending"
                                              ? AppColors.mainLightColor
                                              : AppColors.white,
                                          border: Border.all(
                                            color: AppColors.letterColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          Strings.pending,
                                          style: TextStyle(
                                            color: selectedStatus == "pending"
                                                ? AppColors.white
                                                : AppColors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          fetchTransactions(0, "failed"),
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          left: 5,
                                          right: 5,
                                          top: 10,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: selectedStatus == "failed"
                                              ? AppColors.mainLightColor
                                              : AppColors.white,
                                          border: Border.all(
                                            color: AppColors.letterColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          Strings.failed,
                                          style: TextStyle(
                                            color: selectedStatus == "failed"
                                                ? AppColors.white
                                                : AppColors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: transactionsMap[tabType]!.length +
                                  (isLoading ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == transactionsMap[tabType]!.length) {
                                  return ListView.builder(
                                    itemCount: 10,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return ShimmerWidget(
                                        height: 60,
                                        margin: const EdgeInsets.all(10),
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3,
                                      );
                                    },
                                  );
                                }
                                return singleTransaction(
                                  transactionsMap[tabType]![index],
                                );
                              },
                            ),
                          ),
                        ],
                      );
              }),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: InkWell(
              onTap: () {
                setState(() {
                  oldTransactions = !oldTransactions;
                  skip = 0;
                  transactionsMap[type] = [];
                });
                fetchTransactions();
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 40, top: 10),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 30,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.whiteFade1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  oldTransactions
                      ? "View Recent Transactions"
                      : "View Old Transactions",
                  style: const TextStyle(
                    color: AppColors.mainColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget singleTransaction(TransactionData data) {
    return GestureDetector(
      onTap: () {
        if (AppSingleton.singleton.appData.transactionDetails == true) {
          // AppNavigation.gotoTransactionDetailsScreen(
          //   context,
          //   data.txnid ?? "",
          //   data.type ?? "",
          // );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        margin: const EdgeInsets.all(10).copyWith(bottom: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.whiteFade1.withAlpha(51),
          border: Border.all(color: AppColors.whiteFade1, width: 1),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: AppColors.lightBlue,
                        ),
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: AppColors.transparent,
                          child: Image.asset(
                            Images.icAddCash,
                            color: AppColors.mainColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(1),
                            child: Text(
                              data.type ?? "",
                              style: const TextStyle(
                                color: AppColors.letterColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (_tabController.index == 0)
                            if ((data.gstAmount ?? '') != "" ||
                                (data.gstAmount ?? "").isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(1),
                                child: Text(
                                  "GST Added to Cashback: ${Strings.indianRupee}${AppUtils.formatAmount(data.gstAmount ?? "0.0")}",
                                  style: const TextStyle(
                                    color: AppColors.letterColor,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          if (_tabController.index == 0)
                            if ((data.cashback ?? '') != "" ||
                                (data.cashback ?? "").isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(1),
                                child: Text(
                                  "Cashback you got: ${Strings.indianRupee}${AppUtils.formatAmount(data.cashback ?? "0.0")}",
                                  style: const TextStyle(
                                    color: AppColors.letterColor,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          if (_tabController.index == 0)
                            if ((data.tdsAmount ?? '') != '')
                              Padding(
                                padding: const EdgeInsets.all(1),
                                child: Text(
                                  "${Strings.tdsAmountDeducted}${Strings.indianRupee}${AppUtils.formatAmount(data.tdsAmount ?? "0.0")}",
                                  style: const TextStyle(
                                    color: AppColors.letterColor,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          (_tabController.index == 3)
                              ? ((data.expiresAt ?? "").isNotEmpty)
                                  ? Text(
                                      "This will expire on ${AppUtils.formatDateTime(data.expiresAt ?? "")}.",
                                      style: const TextStyle(
                                        color: AppColors.yellowColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10,
                                      ),
                                    )
                                  : const SizedBox.shrink()
                              : const SizedBox.shrink(),
                          (_tabController.index == 0)
                              ? ((data.paymentstatus ?? "").isNotEmpty)
                                  ? Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(1),
                                          child: Text(
                                            data.paymentstatus?.toUpperCase() ??
                                                "",
                                            style: TextStyle(
                                              color: (data.paymentstatus ==
                                                          "success" ||
                                                      data.paymentstatus ==
                                                          "refund")
                                                  ? AppColors.green
                                                  : (data.paymentstatus ==
                                                          "pending")
                                                      ? AppColors.yellowColor
                                                      : AppColors.mainLightColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                        (data.paymentstatus == "success")
                                            ? ((data.utr ?? "").isEmpty)
                                                ? const SizedBox.shrink()
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                      1,
                                                    ),
                                                    child: Text(
                                                      "- UTR:${data.utr}",
                                                      style: const TextStyle(
                                                        color: AppColors
                                                            .letterColor,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  )
                                            : (data.statusDescription == null ||
                                                    data.statusDescription!
                                                        .isEmpty)
                                                ? const SizedBox.shrink()
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.all(1),
                                                    child: Text(
                                                      "- ${data.statusDescription ?? ""}",
                                                      style: const TextStyle(
                                                        color: AppColors
                                                            .letterColor,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                      ],
                                    )
                                  : const SizedBox.shrink()
                              : const SizedBox.shrink(),
                          (_tabController.index == 0)
                              ? ((data.paymentmethod ?? "").isNotEmpty)
                                  ? Padding(
                                      padding: const EdgeInsets.all(1),
                                      child: Text(
                                        "Payment Method: ${data.paymentmethod ?? ""}",
                                        style: const TextStyle(
                                          color: AppColors.letterColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 10,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink()
                              : const SizedBox.shrink(),
                          Padding(
                            padding: const EdgeInsets.all(1),
                            child: Text(
                              (data.matchName != null && data.matchName != '')
                                  ? '${AppUtils.formatDateTime(data.dateTime ?? "")} - ${data.matchName}'
                                  : AppUtils.formatDateTime(
                                      data.dateTime ?? "",
                                    ),
                              style: const TextStyle(
                                color: AppColors.letterColor,
                                fontWeight: FontWeight.w300,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  RichText(
                    text: TextSpan(
                      text: (data.transactionType! == "Credit") ? "+" : "-",
                      style: GoogleFonts.tomorrow(
                        color: (data.transactionType! == "Credit")
                            ? AppColors.green
                            : AppColors.mainLightColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      children: [
                        TextSpan(
                          text: "${Strings.indianRupee}${data.amount ?? "0"}",
                          style: GoogleFonts.tomorrow(
                            color: (data.transactionType! == "Credit")
                                ? AppColors.green
                                : AppColors.mainLightColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
