import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/images.dart';
import 'package:Dream247/core/app_constants/strings.dart';
import 'package:Dream247/features/accounts/presentation/widgets/account_global_widget.dart';
import 'package:Dream247/features/menu_items/presentation/providers/user_data_provider.dart';

class PaymentProcess extends StatelessWidget {
  final String? paymentStatus;
  final String? amount;
  final PaymentSuccessResponse? success;
  final PaymentFailureResponse? failure;
  const PaymentProcess({
    super.key,
    required this.paymentStatus,
    this.amount,
    this.success,
    this.failure,
  });

  @override
  Widget build(BuildContext context) {
    final userData =
        Provider.of<UserDataProvider>(context, listen: false).userData;
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              color: (paymentStatus == "Success")
                  ? AppColors.green
                  : (paymentStatus == "Failure")
                      ? AppColors.whiteFade1
                      : AppColors.yellowColor,
              height: MediaQuery.of(context).size.height * 0.35,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    (paymentStatus == "Success")
                        ? Icons.verified_user
                        : (paymentStatus == "Failure")
                            ? Icons.gpp_maybe
                            : Icons.schedule,
                    size: 40,
                    color: AppColors.white,
                  ),
                  Text(
                    (paymentStatus == "Success")
                        ? "Payment Successful"
                        : (paymentStatus == "Failure")
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
                    (paymentStatus == "Success")
                        ? "Your transaction was processed securely. We appreciate your trust in us."
                        : (paymentStatus == "Failure")
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
                        "${userData?.mobile}",
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
                        "${Strings.indianRupee}$amount",
                        style: GoogleFonts.tomorrow(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  (paymentStatus == "Success")
                      ? AccountGlobalWidget.detailRow(
                          "Transaction ID",
                          success?.paymentId?.toUpperCase() ?? "---",
                          context,
                        )
                      : const SizedBox.shrink(),
                  AccountGlobalWidget.detailRow(
                    "Total Amount to add:",
                    "${Strings.indianRupee}$amount",
                    context,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                        bottom: 20,
                        right: 8,
                        left: 8,
                        top: 40,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Center(
                        child: Text(
                          Strings.done,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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
