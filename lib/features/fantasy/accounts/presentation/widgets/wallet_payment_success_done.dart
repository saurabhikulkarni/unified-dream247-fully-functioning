import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/main_button.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/wallet_payment_done_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/widgets/account_global_widget.dart';

class WalletPaymentSuccessDone extends StatefulWidget {
  final WalletPaymentDoneModel? data;
  const WalletPaymentSuccessDone({super.key, this.data});

  @override
  State<WalletPaymentSuccessDone> createState() =>
      _WalletPaymentSuccessDoneState();
}

class _WalletPaymentSuccessDoneState extends State<WalletPaymentSuccessDone> {
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
                        'Payment Successful',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Your transaction was processed securely. We appreciate your trust in us.',
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
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            'Transaction Details',
                            style: TextStyle(
                              color: AppColors.letterColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Image.asset(Images.verified, height: 20, width: 20),
                          const Spacer(),
                          Text(
                            '${Strings.indianRupee}${widget.data?.transferredAmount}',
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
                        'Transaction ID',
                        widget.data?.winningTransactionId?.toUpperCase() ??
                            '---',
                        context,
                      ),
                      AccountGlobalWidget.detailRow(
                        'Total Amount for Withdraw',
                        '${Strings.indianRupee}${widget.data?.transferredAmount}',
                        context,
                      ),
                      AccountGlobalWidget.detailRow(
                        'TDS Deduction',
                        '${Strings.indianRupee}${widget.data?.tds}',
                        context,
                      ),
                      AccountGlobalWidget.detailRow(
                        'Receiver Received',
                        '${Strings.indianRupee}${widget.data?.receivedAmount}',
                        context,
                      ),
                      AccountGlobalWidget.detailRow(
                        'Cashback You Won',
                        '${Strings.indianRupee}${widget.data?.cashback}',
                        context,
                      ),
                      AccountGlobalWidget.detailRow(
                        'Date & Time',
                        '${widget.data?.dateTime}',
                        context,
                      ),
                      const SizedBox(height: 30),
                      MainButton(
                        color: AppColors.green,
                        textColor: AppColors.white,
                        text: Strings.done,
                        onTap: () {
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
