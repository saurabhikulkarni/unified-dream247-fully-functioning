import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/images.dart';
import 'package:Dream247/core/app_constants/strings.dart';
import 'package:Dream247/core/global_widgets/main_button.dart';
import 'package:Dream247/features/accounts/data/models/p2p_payment_done_model.dart';
import 'package:Dream247/features/accounts/presentation/widgets/account_global_widget.dart';

class PaymentSuccessDoneP2P extends StatefulWidget {
  final P2pPaymentDoneModel? data;
  const PaymentSuccessDoneP2P({super.key, this.data});

  @override
  State<PaymentSuccessDoneP2P> createState() => _PaymentSuccessDoneP2PState();
}

class _PaymentSuccessDoneP2PState extends State<PaymentSuccessDoneP2P> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.white,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  color: AppColors.green,
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.width,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_user,
                        size: 40,
                        color: AppColors.white,
                      ),
                      Text(
                        "Payment Successful",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Your transaction was processed securely. We appreciate your trust in us.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Receiver's Details",
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
                            "${Strings.indianRupee}${widget.data?.amountTransferred}",
                            style: GoogleFonts.tomorrow(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.data?.name ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: AppColors.letterColor,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Divider(
                        color: AppColors.letterColor,
                        thickness: 0.3,
                      ),
                      const SizedBox(height: 15),
                      AccountGlobalWidget.detailRow(
                        "Transaction ID",
                        widget.data?.transactionId?.toUpperCase() ?? "---",
                        context,
                      ),
                      AccountGlobalWidget.detailRow(
                        "You Sent",
                        "${Strings.indianRupee}${widget.data?.amountTransferred}",
                        context,
                      ),
                      AccountGlobalWidget.detailRow(
                        "TDS Deduction",
                        "${Strings.indianRupee}${widget.data?.tdsDeducted}",
                        context,
                      ),
                      AccountGlobalWidget.detailRow(
                        "Receiver Received",
                        "${Strings.indianRupee}${widget.data?.receivedAmount}",
                        context,
                      ),
                      AccountGlobalWidget.detailRow(
                        "Cashback You Won",
                        "${Strings.indianRupee}${widget.data?.cashbackReceived}",
                        context,
                      ),
                      AccountGlobalWidget.detailRow(
                        "Date & Time",
                        "${widget.data?.dateTime}",
                        context,
                      ),
                      const SizedBox(height: 15),
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
      ),
    );
  }
}
