import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/images.dart';
import 'package:Dream247/core/app_constants/strings.dart';
import 'package:Dream247/core/global_widgets/main_button.dart';
import 'package:Dream247/features/accounts/data/models/bank_transfer_model.dart';
import 'package:Dream247/features/accounts/presentation/widgets/account_global_widget.dart';

class BankPaymentSuccessDone extends StatefulWidget {
  final BankTransferModel? data;
  const BankPaymentSuccessDone({super.key, this.data});

  @override
  State<BankPaymentSuccessDone> createState() => _BankPaymentSuccessDoneState();
}

class _BankPaymentSuccessDoneState extends State<BankPaymentSuccessDone> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.white,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                color: (widget.data?.paymentstatus == "success")
                    ? AppColors.green
                    : (widget.data?.paymentstatus == "failed")
                        ? AppColors.mainLightColor
                        : AppColors.yellowColor,
                height: MediaQuery.of(context).size.height * 0.35,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      (widget.data?.paymentstatus == "success")
                          ? Icons.verified_user
                          : (widget.data?.paymentstatus == "failed")
                              ? Icons.gpp_maybe
                              : Icons.schedule,
                      size: 40,
                      color: AppColors.white,
                    ),
                    Text(
                      (widget.data?.paymentstatus == "success")
                          ? "Payment Successful"
                          : (widget.data?.paymentstatus == "failed")
                              ? "Payment Failed"
                              : "Payment Processing",
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      (widget.data?.paymentstatus == "success")
                          ? "Your transaction was processed securely. We appreciate your trust in us."
                          : (widget.data?.paymentstatus == "failed")
                              ? "Your transaction has been failed. Please try again in sometime."
                              : "Your transaction will be processed securely. We appreciate your trust in us.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Transaction Details",
                      style: TextStyle(
                        color: AppColors.letterColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "${widget.data?.mobile}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.letterColor,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Image.asset(Images.verified, height: 20, width: 20),
                        const Spacer(),
                        Text(
                          "${Strings.indianRupee}${widget.data?.amount}",
                          style: GoogleFonts.tomorrow(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    AccountGlobalWidget.detailRow(
                      "Transaction ID",
                      widget.data?.transactionId?.toUpperCase() ?? "---",
                      context,
                    ),
                    AccountGlobalWidget.detailRow(
                      "Total Amount for Withdraw",
                      "${Strings.indianRupee}${widget.data?.amount}",
                      context,
                    ),
                    AccountGlobalWidget.detailRow(
                      "TDS Deduction",
                      "${Strings.indianRupee}${widget.data?.tdsAmount}",
                      context,
                    ),
                    AccountGlobalWidget.detailRow(
                      "Receiver Received",
                      "${Strings.indianRupee}${widget.data?.receiverAmount}",
                      context,
                    ),
                    AccountGlobalWidget.detailRow(
                      "Date & Time",
                      "${widget.data?.dateTime}",
                      context,
                    ),
                    const SizedBox(height: 10),
                    if (widget.data?.note == true)
                      Text(
                        "*Note: ${widget.data?.noteText ?? "Your previous TDS was not deducted. To maintain balance, the entire amount has been adjusted as TDS, and no withdrawal amount is currently available this time."}",
                        style: const TextStyle(
                          color: AppColors.letterColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 30),
                    MainButton(
                      color: AppColors.green,
                      textColor: AppColors.white,
                      text: Strings.done,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
