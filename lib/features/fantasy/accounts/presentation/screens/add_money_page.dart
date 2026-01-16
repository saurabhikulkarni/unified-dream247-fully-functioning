// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:math';
import 'package:unified_dream247/features/fantasy/core/global_widgets/dashed_underline_text.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/widgets/token_tier_bottomsheet.dart';
import 'package:unified_dream247/features/fantasy/menu_items/data/models/user_data.dart';
import 'package:unified_dream247/features/fantasy/menu_items/presentation/providers/user_data_provider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/app_toast.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/dashed_border.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/main_button.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/sub_container.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/accounts_datasource.dart';
import 'package:unified_dream247/features/fantasy/accounts/domain/use_cases/accounts_usecases.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/menu_items/data/models/offers_model.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class AddMoneyPage extends StatefulWidget {
  const AddMoneyPage({super.key});

  @override
  State<AddMoneyPage> createState() => _AddMoneyPage();
}

class _AddMoneyPage extends State<AddMoneyPage> {
  final ValueNotifier<bool> _isGstVisible = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isKeyboardOpen = ValueNotifier<bool>(false);
  final TextEditingController _amountController = TextEditingController();
  String promoId = "";
  Future<List<OffersModel>?>? offerList;
  int offersCount = 0;
  bool isApplied = false;
  bool isExpanded = false;
  String? _errorText;
  Timer? _typingTimer;
  Razorpay? _razorpay;
  String? _razorpayOrderId;
  bool _showMysteryBox = false;
  String? _lastTxnId;
  UserFullDetailsResponse? userData;
  late ConfettiController _confettiController;
  bool _isPaymentFlowLocked = false;

  AccountsUsecases accountsUsecases = AccountsUsecases(
    AccountsDatasource(ApiImpl(), ApiImplWithAccessToken()),
  );
  bool _showClearIcon = false;

  @override
  void initState() {
    super.initState();
    getAllOffers();
    _amountController.addListener(() {
      setState(() {
        _showClearIcon = _amountController.text.isNotEmpty;
      });
      _typingTimer?.cancel();
      _validateAmount();
      if (_amountController.text.isNotEmpty) {
        _isGstVisible.value = true;
        _typingTimer = Timer(const Duration(seconds: 1), () {
          FocusScope.of(context).unfocus();
        });
      } else {
        _isGstVisible.value = false;
      }
    });
    _initRazorpay();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userData = Provider.of<UserDataProvider>(context).userData;
  }

  bool get _isUserVerified {
    return userData?.verified == 1;
  }

  void _initRazorpay() {
    _razorpay?.clear();

    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _createRazorpayOrder() async {
    final res = await accountsUsecases.requestAddCash(
      context,
      "RazorPay",
      _amountController.text,
      promoId,
    );

    if (res == null ||
        res["data"] == null ||
        res["data"]["order_id"] == null ||
        res["data"]["order_id"].toString().isEmpty) {
      appToast("Unable to create Razorpay order", context);
      return;
    }
    _lastTxnId = res["data"]["txnid"];
    _razorpayOrderId = res["data"]["order_id"];
    _openCheckout();
  }

  void _openCheckout() {
    if (_razorpayOrderId == null) {
      appToast("Order not generated. Please retry.", context);
      return;
    }

    _initRazorpay();

    var options = {
      'key': "rzp_test_S0bjTVUZm4brLR",
      'amount': (double.parse(_amountController.text) * 100).toInt(),
      'order_id': _razorpayOrderId,
      'name': 'Dream247',
      'description': 'Add Wallet Balance',
      'method': {
        'upi': true,
        'card': true,
        'netbanking': true,
        'wallet': true,
      },
      'prefill': {
        'contact': userData?.mobile ?? "",
        'email': userData?.email ?? "",
      },
      'theme': {'color': '#0f9d58'},
    };

    _razorpay!.open(options);
  }

  Future<bool> _handleBackAttempt() async {
    if (_isPaymentFlowLocked || _showMysteryBox) {
      appToast("Please complete the reward process first", context);
      return false;
    }
    return true;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isPaymentFlowLocked = true);
    final res = await accountsUsecases.verifyRazorpayPayment(
      context,
      response.paymentId!,
      response.orderId!,
      response.signature!,
    );

    if (!mounted) return;

    if (res != null && res["success"] == true) {
      appToast(res["message"] ?? "Payment Successful", context);
      setState(() => _showMysteryBox = true);
    } else {
      appToast(res?["message"] ?? "Payment Verification Failed", context);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    appToast("Payment Failed", context);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  void _showTokenBreakdownSheet(
    BuildContext context,
    int enteredAmount,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return TokenTierBottomSheet(
          accountsUsecases: accountsUsecases,
          enteredAmount: enteredAmount,
        );
      },
    );
  }

  void _validateAmount() {
    final text = _amountController.text;

    if (text.isEmpty) {
      setState(() => _errorText = null);
      return;
    }

    final amount = double.tryParse(text) ?? 0;

    final minAdd = double.tryParse(
          AppSingleton
                  .singleton.appData.androidpaymentgateway?.isRazorPay?.min ??
              "0",
        ) ??
        0;

    final maxAdd = double.tryParse(
          AppSingleton
                  .singleton.appData.androidpaymentgateway?.isRazorPay?.max ??
              "0",
        ) ??
        0;

    if (amount < minAdd) {
      setState(() {
        _errorText = "Minimum amount is ₹$minAdd";
      });
      return;
    }

    if (maxAdd != 0 && amount > maxAdd) {
      setState(() {
        _errorText = "Maximum amount is ₹$maxAdd";
      });
      return;
    }

    setState(() => _errorText = null);
  }

  // void _validateAmount() {
  //   String text = _amountController.text;
  //   if (text.isEmpty) {
  //     setState(() {
  //       _errorText = '';
  //     });
  //     return;
  //   }

  //   double amount = double.tryParse(text) ?? 0;
  //   double minAdd = 1;
  //   double.tryParse(AppSingleton.singleton.appData.minadd.toString()) ?? 0;

  //   if (amount < minAdd) {
  //     setState(() {
  //       _errorText = 'Minimum Amount to add: ${Strings.indianRupee}$minAdd';
  //     });
  //   } else {
  //     setState(() {
  //       _errorText = null;
  //     });
  //   }
  // }

  getAllOffers() async {
    offerList = accountsUsecases.getOffers(context);
    var offers = await offerList;
    setState(() {
      offersCount = offers?.length ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    _isKeyboardOpen.value = MediaQuery.of(context).viewInsets.bottom > 0;

    return WillPopScope(
      onWillPop: () async {
        if (_isPaymentFlowLocked || _showMysteryBox) {
          appToast("Please complete the reward process first", context);
          return false;
        }
        return true;
      },
      child: SubContainer(
        onBackPressed: () => _handleBackAttempt(),
        showAppBar: true,
        showWalletIcon: false,
        headerText: Strings.addCash,
        addPadding: true,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF9FBFF), Color(0xFFEFF3F8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          // child: Center(
          //   child: Text("This Feature is Coming Soon !!"),
          // ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card(
                            //   elevation: 3,
                            //   shadowColor: AppColors.black,
                            //   shape: RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.circular(16),
                            //   ),
                            //   child: Padding(
                            //     padding: const EdgeInsets.symmetric(
                            //       horizontal: 16,
                            //       vertical: 12,
                            //     ),
                            //     child: Row(
                            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //       children: [
                            //         Row(
                            //           children: [
                            //             const Icon(
                            //               Icons.account_balance_wallet,
                            //               color: AppColors.mainColor,
                            //             ),
                            //             const SizedBox(width: 8),
                            //             const Text(
                            //               "Shopping Balance",
                            //               style: TextStyle(
                            //                 color: AppColors.letterColor,
                            //                 fontSize: 15,
                            //                 fontWeight: FontWeight.w500,
                            //               ),
                            //             ),
                            //           ],
                            //         ),
                            //         Text(
                            //           "${Strings.indianRupee}${walletData?.totalamount ?? "0.0"}",
                            //           style: GoogleFonts.poppins(
                            //             color: AppColors.mainColor,
                            //             fontSize: 16,
                            //             fontWeight: FontWeight.w700,
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  /// 🔹 Centered Amount Field
                                  Align(
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.75,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.lightGrey,
                                            width: 1,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: TextFormField(
                                          controller: _amountController,
                                          keyboardType: TextInputType.number,
                                          maxLength: 7,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            color: AppColors.letterColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                          cursorColor: AppColors.mainColor,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            counterText: '',
                                            prefixIcon: const Icon(
                                              Icons.currency_rupee,
                                              color: AppColors.mainColor,
                                            ),
                                            suffixIcon: _showClearIcon
                                                ? InkWell(
                                                    onTap: () =>
                                                        _amountController
                                                            .clear(),
                                                    child: const Icon(
                                                      Icons.cancel_rounded,
                                                      color:
                                                          AppColors.lightGrey,
                                                    ),
                                                  )
                                                : null,
                                            labelText: Strings.amountToAdd,
                                            labelStyle: const TextStyle(
                                              color: AppColors.lightGrey,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("Get "),
                                        Image.asset(
                                          Images.tokenImage,
                                          height: 20,
                                        ),
                                        Text(_amountController.text),
                                      ],
                                    ),
                                  ),

                                  if (_errorText != null) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      _errorText!,
                                      style: const TextStyle(
                                        color: AppColors.mainLightColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],

                                  // const Align(
                                  //   alignment: Alignment.centerLeft,
                                  //   child: Text(
                                  //     "${Strings.minimumAmountToAdd}${Strings.indianRupee} 50",
                                  //     style: TextStyle(
                                  //       fontSize: 11,
                                  //       color: AppColors.blackColor,
                                  //     ),
                                  //   ),
                                  // ),

                                  const SizedBox(height: 10),

                                  /// 🔹 Quick Amount Buttons (Row)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _quickAmountButton("₹500", "500"),
                                      _quickAmountButton("₹1000", "1000"),
                                      _quickAmountButton("₹2000", "2000"),
                                    ],
                                  ),
                                ],
                              ),

                              // Column(
                              //   children: [
                              //     Row(
                              //       children: [
                              //         Expanded(
                              //           flex: 2,
                              //           child: Container(
                              //             decoration: BoxDecoration(
                              //               borderRadius: BorderRadius.circular(12),
                              //               border: Border.all(
                              //                 color: AppColors.lightGrey,
                              //                 width: 1,
                              //               ),
                              //             ),
                              //             child: Padding(
                              //               padding: const EdgeInsets.symmetric(
                              //                 horizontal: 8,
                              //               ),
                              //               child: TextFormField(
                              //                 enabled: true,
                              //                 controller: _amountController,
                              //                 keyboardType: TextInputType.number,
                              //                 maxLength: 7,
                              //                 inputFormatters: [
                              //                   FilteringTextInputFormatter
                              //                       .digitsOnly,
                              //                 ],
                              //                 style: GoogleFonts.poppins(
                              //                   color: AppColors.letterColor,
                              //                   fontWeight: FontWeight.w500,
                              //                 ),
                              //                 cursorColor: AppColors.mainColor,
                              //                 decoration: InputDecoration(
                              //                   border: InputBorder.none,
                              //                   counterText: '',
                              //                   prefixIcon: const Icon(
                              //                     Icons.currency_rupee,
                              //                     color: AppColors.mainColor,
                              //                   ),
                              //                   suffixIcon: _showClearIcon
                              //                       ? InkWell(
                              //                           onTap: () {
                              //                             _amountController.clear();
                              //                           },
                              //                           child: const Icon(
                              //                             Icons.cancel_rounded,
                              //                             color: AppColors.lightGrey,
                              //                           ),
                              //                         )
                              //                       : null,
                              //                   labelText: Strings.amountToAdd,
                              //                   labelStyle: const TextStyle(
                              //                     color: AppColors.lightGrey,
                              //                     fontSize: 13,
                              //                   ),
                              //                 ),
                              //               ),
                              //             ),
                              //           ),
                              //         ),
                              //         // const SizedBox(width: 8),
                              //         // _quickAmountButton("₹500", "500"),
                              //         // const SizedBox(width: 6),
                              //         // _quickAmountButton("₹1000", "1000"),
                              //       ],
                              //     ),
                              //     if (_errorText != null) ...[
                              //       const SizedBox(height: 6),
                              //       Text(
                              //         _errorText!,
                              //         style: const TextStyle(
                              //           color: AppColors.mainLightColor,
                              //           fontSize: 12,
                              //         ),
                              //       ),
                              //     ],
                              //     const SizedBox(height: 6),
                              //     const Align(
                              //       alignment: Alignment.centerLeft,
                              //       child: Text(
                              //         "${Strings.minimumAmountToAdd}${Strings.indianRupee}1",
                              //         style: TextStyle(
                              //           fontSize: 11,
                              //           color: AppColors.lightGrey,
                              //         ),
                              //       ),
                              //     ),
                              //     const SizedBox(height: 10),
                              //     if (AppSingleton.singleton.appData.gst != 0)
                              //       ValueListenableBuilder<bool>(
                              //         valueListenable: _isGstVisible,
                              //         builder: (context, isVisible, child) {
                              //           return AnimatedSwitcher(
                              //             duration: const Duration(milliseconds: 300),
                              //             child: isVisible
                              //                 ? ValueListenableBuilder<bool>(
                              //                     valueListenable: _isKeyboardOpen,
                              //                     builder: (
                              //                       context,
                              //                       isKeyboardOpen,
                              //                       child,
                              //                     ) {
                              //                       return GstDialogBox(
                              //                         amount: _amountController.text,
                              //                         isExpanded: isKeyboardOpen
                              //                             ? false
                              //                             : true,
                              //                       );
                              //                     },
                              //                   )
                              //                 : const SizedBox.shrink(),
                              //           );
                              //         },
                              //       ),
                              //     _quickAmountButton("₹500", "500"),
                              //     const SizedBox(width: 6),
                              //     _quickAmountButton("₹1000", "1000"),
                              //   ],
                              // ),
                            ),
                            const SizedBox(height: 20),
                            _offersSection(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _bottomButtonSection(context),
                ],
              ),
              if (_showMysteryBox) _mysteryBoxOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickAmountButton(String label, String value) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        _amountController.text = value;
        FocusScope.of(context).unfocus();
      },
      child: Container(
        height: 45,
        width: 80.w,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.mainColor, AppColors.mainLightColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.mainColor.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _offersSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(5),
            width: Get.width * 0.9,
            decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: Text(
              textAlign: TextAlign.center,
              "Free Rewards",
              style: GoogleFonts.poppins(color: AppColors.white, fontSize: 20),
            ),
          ),
          Container(
            width: Get.width * 0.9,
            height: 200,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    _showTokenBreakdownSheet(
                      context,
                      int.tryParse(_amountController.text) ?? 0,
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        Images.matchToken,
                        height: 50,
                      ),
                      5.verticalSpace,
                      DashedUnderlineText(
                        text: "Game Tokens",
                        style: GoogleFonts.poppins(
                          color: AppColors.letterColor,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    textAlign: TextAlign.center,
                    "+",
                    style: GoogleFonts.poppins(
                        color: AppColors.blackColor, fontSize: 20),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        appToast("Coming Soon", context);
                      },
                      child: Image.asset(
                        Images.mysteryBox,
                        height: 50,
                      ),
                    ),
                    5.verticalSpace,
                    Text(
                      "Mystery Box",
                      style: GoogleFonts.poppins(
                          color: AppColors.letterColor, fontSize: 15),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
    //  Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     if (offersCount != 0)
    //       Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 5),
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Row(
    //               children: [
    //                 const Icon(
    //                   Icons.percent_rounded,
    //                   size: 16,
    //                   color: AppColors.mainColor,
    //                 ),
    //                 const SizedBox(width: 6),
    //                 Text(
    //                   "${Strings.paymentOffers} ($offersCount)",
    //                   style: GoogleFonts.poppins(
    //                     fontWeight: FontWeight.w600,
    //                     fontSize: 13,
    //                     color: AppColors.letterColor,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             InkWell(
    //               onTap: () async {
    //                 await AppNavigation.gotoPromoCodeScreen(
    //                   context,
    //                   _amountController.text,
    //                   isApplied,
    //                   offerList,
    //                 );
    //               },
    //               child: Text(
    //                 Strings.viewAll,
    //                 style: GoogleFonts.poppins(
    //                   color: AppColors.mainColor,
    //                   fontWeight: FontWeight.w500,
    //                   fontSize: 13,
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     const SizedBox(height: 10),
    //     FutureBuilder(
    //       future: offerList,
    //       builder: (context, snapshot) {
    //         if (snapshot.connectionState == ConnectionState.waiting) {
    //           return _shimmerOfferLoader(context);
    //         } else if ((snapshot.data ?? []).isEmpty) {
    //           return (offersCount == 0)
    //               ? const SizedBox()
    //               : const Center(
    //                   child: Padding(
    //                     padding: EdgeInsets.symmetric(vertical: 50.0),
    //                     child: Text(
    //                       Strings.noOffersFound,
    //                       style: TextStyle(
    //                         color: AppColors.letterColor,
    //                         fontSize: 13,
    //                         fontWeight: FontWeight.w500,
    //                       ),
    //                     ),
    //                   ),
    //                 );
    //         } else {
    //           offersCount = snapshot.data?.length ?? 0;
    //           return SizedBox(
    //             width: double.infinity,
    //             height: 160,
    //             child: ListView.builder(
    //               scrollDirection: Axis.horizontal,
    //               itemCount: snapshot.data?.length,
    //               itemBuilder: (context, index) {
    //                 return singleItemOfferCode(snapshot.data?[index], context);
    //               },
    //             ),
    //           );
    //         }
    //       },
    //     ),
    //   ],
    // );
  }

  Widget _bottomButtonSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(Images.safety, width: 24, height: 30),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  "Proceed to verify your details and join the contest",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.letterColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          MainButton(
            text: Strings.addCash,
            color: (_errorText == null && _amountController.text != "")
                ? AppColors.mainColor
                : AppColors.whiteFade1,
            textColor: (_errorText == null && _amountController.text != "")
                ? AppColors.white
                : const Color(0xffbcc5d3),
            onTap: (_errorText == null && _amountController.text != "")
                ? () async {
                    if (!_isUserVerified) {
                      appToast("Please verify your account first", context);
                      return;
                    }
                    if (num.parse(_amountController.text) >=
                            num.parse(
                              AppSingleton.singleton.appData
                                      .androidpaymentgateway?.isRazorPay?.min ??
                                  "0",
                            ) &&
                        num.parse(_amountController.text) <=
                            num.parse(
                              AppSingleton.singleton.appData
                                      .androidpaymentgateway?.isRazorPay?.max ??
                                  "0",
                            )) {
                      await _createRazorpayOrder();
                      // await accountsUsecases
                      //     .requestAddCash(
                      //   context,
                      //   "RazorPay",
                      //   _amountController.text,
                      //   "",
                      // )
                      //     .then((value) async {
                      //   if (value!.isNotEmpty) {
                      //     String url = value['data']['paymentLink'];
                      //     if (!mounted) return;
                      //     final result = await Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (_) => CustomWebView(
                      //           title: "Complete Payment",
                      //           url: url,
                      //         ),
                      //       ),
                      //     );

                      //     if (result == "success") {
                      //       appToast("Payment Successful", context);
                      //     } else {
                      //       appToast("Payment Failed", context);
                      //     }
                      //   }
                      // });
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget singleItemOfferCode(OffersModel? data, BuildContext context) {
    return Container(
      height: 150,
      width: MediaQuery.of(context).size.width * 0.8,
      margin: const EdgeInsets.only(top: 5, left: 5, right: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [AppColors.shade1White, AppColors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            left: 70,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Text(
                      "${data?.title}",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.letterColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Text(
                      "${data?.description}",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppColors.letterColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  DashedBorderContainer(
                    color: AppColors.mainColor,
                    borderRadius: 10.0,
                    dashSpace: 2,
                    dashWidth: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${Strings.validTill}${AppUtils.formatCustomDate(data?.enddate.toString() ?? DateTime.now().toString())}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10,
                                  color: AppColors.letterColor,
                                ),
                              ),
                              Text(
                                "Min Amt: ₹${data?.minAmount}, Max Amt: ₹${data?.maxAmount}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10,
                                  color: AppColors.letterColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 95,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_amountController.text.isNotEmpty &&
                                    num.parse(_amountController.text) >=
                                        (data?.minAmount ?? 0) &&
                                    num.parse(_amountController.text) <=
                                        (data?.maxAmount ?? 0)) {
                                  if ((data?.usedCount ?? 0) >=
                                      (data?.userTime ?? 1)) {
                                    appToast(
                                      "You have already exhausted limit to use this offer code.",
                                      context,
                                    );
                                    setState(() {
                                      promoId = "";
                                      isApplied = false;
                                    });
                                  } else {
                                    setState(() {
                                      promoId = data?.id ?? "";
                                      isApplied = true;
                                      appToast(
                                        Strings.promoCodeApplied,
                                        context,
                                      );
                                    });
                                  }
                                } else {
                                  setState(() {
                                    promoId = "";
                                    isApplied = false;
                                    appToast(
                                      Strings.promoCodeNotApplied,
                                      context,
                                    );
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ((data?.usedCount ?? 0) >=
                                        (data?.userTime ?? 1))
                                    ? AppColors.lightGrey
                                    : AppColors.mainColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Text(
                                  (!isApplied) ? Strings.apply : "Applied",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            child: Container(
              width: 70,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.mainColor, AppColors.lightBlue],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: -pi / 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      Strings.useCode,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      '${data?.offerCode}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mysteryBoxOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.75),
        child: Center(
          child: GestureDetector(
            onTap: _openMysteryBox,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: 1.05,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  child: Image.asset(
                    Images.mysteryBox,
                    height: 160,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Tap to open your Mystery Box!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openMysteryBox() async {
    if (_lastTxnId == null) return;

    setState(() => _showMysteryBox = false);

    final res = await accountsUsecases.openMysteryBox(
      context,
      _lastTxnId!,
    );

    if (!mounted) return;

    if (res != null && res["success"] == true) {
      final winAmount = res["data"]?["winAmount"] ?? 0;

      _confettiController.play();
      _showWinDialog(winAmount);
      setState(() => _isPaymentFlowLocked = true);
    } else {
      appToast(res?["message"] ?? "Failed to open Mystery Box", context);
    }
  }

  void _showWinDialog(int amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(Images.matchToken, height: 60),
                    const SizedBox(height: 12),
                    Text(
                      "Congratulations! 🎉",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "You won",
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "$amount Game Tokens",
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.mainColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                    MainButton(
                      color: AppColors.mainColor,
                      text: "Awesome!",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        _confettiController.stop();
                      },
                    )
                  ],
                ),
              ),
            ),

            /// 🎊 CONFETTI BLAST
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.05,
              numberOfParticles: 25,
              gravity: 0.2,
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _amountController.dispose();
    _razorpay?.clear();
    _confettiController.dispose();
    super.dispose();
  }
}
