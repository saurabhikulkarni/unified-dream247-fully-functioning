// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_urls.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/app_toast.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/custom_textfield.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/main_button.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/accounts_datasource.dart';
import 'package:unified_dream247/features/fantasy/accounts/domain/use_cases/accounts_usecases.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';

class TdsBottomsheet extends StatefulWidget {
  final String tdsAmount;
  final String netAmount;
  final String withdrawalAmount;
  final String bankName;
  final String accNo;
  final bool? isBankTransfer;
  const TdsBottomsheet({
    super.key,
    required this.tdsAmount,
    required this.netAmount,
    required this.withdrawalAmount,
    required this.bankName,
    required this.accNo,
    this.isBankTransfer,
  });

  @override
  State<TdsBottomsheet> createState() => _TdsBottomsheetState();
}

class _TdsBottomsheetState extends State<TdsBottomsheet> {
  bool? validationDone = false;
  int step = 0;
  String otp = '';
  String receiverId = '';
  String receiverName = '';
  bool isMobileValidLength = false;
  Timer? _debounce;
  bool? isLoading;
  final TextEditingController _mobileController = TextEditingController();
  TextEditingController otpFieldController = TextEditingController();
  AccountsUsecases accountsUsecases = AccountsUsecases(
    AccountsDatasource(ApiImpl(), ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    if (widget.isBankTransfer == false) {
      calculateCashbackAmount();
    }
  }

  String calculateCashbackAmount() {
    try {
      final withdrawal = num.tryParse(widget.withdrawalAmount) ?? 0;
      final cashbackRate =
          num.tryParse(AppSingleton.singleton.appData.p2pCashback.toString()) ??
              0;

      final cashbackAmount = (withdrawal * cashbackRate) / 100;
      return AppUtils.formatAmount(cashbackAmount.toString());
    } catch (e) {
      debugPrint('Error in calculating cashback: $e');
      return '0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        color: AppColors.white,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Wrap(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                    ),
                  ),
                  child: Column(
                    children: [
                      if (step == 0) tdsDeductDetails(),
                      if (step == 1) p2pGetCashback(),
                      if (step == 2) mobileNumberValidation(),
                      if (step == 3) otpValidation(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget tdsDeductDetails() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${Strings.indianRupee}${widget.netAmount}',
          style: GoogleFonts.tomorrow(
            fontWeight: FontWeight.w700,
            fontSize: 26,
            color: AppColors.green,
          ),
        ),
        const Text(
          'Withdrawal Amount',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.letterColor,
          ),
        ),
        CustomPaint(size: const Size(200, 50), painter: LinePainter()),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAmountCard(
              SvgPicture.asset(Images.icBank, height: 40),
              widget.bankName,
              '${Strings.indianRupee}${widget.withdrawalAmount}',
              AppUtils.maskDigits(widget.accNo, 4),
            ),
            _buildAmountCard(
              Image.asset(Images.icTax, height: 40),
              'Govt. Tax',
              '${Strings.indianRupee}${widget.tdsAmount}',
              'TDS to the Government',
            ),
          ],
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              children: [
                const TextSpan(
                  text: 'Note: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.letterColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  text:
                      '${APIServerUrl.appName} follows the new TDS law set for the Online Gaming Industry by the Income Tax Act of India (Section 194BA) ',
                ),
                TextSpan(
                  text: 'Read more',
                  style: TextStyle(
                    color: AppColors.blueColor.withAlpha(200),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Flexible(
              child: MainButton(
                text: (widget.isBankTransfer == true)
                    ? Strings.withdraw
                    : Strings.next,
                onTap: () {
                  if (widget.isBankTransfer == true) {
                    accountsUsecases.requestWithdraw(context, widget.netAmount);
                    setState(() {
                      isLoading = true;
                    });
                  } else {
                    setState(() {
                      step = 1;
                    });
                  }
                },
                color: AppColors.green,
                textColor: AppColors.white,
                isLoading: isLoading ?? false,
              ),
            ),
            const SizedBox(width: 15),
            Flexible(
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 0.25,
                      color: AppColors.letterColor,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(
                    child: Text(
                      Strings.cancel,
                      style: TextStyle(
                        color: AppColors.letterColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountCard(
    Widget iconPath,
    String title,
    String amount,
    String details,
  ) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.greyColor.withAlpha(80),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: iconPath,
        ),
        const SizedBox(height: 8),
        Text(
          amount,
          style: GoogleFonts.tomorrow(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(details, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }

  Widget p2pGetCashback() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 15),
        Image.asset(Images.icWonCashback, height: 80, width: 80),
        Text(
          'Hurrah!',
          style: GoogleFonts.exo2(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.green,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'You will get Cashback',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.letterColor,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${Strings.indianRupee}${calculateCashbackAmount()}',
          style: GoogleFonts.tomorrow(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.green,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'while successfully doing P2P Withdrawal',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.letterColor,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Flexible(
              child: MainButton(
                text: Strings.next,
                onTap: () {
                  setState(() {
                    step = 2;
                  });
                },
                color: AppColors.green,
                textColor: AppColors.white,
              ),
            ),
            const SizedBox(width: 15),
            Flexible(
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 0.25,
                      color: AppColors.letterColor,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(
                    child: Text(
                      Strings.cancel,
                      style: TextStyle(
                        color: AppColors.letterColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget mobileNumberValidation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: Text(
            "Enter Receiver's Mobile Number",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.letterColor,
            ),
          ),
        ),
        const SizedBox(height: 5),
        CustomTextfield(
          readOnly: false,
          maxLength: 10,
          showPrefix: true,
          keyboardType: TextInputType.number,
          controller: _mobileController,
          hintText: '10 digit mobile number',
          onChanged: (value) {
            if (_debounce?.isActive ?? false) _debounce?.cancel();

            if (value.length == 10) {
              Timer(const Duration(milliseconds: 500), () {
                FocusScope.of(context).unfocus();
              });

              _debounce = Timer(const Duration(seconds: 1), () async {
                if (!AppUtils.isValidMobileNumber(value)) {
                  appToast(Strings.msgEnterValidNumber, context);
                  return;
                }

                final result = await accountsUsecases.p2pUserValidation(
                  context,
                  value,
                );
                if (result != null) {
                  setState(() {
                    receiverId = result['data']['receiverId'];
                    receiverName = result['data']['name'];
                    validationDone = true;
                    isMobileValidLength = true;
                  });
                } else {
                  appToast('Validation failed', context);
                }
              });
            } else {
              setState(() {
                isMobileValidLength = false;
                validationDone = false;
              });
            }
          },
        ),
        if (validationDone == true)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Receiver's Banking Name",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.letterColor,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      receiverName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.letterColor,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Image.asset(Images.verified, height: 20, width: 20),
                  ],
                ),
                const SizedBox(height: 25),
                const Text(
                  'Review Details before money transfer',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: AppColors.letterColor,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 5),
        Row(
          children: [
            Flexible(
              child: IgnorePointer(
                ignoring: !validationDone!,
                child: MainButton(
                  height: 45,
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    final value = await accountsUsecases.p2pSendOtp(context);
                    if (value != null) {
                      setState(() {
                        step = 3;
                      });
                    } else {
                      appToast('Failed to send OTP', context);
                    }
                  },
                  text: Strings.next,
                  color: validationDone == true
                      ? AppColors.green
                      : AppColors.whiteFade1,
                  textColor: validationDone == true
                      ? AppColors.white
                      : AppColors.lightGrey,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Flexible(
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 0.25,
                      color: AppColors.letterColor,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(
                    child: Text(
                      Strings.cancel,
                      style: TextStyle(
                        color: AppColors.letterColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget otpValidation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text(
          'Enter 6 digit OTP we have sent on your registered mobile number',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: AppColors.letterColor,
          ),
        ),
        const SizedBox(height: 15),
        PinCodeTextField(
          appContext: context,
          controller: otpFieldController,
          length: 6,
          obscureText: false,
          animationType: AnimationType.fade,
          autoDismissKeyboard: true,
          keyboardType: TextInputType.number,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(10),
            errorBorderColor: AppColors.mainLightColor,
            activeColor: AppColors.green,
            selectedColor: AppColors.green,
            disabledColor: AppColors.letterColor,
            inactiveColor: AppColors.letterColor,
            inactiveFillColor: AppColors.letterColor,
            selectedFillColor: AppColors.letterColor,
            fieldHeight: 45,
            fieldWidth: 45,
            activeFillColor: const Color(0xfff6f7fb),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          onChanged: (value) {
            otp = '';
          },
          onCompleted: (value) {
            otp = value;
            setState(() {});
          },
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () async {
            await accountsUsecases.p2pSendOtp(context);
          },
          child: RichText(
            text: const TextSpan(
              text: "Didn't Get OTP? ",
              style: TextStyle(
                color: AppColors.letterColor,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: 'Send Again',
                  style: TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Flexible(
              child: MainButton(
                text: Strings.next,
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  if (otp != '') {
                    await accountsUsecases.verifyp2pOtp(
                      context,
                      widget.netAmount,
                      receiverId,
                      otp,
                    );
                    setState(() {
                      isLoading = true;
                    });
                  }
                },
                height: 45,
                color: otp != '' ? AppColors.green : AppColors.whiteFade1,
                textColor: otp != '' ? Colors.white : const Color(0xffafafaf),
                isLoading: isLoading ?? false,
              ),
            ),
            const SizedBox(width: 15),
            Flexible(
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 0.25,
                      color: AppColors.letterColor,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(
                    child: Text(
                      Strings.cancel,
                      style: TextStyle(
                        color: AppColors.letterColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

class LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.whiteFade1
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.5),
      Offset(size.width * 0.25, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.75, size.height * 0.5),
      Offset(size.width * 0.75, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
