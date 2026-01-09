// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';

import 'package:Dream247/core/global_widgets/main_button.dart';
import 'package:Dream247/core/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/images.dart';
import 'package:Dream247/core/app_constants/strings.dart';
import 'package:Dream247/core/global_widgets/app_toast.dart';
import 'package:Dream247/core/global_widgets/sub_container.dart';
import 'package:Dream247/core/utils/model_parsers.dart';
import 'package:Dream247/features/accounts/data/accounts_datasource.dart';
import 'package:Dream247/features/accounts/domain/use_cases/accounts_usecases.dart';
import 'package:Dream247/features/accounts/presentation/providers/wallet_details_provider.dart';
import 'package:Dream247/features/accounts/presentation/widgets/bank_transfer_widget.dart';
import 'package:Dream247/features/accounts/presentation/widgets/tds_bottomsheet.dart';
import 'package:Dream247/features/accounts/presentation/widgets/wallet_transfer_widget.dart';
import 'package:Dream247/features/landing/data/singleton/app_singleton.dart';
import 'package:Dream247/features/user_verification/data/models/kyc_detail_model.dart';
import 'package:Dream247/features/user_verification/data/verification_datasource.dart';
import 'package:Dream247/features/user_verification/domain/use_cases/verification_usecases.dart';

enum MoneyTransfer { walletTransfer, bankTransfer, p2pTransfer }

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final TextEditingController _amountController = TextEditingController();
  Timer? _typingTimer;
  String? _errorText;
  MoneyTransfer paymentOption = MoneyTransfer.bankTransfer;
  KycDetailsModel? kycDetailsModel;
  VerificationUsecases verificationUsecases = VerificationUsecases(
    VerificationDatasource(ApiImplWithAccessToken()),
  );
  AccountsUsecases accountsUsecases = AccountsUsecases(
    AccountsDatasource(ApiImpl(), ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    loadKycData();
    _amountController.addListener(() {
      _typingTimer?.cancel();
      _validateAmount();
      if (_amountController.text.isNotEmpty) {
        _typingTimer = Timer(const Duration(seconds: 1), () {
          FocusScope.of(context).unfocus();
        });
      }
    });
  }

  void _validateAmount() {
    String text = _amountController.text;
    if (text.isEmpty) {
      setState(() {
        _errorText = 'Please enter an amount';
      });
      return;
    }

    double amount = double.tryParse(text) ?? 0;

    double minWithdraw = (paymentOption == MoneyTransfer.bankTransfer)
        ? double.tryParse(
              AppSingleton.singleton.appData.minwithdraw.toString(),
            ) ??
            0.0
        : (paymentOption == MoneyTransfer.p2pTransfer)
            ? double.tryParse(
                  AppSingleton.singleton.appData.ptoptransfer?.min.toString() ??
                      "0",
                ) ??
                0.0
            : double.tryParse(
                  AppSingleton.singleton.appData.selftransfer?.min.toString() ??
                      "0",
                ) ??
                0.0;
    double maxWithdraw = (paymentOption == MoneyTransfer.bankTransfer)
        ? double.tryParse(
              AppSingleton.singleton.appData.maxwithdraw.toString(),
            ) ??
            0.0
        : (paymentOption == MoneyTransfer.p2pTransfer)
            ? double.tryParse(
                  AppSingleton.singleton.appData.ptoptransfer?.max.toString() ??
                      "0",
                ) ??
                0.0
            : double.tryParse(
                  AppSingleton.singleton.appData.selftransfer?.max.toString() ??
                      "0",
                ) ??
                0.0;
    double availableBalance = double.parse(
      Provider.of<WalletDetailsProvider>(
            context,
            listen: false,
          ).walletData?.winning ??
          "0",
    );

    if (amount < minWithdraw) {
      setState(() {
        _errorText =
            'Minimum withdrawal amount is ${Strings.indianRupee}$minWithdraw';
      });
    } else if (amount > maxWithdraw) {
      setState(() {
        _errorText =
            'Maximum withdrawal limit is ${Strings.indianRupee}$maxWithdraw';
      });
    } else if (amount > availableBalance) {
      setState(() {
        _errorText = 'Insufficient balance';
      });
    } else {
      setState(() {
        _errorText = null;
      });
    }
  }

  void loadKycData() async {
    kycDetailsModel = await verificationUsecases.getKycDetails(context);
    setState(() {});
  }

  void requestWithdraw() async {
    if (_errorText != null) return;
    if (MoneyTransfer.walletTransfer == paymentOption) {
      await accountsUsecases.walletTransfer(context, _amountController.text);
    } else if (MoneyTransfer.bankTransfer == paymentOption) {
      if (AppSingleton.singleton.appData.tds == 1) {
        await accountsUsecases
            .tdsDeductionDetails(context, _amountController.text)
            .then((value) {
          if (value != null) {
            String netAmount =
                ModelParsers.toStringParser(value["data"]["netAmount"]) ??
                    "0.00";
            String tdsAmount =
                ModelParsers.toStringParser(value["data"]["tdsAmount"]) ??
                    "0.00";
            String withdrawalAmount = ModelParsers.toStringParser(
                  value["data"]["withdrawalAmount"],
                ) ??
                "0.00";

            showModalBottomSheet(
              isDismissible: false,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(10.0),
                ),
              ),
              context: context,
              builder: (context) {
                return PopScope(
                  canPop: false,
                  child: TdsBottomsheet(
                    isBankTransfer: true,
                    tdsAmount: tdsAmount,
                    netAmount: netAmount,
                    withdrawalAmount: withdrawalAmount,
                    bankName: kycDetailsModel?.bank?.bankname ?? "",
                    accNo: kycDetailsModel?.bank?.accno ?? "",
                  ),
                );
              },
            );
          }
        });
      } else {
        await accountsUsecases.requestWithdraw(context, _amountController.text);
      }
    } else if (MoneyTransfer.p2pTransfer == paymentOption) {
      await accountsUsecases
          .tdsDeductionDetails(context, _amountController.text)
          .then((value) {
        if (value != null) {
          String netAmount =
              ModelParsers.toStringParser(value["data"]["netAmount"]) ?? "0.00";
          String tdsAmount =
              ModelParsers.toStringParser(value["data"]["tdsAmount"]) ?? "0.00";
          String withdrawalAmount = ModelParsers.toStringParser(
                value["data"]["withdrawalAmount"],
              ) ??
              "0.00";

          showModalBottomSheet(
            isDismissible: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(10.0),
              ),
            ),
            context: context,
            builder: (context) {
              return PopScope(
                canPop: false,
                child: TdsBottomsheet(
                  isBankTransfer: false,
                  tdsAmount: tdsAmount,
                  netAmount: netAmount,
                  withdrawalAmount: withdrawalAmount,
                  bankName: kycDetailsModel?.bank?.bankname ?? "",
                  accNo: kycDetailsModel?.bank?.accno ?? "",
                ),
              );
            },
          );
        }
      });
    } else {
      await accountsUsecases.requestWithdraw(context, _amountController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubContainer(
      showAppBar: true,
      showWalletIcon: false,
      headerText: Strings.withdraw,
      addPadding: true,
      child: SingleChildScrollView(
        // child: Center(
        //   child: Text("This Feature is Coming Soon !!"),
        // ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppColors.shade1White,
              ),
              child: Text(
                (paymentOption == MoneyTransfer.walletTransfer)
                    ? "*Winning Amount Instantly Transfer to your Deposit Wallet"
                    : (paymentOption == MoneyTransfer.bankTransfer)
                        ? "*Winning Amount Instantly Transfer to your Bank Account"
                        : "*Winning Amount Instantly Transfer to your Friend's Wallet",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.letterColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // _buildOptionTile(
                  //   MoneyTransfer.walletTransfer,
                  //   'Wallet Transfer',
                  //   true,
                  //   AppSingleton.singleton.appData.selftransfer?.status ??
                  //       false,
                  // ),
                  const SizedBox(width: 8),
                  _buildOptionTile(
                    MoneyTransfer.bankTransfer,
                    'Bank Transfer',
                    false,
                    AppSingleton.singleton.appData.disableWithdraw == 1
                        ? false
                        : true,
                  ),
                  const SizedBox(width: 8),
                  // _buildOptionTile(
                  //   MoneyTransfer.p2pTransfer,
                  //   'P2P Transfer',
                  //   true,
                  //   AppSingleton.singleton.appData.ptoptransfer?.status ??
                  //       false,
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            Images.imageWithdrawBadge,
                            width: 18,
                            height: 18,
                          ),
                          const SizedBox(width: 5),
                          const Padding(
                            padding: EdgeInsets.all(3),
                            child: Text(
                              'Your Winnings : ',
                              style: TextStyle(
                                color: AppColors.letterColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(3),
                        child: Text(
                          "${Strings.indianRupee}${AppUtils.stringifyNumber(num.parse(Provider.of<WalletDetailsProvider>(context, listen: true).walletData?.winning ?? "0.0"))}",
                          style: GoogleFonts.tomorrow(
                            color: AppColors.letterColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: <Widget>[
                      const Text(
                        'Enter Amount',
                        style: TextStyle(
                          color: AppColors.letterColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Container(
                        padding: const EdgeInsets.all(0),
                        width: 150,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.whiteFade1,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: TextField(
                            controller: _amountController,
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: "0",
                              prefix: const Text(
                                Strings.indianRupee,
                                style: TextStyle(
                                  color: AppColors.letterColor,
                                  fontSize: 24,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.transparent,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.transparent,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.transparent,
                                ),
                              ),
                              hintStyle: const TextStyle(
                                color: AppColors.letterColor,
                                fontSize: 24,
                              ),
                            ),
                            style: GoogleFonts.tomorrow(
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              color: AppColors.letterColor,
                            ),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 7,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      if (_errorText != null)
                        Text(
                          _errorText!,
                          style: const TextStyle(
                            color: AppColors.mainLightColor,
                            fontSize: 12.0,
                          ),
                        ),
                      const SizedBox(height: 10.0),
                      RichText(
                        text: TextSpan(
                          text: 'Min. ',
                          style: const TextStyle(
                            fontSize: 10.0,
                            color: AppColors.letterColor,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: (paymentOption ==
                                      MoneyTransfer.walletTransfer)
                                  ? '${Strings.indianRupee}${AppSingleton.singleton.appData.selftransfer?.min} '
                                  : (paymentOption == MoneyTransfer.p2pTransfer)
                                      ? '${Strings.indianRupee}${AppSingleton.singleton.appData.ptoptransfer?.min} '
                                      : '${Strings.indianRupee}${AppSingleton.singleton.appData.minwithdraw} ',
                              style: GoogleFonts.tomorrow(
                                fontSize: 10.0,
                                color: AppColors.letterColor,
                              ),
                            ),
                            const TextSpan(
                              text: '- Max ',
                              style: TextStyle(
                                fontSize: 10.0,
                                color: AppColors.letterColor,
                              ),
                            ),
                            TextSpan(
                              text: (paymentOption ==
                                      MoneyTransfer.walletTransfer)
                                  ? '${Strings.indianRupee}${AppSingleton.singleton.appData.selftransfer?.max} '
                                  : (paymentOption == MoneyTransfer.p2pTransfer)
                                      ? '${Strings.indianRupee}${AppSingleton.singleton.appData.ptoptransfer?.max} '
                                      : '${Strings.indianRupee}${AppSingleton.singleton.appData.maxwithdraw} ',
                              style: GoogleFonts.tomorrow(
                                fontSize: 10.0,
                                color: AppColors.letterColor,
                              ),
                            ),
                            const TextSpan(
                              text: 'Per Day',
                              style: TextStyle(
                                fontSize: 10.0,
                                color: AppColors.letterColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTransferWidget(),
                const SizedBox(height: 30),
                MainButton(
                  text: 'Withdraw Now',
                  onTap: (_errorText == null && _amountController.text != "")
                      ? requestWithdraw
                      : null,
                  color: (_errorText == null && _amountController.text != "")
                      ? AppColors.green
                      : AppColors.whiteFade1,
                  textColor:
                      (_errorText == null && _amountController.text != "")
                          ? AppColors.white
                          : const Color(0xffbcc5d3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    MoneyTransfer value,
    String title,
    bool isCashback,
    bool isEnabled,
  ) {
    bool isSelected = paymentOption == value;
    return GestureDetector(
      onTap: isEnabled
          ? () {
              setState(() {
                paymentOption = value;
              });
            }
          : () {
              appToast("$title is temporarily unavailable for now.", context);
            },
      child: Stack(
        children: [
          Opacity(
            opacity: isEnabled ? 1 : 0.5,
            child: Container(
              height: 50,
              padding: EdgeInsets.only(
                top: 6,
                bottom: 6,
                left: (isCashback) ? 28 : 8,
                right: 8,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: isSelected ? AppColors.green : AppColors.lightGrey,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 18,
                    color: isSelected ? AppColors.green : AppColors.lightGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.blackColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isCashback)
            Positioned(
              top: -4,
              left: -28,
              bottom: -8,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.flip(
                    flipX: true,
                    child: Image.asset(
                      Images.icRibbon,
                      height: 65,
                      width: 114,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    top: 15,
                    bottom: 13,
                    left: 4,
                    right: 4,
                    child: Transform.rotate(
                      angle: -pi / 4,
                      child: Text(
                        (title == "Wallet Transfer")
                            ? "${AppSingleton.singleton.appData.winningDepositCashback ?? "10"}% Cashback"
                            : (title == "P2P Transfer")
                                ? "${AppSingleton.singleton.appData.p2pCashback ?? "8"}% Cashback"
                                : "",
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransferWidget() {
    switch (paymentOption) {
      case MoneyTransfer.bankTransfer:
        return BankTransferWidget(
          bankAccNo: kycDetailsModel?.bank?.accno ?? "",
        );
      case MoneyTransfer.walletTransfer:
        return WalletTransferWidget(amount: _amountController.text);
      case MoneyTransfer.p2pTransfer:
        return const SizedBox.shrink();
    }
  }
}
